import 'package:flutter/material.dart';

import '../../cart_bloc.dart';
import '../cart_customer_info.dart';

/// Tab content for Customer info (Khách hàng)
class CartCustomerTab extends StatelessWidget {
  final CartBloc bloc;
  final Widget Function() buildInfoCallOtherPeople;
  final Widget Function() transactionWidget;
  final Widget Function() typeOrderWidget;
  final Widget Function() genderWidget;
  final Widget Function() genderTaxWidget;
  final Widget Function() typePaymentWidget;
  final Widget Function() typeDeliveryWidget;
  final Widget Function() buildPopupVvHd;
  final String maGD;
  final VoidCallback onStateChanged;

  const CartCustomerTab({
    super.key,
    required this.bloc,
    required this.buildInfoCallOtherPeople,
    required this.transactionWidget,
    required this.typeOrderWidget,
    required this.genderWidget,
    required this.genderTaxWidget,
    required this.typePaymentWidget,
    required this.typeDeliveryWidget,
    required this.buildPopupVvHd,
    required this.maGD,
    required this.onStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CartCustomerInfo(
      bloc: bloc,
      buildInfoCallOtherPeople: buildInfoCallOtherPeople,
      transactionWidget: transactionWidget,
      typeOrderWidget: typeOrderWidget,
      genderWidget: genderWidget,
      genderTaxWidget: genderTaxWidget,
      typePaymentWidget: typePaymentWidget,
      typeDeliveryWidget: typeDeliveryWidget,
      buildPopupVvHd: buildPopupVvHd,
      maGD: maGD,
      onStateChanged: onStateChanged,
    );
  }
}

