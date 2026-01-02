import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../model/database/data_local.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';
import 'cart_popup_vvhd.dart';

/// Widget hiển thị một item trong danh sách sản phẩm quà tặng
class CartGiftItemWidget extends StatefulWidget {
  final int index;
  final CartBloc bloc;
  final String? currencyCode;
  final Widget Function() buildPopupVvHd;
  final Function(bool, int) onGiftStateChanged; // Callback để update gift và indexSelectGift

  const CartGiftItemWidget({
    Key? key,
    required this.index,
    required this.bloc,
    required this.currencyCode,
    required this.buildPopupVvHd,
    required this.onGiftStateChanged,
  }) : super(key: key);

  @override
  State<CartGiftItemWidget> createState() => _CartGiftItemWidgetState();
}

class _CartGiftItemWidgetState extends State<CartGiftItemWidget> {
  @override
  Widget build(BuildContext context) {
    final giftItem = DataLocal.listProductGift[widget.index];
    
    return Slidable(
      key: const ValueKey(1),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dragDismissible: false,
        children: [
          Visibility(
            visible: Const.isVv == true,
            child: SlidableAction(
              onPressed: (_) {
                setState(() {
                  if (giftItem.chooseVuViec == true) {
                    giftItem.chooseVuViec = false;
                    giftItem.idVv = '';
                    giftItem.idHd = '';
                    giftItem.nameVv = '';
                    giftItem.nameHd = '';
                    giftItem.idHdForVv = '';
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
                          setState(() {
                            giftItem.chooseVuViec = true;
                            giftItem.idVv = widget.bloc.idVv;
                            giftItem.nameVv = widget.bloc.nameVv;
                            giftItem.idHd = widget.bloc.idHd;
                            giftItem.nameHd = widget.bloc.nameHd;
                            giftItem.idHdForVv = widget.bloc.idHdForVv;
                          });
                        } else {
                          giftItem.chooseVuViec = false;
                        }
                      } else {
                        giftItem.chooseVuViec = false;
                      }
                    });
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              backgroundColor: giftItem.chooseVuViec == false ? const Color(0xFFA8B1A6) : const Color(0xFF2DC703),
              foregroundColor: Colors.white,
              icon: Icons.description,
              label: 'CTBH',
            ),
          )
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dragDismissible: false,
        children: [
          SlidableAction(
            onPressed: (_) {
              final deletedItem = giftItem;
              
              // Reset CKN selection if deleting a CKN product
              if (deletedItem.typeCK == 'CKN') {
                final deletedSttRecCk = deletedItem.sttRecCK?.toString().trim();
                
                // Check if there are any other CKN products with same sttRecCK
                final hasOtherProductsInSameGroup = DataLocal.listProductGift.any((item) =>
                    item.typeCK == 'CKN' &&
                    item.sttRecCK?.toString().trim() == deletedSttRecCk &&
                    item.code != deletedItem.code);

                print('🔍 CKN Debug: Deleting CKN product - code: ${deletedItem.code}, sttRecCk: $deletedSttRecCk');
                print('🔍 CKN Debug: hasOtherProductsInSameGroup: $hasOtherProductsInSameGroup');
                
                // If this is the last product in the group, clear selection
                if (!hasOtherProductsInSameGroup) {
                  print('🔍 CKN Debug: Last product in group! Clearing selectedDiscountGroup');
                  widget.bloc.selectedDiscountGroup = null;
                }
                
                widget.bloc.selectedCknProductCode = null;
                widget.bloc.selectedCknSttRecCk = null;
              }
              
              widget.bloc.totalProductGift = widget.bloc.totalProductGift - deletedItem.count!;
              widget.bloc.add(AddOrDeleteProductGiftEvent(false, deletedItem));
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            backgroundColor: const Color(0xFFC90000),
            foregroundColor: Colors.white,
            icon: Icons.delete_forever,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: Const.lockStockInItemGift == true
            ? null
            : () {
                widget.onGiftStateChanged(true, widget.index);
                widget.bloc.add(GetListStockEvent(
                  itemCode: giftItem.code.toString(),
                  getListGroup: false,
                  lockInputToCart: true,
                  checkStockEmployee: Const.checkStockEmployee == true ? true : false,
                ));
              },
        child: Card(
          semanticContainer: true,
          margin: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 6, top: 10, bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    color: const Color(0xFF0EBB00),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, size: 16, color: Colors.white),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 3, top: 6, bottom: 5),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '[${giftItem.code.toString().trim()}] ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 12,
                                        color: Color(0xff555a55),
                                      ),
                                    ),
                                    TextSpan(
                                      text: giftItem.name.toString().trim(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              children: [
                                (giftItem.price! > 0 && giftItem.price == giftItem.priceAfter)
                                    ? Container()
                                    : Text(
                                        ((widget.currencyCode == "VND"
                                                ? giftItem.price
                                                : giftItem.price)) ==
                                                0
                                            ? 'Giá đang cập nhật'
                                            : '${widget.currencyCode == "VND" ? Utils.formatMoneyStringToDouble(giftItem.price ?? 0) : Utils.formatMoneyStringToDouble(giftItem.price ?? 0)} ₫',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: ((widget.currencyCode == "VND"
                                                  ? giftItem.price
                                                  : giftItem.price)) ==
                                                  0
                                              ? Colors.grey
                                              : Colors.red,
                                          fontSize: 10,
                                          decoration: ((widget.currencyCode == "VND"
                                                  ? giftItem.price
                                                  : giftItem.price)) ==
                                                  0
                                              ? TextDecoration.none
                                              : TextDecoration.lineThrough,
                                        ),
                                      ),
                                const SizedBox(height: 3),
                                Visibility(
                                  visible: giftItem.priceAfter! > 0,
                                  child: Text(
                                    '${Utils.formatMoneyStringToDouble(giftItem.priceAfter ?? 0)} ₫',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xff067902),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ✅ Luôn hiển thị thông tin kho (nếu có)
                            // lockStockInItemGift chỉ khóa chức năng chọn kho, không khóa hiển thị
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  '${(giftItem.stockName.toString().isNotEmpty && giftItem.stockName.toString() != 'null') ? giftItem.stockName : (Const.lockStockInItemGift == false ? 'Chọn kho xuất hàng' : '')}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: (giftItem.stockName.toString().isNotEmpty &&
                                            giftItem.stockName.toString() != 'null')
                                        ? const Color(0xff358032)
                                        : (Const.lockStockInItemGift == false ? Colors.red : Colors.grey),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'KL Tặng:',
                                  style: TextStyle(
                                    color: giftItem.gifProduct == true
                                        ? Colors.red
                                        : Colors.black.withOpacity(0.7),
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "${giftItem.count ?? 0} (${giftItem.dvt.toString().trim()})",
                                  style: TextStyle(
                                    color:
                                        giftItem.gifProduct == true ? Colors.red : blue,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Visibility(
                          visible: Const.noteForEachProduct == true,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Ghi chú: ${giftItem.note}',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: Const.isVv == true || Const.isHd == true,
                          child: Padding(
                            padding: EdgeInsets.only(top: Const.lockStockInItem == false ? 0 : 5),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible: Const.isVv == true,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Chương trình bán hàng:',
                                              style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 11,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            const SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                '${(giftItem.idVv.toString() != '' && giftItem.idVv.toString() != 'null') ? giftItem.nameVv : 'Chọn Chương trình bán hàng'}',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  color: (giftItem.idVv.toString() != '' &&
                                                          giftItem.idVv.toString() != 'null')
                                                      ? Colors.blueGrey
                                                      : Colors.red,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: Const.isHd == true,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Hợp đồng:',
                                              style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontSize: 11,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            const SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                '${(giftItem.idHd.toString().isNotEmpty && giftItem.idHd.toString() != 'null') ? giftItem.nameHd : 'Chọn hợp đồng'}',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 12,
                                                  color: (giftItem.idHd.toString().isNotEmpty &&
                                                          giftItem.idHd.toString() != 'null') ==
                                                      true
                                                      ? Colors.blueGrey
                                                      : Colors.red,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'KL Tặng:',
                                      style: TextStyle(
                                        color: giftItem.gifProduct == true
                                            ? Colors.red
                                            : Colors.black.withOpacity(0.7),
                                        fontSize: 11,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${giftItem.count ?? 0} (${giftItem.dvt.toString().trim()})",
                                      style: TextStyle(
                                        color:
                                            giftItem.gifProduct == true ? Colors.red : blue,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
      ),
    );
  }
}

