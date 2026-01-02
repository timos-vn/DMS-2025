import 'package:flutter/material.dart';
import '../../../../model/database/data_local.dart';
import '../../../../model/network/request/create_order_request.dart';
import '../../../../model/network/request/update_order_request.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/custom_order.dart';
import '../../../sell/cart/cart_bloc.dart';
import '../../../sell/cart/cart_event.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// Handler cho logic tạo và cập nhật đơn hàng
class CartOrderHandler {
  final BuildContext context;
  final CartBloc bloc;
  final bool? viewUpdateOrder;
  final String? sttRec;
  final String? currencyCode;
  final String? dateOrder;
  final bool? isContractCreateOrder;
  final String? sttRectHD;
  final TextEditingController nameCompanyController;
  final TextEditingController mstController;
  final TextEditingController addressCompanyController;
  final TextEditingController noteCompanyController;
  final TextEditingController noteController;

  CartOrderHandler({
    required this.context,
    required this.bloc,
    this.viewUpdateOrder,
    this.sttRec,
    this.currencyCode,
    this.dateOrder,
    this.isContractCreateOrder,
    this.sttRectHD,
    required this.nameCompanyController,
    required this.mstController,
    required this.addressCompanyController,
    required this.noteCompanyController,
    required this.noteController,
  });

  /// Tạo đơn hàng mới hoặc cập nhật đơn hàng
  void createOrder() {
    print('💾 CartOrderHandler.createOrder() called');
    print('💾   - bloc.codeCustomer = ${bloc.codeCustomer}');
    print('💾   - bloc.customerName = ${bloc.customerName}');
    print('💾   - bloc.listProductOrderAndUpdate.length = ${bloc.listProductOrderAndUpdate.length}');
    
    if (Utils.isEmpty(bloc.listProductOrderAndUpdate)) {
      print('💾 ❌ listProductOrderAndUpdate is empty');
      return;
    }

    // ✅ Kiểm tra codeCustomer với nhiều điều kiện
    final codeCustomerStr = bloc.codeCustomer?.toString().trim() ?? '';
    final codeCustomerValid = codeCustomerStr.isNotEmpty && 
                              codeCustomerStr != 'null' && 
                              codeCustomerStr != '';
    
    print('💾   - codeCustomerStr = "$codeCustomerStr"');
    print('💾   - codeCustomerValid = $codeCustomerValid');
    
    if (!codeCustomerValid) {
      print('💾 ❌ codeCustomer is invalid, showing error');
      Utils.showCustomToast(
        context,
        Icons.warning_amber_outlined,
        'Úi, Thông tin Khách hàng không được để trống',
      );
      return;
    }
    
    print('💾 ✅ Validation passed, proceeding to create order');

    // Kiểm tra sttRectHD khi isContractCreateOrder = true
    if (isContractCreateOrder == true &&
        (sttRectHD == null || sttRectHD!.isEmpty)) {
      Utils.showCustomToast(
        context,
        Icons.warning_amber_outlined,
        'Lỗi: sttRectHD không được để trống khi tạo đơn từ hợp đồng',
      );
      return;
    }

    // Kiểm tra danh sách sản phẩm có hợp lệ không
    for (var item in bloc.listProductOrderAndUpdate) {
      if (item.code == null || item.code!.isEmpty) {
        Utils.showCustomToast(
          context,
          Icons.warning_amber_outlined,
          'Lỗi: Mã sản phẩm không được để trống',
        );
        return;
      }
      if (item.count == null || item.count! <= 0) {
        Utils.showCustomToast(
          context,
          Icons.warning_amber_outlined,
          'Lỗi: Số lượng sản phẩm phải lớn hơn 0',
        );
        return;
      }
    }

    if (viewUpdateOrder == true) {
      _updateOrder();
    } else {
      _createNewOrder();
    }
  }

  /// Cập nhật đơn hàng
  void _updateOrder() {
    ItemTotalMoneyUpdateRequestData val = ItemTotalMoneyUpdateRequestData();
    val.preAmount = bloc.totalMNProduct.toString();
    val.discount = bloc.totalMNDiscount.toString();
    val.totalMNProduct = bloc.totalMNProduct.toString();
    val.totalMNDiscount = bloc.totalMNDiscount.toString();
    val.totalMNPayment = bloc.totalMNPayment.toString();

    if (Const.chooseStatusToCreateOrder == true) {
      _showStatusDialogForUpdate(val);
    } else {
      _executeUpdateOrder(val, 0);
    }
  }

