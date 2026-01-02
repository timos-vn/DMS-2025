import 'package:flutter/material.dart';

import '../../../../model/database/data_local.dart';
import '../../../../model/network/response/list_tax_response.dart';
import '../../../../model/network/response/setting_options_response.dart';
import '../../../../model/network/response/data_default_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/const.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/text_field_widget2.dart';
import '../cart_bloc.dart';
import '../cart_event.dart';
import 'package:dotted_border/dotted_border.dart';
import 'tax_selection_sheet.dart';

/// Helper widgets for CartScreen
class CartHelperWidgets {
  // Payment type dropdown widget
  static Widget typePaymentWidget(CartBloc bloc) {
    return Utils.isEmpty(DataLocal.typePaymentList)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<String>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: DataLocal.typePaymentList[bloc.typePaymentIndex],
          items: DataLocal.typePaymentList.map((value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            DataLocal.valuesTypePayment = value.toString();
            bloc.add(PickTypePayment(DataLocal.typePaymentList.indexOf(value!),  DataLocal.valuesTypePayment));
          }),
    );
  }

  // Delivery type dropdown widget
  static Widget typeChooseTypeDelivery(CartBloc bloc) {
    return Utils.isEmpty(DataLocal.listTypeDelivery)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<ListTypeDelivery>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: DataLocal.listTypeDelivery[bloc.typeDeliveryIndex < 0 ? 0 : bloc.typeDeliveryIndex],
          items: DataLocal.listTypeDelivery.map((value) => DropdownMenuItem<ListTypeDelivery>(
            value: value,
            child: Text(value.nameTypeDelivery.toString(), style: const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            ListTypeDelivery item = value??ListTypeDelivery();
            bloc.add(PickListTypeDeliveryEvent(item,DataLocal.listTypeDelivery.indexOf(item)));
          }),
    );
  }

  // Transaction type dropdown widget
  static Widget transactionWidget(CartBloc bloc, Function(String) onMaGDChanged) {
    return Utils.isEmpty(Const.listTransactionsOrder)
        ?
    const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        :
    DropdownButtonHideUnderline(
      child: DropdownButton<ListTransaction>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: Const.listTransactionsOrder[bloc.transactionIndex < 0 ? 0 : bloc.transactionIndex],
          items: Const.listTransactionsOrder.map((value) => DropdownMenuItem<ListTransaction>(
            value: value,
            child: Text(value.tenGd.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              DataLocal.transaction = value;
              DataLocal.transactionCode = DataLocal.transaction.maGd.toString();
              DataLocal.transactionYN = DataLocal.transaction.chonDLYN??0;
              final maGD = value.maGd.toString().trim();
              onMaGDChanged(maGD);
              bloc.add(PickTransactionName(Const.listTransactionsOrder.indexOf(DataLocal.transaction),DataLocal.transaction.tenGd.toString(),DataLocal.transaction.chonDLYN??0));
            }
          }),
    );
  }

  // Order type widget
  static Widget typeOrderWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child:  Text(Const.nameTypeAdvOrder.toString().trim().replaceAll('null', '').isNotEmpty ?
      Const.nameTypeAdvOrder.toString() : 'Vui lòng chọn loại đơn hàng',style: const TextStyle(color: Colors.blueGrey,fontSize: 12)),
    );
  }

  // Tax widget - ✅ CHANGED: Dùng button + bottom sheet thay vì dropdown
  static Widget genderTaxWidget(
    BuildContext context,
    CartBloc bloc,
    Function(int) onTaxIndexChanged,
    Future<List<GetListTaxResponseData>> Function()? onLoadTaxList,
  ) {
    // Lấy tax hiện tại
    GetListTaxResponseData? currentTax;
    if (DataLocal.listTax.isNotEmpty && bloc.taxIndex < DataLocal.listTax.length) {
      currentTax = DataLocal.listTax[bloc.taxIndex];
    }

    return InkWell(
      onTap: () {
        // Show bottom sheet để chọn thuế
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => TaxSelectionSheet(
            selectedTax: currentTax,
            onTaxSelected: (tax) {
              // Xử lý khi chọn thuế
              if (tax.maThue.toString().trim() == '#000') {
                bloc.allowTaxPercent = false;
              } else {
                bloc.allowTaxPercent = true;
              }

              // Tìm index của tax trong DataLocal.listTax
              int indexValuesTax = 0;
              if (DataLocal.listTax.isNotEmpty) {
                int foundIndex = DataLocal.listTax.indexWhere(
                  (t) => t.maThue == tax.maThue,
                );
                if (foundIndex >= 0) {
                  indexValuesTax = foundIndex;
                }
              }

              DataLocal.indexValuesTax = indexValuesTax;
              DataLocal.taxPercent = tax.thueSuat!.toDouble();
              DataLocal.taxCode = tax.maThue.toString().trim();
              onTaxIndexChanged(indexValuesTax);

              if (Const.afterTax == true) {
                bloc.add(PickTaxAfter(DataLocal.indexValuesTax, DataLocal.taxPercent));
              } else {
                bloc.add(PickTaxBefore(DataLocal.indexValuesTax, DataLocal.taxPercent));
              }
            },
            onLoadTaxList: onLoadTaxList,
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              currentTax?.tenThue?.toString() ?? 'Chọn thuế',
              style: TextStyle(
                fontSize: 12.0,
                color: currentTax != null ? black : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.grey.shade600,
            size: 20,
          ),
        ],
      ),
    );
  }

  // Stock widget
  static Widget genderWidget(CartBloc bloc) {
    return Utils.isEmpty(Const.stockList)
        ? const Padding(
      padding: EdgeInsets.only(top: 6),
      child:  Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
    )
        : DropdownButtonHideUnderline(
      child: DropdownButton<StockList>(
          isDense: true,
          isExpanded: true,
          style: const TextStyle(
            color: black,
            fontSize: 12.0,
          ),
          value: Const.stockList[bloc.storeIndex],
          items: Const.stockList.map((value) => DropdownMenuItem<StockList>(
            value: value,
            child: Text(value.stockName.toString(), style:  const TextStyle(fontSize: 12.0, color: black),maxLines: 1,overflow: TextOverflow.ellipsis,),
          )).toList(),
          onChanged: (value) {
            if (value != null) {
              StockList stocks = value;
              bloc.storeCode = stocks.stockCode;
              bloc.add(PickStoreName(Const.stockList.indexOf(value)));
            }
          }),
    );
  }

  // Input widget
  static Widget inputWidget({
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
    bool inputNumber = false,
    bool note = false,
    bool isPassWord = false
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 0,left: 10,right: 10,bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title??'',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13,color: Colors.black),
              ),
              Visibility(
                visible: note == true,
                child: const Text(' *',style: TextStyle(color: Colors.red),),
              )
            ],
          ),
          const SizedBox(height: 5,),
          Container(
            height: 45,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8)
            ),
            child: TextFieldWidget2(
              controller: controller!,
              suffix: iconSuffix,
              textInputAction: textInputAction!,
              isEnable: isEnable ?? true,
              keyboardType: inputNumber == true ? TextInputType.phone : TextInputType.text,
              hintText: hideText,
              focusNode: focusNode,
              onSubmitted: onSubmitted != null ? (text) => onSubmitted(text) : null,
              isPassword: isPassWord,
              isNull: true,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  // Custom payment widget
  static Widget customWidgetPayment(String title, String subtitle, int discount, String codeDiscount) {
    return Padding(
      padding:const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,style: const TextStyle(fontSize: 12,color: Colors.blueGrey),),
              subtitle != '' ? Text(subtitle,style: const TextStyle(fontSize: 13,color: Colors.black),) :
              discount > 0 ?
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: DottedBorder(
                        dashPattern: const [5, 3],
                        color: Colors.red,
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(2),
                        padding: const EdgeInsets.only(top: 2,bottom: 2,left: 10,right: 10),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          child: Text(codeDiscount,style: const TextStyle(fontSize: 11,color: Colors.red),
                          ),
                        )
                    ),
                  )
                ],
              )
                  : Container(),
            ],
          ),
          const Divider(color: Colors.grey,)
        ],
      ),
    );
  }

  // Checkbox list widget
  static Widget buildCheckboxList(String title, bool value, int index, CartBloc bloc) {
    return Row(
      children: [
        SizedBox(
          height: 10,
          child: Transform.scale(
            scale: 1,
            alignment: Alignment.topLeft,
            child: Checkbox(
              value: value,
              onChanged: (b){
                if(index == 4){
                  bloc.add(CheckInTransferEvent(index: 4));
                }else if(index == 5){
                  bloc.add(CheckInTransferEvent(index: 5));
                }
              },
              activeColor: mainColor,
              hoverColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)
              ),
              side: WidgetStateBorderSide.resolveWith((states){
                if(states.contains(WidgetState.pressed)){
                  return BorderSide(color: mainColor);
                }else{
                  return BorderSide(color: mainColor);
                }
              }),
            ),
          ),
        ),
        Text(title,style: const TextStyle(color: Colors.blueGrey,fontSize: 12),),
      ],
    );
  }

  // Format tax rate helper
  static String formatTaxRate(double taxRate) {
    if (taxRate == taxRate.roundToDouble()) {
      return taxRate.round().toString();
    } else {
      return taxRate.toStringAsFixed(1);
    }
  }
}

