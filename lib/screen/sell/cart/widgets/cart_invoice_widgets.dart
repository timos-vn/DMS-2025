import 'dart:io';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../../themes/colors.dart';
import '../../../../widget/pending_action.dart';
import '../../component/input_address_popup.dart';
import '../../../../screen/customer/search_customer/search_customer_screen.dart';
import '../../../../model/database/data_local.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';
import 'cart_helper_widgets.dart';

/// Widget hiển thị thông tin khách hàng
class CartCustomerInfoWidget extends StatelessWidget {
  final CartBloc bloc;
  final TextEditingController nameCustomerController;
  final TextEditingController phoneCustomerController;
  final TextEditingController addressCustomerController;
  final FocusNode nameCustomerFocus;
  final FocusNode phoneCustomerFocus;
  final FocusNode addressCustomerFocus;
  final bool isContractCreateOrder;
  final bool orderFromCheckIn;
  final bool addInfoCheckIn;
  final Widget Function({
    String? title,
    String? hideText,
    IconData? iconPrefix,
    IconData? iconSuffix,
    bool? isEnable,
    TextEditingController? controller,
    Function? onTapSuffix,
    Function? onSubmitted,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    bool inputNumber,
    bool note,
    bool isPassWord,
  }) inputWidget;
  final VoidCallback onStateChanged;

