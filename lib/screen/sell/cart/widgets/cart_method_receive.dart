import 'package:dms/screen/customer/search_customer/search_customer_screen.dart';
import 'package:dms/screen/sell/cart/component/custom_order.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../model/database/data_local.dart';
import '../../../../model/network/response/manager_customer_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/custom_order.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';
import 'cart_popup_vvhd.dart';
import 'cart_helper_widgets.dart';
import '../../component/input_address_popup.dart';

/// Widget hiển thị thông tin và phương thức nhận hàng
class CartMethodReceive extends StatelessWidget {
  final CartBloc bloc;
  final String maGD;
  final Widget Function() buildInfoCallOtherPeople;
  final Widget Function() transactionWidget;
  final Widget Function() typeOrderWidget;
  final Widget Function() genderWidget;
  final Widget Function() genderTaxWidget;
  final Widget Function() typePaymentWidget;
  final Widget Function() typeDeliveryWidget;
  final Function() buildPopupVvHd;
  final VoidCallback onStateChanged;

  const CartMethodReceive({
    Key? key,
    required this.bloc,
    required this.maGD,
    required this.buildInfoCallOtherPeople,
    required this.transactionWidget,
    required this.typeOrderWidget,
    required this.genderWidget,
    required this.genderTaxWidget,
    required this.typePaymentWidget,
    required this.typeDeliveryWidget,
    required this.buildPopupVvHd,
    required this.onStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8, top: 10, bottom: 6),
          child: Row(
            children: [
              Icon(MdiIcons.truckFast, color: mainColor),
              const SizedBox(width: 10),
              const Text(
                'Thông tin & Phương thức nhận hàng',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Thông tin nhận hàng:',
                style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
              ),
              buildInfoCallOtherPeople(),
              const SizedBox(height: 14),
              Utils.buildLine(),
              InkWell(
                onTap: () {
                  showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (context) {
                      return InputAddressPopup(
                        note: (DataLocal.noteSell != '' && DataLocal.noteSell != "null")
                            ? DataLocal.noteSell.toString()
                            : "",
                        title: 'Thêm ghi chú cho đơn hàng',
                        desc: 'Vui lòng nhập ghi chú',
                        convertMoney: false,
                        inputNumber: false,
                      );
                    },
                  ).then((note) {
                    if (note != null) {
                      bloc.add(AddNote(note: note));
                    }
                  });
                },
                child: SizedBox(
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 16, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ghi chú:',
                          style: TextStyle(
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.underline,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              (DataLocal.noteSell.isNotEmpty &&
                                      DataLocal.noteSell != '' &&
                                      DataLocal.noteSell != "null")
                                  ? DataLocal.noteSell.toString()
                                  : "Viết tin nhắn...",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Utils.buildLine(),
              Visibility(
                visible: Const.typeTransfer == true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    Text(
                      'Loại giao dịch:',
                      style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 45,
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: (Const.woPrice == true && Const.allowsWoPriceAndTransactionType == false)
                          ? Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Text(
                                Const.isWoPrice == false ? 'Bán lẻ' : 'Bán buôn',
                                style: const TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            )
                          : transactionWidget(),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: maGD.toString().replaceAll('null', '').isNotEmpty &&
                    (maGD.toString().replaceAll('null', '') == '5' ||
                        maGD.toString().replaceAll('null', '') == '6'),
                child: CustomOrder(
                  bloc: bloc,
                  idCustomer: DataLocal.infoCustomer.customerCode.toString(),
                ),
              ),
              Visibility(
                visible: Const.typeOrder == true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: Text(
                    'Loại đơn hàng:',
                    style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Visibility(
                visible: Const.typeOrder == true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: typeOrderWidget(),
                  ),
                ),
              ),
              Visibility(
                visible: Const.chooseAgency == true && bloc.showSelectAgency == true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: Text(
                    'Thông tin đại lý:',
                    style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Visibility(
                visible: Const.chooseAgency == true && bloc.showSelectAgency == true,
                child: GestureDetector(
                  onTap: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const SearchCustomerScreen(
                        selected: true,
                        allowCustomerSearch: false,
                        typeName: true,
                        inputQuantity: false,
                      ),
                      withNavBar: false,
                    ).then((value) {
                      if (value != null) {
                        bloc.chooseAgencyCode = false;
                        bloc.add(PickInfoAgency(
                          typeDiscount: '',
                          codeAgency: '',
                          nameAgency: '',
                          cancelAgency: true,
                        ));

                        ManagerCustomerResponseData infoCustomer = value;
                        bloc.chooseAgencyCode = true;
                        bloc.add(PickInfoAgency(
                          typeDiscount: infoCustomer.typeDiscount,
                          codeAgency: infoCustomer.customerCode,
                          nameAgency: infoCustomer.customerName,
                          cancelAgency: false,
                        ));
                      }
                    });
                  },
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            bloc.nameAgency ?? 'Chọn đại lý bán hàng',
                            style: const TextStyle(color: Colors.black, fontSize: 13),
                          ),
                        ),
                        bloc.chooseAgencyCode == false
                            ? const Icon(Icons.search, color: Colors.blueGrey, size: 20)
                            : InkWell(
                                onTap: () {
                                  bloc.chooseAgencyCode = false;
                                  bloc.add(PickInfoAgency(
                                    typeDiscount: '',
                                    codeAgency: '',
                                    nameAgency: '',
                                    cancelAgency: true,
                                  ));
                                },
                                child: const Icon(Icons.cancel_outlined, color: Colors.blueGrey, size: 20),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: Const.lockStockInCart == false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    'Kho xuất hàng:',
                    style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Visibility(
                visible: Const.lockStockInCart == false,
                child: const SizedBox(height: 10),
              ),
              Visibility(
                visible: Const.lockStockInCart == false,
                child: Container(
                  height: 45,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: genderWidget(),
                ),
              ),
              Visibility(
                visible: Const.isVvHd == true,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 14),
                  child: Text(
                    'Loại Chương trình bán hàng:',
                    style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Visibility(
                visible: Const.isVvHd == true,
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: true,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25.0),
                          topRight: Radius.circular(25.0),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      builder: (builder) {
                        return buildPopupVvHd();
                      },
                    ).then((value) {
                      if (value != null) {
                        if (value[0] == 'ReLoad') {
                          onStateChanged();
                          bloc.idVv = value[1];
                          bloc.nameVv = value[2];
                          bloc.idHd = value[3];
                          bloc.nameHd = value[4];
                          bloc.idHdForVv = value[5];
                        }
                      }
                    });
                  },
                  child: Container(
                    height: 45,
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            (bloc.nameVv.toString().trim() != '' &&
                                    bloc.nameVv.toString().trim() != 'null')
                                ? bloc.nameVv.toString().trim()
                                : 'Chọn Chương trình bán hàng',
                            style: const TextStyle(fontSize: 12.0, color: black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            (bloc.nameHd.toString().trim() != '' &&
                                    bloc.nameHd.toString().trim() != 'null')
                                ? bloc.nameHd.toString().trim()
                                : 'Chọn loại hợp đồng',
                            style: const TextStyle(fontSize: 12.0, color: black),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: Const.useTax == true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: Text(
                    Const.afterTax == true
                        ? 'Áp dụng thuế sau chiết khấu cho đơn hàng:'
                        : 'Áp dụng thuế trước chiết khấu cho đơn hàng:',
                    style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Visibility(
                visible: Const.useTax == true,
                child: Container(
                  height: 45,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: genderTaxWidget(),
                ),
              ),
              Visibility(
                visible: Const.chooseTypePayment == true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: Text(
                    'Loại hình thức thanh toán:',
                    style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Visibility(
                visible: Const.chooseTypePayment == true,
                child: Container(
                  height: 45,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: typePaymentWidget()),
                      Visibility(
                        visible: bloc.showDatePayment == true,
                        child: InkWell(
                          onTap: () {
                            Utils.dateTimePickerCustom(context).then((value) {
                              if (value != null) {
                                onStateChanged();
                                DataLocal.datePayment = Utils.parseStringDateToString(
                                  value.toString(),
                                  Const.DATE_TIME_FORMAT,
                                  Const.DATE_SV_FORMAT,
                                );
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 50),
                            child: Row(
                              children: [
                                Text(
                                  DataLocal.datePayment,
                                  style: const TextStyle(fontSize: 12.0, color: black),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 5),
                                Icon(Icons.calendar_today_rounded, color: mainColor, size: 19),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: Const.chooseTypeDelivery == true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: Text(
                    'Loại hình vận chuyển:',
                    style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Visibility(
                visible: Const.chooseTypeDelivery == true,
                child: Container(
                  height: 45,
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: typeDeliveryWidget()),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: Const.dateEstDelivery == true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 10),
                  child: Text(
                    'Dự kiến giao hàng:',
                    style: TextStyle(color: mainColor, fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
              Visibility(
                visible: Const.dateEstDelivery == true,
                child: Container(
                  padding: const EdgeInsets.only(left: 12, right: 2, top: 10, bottom: 10),
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: grey.withOpacity(0.8), width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          const Text(
                            'Ngày dự kiến giao hàng: ',
                            style: TextStyle(color: Colors.black, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            DataLocal.dateEstDelivery,
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                        child: InkWell(
                          onTap: () {
                            Utils.dateTimePickerCustom(context).then((value) {
                              if (value != null) {
                                onStateChanged();
                                DataLocal.dateEstDelivery = Utils.parseStringDateToString(
                                  value.toString(),
                                  Const.DATE_TIME_FORMAT,
                                  Const.DATE_SV_FORMAT,
                                );
                              }
                            });
                          },
                          child: const Icon(Icons.event, color: Colors.blueGrey, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

