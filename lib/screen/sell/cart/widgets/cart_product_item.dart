import 'package:dms/screen/sell/cart/component/quantity_info_box.dart';
import 'package:dms/screen/sell/contract/component/popup_update_quantity_contract.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../model/database/data_local.dart';
import '../../../../model/entity/product.dart';
import '../../../../model/network/response/search_list_item_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/InputDiscountPercent.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';

/// Widget hiển thị một item trong danh sách sản phẩm
class CartProductItemWidget extends StatefulWidget {
  final int index;
  final CartBloc bloc;
  final bool isContractCreateOrder;
  final bool? orderFromCheckIn;
  final Widget Function() buildPopupVvHd;
  final Function(int, double) onApplyManualDiscount; // Callback để apply manual discount
  final String Function(double) formatTaxRate; // Helper để format tax rate
  final Function(bool, int, SearchItemResponseData) onProductStateChanged; // Callback để update gift, indexSelect, itemSelect

  const CartProductItemWidget({
    super.key,
    required this.index,
    required this.bloc,
    required this.isContractCreateOrder,
    required this.orderFromCheckIn,
    required this.buildPopupVvHd,
    required this.onApplyManualDiscount,
    required this.formatTaxRate,
    required this.onProductStateChanged,
  });

  @override
  State<CartProductItemWidget> createState() => _CartProductItemWidgetState();
}