  const CartCustomerInfoWidget({
    Key? key,
    required this.bloc,
    required this.nameCustomerController,
    required this.phoneCustomerController,
    required this.addressCustomerController,
    required this.nameCustomerFocus,
    required this.phoneCustomerFocus,
    required this.addressCustomerFocus,
    required this.isContractCreateOrder,
    required this.orderFromCheckIn,
    required this.addInfoCheckIn,
    required this.inputWidget,
    required this.onStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              height: 40,
              width: double.infinity,
              color: Colors.amber.withOpacity(0.4),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thông tin khách hàng',
                  style: TextStyle(color: Colors.black, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () {
                if (isContractCreateOrder == true) {
                  return;
                }
                if ((orderFromCheckIn == false && addInfoCheckIn != true)) {
                  PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const SearchCustomerScreen(
                      selected: true,
                      allowCustomerSearch: true,
                      inputQuantity: false,
                    ),
                    withNavBar: false,
                  ).then((value) {
                    if (value != null) {
                      DataLocal.infoCustomer = value;
                      bloc.add(PickInfoCustomer(
                        customerName: DataLocal.infoCustomer.customerName,
                        phone: DataLocal.infoCustomer.phone,
                        address: DataLocal.infoCustomer.address,
                        codeCustomer: DataLocal.infoCustomer.customerCode,
                      ));
                    }
                  });
                }
              },
              child: Stack(
                children: [
                  inputWidget(
                    title: 'Tên khách hàng',
                    hideText: "Nguyễn Văn A",
                    controller: nameCustomerController,
                    focusNode: nameCustomerFocus,
                    textInputAction: TextInputAction.done,
                    onTapSuffix: () {},
                    note: true,
                    isEnable: false,
                  ),
                  Positioned(
                    top: 20,
                    right: 10,
                    child: (orderFromCheckIn == false && addInfoCheckIn != true)
                        ? Icon(
                            Icons.search_outlined,
                            color: isContractCreateOrder == true
                                ? Colors.transparent
                                : Colors.grey,
                            size: 20,
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
            inputWidget(
              title: "SĐT khách hàng",
              hideText: '0963 xxx xxx ',
              controller: phoneCustomerController,
              focusNode: phoneCustomerFocus,
              textInputAction: TextInputAction.done,
              onTapSuffix: () {},
              note: true,
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (context) {
                    return InputAddressPopup(
                      note: addressCustomerController.text != null
                          ? addressCustomerController.text.toString()
                          : "",
                      title: 'Địa chỉ KH',
                      desc: 'Vui lòng nhập địa chỉ KH',
                      convertMoney: false,
                      inputNumber: false,
                    );
                  },
                ).then((note) {
                  if (note != null) {
                    onStateChanged();
                    addressCustomerController.text = note;
                  }
                });
              },
              child: Stack(
                children: [
                  inputWidget(
                    title: 'Địa chỉ khách hàng',
                    hideText: "Vui lòng nhập địa chỉ KH",
                    controller: addressCustomerController,
                    focusNode: addressCustomerFocus,
                    textInputAction: TextInputAction.done,
                    onTapSuffix: () {},
                    note: true,
                    isEnable: false,
                  ),
                  const Positioned(
                    top: 20,
                    right: 10,
                    child: Icon(Icons.edit, color: Colors.grey, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị yêu cầu khác (đính kèm hoá đơn, xuất hoá đơn)
class CartOtherRequestWidget extends StatelessWidget {
  final CartBloc bloc;
  final Widget Function() buildAttachFileInvoice;
  final Widget Function() buildInfoInvoice;
  final Widget Function(String, bool, int) buildCheckboxList;

  const CartOtherRequestWidget({
    Key? key,
    required this.bloc,
    required this.buildAttachFileInvoice,
    required this.buildInfoInvoice,
    required this.buildCheckboxList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yêu cầu khác:',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => bloc.add(CheckInTransferEvent(index: 4)),
            child: buildCheckboxList(
              'Đính kèm hoá đơn (nếu có)',
              bloc.attachInvoice,
              4,
            ),
          ),
          Visibility(
            visible: bloc.attachInvoice == true,
            child: buildAttachFileInvoice(),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => bloc.add(CheckInTransferEvent(index: 5)),
            child: buildCheckboxList(
              'Xuất hoá đơn cho công ty',
              bloc.exportInvoice,
              5,
            ),
          ),
          Visibility(
            visible: bloc.exportInvoice == true,
            child: buildInfoInvoice(),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị đính kèm file hoá đơn
class CartAttachFileInvoiceWidget extends StatelessWidget {
  final CartBloc bloc;
  final int start;
  final bool waitingLoad;
  final VoidCallback getImage;
  final Function(int, File) openImageFullScreen;
  final VoidCallback onStateChanged;

  const CartAttachFileInvoiceWidget({
    Key? key,
    required this.bloc,
    required this.start,
    required this.waitingLoad,
    required this.getImage,
    required this.openImageFullScreen,
    required this.onStateChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                getImage();
              },
              child: Container(
                padding: const EdgeInsets.only(left: 10, right: 15, top: 8, bottom: 8),
                height: 40,
                width: double.infinity,
                color: Colors.amber.withOpacity(0.4),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ảnh của bạn',
                      style: TextStyle(color: Colors.black, fontSize: 13),
                    ),
                    Icon(Icons.add_a_photo_outlined, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            bloc.listFileInvoice.isEmpty
                ? const SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        'Hãy chọn thêm hình ảnh của bạn từ thư viện ảnh hoặc từ camera',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: bloc.listFileInvoice.length,
                        itemBuilder: (context, index) {
                          return (start > 1 &&
                                  waitingLoad == true &&
                                  bloc.listFileInvoice.length == (index + 1))
                              ? const SizedBox(
                                  height: 100,
                                  width: 80,
                                  child: PendingAction(),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    openImageFullScreen(index, bloc.listFileInvoice[index]);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          width: 115,
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(8)),
                                            child: Hero(
                                              tag: index,
                                              child: Image.file(
                                                bloc.listFileInvoice[index],
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: InkWell(
                                            onTap: () {
                                              onStateChanged();
                                              bloc.listFileInvoice.removeAt(index);
                                              bloc.listFileInvoiceSave.removeAt(index);
                                            },
                                            child: Container(
                                              height: 20,
                                              width: 20,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.black.withOpacity(.7),
                                              ),
                                              child: const Icon(
                                                Icons.clear,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị thông tin xuất hoá đơn
class CartInfoInvoiceWidget extends StatelessWidget {
  final TextEditingController nameCompanyController;
  final TextEditingController mstController;
  final TextEditingController addressCompanyController;
  final TextEditingController noteController;
  final FocusNode nameCompanyFocus;
  final FocusNode mstFocus;
  final FocusNode addressFocus;
  final FocusNode noteFocus;
  final Widget Function({
    String? title,
    String? hideText,
    IconData? iconPrefix,
    IconData? iconSuffix,
    bool? isEnable,
    TextEditingController? controller,
    Function? onTapSuffix,
    Function? onSubmitted,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    bool inputNumber,
    bool note,
    bool isPassWord,
  }) inputWidget;

  const CartInfoInvoiceWidget({
    Key? key,
    required this.nameCompanyController,
    required this.mstController,
    required this.addressCompanyController,
    required this.noteController,
    required this.nameCompanyFocus,
    required this.mstFocus,
    required this.addressFocus,
    required this.noteFocus,
    required this.inputWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              height: 40,
              width: double.infinity,
              color: Colors.amber.withOpacity(0.4),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thông tin xuất hoá đơn',
                  style: TextStyle(color: Colors.black, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: 8),
            inputWidget(
              title: "Công ty",
              hideText: 'Tên công ty',
              controller: nameCompanyController,
              focusNode: nameCompanyFocus,
              textInputAction: TextInputAction.done,
              onTapSuffix: () {},
              note: true,
            ),
            inputWidget(
              title: "Mã số thuế",
              hideText: 'Mã số thuế',
              controller: mstController,
              focusNode: mstFocus,
              textInputAction: TextInputAction.done,
              onTapSuffix: () {},
              note: true,
            ),
            inputWidget(
              title: "Địa chỉ",
              hideText: 'Địa chỉ',
              controller: addressCompanyController,
              focusNode: addressFocus,
              textInputAction: TextInputAction.done,
              onTapSuffix: () {},
              note: true,
            ),
            inputWidget(
              title: "Ghi chú",
              hideText: 'Ghi chú',
              controller: noteController,
              focusNode: noteFocus,
              textInputAction: TextInputAction.done,
              onTapSuffix: () {},
              note: false,
            ),
          ],
        ),
      ),
    );
  }
}

