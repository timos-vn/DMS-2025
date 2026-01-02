import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../model/database/data_local.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/view_desc_discount.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';

/// Component hiển thị thông tin thanh toán và hóa đơn
class CartBillInfo extends StatelessWidget {
  final CartBloc bloc;
  final String listItem;
  final String listQty;
  final String listPrice;
  final String listMoney;
  final String codeStore;
  final VoidCallback onVoucherTap;
  final Widget Function() buildOtherRequest;
  final Widget Function(String, String, int, String) customWidgetPayment;

  const CartBillInfo({
    Key? key,
    required this.bloc,
    required this.listItem,
    required this.listQty,
    required this.listPrice,
    required this.listMoney,
    required this.codeStore,
    required this.onVoucherTap,
    required this.buildOtherRequest,
    required this.customWidgetPayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              'Hãy kiểm tra thông tin thanh toán của đơn hàng trước khi lên đơn hàng nhé bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
          ),
          _buildPaymentDetail(context),
          Utils.buildLine(),
          buildOtherRequest(),
        ],
      ),
    );
  }

  Widget _buildPaymentDetail(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Row(
              children: [
                Icon(MdiIcons.idCard, color: mainColor),
                const SizedBox(width: 10),
                const Text(
                  'Thanh toán',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          customWidgetPayment(
            'Tổng tiền đặt hàng:',
            '${Utils.formatMoneyStringToDouble(bloc.totalMoney)} ₫',
            0,
            '',
          ),
          Visibility(
            visible: Const.enableViewPriceAndTotalPriceProductGift == true &&
                DataLocal.listProductGift.isNotEmpty,
            child: customWidgetPayment(
              'Tổng tiền hàng được khuyến mại:',
              '${Utils.formatMoneyStringToDouble(bloc.totalMoneyProductGift)} ₫',
              0,
              '',
            ),
          ),
          customWidgetPayment(
            'Thuế:',
            '${Utils.formatMoneyStringToDouble((bloc.totalTax + bloc.totalTax2))} ₫',
            0,
            '',
          ),
          customWidgetPayment(
            'Chiết khấu:',
            '- ${Utils.formatMoneyStringToDouble(bloc.totalDiscount)} ₫',
            0,
            '',
          ),
          InkWell(
            onTap: () => _handleVoucherTap(context),
            child: customWidgetPayment(
              'Voucher:',
              '',
              1,
              bloc.codeDiscountTD.isEmpty
                  ? 'FreeShip'
                  : "${bloc.codeDiscountTD.toString().trim()} ${(bloc.totalDiscountForOder ?? 0) == 0 ? '0 ₫' : '- ${Utils.formatMoneyStringToDouble(bloc.totalDiscountForOder ?? 0)} ₫'}",
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng Thanh toán',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${Utils.formatMoneyStringToDouble(bloc.totalPayment)} ₫',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleVoucherTap(BuildContext context) {
    if (bloc.listCkTongDon.isNotEmpty && bloc.listCkTongDon.length > 1) {
      for (var element in bloc.listCkTongDon) {
        if (bloc.listPromotion
            .split(',')
            .any((values) =>
                values.toString().trim() ==
                element.sttRecCk.toString().trim()) ==
            true) {
          bloc.codeDiscountOld = element.maCk.toString().trim();
        }
      }
      showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => true,
            child: CustomViewDiscountComponent(
              iconData: Icons.card_giftcard_rounded,
              title: 'Chương trình Khuyến Mại',
              listDiscount: const [],
              codeDiscountOld: bloc.codeDiscountOld,
              listDiscountTotal: bloc.listCkTongDon,
            ),
          );
        },
      ).then((value) {
        if (value != '' && value[0] == 'Yeah') {
          if (bloc.listPromotion.isNotEmpty &&
              bloc.listPromotion.contains(value[6].toString().trim())) {
            bloc.listPromotion = bloc.listPromotion.replaceAll(
              value[6].toString().trim(),
              value[7].toString().trim(),
            );
          } else {
            bloc.listPromotion = bloc.listPromotion == ''
                ? value[7].toString().trim()
                : '${bloc.listPromotion},${value[7].toString().trim()}';
          }
          bloc.codeDiscountTD = value[2];
          bloc.sttRecCKOld = value[7];
          bloc.listCkMatHang.clear();
          // ✅ Đảm bảo warehouseId không rỗng
          // Ưu tiên: bloc.storeCode > codeStore > Const.stockList[0].stockCode
          final finalWarehouseId = (!Utils.isEmpty(bloc.storeCode.toString()) && bloc.storeCode.toString().trim().isNotEmpty)
              ? bloc.storeCode.toString()
              : ((!Utils.isEmpty(codeStore) && codeStore.trim().isNotEmpty)
                  ? codeStore
                  : (Const.stockList.isNotEmpty ? Const.stockList[0].stockCode.toString() : ''));
          
          if (finalWarehouseId.isEmpty) {
            print('⚠️ Warning: warehouseId is empty in CartBillInfo, API may fail!');
            print('   - bloc.storeCode = ${bloc.storeCode}');
            print('   - codeStore = $codeStore');
            print('   - Const.stockList.length = ${Const.stockList.length}');
          }
          
          bloc.add(GetListItemApplyDiscountEvent(
            listCKVT: DataLocal.listCKVT,
            listPromotion: bloc.listPromotion,
            listItem: listItem,
            listQty: listQty,
            listPrice: listPrice,
            listMoney: listMoney,
            warehouseId: finalWarehouseId,
            customerId: bloc.codeCustomer.toString(),
            keyLoad: 'Second',
          ));
        }
      });
    }
  }
}

