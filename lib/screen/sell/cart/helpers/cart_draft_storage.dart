import 'dart:convert';

import '../../../../model/database/data_local.dart';
import '../../../../model/database/dbhelper.dart';
import '../../../../model/entity/entity.dart';
import '../../../../model/network/response/search_list_item_response.dart';
import '../../../../utils/const.dart';
import '../cart_bloc.dart';

/// Lưu/khôi phục draft đơn (tạo mới) vào SQLite để tránh bị mất khi vào màn sửa đơn.
class CartDraftStorage {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<void> saveDraft(CartBloc bloc) async {
    try {
      // Chỉ lưu nếu có sản phẩm hoặc hàng tặng
      if (bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
        return;
      }

      await _dbHelper.saveCartDraftOrder(
        listOrderJson: jsonEncode(bloc.listOrder.map((e) => e.toJson()).toList()),
        listProductGiftJson: jsonEncode(DataLocal.listProductGift.map((e) => e.toJson()).toList()),
        listPromotion: bloc.listPromotion,
        listOrderCalculatorDiscountJson:
            jsonEncode(DataLocal.listOrderCalculatorDiscount.map((e) => e.toJson()).toList()),
        listObjectDiscountJson: jsonEncode(
          DataLocal.listObjectDiscount
              .map((e) => {
                    'itemProduct': e.itemProduct,
                    'itemDiscountNew': e.itemDiscountNew,
                    'itemDiscountOld': e.itemDiscountOld,
                  })
              .toList(),
        ),
        totalMoney: bloc.totalMoney,
        totalDiscount: bloc.totalDiscount,
        totalPayment: bloc.totalPayment,
        totalTax: bloc.totalTax,
        totalTax2: bloc.totalTax2,
        totalMoneyProductGift: bloc.totalMoneyProductGift,
        transactionCode: DataLocal.transactionCode,
        transactionYN: DataLocal.transactionYN,
        valuesTypePayment: DataLocal.valuesTypePayment,
        datePayment: DataLocal.datePayment,
        taxPercent: DataLocal.taxPercent,
        taxCode: DataLocal.taxCode,
        noteSell: DataLocal.noteSell,
        listCKVT: DataLocal.listCKVT,
        customerName: bloc.customerName,
        phoneCustomer: bloc.phoneCustomer,
        addressCustomer: bloc.addressCustomer,
        codeCustomer: bloc.codeCustomer,
        typeDeliveryIndex: bloc.typeDeliveryIndex,
        typeDeliveryName: bloc.typeDeliveryName,
        typeDeliveryCode: bloc.typeDeliveryCode,
        storeCode: bloc.storeCode,
        storeIndex: bloc.storeIndex,
        transactionIndex: bloc.transactionIndex,
        typeOrderIndex: bloc.typeOrderIndex,
        typePaymentIndex: bloc.typePaymentIndex,
        taxIndex: bloc.taxIndex,
        idVv: bloc.idVv,
        nameVv: bloc.nameVv,
        idHd: bloc.idHd,
        nameHd: bloc.nameHd,
        idHdForVv: bloc.idHdForVv,
        codeAgency: bloc.codeAgency,
        nameAgency: bloc.nameAgency,
        typeDiscount: bloc.typeDiscount,
        discountAgency: bloc.discountAgency,
        chooseAgencyCode: bloc.chooseAgencyCode ? 1 : 0,
      );
    } catch (e) {
      print('Error saving draft: $e');
      // ignore
    }
  }