  /// Tạo đơn hàng mới
  void _createNewOrder() {
    ItemTotalMoneyRequestData val = ItemTotalMoneyRequestData();
    val.preAmount = bloc.totalMNProduct.toString();
    val.discount = bloc.totalMNDiscount.toString();
    val.totalMNProduct = bloc.totalMNProduct.toString();
    val.totalMNDiscount = bloc.totalMNDiscount.toString();
    val.totalMNPayment = bloc.totalMNPayment.toString();

    if (Const.chooseStatusToCreateOrder == true) {
      _showStatusDialogForCreate(val);
    } else {
      _executeCreateOrder(val, 0);
    }
  }

  /// Hiển thị dialog chọn trạng thái cho cập nhật đơn
  void _showStatusDialogForUpdate(ItemTotalMoneyUpdateRequestData val) {
    showDialog(
      context: context,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: CustomOrderComponent(
            iconData: MdiIcons.shopping,
            title: 'Xác nhận đơn hàng',
            content: Const.chooseStatusToCreateOrder == true
                ? 'Chọn trạng thái đơn trước khi tạo mới'
                : 'Kiểm tra kỹ thông tin trước khi đặt hàng nhé',
            ck_dac_biet: bloc.ck_dac_biet,
          ),
        );
      },
    ).then((value) async {
      if (value != null) {
        if (!Utils.isEmpty(value) && value[0] == 'Yeah') {
          int valuesStatus = int.parse(value[1].toString());
          _executeUpdateOrder(val, valuesStatus);
        }
      }
    });
  }

  /// Hiển thị dialog chọn trạng thái cho tạo đơn mới
  void _showStatusDialogForCreate(ItemTotalMoneyRequestData val) {
    showDialog(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: CustomOrderComponent(
            iconData: MdiIcons.shopping,
            title: 'Xác nhận đơn hàng',
            content: 'Chọn trạng thái đơn trước khi tạo mới',
            ck_dac_biet: bloc.ck_dac_biet,
          ),
        );
      },
    ).then((value) async {
      if (value != null) {
        if (!Utils.isEmpty(value) && value[0] == 'Yeah') {
          int valuesStatus = int.parse(value[1].toString());
          _executeCreateOrder(val, valuesStatus);
        }
      }
    });
  }

  /// Thực thi cập nhật đơn hàng
  void _executeUpdateOrder(
      ItemTotalMoneyUpdateRequestData val, int valuesStatus) {
    bloc.add(UpdateOderEvent(
      sttRec: sttRec,
      code: bloc.codeCustomer,
      storeCode: !Utils.isEmpty(bloc.storeCode.toString())
          ? bloc.storeCode
          : Const.stockList[0].stockCode,
      currencyCode: currencyCode,
      listOrder: bloc.listProductOrderAndUpdate,
      totalMoney: val,
      dateEstDelivery: DataLocal.dateEstDelivery,
      dateOrder: dateOrder.toString(),
      valuesStatus: valuesStatus,
      nameCompany: nameCompanyController.text,
      mstCompany: mstController.text,
      addressCompany: addressCompanyController.text,
      noteCompany: noteCompanyController.text,
      sttRectHD: sttRectHD,
    ));
  }

  /// Thực thi tạo đơn hàng mới
  void _executeCreateOrder(ItemTotalMoneyRequestData val, int valuesStatus) {
    bloc.add(CreateOderEvent(
      code: bloc.codeCustomer,
      storeCode: !Utils.isEmpty(bloc.storeCode.toString())
          ? bloc.storeCode
          : Const.stockList[0].stockCode,
      currencyCode: currencyCode,
      listOrder: bloc.listProductOrderAndUpdate,
      totalMoney: val,
      comment: noteController.text,
      dateEstDelivery: DataLocal.dateEstDelivery,
      valuesStatus: valuesStatus,
      nameCompany: nameCompanyController.text,
      mstCompany: mstController.text,
      addressCompany: addressCompanyController.text,
      noteCompany: noteCompanyController.text,
      sttRectHD: sttRectHD,
    ));
  }
}

