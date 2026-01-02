import 'package:flutter/material.dart';

import '../../cart_bloc.dart';
import '../../cart_event.dart';
import '../../cart_state.dart'; // keep import parity if needed later
import '../cart_product_list.dart';

/// Tab content for the Product list (Sản phẩm)
class CartProductTab extends StatelessWidget {
  final CartBloc bloc;
  final VoidCallback onShowDiscountFlow;
  final VoidCallback onAddAllHDVV;
  final VoidCallback onAddDiscountForAll;
  final VoidCallback onDeleteAll;
  final Function(int) onEditProduct;
  final Function(int) onDeleteProduct;
  final Function(int) onApplyVVHD;
  final Function(int, double) onApplyManualDiscount;
  final Widget Function(BuildContext, int) buildProductItem;
  final Widget Function(BuildContext, int) buildGiftItem;
  final VoidCallback? onAddGiftProduct;

  const CartProductTab({
    super.key,
    required this.bloc,
    required this.onShowDiscountFlow,
    required this.onAddAllHDVV,
    required this.onAddDiscountForAll,
    required this.onDeleteAll,
    required this.onEditProduct,
    required this.onDeleteProduct,
    required this.onApplyVVHD,
    required this.onApplyManualDiscount,
    required this.buildProductItem,
    required this.buildGiftItem,
    this.onAddGiftProduct,
  });

  @override
  Widget build(BuildContext context) {
    return CartProductList(
      bloc: bloc,
      onShowDiscountFlow: onShowDiscountFlow,
      onAddAllHDVV: onAddAllHDVV,
      onAddDiscountForAll: onAddDiscountForAll,
      onDeleteAll: onDeleteAll,
      onEditProduct: onEditProduct,
      onDeleteProduct: onDeleteProduct,
      onApplyVVHD: onApplyVVHD,
      onApplyManualDiscount: onApplyManualDiscount,
      buildProductItem: buildProductItem,
      buildGiftItem: buildGiftItem,
      onAddGiftProduct: onAddGiftProduct,
    );
  }
}

