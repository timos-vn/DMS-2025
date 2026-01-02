import 'package:dms/screen/customer/search_customer/search_customer_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../model/database/data_local.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';
import '../component/custom_order.dart';
import '../../component/input_address_popup.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

/// Component hiển thị thông tin khách hàng và phương thức nhận hàng
class CartCustomerInfo extends StatelessWidget {
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

  const CartCustomerInfo({
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              'Hãy kiểm tra thông tin khách hàng, ghi chú của đơn hàng trước khi lên đơn hàng nhé bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
          ),
          _buildMethodReceive(context),
        ],
      ),
    );
  }

  Widget _buildMethodReceive(BuildContext context) {
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
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
                style: TextStyle(
                  color: mainColor,
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
              buildInfoCallOtherPeople(),
              const SizedBox(height: 14),
              Utils.buildLine(),
              _buildNoteSection(context),
              Utils.buildLine(),
              if (Const.typeTransfer == true) _buildTransactionType(context),
              if (maGD.toString().replaceAll('null', '').isNotEmpty &&
                  (maGD.toString().replaceAll('null', '') == '5' ||
                      maGD.toString().replaceAll('null', '') == '6'))
                CustomOrder(
                  bloc: bloc,
                  idCustomer: DataLocal.infoCustomer.customerCode.toString(),
                ),
              if (Const.typeOrder == true) _buildOrderType(context),
              if (Const.chooseAgency == true && bloc.showSelectAgency == true)
                _buildAgencySection(context),
              if (Const.lockStockInCart == false) _buildStockSection(context),
              if (Const.isVvHd == true) _buildVVHDSection(context),
              if (Const.useTax == true) _buildTaxSection(context),
              if (Const.chooseTypePayment == true) _buildPaymentType(context),
              if (Const.chooseTypeDelivery == true) _buildDeliveryType(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return InkWell(
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
    );
  }

  Widget _buildTransactionType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Text(
          'Loại giao dịch:',
          style: TextStyle(
            color: mainColor,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
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
          child: (Const.woPrice == true &&
                  Const.allowsWoPriceAndTransactionType == false)
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
    );
  }

  Widget _buildOrderType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          child: Text(
            'Loại đơn hàng:',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Container(
            height: 45,
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
            child: typeOrderWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildAgencySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          child: Text(
            'Thông tin đại lý:',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        GestureDetector(
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

                final infoCustomer = value;
                bloc.chooseAgencyCode = true;
                bloc.add(PickInfoAgency(
                  typeDiscount: infoCustomer.typeDiscount,
                  codeAgency: infoCustomer.customerCode,
                  nameAgency: infoCustomer.customerName,
                  cancelAgency: false,
                ));
                onStateChanged();
              }
            });
          },
          child: Container(
            height: 45,
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
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
                          onStateChanged();
                        },
                        child: const Icon(Icons.cancel_outlined,
                            color: Colors.blueGrey, size: 20),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(
            'Kho xuất hàng:',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
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
          child: genderWidget(),
        ),
      ],
    );
  }

  Widget _buildVVHDSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 14),
          child: Text(
            'Loại Chương trình bán hàng:',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        GestureDetector(
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
              builder: (builder) => buildPopupVvHd(),
            ).then((value) {
              if (value != null) {
                if (value[0] == 'ReLoad') {
                  bloc.idVv = value[1];
                  bloc.nameVv = value[2];
                  bloc.idHd = value[3];
                  bloc.nameHd = value[4];
                  bloc.idHdForVv = value[5];
                  onStateChanged();
                }
              }
            });
          },
          child: Container(
            height: 45,
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
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
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
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
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          child: Text(
            Const.afterTax == true
                ? 'Áp dụng thuế sau chiết khấu cho đơn hàng:'
                : '1 Áp dụng thuế trước chiết khấu cho đơn hàng:',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Container(
          height: 45,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: genderTaxWidget(),
        ),
      ],
    );
  }

  Widget _buildPaymentType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          child: Text(
            'Loại hình thức thanh toán:',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Container(
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
              if (bloc.showDatePayment == true)
                InkWell(
                  onTap: () {
                    Utils.dateTimePickerCustom(context).then((value) {
                      if (value != null) {
                        DataLocal.datePayment = Utils.parseStringDateToString(
                          value.toString(),
                          Const.DATE_TIME_FORMAT,
                          Const.DATE_SV_FORMAT,
                        );
                        onStateChanged();
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50),
                    child: Row(
                      children: [
                        Text(
                          DataLocal.datePayment,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 5),
                        Icon(Icons.calendar_today_rounded,
                            color: mainColor, size: 19),
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

  Widget _buildDeliveryType(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          child: Text(
            'Loại hình thức giao hàng:',
            style: TextStyle(
              color: mainColor,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Container(
          height: 45,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: typeDeliveryWidget(),
        ),
      ],
    );
  }
}

