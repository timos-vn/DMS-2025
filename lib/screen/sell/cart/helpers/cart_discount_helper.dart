import 'package:flutter/material.dart';

import '../../../../model/database/data_local.dart';
import '../../../../model/network/response/search_list_item_response.dart';
import '../../../../utils/utils.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';

/// Helper tách riêng logic chiết khấu thủ công cho sản phẩm
class CartDiscountHelper {
  static void applyManualDiscountForItem({
    required CartBloc bloc,
    required int index,
    required double percent,
    required BuildContext context,
    required void Function(void Function()) setState,
  }) {
    if (percent <= 0) return;
    if (index < 0 || index >= bloc.listOrder.length) return;

    final SearchItemResponseData item = bloc.listOrder[index];
    if (item.gifProduct == true || item.gifProductByHand == true) return;

    final double quantity = item.count ?? 0;
    final double price = bloc.allowTaxPercent == true
        ? (item.priceAfterTax ?? item.priceAfter ?? 0)
        : (item.giaSuaDoi != 0 ? item.giaSuaDoi : item.price ?? 0);

    final double discountValue = (price * quantity * percent) / 100;

    setState(() {
      item.discountByHand = true;
      item.discountPercentByHand = percent;
      item.ckntByHand = discountValue;
      item.priceAfter2 = price;
      item.priceAfter = (item.giaSuaDoi - ((item.giaSuaDoi * percent) / 100));
    });

    // Persist to local cache so reload keeps manual discount
    if (DataLocal.listOrderCalculatorDiscount.any(
        (element) => element.code.toString().trim() == item.code.toString().trim())) {
      DataLocal.listOrderCalculatorDiscount.removeAt(
          DataLocal.listOrderCalculatorDiscount.indexWhere(
              (element) => element.code.toString().trim() == item.code.toString().trim()));
    }
    DataLocal.listOrderCalculatorDiscount.add(item);

    // Recalculate totals for this item
    bloc.add(CalculatorDiscountEvent(
        addOnProduct: true, product: item, reLoad: false, addTax: false));

    Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã áp dụng chiết khấu tự do');
  }
}