class _CartProductItemWidgetState extends State<CartProductItemWidget> {
  @override
  Widget build(BuildContext context) {
    final productItem = widget.bloc.listOrder[widget.index];
    
    return Slidable(
      key: const ValueKey(1),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dragDismissible: false,
        children: [
          if (Const.isVv == true)
            SlidableAction(
              onPressed: (_) {
                setState(() {
                  if (productItem.chooseVuViec == true) {
                    productItem.chooseVuViec = false;
                    productItem.idVv = '';
                    productItem.idHd = '';
                    productItem.nameVv = '';
                    productItem.nameHd = '';
                    productItem.idHdForVv = '';
                    Utils.showCustomToast(context, Icons.check_circle_outline, 'Đã huỷ áp dụng CTBH cho mặt hàng này');
                  } else {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: true,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                      ),
                      backgroundColor: Colors.white,
                      builder: (builder) {
                        return widget.buildPopupVvHd();
                      },
                    ).then((value) {
                      if (value != null) {
                        if (value[0] == 'ReLoad' && value[1] != '' && value[1] != 'null') {
                          productItem.chooseVuViec = true;
                          productItem.idVv = widget.bloc.idVv;
                          productItem.nameVv = widget.bloc.nameVv;
                          productItem.idHd = widget.bloc.idHd;
                          productItem.nameHd = widget.bloc.nameHd;
                          productItem.idHdForVv = widget.bloc.idHdForVv;
                          widget.bloc.add(CalculatorDiscountEvent(addOnProduct: true, product: productItem, reLoad: false, addTax: false));
                        } else {
                          productItem.chooseVuViec = false;
                        }
                      } else {
                        productItem.chooseVuViec = false;
                      }
                    });
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              padding: const EdgeInsets.all(10),
              backgroundColor: productItem.chooseVuViec == false ? const Color(0xFFA8B1A6) : const Color(0xFF2DC703),
              foregroundColor: Colors.white,
              icon: Icons.description,
              label: 'CTBH',
            ),
          if (Const.freeDiscount == true && productItem.gifProduct != true && productItem.gifProductByHand != true)
            SlidableAction(
              onPressed: (_) async {
                final percent = await showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return const InputDiscountPercent(
                      title: 'Vui lòng nhập tỉ lệ chiết khấu',
                      subTitle: 'Vui lòng nhập tỉ lệ chiết khấu',
                      typeValues: '%',
                      percent: 0,
                    );
                  },
                );
                if (percent != null && percent is List && percent.isNotEmpty && percent[0] == 'BACK') {
                  final value = double.tryParse(percent[1].toString()) ?? 0;
                  widget.onApplyManualDiscount(widget.index, value);
                }
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icons.discount_outlined,
              label: 'Chiết khấu',
            ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        dragDismissible: false,
        children: [
          Visibility(
            visible: productItem.gifProduct != true,
            child: SlidableAction(
              onPressed: (_) {
                if (widget.isContractCreateOrder == true) {
                  // Tìm giá trị LỚN NHẤT của availableQuantity trong các items cùng maVt2
                  double totalAvailableForMaVt2 = 0;
                  for (var item in widget.bloc.listOrder) {
                    if (item.maVt2 == productItem.maVt2) {
                      double itemAvailable = item.availableQuantity ?? item.so_luong_kd;
                      if (itemAvailable > totalAvailableForMaVt2) {
                        totalAvailableForMaVt2 = itemAvailable;
                      }
                    }
                  }
                  
                  // Tính TỔNG số lượng đã đặt của TẤT CẢ items cùng maVt2
                  double totalOrderedForMaVt2 = 0;
                  for (var item in widget.bloc.listOrder) {
                    if (item.maVt2 == productItem.maVt2) {
                      totalOrderedForMaVt2 += item.count ?? 0;
                    }
                  }
                  
                  // Tính TỔNG số lượng đã đặt của các items KHÁC (để tính Max)
                  double totalOrderedExcludingCurrent = 0;
                  for (var item in widget.bloc.listOrder) {
                    if (item.maVt2 == productItem.maVt2 && item.sttRec0 != productItem.sttRec0) {
                      totalOrderedExcludingCurrent += item.count ?? 0;
                    }
                  }
                  
                  // Max = Tổng khả dụng - Số đã đặt (items KHÁC)
                  double maxCanOrder = totalAvailableForMaVt2 - totalOrderedExcludingCurrent;
                  
                  showChangeQuantityPopup(
                    context: context,
                    originalQuantity: maxCanOrder,
                    productName: productItem.name?.toString(),
                    onConfirmed: (newQty) {
                      widget.onProductStateChanged(false, widget.index, productItem);
                      productItem.count = newQty;
                      final itemSelect = productItem;
                      Product production = Product(
                        code: itemSelect.code,
                        sttRec0: itemSelect.sttRec0,
                        name: itemSelect.name,
                        name2: itemSelect.name2,
                        dvt: itemSelect.dvt,
                        description: itemSelect.descript,
                        price: Const.isWoPrice == false ? itemSelect.price : itemSelect.woPrice,
                        priceAfter: itemSelect.priceAfter,
                        discountPercent: itemSelect.discountPercent,
                        stockAmount: itemSelect.stockAmount,
                        taxPercent: itemSelect.taxPercent,
                        imageUrl: itemSelect.imageUrl ?? '',
                        count: itemSelect.count,
                        countMax: itemSelect.countMax,
                        isMark: itemSelect.isMark,
                        discountMoney: itemSelect.discountMoney ?? '0',
                        discountProduct: itemSelect.discountProduct ?? '0',
                        budgetForItem: itemSelect.budgetForItem ?? '',
                        budgetForProduct: itemSelect.budgetForProduct ?? '',
                        residualValueProduct: itemSelect.residualValueProduct ?? 0,
                        residualValue: itemSelect.residualValue ?? 0,
                        unit: itemSelect.unit ?? '',
                        unitProduct: itemSelect.unitProduct ?? '',
                        dsCKLineItem: itemSelect.maCk.toString(),
                        allowDvt: itemSelect.allowDvt == true ? 0 : 1,
                        availableQuantity: totalAvailableForMaVt2,
                        contentDvt: itemSelect.contentDvt,
                        kColorFormatAlphaB: itemSelect.kColorFormatAlphaB?.value,
                        codeStock: itemSelect.stockCode,
                        nameStock: itemSelect.stockName,
                        editPrice: 0,
                        isSanXuat: 0,
                        isCheBien: 0,
                        giaSuaDoi: itemSelect.giaSuaDoi,
                        giaGui: itemSelect.giaGui,
                        priceMin: widget.bloc.listStockResponse.isNotEmpty ? widget.bloc.listStockResponse[0].priceMin ?? 0 : 0,
                        note: itemSelect.note,
                        jsonOtherInfo: itemSelect.jsonOtherInfo,
                        heSo: itemSelect.heSo,
                        idNVKD: itemSelect.idNVKD,
                        nameNVKD: itemSelect.nameNVKD,
                        nuocsx: itemSelect.nuocsx,
                        quycach: itemSelect.quycach,
                        maThue: itemSelect.maThue,
                        tenThue: itemSelect.tenThue,
                        thueSuat: itemSelect.thueSuat,
                        applyPriceAfterTax: itemSelect.applyPriceAfterTax == true ? 1 : 0,
                        discountByHand: itemSelect.discountByHand == true ? 1 : 0,
                        discountPercentByHand: itemSelect.discountPercentByHand,
                        ckntByHand: itemSelect.ckntByHand,
                        priceOk: itemSelect.priceOk,
                        woPrice: itemSelect.woPrice,
                        woPriceAfter: itemSelect.woPriceAfter,
                        maVt2: itemSelect.maVt2,
                        so_luong_kd: itemSelect.so_luong_kd,
                      );
                      widget.bloc.add(UpdateProductCount(
                        index: widget.index,
                        count: double.parse(newQty.toString()),
                        addOrderFromCheckIn: widget.orderFromCheckIn ?? false,
                        product: production,
                        stockCodeOld: itemSelect.stockCode.toString().trim(),
                      ));
                    },
                    maVt2: productItem.maVt2 ?? '',
                    listOrder: widget.bloc.listOrder,
                    currentQuantity: productItem.count ?? 0,
                    availableQuantity: maxCanOrder,
                  );
                } else {
                  widget.onProductStateChanged(false, widget.index, productItem);
                  widget.bloc.add(GetListStockEvent(
                    itemCode: productItem.code.toString(),
                    getListGroup: false,
                    lockInputToCart: false,
                    checkStockEmployee: Const.checkStockEmployee == true ? true : false,
                  ));
                }
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              padding: const EdgeInsets.all(10),
              backgroundColor: Colors.indigoAccent,
              foregroundColor: Colors.white,
              icon: Icons.edit_calendar_outlined,
              label: 'Sửa',
            ),
          ),
          const SizedBox(width: 2),
          Visibility(
            visible: productItem.gifProduct != true,
            child: SlidableAction(
              onPressed: (_) {
                final itemSelect = productItem;
                
                // Clean up DataLocal.listCKVT properly khi xóa product
                if (DataLocal.listCKVT.isNotEmpty) {
                  String productCode = itemSelect.code.toString().trim();
                  
                  List<String> ckList = DataLocal.listCKVT.split(',').where((s) => s.isNotEmpty).toList();
                  ckList.removeWhere((item) {
                    return item.endsWith('-$productCode');
                  });
                  DataLocal.listCKVT = ckList.join(',');
                  
                  print('💰 Removed product $productCode from listCKVT, new value: ${DataLocal.listCKVT}');
                  
                  // ✅ CHANGED: Remove maCk của CKG items có productCode bị xóa
                  // Tìm tất cả maCk của CKG items có productCode này
                  Set<String> maCksToRemove = {};
                  for (var ckg in widget.bloc.listCkg) {
                    if ((ckg.maVt ?? '').trim() == productCode) {
                      String maCk = (ckg.maCk ?? '').trim();
                      if (maCk.isNotEmpty) {
                        maCksToRemove.add(maCk);
                      }
                    }
                  }
                  // Note: Không remove ngay vì có thể cùng maCk áp dụng cho nhiều products
                  // Discount sẽ được remove tự động trong _applySingleCKG khi product bị xóa
                  // Chỉ remove nếu không còn product nào trong cart có CKG với maCk này
                  // Logic này được xử lý trong cart_screen.dart khi delete product
                  // widget.bloc.selectedCkgIds.removeAll(maCksToRemove);
                }
                
                // ✅ FIX: Chỉ gọi DeleteProductFromDB, không cần gọi GetListProductFromDB
                // Vì _deleteProductFromDB trong cart_bloc đã tự động gọi GetListProductFromDB rồi (dòng 1681)
                widget.bloc.add(DeleteProductFromDB(false, widget.index, productItem.code.toString(), productItem.stockCode.toString()));
                // widget.bloc.add(GetListProductFromDB(addOrderFromCheckIn: false, getValuesTax: false, key: '')); // ❌ REMOVED: Bị gọi 2 lần
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              padding: const EdgeInsets.all(10),
              backgroundColor: const Color(0xFFC90000),
              foregroundColor: Colors.white,
              icon: Icons.delete_forever,
              label: 'Xoá',
            ),
          ),
        ],
      ),
      child: Card(
        semanticContainer: true,
        margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
        child: Column(
          children: [
            Row(
              children: [
                productItem.gifProduct == true || productItem.gifProductByHand == true
                    ? Container(
                        width: 100,
                        height: 130,
                        padding: const EdgeInsets.all(5),
                        child: const Icon(EneftyIcons.gift_outline, size: 32, color: Color(0xFF0EBB00)),
                      )
                    : Container(
                        width: 100,
                        height: 130,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: const Icon(EneftyIcons.image_outline, size: 50, weight: 0.6),
                      ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, right: 6, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          '[${productItem.code.toString().trim()}] ${productItem.name.toString().toUpperCase()}',
                          style: const TextStyle(color: subColor, fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Visibility(
                          visible: (productItem.thueSuat ?? 0.0) > 0,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xffdc2626).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xffdc2626).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.account_balance,
                                  size: 14,
                                  color: Color(0xffdc2626),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Thuế: ${widget.formatTaxRate(productItem.thueSuat ?? 0)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: Color(0xffdc2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            productItem.gifProduct == true || productItem.gifProductByHand == true
                                ? const Icon(EneftyIcons.card_tick_outline, color: Color(0xFF0EBB00), size: 15)
                                : const Icon(FluentIcons.cart_16_filled),
                            const SizedBox(width: 5),
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 13,
                                child: (productItem.gifProduct != true && productItem.gifProductByHand != true)
                                    ? Text(
                                        '${(productItem.stockName.toString().isNotEmpty && productItem.stockName.toString() != 'null') ? productItem.stockName : 'Chọn kho xuất hàng'}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : const Text(
                                        'Hàng khuyến mãi kèm theo',
                                        style: TextStyle(color: Color(0xFF0EBB00), fontSize: 13),
                                      ),
                              ),
                            ),
                            Const.typeProduction == true
                                ? Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Container(
                                          height: 13,
                                          width: 1.5,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            'Loại: ${productItem.isSanXuat == true ? 'Sản xuất' : productItem.isCheBien == true ? 'Chế biến' : 'Thường'}',
                                            style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                        Visibility(
                          visible: Const.isVv == true || Const.isHd == true,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(FluentIcons.clipboard_task_list_ltr_20_filled),
                                const SizedBox(width: 5),
                                Visibility(
                                  visible: Const.isVv == true,
                                  child: Expanded(
                                    child: SizedBox(
                                      height: 13,
                                      child: Text(
                                        '${(productItem.idVv.toString() != '' && productItem.idVv.toString() != 'null') ? productItem.nameVv : 'Chương trình bán hàng'}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: Const.isHd == true,
                                  child: Expanded(
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Container(
                                          height: 13,
                                          width: 1.5,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          '${(productItem.idHd.toString().isNotEmpty && productItem.idHd.toString() != 'null') ? productItem.nameHd : 'Hợp đồng'}',
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: productItem.giaGui > 0 || productItem.giaSuaDoi > 0,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(EneftyIcons.money_recive_bold),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 3,
                                  child: productItem.giaSuaDoi > 0
                                      ? SizedBox(
                                          height: 13,
                                          child: Builder(
                                            builder: (context) {
                                              final discountPercent = productItem.discountPercentByHand > 0
                                                  ? productItem.discountPercentByHand
                                                  : (productItem.discountPercent ?? 0);
                                              
                                              return Text.rich(
                                                TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: 'Giá bán: \$${Utils.formatMoneyStringToDouble(productItem.giaSuaDoi)}',
                                                      style: const TextStyle(color: Colors.blueGrey, fontSize: 12, overflow: TextOverflow.ellipsis),
                                                    ),
                                                    if (discountPercent > 0)
                                                      TextSpan(
                                                        text: '  (-${discountPercent.toStringAsFixed(1)} %)',
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.red),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : SizedBox(
                                          height: 13,
                                          child: Text(
                                            'Giá Gửi: \$${Utils.formatMoneyStringToDouble(productItem.giaGui ?? 0)}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                ),
                                Visibility(
                                  visible: productItem.giaGui > 0 && productItem.giaSuaDoi > 0,
                                  child: Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Container(
                                          height: 13,
                                          width: 1.5,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          height: 13,
                                          child: Text(
                                            'Giá thu: \$${Utils.formatMoneyStringToDouble(productItem.giaGui)}',
                                            textAlign: TextAlign.left,
                                            style: const TextStyle(color: Colors.blueGrey, fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: (productItem.giaGui > 0 || productItem.giaSuaDoi > 0) ? 0 : 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 35,
                                  padding: const EdgeInsets.only(left: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: productItem.gifProduct != true && productItem.gifProductByHand != true,
                                        child: Row(
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                final discountPercent = productItem.discountPercentByHand > 0
                                                    ? productItem.discountPercentByHand
                                                    : (productItem.discountPercent ?? 0);
                                                final originalPrice = productItem.giaSuaDoi ?? 0;
                                                final priceAfter = productItem.priceAfter ?? 0;
                                                
                                                final hasDiscount = discountPercent > 0 || (priceAfter > 0 && priceAfter != originalPrice);
                                                
                                                if (!hasDiscount || originalPrice == 0) {
                                                  return Container();
                                                }
                                                
                                                return Text(
                                                  '\$ ${Utils.formatMoneyStringToDouble(originalPrice * (productItem.count ?? 0))} ',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 10,
                                                    decoration: TextDecoration.lineThrough,
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 5),
                                            Builder(
                                              builder: (context) {
                                                final discountPercent = productItem.discountPercentByHand > 0
                                                    ? productItem.discountPercentByHand
                                                    : (productItem.discountPercent ?? 0);
                                                final originalPrice = productItem.giaSuaDoi ?? 0;
                                                final priceAfter = productItem.priceAfter ?? 0;
                                                
                                                double displayPrice;
                                                final hasDiscount = discountPercent > 0 || (priceAfter > 0 && priceAfter != originalPrice);
                                                
                                                if (hasDiscount) {
                                                  if (priceAfter > 0 && priceAfter != originalPrice) {
                                                    displayPrice = priceAfter;
                                                  } else if (originalPrice > 0 && discountPercent > 0) {
                                                    displayPrice = originalPrice - (originalPrice * discountPercent / 100);
                                                    if (displayPrice < 0) displayPrice = 0;
                                                  } else {
                                                    displayPrice = originalPrice;
                                                  }
                                                } else {
                                                  displayPrice = originalPrice;
                                                }
                                                
                                                return Text(
                                                  displayPrice == 0 && originalPrice == 0
                                                      ? 'Giá đang cập nhật'
                                                      : '\$ ${Utils.formatMoneyStringToDouble(displayPrice * (productItem.count ?? 0))}',
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              QuantityInfoBox(
                                quantity: productItem.count?.toString() ?? '0',
                                unit: productItem.dvt.toString(),
                                isShowInfo: widget.isContractCreateOrder == true ? true : false,
                                contractQuantity: widget.isContractCreateOrder == true
                                    ? () {
                                        double currentCount = productItem.count ?? 0;
                                        
                                        double totalAvailableForMaVt2 = 0;
                                        for (var item in widget.bloc.listOrder) {
                                          if (item.maVt2 == productItem.maVt2) {
                                            double itemAvailable = item.availableQuantity ?? item.so_luong_kd;
                                            if (itemAvailable > totalAvailableForMaVt2) {
                                              totalAvailableForMaVt2 = itemAvailable;
                                            }
                                          }
                                        }
                                        
                                        double totalOrderedForMaVt2 = 0;
                                        for (var item in widget.bloc.listOrder) {
                                          if (item.maVt2 == productItem.maVt2) {
                                            totalOrderedForMaVt2 += item.count ?? 0;
                                          }
                                        }
                                        
                                        double remainingAvailable = (totalAvailableForMaVt2 - totalOrderedForMaVt2).clamp(0, totalAvailableForMaVt2);
                                        
                                        return '${Utils.formatQuantity(currentCount)}/${Utils.formatQuantity(remainingAvailable)}';
                                      }()
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: Const.noteForEachProduct == true && productItem.note.toString().trim().replaceAll('null', '').isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Ghi chú: ${productItem.note}',
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: Const.isBaoGia,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Thuế: ${productItem.tenThue.toString()}'),
                        Text(productItem.thueSuat.toString()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nhân viên kinh doanh'),
                        Text(productItem.nameNVKD.toString()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Nước sản xuất'),
                        Text(productItem.nuocsx.toString()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quy cách'),
                        Text(productItem.quycach.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

