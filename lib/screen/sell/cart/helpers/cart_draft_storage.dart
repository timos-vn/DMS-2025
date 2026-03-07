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
      // ✅ QUAN TRỌNG: Nếu không có sản phẩm, xóa draft thay vì lưu
      if (bloc.listOrder.isEmpty && DataLocal.listProductGift.isEmpty) {
        await clearDraft();
        print('💾 Draft cleared because no products');
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
        manualTotalDiscountPercent: bloc.manualTotalDiscountPercent,
      );
    } catch (e) {
      print('Error saving draft: $e');
      // ignore
    }
  }

  /// Khôi phục draft. Trả về true nếu khôi phục thành công.
  /// [clearDiscounts] nếu true, sẽ không restore chiết khấu (dùng cho mode add)
  static Future<bool> restoreDraft(CartBloc bloc, {bool clearDiscounts = false}) async {
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
      print('💾 manualTotalDiscountPercent: ${draft['manualTotalDiscountPercent']}');
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
      
      // ✅ QUAN TRỌNG: Chỉ restore sản phẩm tặng nếu có sản phẩm chính trong giỏ hàng
      // Sản phẩm tặng không nên hiển thị khi chưa có sản phẩm chính
      if (listOrder.isNotEmpty) {
        DataLocal.listProductGift
          ..clear()
          ..addAll(listGift);
        print('💾 ✅ Restored listProductGift because listOrder is not empty');
      } else {
        // Nếu không có sản phẩm chính, clear hết sản phẩm tặng
        DataLocal.listProductGift.clear();
        print('💾 ⚠️ Cleared listProductGift because listOrder is empty (no main products)');
      }
      
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
      
      // ✅ QUAN TRỌNG: Nếu clearDiscounts == true (mode add), không restore chiết khấu
      if (clearDiscounts) {
        print('💾 ⚠️ clearDiscounts=true: NOT restoring discounts from draft');
        DataLocal.listOrderCalculatorDiscount.clear();
        DataLocal.listObjectDiscount.clear();
        bloc.listPromotion = '';
        DataLocal.listCKVT = '';
        
        // Clear chiết khấu trên từng sản phẩm trong listOrder
        // ✅ QUAN TRỌNG: Chỉ clear chiết khấu tự động, GIỮ LẠI chiết khấu nhập tay
        for (var product in bloc.listOrder) {
          if (product.gifProduct == true) continue;
          
          // ✅ Nếu có chiết khấu nhập tay, giữ lại và tính lại priceAfter
          if (product.discountByHand == true && product.discountPercentByHand != null && product.discountPercentByHand! > 0) {
            double originalPrice = product.giaSuaDoi ?? product.price ?? 0;
            product.priceAfter = originalPrice * (1 - product.discountPercentByHand! / 100);
            product.ckntByHand = (originalPrice * (product.count ?? 0) * product.discountPercentByHand!) / 100;
            // Clear chiết khấu tự động nhưng giữ chiết khấu nhập tay
            product.discountPercent = 0;
            product.maCk = null;
            product.sttRecCK = null;
            product.typeCK = null;
            product.discountMoney = null;
            product.discountProduct = null;
          } else {
            // Không có chiết khấu nhập tay, reset về giá gốc
            double originalPrice = product.giaSuaDoi ?? product.price ?? 0;
            product.priceAfter = originalPrice;
            product.discountPercent = 0;
            product.discountPercentByHand = 0;
            product.discountByHand = false;
            product.ckntByHand = 0;
            product.maCk = null;
            product.sttRecCK = null;
            product.typeCK = null;
            product.discountMoney = null;
            product.discountProduct = null;
          }
        }
      } else {
        DataLocal.listOrderCalculatorDiscount
          ..clear()
          ..addAll(listCalc);
        DataLocal.listObjectDiscount
          ..clear()
          ..addAll(listObjDiscount);
        bloc.listPromotion = draft['listPromotion'] ?? '';
        DataLocal.listCKVT = draft['listCKVT'] ?? '';
      }

      // ✅ QUAN TRỌNG: Sync chiết khấu byhand từ listOrder vào listProductOrderAndUpdate
      // Đảm bảo chiết khấu byhand có trong listProductOrderAndUpdate để preserve khi call API tính chiết khấu
      if (!clearDiscounts && bloc.listOrder.isNotEmpty && bloc.listProductOrderAndUpdate.isNotEmpty) {
        print('💾 Syncing manual discount from listOrder to listProductOrderAndUpdate...');
        for (var item in bloc.listOrder) {
          if (item.discountByHand == true && (item.discountPercentByHand ?? 0) > 0 && item.code != null) {
            // Tìm sản phẩm tương ứng trong listProductOrderAndUpdate
            for (var element in bloc.listProductOrderAndUpdate) {
              if (element.code != null && element.code.toString().trim() == item.code!.trim()) {
                // Sync chiết khấu byhand vào listProductOrderAndUpdate
                element.discountByHand = 1;
                element.discountPercentByHand = item.discountPercentByHand;
                element.ckntByHand = item.ckntByHand ?? 0;
                element.priceAfter = item.priceAfter;
                print('💾 ✅ Synced manual discount for ${element.code}: discountPercentByHand=${element.discountPercentByHand}, ckntByHand=${element.ckntByHand}');
                break;
              }
            }
          }
        }
      }
      
      // Restore totals
      bloc.totalMoney = (draft['totalMoney'] ?? 0).toDouble();
      if (clearDiscounts) {
        // Nếu clear discounts, reset tổng tiền về tổng giá gốc
        bloc.totalDiscount = 0;
        bloc.totalDiscountForOder = 0;
        bloc.totalPayment = bloc.totalMoney;
      } else {
        bloc.totalDiscount = (draft['totalDiscount'] ?? 0).toDouble();
        bloc.totalPayment = (draft['totalPayment'] ?? 0).toDouble();
      }
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

      // ✅ QUAN TRỌNG: Restore manualTotalDiscountPercent (chiết khấu tổng đơn bằng tay cho freeDiscount)
      // Đảm bảo restore ngay cả khi clearDiscounts: true (vì đây là chiết khấu bằng tay, không phải chiết khấu tự động)
      bloc.manualTotalDiscountPercent = (draft['manualTotalDiscountPercent'] ?? 0).toDouble();
      print('💾 ✅ Restored manualTotalDiscountPercent: ${bloc.manualTotalDiscountPercent}% (even with clearDiscounts=$clearDiscounts)');

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

