import 'package:flutter/material.dart';

import '../../cart_bloc.dart';
import '../cart_bill_info.dart';

/// Tab content for Bill/Payment info (Thanh toán)
class CartBillTab extends StatelessWidget {
  final CartBloc bloc;
  final String listItem;
  final String listQty;
  final String listPrice;
  final String listMoney;
  final String codeStore;
  final VoidCallback onVoucherTap;
  final Widget Function() buildOtherRequest;
  final Widget Function(String, String, int, String) customWidgetPayment;

  const CartBillTab({
    super.key,
    required this.bloc,
    required this.listItem,
    required this.listQty,
    required this.listPrice,
    required this.listMoney,
    required this.codeStore,
    required this.onVoucherTap,
    required this.buildOtherRequest,
    required this.customWidgetPayment,
  });

  @override
  Widget build(BuildContext context) {
    return CartBillInfo(
      bloc: bloc,
      listItem: listItem,
      listQty: listQty,
      listPrice: listPrice,
      listMoney: listMoney,
      codeStore: codeStore,
      onVoucherTap: onVoucherTap,
      buildOtherRequest: buildOtherRequest,
      customWidgetPayment: customWidgetPayment,
    );
  }
}