  /// Khôi phục draft. Trả về true nếu khôi phục thành công.
  static Future<bool> restoreDraft(CartBloc bloc) async {
    try {
      final draft = await _dbHelper.fetchCartDraftOrder();
      if (draft == null) {
        print('💾 No draft found in database');
        return false;
      }
      
      // ✅ Print toàn bộ thông tin draft để debug
      print('💾 ========== DRAFT DATA ==========');
      print('💾 listOrder: ${draft['listOrder']}');
      print('💾 listProductGift: ${draft['listProductGift']}');
      print('💾 listPromotion: ${draft['listPromotion']}');
      print('💾 totalMoney: ${draft['totalMoney']}');
      print('💾 totalDiscount: ${draft['totalDiscount']}');
      print('💾 totalPayment: ${draft['totalPayment']}');
      print('💾 customerName: ${draft['customerName']}');
      print('💾 codeCustomer: ${draft['codeCustomer']}');
      print('💾 typeDeliveryName: ${draft['typeDeliveryName']}');
      print('💾 storeCode: ${draft['storeCode']}');
      print('💾 =================================');

      // Parse listOrder
      final listOrderJson = draft['listOrder'] as String? ?? '[]';
      print('💾 Parsing listOrderJson: ${listOrderJson.substring(0, listOrderJson.length > 200 ? 200 : listOrderJson.length)}...');
      final listOrder = (jsonDecode(listOrderJson) as List<dynamic>?)
              ?.map((e) => SearchItemResponseData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      print('💾 Parsed listOrder: ${listOrder.length} items');

      // Parse listProductGift
      final listGiftJson = draft['listProductGift'] as String? ?? '[]';
      print('💾 Restoring listProductGift from draft: $listGiftJson');
      final listGift = (jsonDecode(listGiftJson) as List<dynamic>?)
              ?.map((e) => SearchItemResponseData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      // Parse listOrderCalculatorDiscount
      final listCalcJson = draft['listOrderCalculatorDiscount'] as String? ?? '[]';
      final listCalc = (jsonDecode(listCalcJson) as List<dynamic>?)
              ?.map((e) => SearchItemResponseData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      // Parse listObjectDiscount
      final listObjDiscountJson = draft['listObjectDiscount'] as String? ?? '[]';
      final listObjDiscount = (jsonDecode(listObjDiscountJson) as List<dynamic>?)
              ?.map((e) {
                    final m = e as Map<String, dynamic>;
                    return ObjectDiscount(
                      itemProduct: (m['itemProduct'] ?? '') as String,
                      itemDiscountNew: (m['itemDiscountNew'] ?? '') as String,
                      itemDiscountOld: (m['itemDiscountOld'] ?? '') as String,
                    );
                  })
              .toList() ??
          [];

      // Restore vào bloc và DataLocal
      bloc.listOrder
        ..clear()
        ..addAll(listOrder);
      DataLocal.listProductGift
        ..clear()
        ..addAll(listGift);
      
      // ✅ Cập nhật số lượng sản phẩm trong giỏ hàng để badge hiển thị đúng
      // Badge ở OrderScreen sử dụng Const.numberProductInCart
      Const.numberProductInCart = listOrder.length;
      
      print('💾 Restored to bloc:');
      print('💾   - bloc.listOrder.length = ${bloc.listOrder.length}');
      print('💾   - DataLocal.listProductGift.length = ${DataLocal.listProductGift.length}');
      
      // ✅ Debug: Print stock info của từng gift item sau khi restore
      for (int i = 0; i < DataLocal.listProductGift.length; i++) {
        final gift = DataLocal.listProductGift[i];
        print('💾   Gift[$i]: code=${gift.code}, stockCode=${gift.stockCode}, stockName=${gift.stockName}');
      }
      print('💾   - Const.numberProductInCart = ${Const.numberProductInCart} (updated for badge)');
      print('💾   - bloc.totalMoney = ${bloc.totalMoney}');
      print('💾   - bloc.totalPayment = ${bloc.totalPayment}');
      print('💾   - bloc.customerName = ${bloc.customerName}');
      print('💾   - bloc.codeCustomer = ${bloc.codeCustomer}');
      DataLocal.listOrderCalculatorDiscount
        ..clear()
        ..addAll(listCalc);
      DataLocal.listObjectDiscount
        ..clear()
        ..addAll(listObjDiscount);

      // Restore totals
      bloc.totalMoney = (draft['totalMoney'] ?? 0).toDouble();
      bloc.totalDiscount = (draft['totalDiscount'] ?? 0).toDouble();
      bloc.totalPayment = (draft['totalPayment'] ?? 0).toDouble();
      bloc.totalTax = (draft['totalTax'] ?? 0).toDouble();
      bloc.totalTax2 = (draft['totalTax2'] ?? 0).toDouble();
      bloc.totalMoneyProductGift = (draft['totalMoneyProductGift'] ?? 0).toDouble();

      // Restore payment/tax
      DataLocal.transactionCode = draft['transactionCode'] ?? '';
      DataLocal.transactionYN = draft['transactionYN'] ?? 0;
      DataLocal.valuesTypePayment = draft['valuesTypePayment'] ?? '';
      DataLocal.datePayment = draft['datePayment'] ?? '';
      DataLocal.taxPercent = (draft['taxPercent'] ?? 0).toDouble();
      DataLocal.taxCode = draft['taxCode'] ?? '';

      // Restore misc
      DataLocal.noteSell = draft['noteSell'] ?? '';
      bloc.listPromotion = draft['listPromotion'] ?? '';
      DataLocal.listCKVT = draft['listCKVT'] ?? '';

      // Restore customer info
      bloc.customerName = draft['customerName'] ?? '';
      bloc.phoneCustomer = draft['phoneCustomer'] ?? '';
      bloc.addressCustomer = draft['addressCustomer'] ?? '';
      bloc.codeCustomer = draft['codeCustomer'] ?? '';

      // Restore delivery method
      bloc.typeDeliveryIndex = draft['typeDeliveryIndex'] ?? 0;
      bloc.typeDeliveryName = draft['typeDeliveryName'] ?? '';
      bloc.typeDeliveryCode = draft['typeDeliveryCode'] ?? '';

      // Restore store info
      bloc.storeCode = draft['storeCode'] ?? '';
      bloc.storeIndex = draft['storeIndex'] ?? 0;

      // Restore transaction/order/payment/tax indices
      bloc.transactionIndex = draft['transactionIndex'] ?? 0;
      bloc.typeOrderIndex = draft['typeOrderIndex'] ?? 0;
      bloc.typePaymentIndex = draft['typePaymentIndex'] ?? 0;
      bloc.taxIndex = draft['taxIndex'] ?? 0;

      // Restore VV/HD info
      bloc.idVv = draft['idVv'] ?? '';
      bloc.nameVv = draft['nameVv'] ?? '';
      bloc.idHd = draft['idHd'] ?? '';
      bloc.nameHd = draft['nameHd'] ?? '';
      bloc.idHdForVv = draft['idHdForVv'] ?? '';

      // Restore agency info
      bloc.codeAgency = draft['codeAgency'] ?? '';
      bloc.nameAgency = draft['nameAgency'] ?? '';
      bloc.typeDiscount = draft['typeDiscount'] ?? '';
      bloc.discountAgency = (draft['discountAgency'] ?? 0).toDouble();
      bloc.chooseAgencyCode = (draft['chooseAgencyCode'] ?? 0) == 1;

      return true;
    } catch (e) {
      print('Error restoring draft: $e');
      return false;
    }
  }

  static Future<void> clearDraft() async {
    try {
      await _dbHelper.deleteCartDraftOrder();
      print('💾 Draft cleared from database');
    } catch (e) {
      print('Error clearing draft: $e');
      // ignore
    }
  }

  /// Kiểm tra draft có tồn tại không
  static Future<bool> checkDraftExists() async {
    try {
      final draft = await _dbHelper.fetchCartDraftOrder();
      return draft != null;
    } catch (e) {
      print('Error checking draft existence: $e');
      return false;
    }
  }

  /// Lấy thông tin draft (để debug)
  static Future<String> getDraftInfo() async {
    try {
      final draft = await _dbHelper.fetchCartDraftOrder();
      if (draft == null) {
        return 'No draft found';
      }
      
      final listOrderJson = draft['listOrder'] as String? ?? '[]';
      final listGiftJson = draft['listProductGift'] as String? ?? '[]';
      final listOrder = jsonDecode(listOrderJson) as List<dynamic>;
      final listGift = jsonDecode(listGiftJson) as List<dynamic>;
      
      return 'Draft exists: listOrder=${listOrder.length} items, listProductGift=${listGift.length} items, '
          'totalMoney=${draft['totalMoney']}, customerName=${draft['customerName']}';
    } catch (e) {
      return 'Error getting draft info: $e';
    }
  }
}

