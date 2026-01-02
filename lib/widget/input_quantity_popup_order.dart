// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:dms/screen/filter/filter_page.dart';
import 'package:dms/screen/menu/component/option_report_filter.dart';
import 'package:dms/screen/sell/cart/component/search_item.dart';
import 'package:dms/screen/sell/component/input_address_popup.dart';
import 'package:dms/screen/sell/order/order_bloc.dart';
import 'package:dms/screen/sell/order/order_event.dart';
import 'package:dms/screen/sell/order/order_sate.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/text_field_widget2.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../model/entity/entity.dart';
import '../../model/network/response/list_stock_response.dart';
import '../../model/network/response/report_field_lookup_response.dart';
import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import 'custom_dropdown.dart';

class InputQuantityPopupOrder extends StatefulWidget {
  final String nameProduction;
  final String codeProduction;
  final double price;
  final double? giaGui;
  final double quantity;
  final double quantityStock;
  final List<String> listDvt;
  final bool? allowDvt;
  final bool? inventoryStore;
  final String title;
  final String? typeValues;
  final bool findStock;
  final bool? isCreateItemHolder;
  final List<ListStore> listStock;
  final String listObjectJson;
  final bool? updateValues;
  final List<ListQDDVT> listQuyDoiDonViTinh;
  final String nuocsx;
  final String quycach;
  final String? idNVKD;
  final String? nameNVKD;
  final String? tenThue;
  final dynamic thueSuat;
  final double? originalPrice; // Giá gốc ban đầu từ API

  const InputQuantityPopupOrder({Key? key,
    required this.codeProduction, required this.nameProduction,required this.price,this.giaGui,required this.title,required this.quantity,
    required this.listDvt, required this.allowDvt,required this.inventoryStore,
    required this.findStock,required this.listStock, required this.quantityStock,this.typeValues,
    this.isCreateItemHolder,required this.listObjectJson, this.updateValues, required this.listQuyDoiDonViTinh,
    required this.nuocsx, required this.quycach,
    this.idNVKD, this.nameNVKD, this.tenThue, this.thueSuat, this.originalPrice,
  }) : super(key: key);

  @override
  _InputQuantityPopupOrderState createState() => _InputQuantityPopupOrderState();
}

class _InputQuantityPopupOrderState extends State<InputQuantityPopupOrder> {

  /// Kiểm tra xem có cho phép sửa giá hay không dựa trên các điều kiện:
  /// - Nếu editPriceWidthValuesEmptyOrZero = true: Chỉ cho sửa khi giá gốc (originalPrice) = 0 hoặc null
  /// - Nếu editPriceWidthValuesEmptyOrZero = false && editPrice = true: Cho phép sửa
  /// - Nếu editPriceWidthValuesEmptyOrZero = false && editPrice = false: Không cho sửa
  bool get canEditPrice {
    if (Const.editPriceWidthValuesEmptyOrZero == true) {
      // Chỉ cho sửa giá khi giá gốc ban đầu = 0 hoặc null
      // Điều này cho phép user tiếp tục sửa giá nhiều lần nếu giá ban đầu từ API là 0
      return (widget.originalPrice ?? widget.price) == 0;
    } else {
      // Logic cũ: phụ thuộc vào Const.editPrice
      return Const.editPrice == true;
    }
  }

  late TextEditingController nuocsxController  =  TextEditingController();
  late TextEditingController quycachController  =  TextEditingController();

  late TextEditingController contentController  =  TextEditingController();
  late TextEditingController nameProductController  =  TextEditingController();
  late TextEditingController giaGuiController  =  TextEditingController();

  FocusNode focusNodeContent = FocusNode();

  late TextEditingController priceController  =  TextEditingController();
  late TextEditingController priceTotalController  =  TextEditingController();

  FocusNode focusNodePrice = FocusNode();

  double valueInput = 0;
  double priceInput = 0;  double giaGui = 0;
  late OrderBloc _orderBloc;
  String note = '';
  String unitOfCalculation = '';
  String unitTransfer = '';
  String nameStore = '';
  String codeStore = '';
  double x = 0;
  String nameProductionEdited = '';
  String codeUnit = '';String nameUnit = '';

  List<String> listType = ['Thường','Sản xuất','Chế biến'];
  String typeValues = 'Thường';

  final TextEditingController type4 = TextEditingController();


  static const _locale = 'en';
  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(int.parse(s));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.listDvt.length);
    nuocsxController.text = widget.nuocsx.toString();
    quycachController.text = widget.quycach.toString();
    idNVKD = widget.idNVKD.toString();
    nameNVKD = widget.nameNVKD.toString();
    if(widget.listQuyDoiDonViTinh.isNotEmpty){
      for (var element in widget.listQuyDoiDonViTinh) {
        if(element.isDefault == true){
          unitOfCalculation = element.dvt.toString().trim();
          unitTransfer = (element.heSo.toString());
        }
      }
    }
    _orderBloc = OrderBloc(context);
    _orderBloc.add(GetPrefs());
    giaGui = widget.giaGui??0;
    nameProductController.text = widget.nameProduction;
   if(widget.listStock.isNotEmpty){
     nameStore = widget.listStock[0].tenKho.toString().trim();
     codeStore = widget.listStock[0].maKho.toString().trim();
   }
    if(giaGui > 0){
      giaGuiController.text = Utils.formatMoneyStringToDouble(giaGui);
    }
    if(Const.typeProduction == true){
      typeValues = 'Thường';
    }
    else{
      typeValues = 'Default';
    }
    typeValues = (widget.typeValues.toString().isNotEmpty && widget.typeValues.toString() != 'null') ? widget.typeValues.toString() : 'Thường';
    if(widget.quantity > 0){
      contentController.text = widget.quantity.round().toString();
      valueInput = widget.quantity;
    }
    else{
      valueInput = 1;
    }

    x = widget.price;

    if(x > 0){
      priceController.text = Utils.formatMoneyStringToDouble(widget.price);
      priceTotalController.text = Utils.formatMoneyStringToDouble(
          giaGui > 0 ?
          giaGui * (widget.quantity > 0 ? widget.quantity : 1)
          :
          widget.price * (widget.quantity > 0 ? widget.quantity : 1)
      );
      priceInput = widget.price;
    }
    if(widget.listDvt.isNotEmpty){
      unitOfCalculation = widget.listDvt[0];
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      // (Const.isGetAdvanceOrderInfo == true && isExpaned == true) ? false : true,
      body: BlocListener<OrderBloc, OrderState>(
          bloc: _orderBloc,
          listener: (context, state) {
            if(state is GetInfoOrderSuccess){
              isLoaded = false;
            }else if(state is GetListStockEventSuccess){

            }
          },
          child: BlocBuilder<OrderBloc, OrderState>(
            bloc: _orderBloc,
            builder: (BuildContext context, OrderState state) {
              return Stack(
                children: [
                  buildBody(context, state),
                  Visibility(
                    visible: state is EmptyDataState,
                    child:const Center(
                      child: Text('Không có dữ liệu',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                    ),
                  ),
                  Visibility(
                    visible: state is OrderLoading,
                    child:const PendingAction(),
                  ),
                ],
              );
            },
          )),
    );
  }

  bool isExpaned = false;
  bool isLoaded = true;
  bool resizeToAvoidBottomInset = true;

  buildBody(BuildContext context, OrderState state){
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration:const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16)),
          ),
          // height: (Const.editPrice == true && x > 0) ? 260 : 200,
          // height: Const.noteForEachProduct == true ? 350 : 300,
          height: Const.isBaoGia == true ? 400 :
          (Const.isGetAdvanceOrderInfo == true
              ?
          (isExpaned == true ? (MediaQuery.of(context).size.height * 0.9) : 350)
              :
          350),
          width: double.infinity,
          child: Material(
            color: grey_100,
              animationDuration:const Duration(seconds: 3),
              borderRadius:const BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox( height: 35,width: 45, child:  Icon(Icons.clear,color: Colors.transparent,)),
                      const Text(
                        'Thông tin sản phẩm',
                        style:TextStyle(color: subColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      InkWell(
                        onTap: (){
                         Navigator.pop(context);
                        },
                        child:const SizedBox( height: 35,width: 45, child:  Icon(Icons.clear,color: Colors.grey,)),
                      )
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: grey_100, borderRadius: const BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
                      padding: const EdgeInsets.only(left: 4, right: 4,),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 170,
                              child: Card(
                              semanticContainer: true,
                              margin: const EdgeInsets.only(left: 10,right: 10),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 110,
                                          decoration: const BoxDecoration(
                                              borderRadius:BorderRadius.all( Radius.circular(6),),
                                          ),
                                          child: const Icon(EneftyIcons.image_outline,size: 50,weight: 0.6,)
                                          //Image.network('https://i.pinimg.com/564x/49/77/91/4977919321475b060fcdd89504cee992.jpg',fit: BoxFit.contain,),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 0,right: 6),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                color: Colors.white,
                                                height: 30,
                                                padding: const EdgeInsets.only(right: 6),
                                                child: TextField(
                                                  autofocus: false,
                                                  enabled: Const.editNameProduction == true ? true : false,
                                                  textAlign: TextAlign.left,
                                                  textAlignVertical: TextAlignVertical.top,
                                                  style: const TextStyle(color: subColor, fontSize: 14, fontWeight: FontWeight.w600,overflow: TextOverflow.ellipsis),
                                                  maxLines: 1,
                                                  controller: nameProductController,
                                                  keyboardType: TextInputType.text,
                                                  textInputAction: TextInputAction.done,
                                                  onChanged: (string){
                                                    if(string != '' ){
                                                      nameProductionEdited = string;
                                                    }
                                                  },
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      filled: true,
                                                      fillColor: transparent,
                                                      hintText: "Vui lòng nhập tên sản phẩm",
                                                      hintStyle: const TextStyle(color: accent),
                                                      suffixIcon: Icon(FluentIcons.edit_12_filled,size: 15,color: Const.editNameProduction == true ? Colors.grey : Colors.transparent,),
                                                      suffixIconConstraints: const BoxConstraints(maxWidth: 20),
                                                      contentPadding: const EdgeInsets.only(
                                                          bottom: 12, right: 20,left: 0)
                                                  ),
                                                ),
                                              ),
                                                const SizedBox(height: 5,),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    const Icon(FluentIcons.cart_16_filled),
                                                    const SizedBox(width: 5,),
                                                    Expanded(
                                                      flex: 3,
                                                      child: SizedBox(
                                                        height: 25,
                                                        child: genderStore(),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(width: 10,),
                                                          Container(
                                                            height: 13,
                                                            width: 1.5,
                                                            color: Colors.grey,
                                                          ),
                                                          const SizedBox(width: 10,),
                                                          Expanded(
                                                            child: Container(
                                                              width: double.infinity,height: 25,
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(16),
                                                                  color: Colors.white
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  const Text(
                                                                    '\$',
                                                                    style:TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                                  ),
                                                                  Expanded(
                                                                    child: Container(
                                                                      color: Colors.white,
                                                                      padding: const EdgeInsets.only(right: 6),
                                                                      child: TextField(
                                                                        autofocus: false,
                                                                        enabled: canEditPrice,
                                                                        textAlign: TextAlign.left,
                                                                        textAlignVertical: TextAlignVertical.top,
                                                                        style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                                        controller: priceController,
                                                                        keyboardType: TextInputType.number,
                                                                        textInputAction: TextInputAction.done,
                                                                        onChanged: (string){
                                                                          if(string != '' ){
                                                                            if(string.contains(',')){
                                                                              priceInput = double.parse(string.replaceAll(',', ''));
                                                                            }else{
                                                                              priceInput = double.parse(string);
                                                                            }
                                                                            string = _formatNumber(string.replaceAll(',', '').replaceAll('.', ''));
                                                                            priceController.value = TextEditingValue(
                                                                              text: string,
                                                                              selection: TextSelection.collapsed(offset: string.length),
                                                                            );
                                                                            double qty = 0;
                                                                            qty = double.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                                                            priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput ).toString();
                                                                          }
                                                                          else{
                                                                            double qty = 0;
                                                                            qty = double.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                                                            priceTotalController.text = Utils.formatMoneyStringToDouble(qty * widget.price).toString();
                                                                          }
                                                                          if(widget.listStock.isNotEmpty){
                                                                            if(priceInput <= double.parse(widget.listStock[0].priceMin.toString())){
                                                                              Utils.showCustomToast(context, Icons.warning_amber, 'Lưu ý: Giá của bạn đang dưới hoặc bằng với giá Min');
                                                                            }
                                                                          }
                                                                        },
                                                                        decoration: InputDecoration(
                                                                            border: InputBorder.none,
                                                                            filled: true,
                                                                            fillColor: transparent,
                                                                            hintText: "0",
                                                                            hintStyle: const TextStyle(color: accent),
                                                                            suffixIcon: Icon(FluentIcons.edit_12_filled,size: 15,color: canEditPrice ? Colors.grey : Colors.transparent,),
                                                                            suffixIconConstraints: const BoxConstraints(maxWidth: 20),
                                                                            contentPadding: const EdgeInsets.only(
                                                                                bottom: 14, top: 0,right: 0)
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(height: 3,),
                                                Visibility(
                                                  visible: (Const.giaGui == true || Const.typeProduction == true) && widget.isCreateItemHolder != true,
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      const Icon(FluentIcons.clipboard_task_list_ltr_20_filled),
                                                      const SizedBox(width: 5,),
                                                      Visibility(
                                                        visible: Const.typeProduction == true && widget.isCreateItemHolder != true,
                                                        child: Expanded(
                                                          flex: 3,
                                                          child: SizedBox(
                                                              height: 25,
                                                              child: genderTypes()
                                                          ),
                                                        ),
                                                      ),
                                                      Visibility(
                                                        visible: Const.giaGui == true && widget.isCreateItemHolder != true,
                                                        child: Expanded(
                                                          flex: 4,
                                                          child: Row(
                                                            children: [
                                                              const SizedBox(width: 10,),
                                                              Container(
                                                                height: 13,
                                                                width: 1.5,
                                                                color: Colors.grey,
                                                              ),
                                                              const SizedBox(width: 10,),
                                                              Visibility(
                                                                visible: giaGuiController.text.isNotEmpty && giaGuiController.text != '',
                                                                child: const Text(
                                                                  '\$',
                                                                  style:TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Container(
                                                                  color: Colors.white, padding: const EdgeInsets.only(right: 6),
                                                                  width: double.infinity,height: 25,
                                                                  child: TextField(
                                                                    autofocus: false,
                                                                    textAlign: TextAlign.left,
                                                                    textAlignVertical: TextAlignVertical.center,
                                                                    style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                                    controller: giaGuiController,
                                                                    keyboardType: TextInputType.number,
                                                                    textInputAction: TextInputAction.done,
                                                                    onChanged: (string){
                                                                      setState(() {
                                                                        if(string != '' ){
                                                                          if(string.contains(',')){
                                                                            giaGui = double.parse(string.replaceAll(',', ''));
                                                                          }else{
                                                                            giaGui = double.parse(string);
                                                                          }
                                                                          string = _formatNumber(string.replaceAll(',', ''));
                                                                          giaGuiController.value = TextEditingValue(
                                                                            text: string,
                                                                            selection: TextSelection.collapsed(offset: string.length),
                                                                          );
                                                                        }
                                                                      });
                                                                    },
                                                                    decoration: const InputDecoration(
                                                                        border: InputBorder.none,
                                                                        filled: true,
                                                                        fillColor: transparent,
                                                                        hintText: "Giá thu",
                                                                        hintStyle: TextStyle(color: Colors.blueGrey,fontSize: 12,fontWeight: FontWeight.normal),
                                                                        suffixIconConstraints: BoxConstraints(maxWidth: 20),
                                                                        suffixIcon: Icon(FluentIcons.edit_12_filled,size: 15,),
                                                                        contentPadding: EdgeInsets.only(
                                                                            bottom: 16, top: 0)
                                                                    ),
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
                                                Visibility(
                                                  visible: widget.isCreateItemHolder == true,
                                                  child: SizedBox(
                                                    height: 25,
                                                    width: double.infinity,
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Icon(FluentIcons.building_shop_16_filled),
                                                        const SizedBox(width: 5,),
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: (){
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context) => const FilterScreen(controller: 'dmdvcs_lookup',
                                                                    listItem: null,show: false,)).then((value){
                                                                if(value != null){
                                                                  setState(() {
                                                                    codeUnit = value[0];
                                                                    nameUnit = value[1];
                                                                  });
                                                                }
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    nameUnit.isNotEmpty ? nameUnit : 'Vui lòng chọn đơn vị',
                                                                    style: const TextStyle(color: Colors.blueGrey,fontSize: 12,fontWeight: FontWeight.normal),
                                                                  ),
                                                                ),
                                                                const Icon(EneftyIcons.search_normal_outline,size: 15,color: accent,),
                                                                const SizedBox(width: 5,),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: Const.manyUnitAllow == false,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 5),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            height: 35,
                                                            width: 100,
                                                            padding: const EdgeInsets.symmetric(horizontal: 10),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(16),
                                                                color: Colors.white
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                const Text(
                                                                  '\$',
                                                                  style:TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    color: Colors.transparent,
                                                                    width: 40,
                                                                    child: TextField(
                                                                      autofocus: false,
                                                                      enabled: false,
                                                                      textAlign: TextAlign.left,
                                                                      textAlignVertical: TextAlignVertical.top,
                                                                      style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                                      controller: priceTotalController,
                                                                      keyboardType: TextInputType.number,
                                                                      textInputAction: TextInputAction.done,
                                                                      onChanged: (string){
                                                                        if(string != '' ){
                                                                          string = _formatNumber(string.replaceAll(',', ''));
                                                                          priceTotalController.value = TextEditingValue(
                                                                            text: string,
                                                                            selection: TextSelection.collapsed(offset: string.length),
                                                                          );
                                                                        }
                                                                      },
                                                                      decoration: const InputDecoration(
                                                                          border: InputBorder.none,
                                                                          filled: true,
                                                                          fillColor: transparent,
                                                                          hintText: "0",
                                                                          hintStyle: TextStyle(color: accent),
                                                                          contentPadding: EdgeInsets.only(
                                                                              bottom: 14, top: 0)
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 35,
                                                          // width: 100,
                                                          padding: const EdgeInsets.symmetric(horizontal: 0),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(16),
                                                            color: grey_100
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                            children: [
                                                              InkWell(
                                                                  onTap: (){
                                                                    double qty = 0;
                                                                    qty = double.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                                                    if(qty > 1){
                                                                      setState(() {
                                                                        qty = qty - 1;
                                                                        contentController.text = qty.toString();
                                                                        valueInput = double.parse(contentController.text);
                                                                        priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput).toString();
                                                                      });
                                                                    }
                                                                  },
                                                                  child: const SizedBox(
                                                                      height: 35,width: 25,
                                                                      child: Icon(FluentIcons.subtract_12_filled,size: 15,))),
                                                              Container(
                                                                color: Colors.transparent,
                                                                width: 45,
                                                                child: TextField(
                                                                  autofocus: false,
                                                                  textAlign: TextAlign.center,
                                                                  textAlignVertical: TextAlignVertical.top,
                                                                  style: const TextStyle(fontSize: 14, color: accent),
                                                                  controller: contentController,
                                                                  keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                                  ],
                                                                  textInputAction: TextInputAction.done,
                                                                  onChanged: (text){
                                                                    double qty = 0;
                                                                    if(contentController.text.toString().isNotEmpty && contentController.text.toString() != 'null'){
                                                                      qty = double.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                                                      setState(() {
                                                                        valueInput = double.parse(contentController.text);
                                                                        priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput).toString();
                                                                      });
                                                                    }
                                                                    else{
                                                                      setState(() {
                                                                        valueInput = 1;
                                                                        priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput).toString();
                                                                      });
                                                                    }
                                                                  },
                                                                  decoration: const InputDecoration(
                                                                      border: InputBorder.none,
                                                                      filled: true,
                                                                      fillColor: transparent,
                                                                      hintText: "1",
                                                                      hintStyle: TextStyle(color: accent),
                                                                      contentPadding: EdgeInsets.only(
                                                                          bottom: 12, top: 0)
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                // width: 70,height: 30,
                                                                child: genderUnitOfCalculation(),
                                                              ),
                                                              InkWell(
                                                                  onTap: (){
                                                                    double qty = 0;
                                                                    qty = double.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                                                    setState(() {
                                                                      qty = qty + 1;
                                                                      contentController.text = qty.toString();
                                                                      valueInput = double.parse(contentController.text);
                                                                      priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput).toString();
                                                                    });
                                                                  },
                                                                  child: const SizedBox(width: 25,
                                                                      height: 35,child: Icon(FluentIcons.add_12_filled,size: 15))),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            ],
                                        ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible: Const.manyUnitAllow == true,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Container(
                                        height: 35,
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            color: Colors.white
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child:  Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Container(
                                                      height: 35,
                                                      width: 100,
                                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(16),
                                                          color: Colors.white
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            '\$',
                                                            style:TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              color: Colors.transparent,
                                                              width: 40,
                                                              child: TextField(
                                                                autofocus: false,
                                                                enabled: false,
                                                                textAlign: TextAlign.left,
                                                                textAlignVertical: TextAlignVertical.top,
                                                                style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                                                controller: priceTotalController,
                                                                keyboardType: TextInputType.number,
                                                                textInputAction: TextInputAction.done,
                                                                onChanged: (string){
                                                                  if(string != '' ){
                                                                    string = _formatNumber(string.replaceAll(',', ''));
                                                                    priceTotalController.value = TextEditingValue(
                                                                      text: string,
                                                                      selection: TextSelection.collapsed(offset: string.length),
                                                                    );
                                                                  }
                                                                },
                                                                decoration: const InputDecoration(
                                                                    border: InputBorder.none,
                                                                    filled: true,
                                                                    fillColor: transparent,
                                                                    hintText: "0",
                                                                    hintStyle: TextStyle(color: accent),
                                                                    contentPadding: EdgeInsets.only(
                                                                        bottom: 14, top: 0)
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 35,
                                                    // width: 100,
                                                    padding: const EdgeInsets.symmetric(horizontal: 0),
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(16),
                                                        color: grey_100
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        InkWell(
                                                            onTap: (){
                                                              double qty = 0;
                                                              qty = double.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                                              if(qty > 1){
                                                                setState(() {
                                                                  qty = qty - 1;
                                                                  contentController.text = qty.toString();
                                                                  valueInput = double.parse(contentController.text);
                                                                  priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput).toString();
                                                                });
                                                              }
                                                            },
                                                            child: const SizedBox(
                                                                height: 35,width: 25,
                                                                child: Icon(FluentIcons.subtract_12_filled,size: 15,))),
                                                        Container(
                                                          color: Colors.transparent,
                                                          width: 45,
                                                          child: TextField(
                                                            autofocus: false,
                                                            textAlign: TextAlign.center,
                                                            textAlignVertical: TextAlignVertical.top,
                                                            style: const TextStyle(fontSize: 14, color: accent),
                                                            controller: contentController,
                                                            keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                                            ],
                                                            textInputAction: TextInputAction.done,
                                                            onChanged: (text){
                                                              double qty = 0;
                                                              if(contentController.text.toString().isNotEmpty && contentController.text.toString() != 'null'){
                                                                qty = double.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                                                setState(() {
                                                                  valueInput = double.parse(contentController.text);
                                                                  priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput).toString();
                                                                });
                                                              }
                                                              else{
                                                                setState(() {
                                                                  valueInput = 1;
                                                                  priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput).toString();
                                                                });
                                                              }
                                                            },
                                                            decoration: const InputDecoration(
                                                                border: InputBorder.none,
                                                                filled: true,
                                                                fillColor: transparent,
                                                                hintText: "1",
                                                                hintStyle: TextStyle(color: accent),
                                                                contentPadding: EdgeInsets.only(
                                                                    bottom: 12, top: 0)
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          // width: 70,height: 30,
                                                          child:  genderManyUnitAllow(),
                                                        ),
                                                        InkWell(
                                                            onTap: (){
                                                              double qty = 0;
                                                              qty = double.parse(contentController.text.toString().isNotEmpty == true ? contentController.text.toString() : '1');
                                                              setState(() {
                                                                qty = qty + 1;
                                                                contentController.text = qty.toString();
                                                                valueInput = double.parse(contentController.text);
                                                                priceTotalController.text = Utils.formatMoneyStringToDouble(qty * priceInput).toString();
                                                              });
                                                            },
                                                            child: const SizedBox(width: 25,
                                                                height: 35,child: Icon(FluentIcons.add_12_filled,size: 15))),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
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
                                visible:  Const.isBaoGia,
                                child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children:[
                                            Expanded(child: Text('Thuế: ${widget.tenThue}'.toString(),style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),)),
                                            const SizedBox(width: 10,),
                                             Text(widget.thueSuat.toString(),style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
                                          ]
                                      ),
                                      customSelect('Nhân viên kinh doanh',false,onTap: (){
                                        PersistentNavBarNavigator.pushNewScreen(context, screen: const SearchItem(customerID: '',typeSearch: 3, title: 'Nhân viên kinh doanh',)).then((value) {
                                          if(value != null){
                                            setState(() {
                                              idNVKD = value[0];
                                              nameNVKD = value[1];
                                            });
                                          }
                                        });
                                      },values: nameNVKD.toString()),
                                      customSelect('Nước sản xuất',true,controller: nuocsxController,onTap: (){}),
                                      customSelect('Quy cách',true,controller: quycachController,onTap: (){}),
                                      const SizedBox(height: 16,)
                                    ]
                                ),
                            ),

                            Visibility(
                              visible: Const.noteForEachProduct == true,
                              child: InkWell(
                                onTap: (){
                                  showDialog(
                                      barrierDismissible: true,
                                      context: context,
                                      builder: (context) {
                                        return InputAddressPopup(note:note,
                                          title: 'Thêm ghi chú cho sản phẩm của bạn',desc: 'Viết gì đó đi....',convertMoney: false, inputNumber: false,);
                                      }).then((text){
                                    if(text != null){
                                      setState(() {
                                        note = text.toString();
                                      });
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10,right: 4,top: 10),
                                  child: Container(
                                    color: Colors.transparent,
                                    height: 30,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 5,left: 16,right: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text('Ghi chú:',style: TextStyle(color: Colors.black,fontStyle: FontStyle.italic,decoration: TextDecoration.underline,fontSize: 12),),
                                          const SizedBox(width: 12,),
                                          Expanded(child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text((note.toString().trim().replaceAll('null', '') != '') ? note : "Viết ghi chú cho sản phẩm của bạn",style: const TextStyle(color: Colors.grey,fontStyle: FontStyle.italic,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),),
                            Visibility(
                              visible: Const.isGetAdvanceOrderInfo == true && isExpaned == true,
                              child: _orderBloc.listHeaderData.isEmpty
                                  ? const Center(
                                child:Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),)
                                  :
                              Flexible(
                                child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (BuildContext context, int index) {
                                      ///Text
                                      if (_orderBloc.listHeaderData[index].type.toString().contains('Text')) {
                                        //if(widget.listRPLayout[index].field == 'so_ct1'){
                                        return textInput(context, index);
                                        // }
                                      }
                                      ///Numeric
                                      else if (_orderBloc.listHeaderData[index].type.toString().contains('Numeric')) {
                                        return numberInput(context,index);
                                      }
                                      ///Datetime
                                      else if ((_orderBloc.listHeaderData[index].type.toString()).contains('Datetime')) {
                                        if (_orderBloc.listHeaderData[index].type.toString().contains('DateFrom')) {
                                          return dateTimeFrom(context,index);
                                        }
                                        if (_orderBloc.listHeaderData[index].type.toString().contains('DateTo')) {
                                          return dateTimeTo(context,index);
                                        }
                                        if (_orderBloc.listHeaderData[index].type.toString().contains('Datetime')) {
                                          return dateTimeTo(context,index);
                                        }
                                      }
                                      ///Lookup
                                      else if (_orderBloc.listHeaderData[index].type.toString().contains('Lookup')) {
                                        return filterLookup(context, index);
                                      }
                                      ///AutoComplete
                                      else if (_orderBloc.listHeaderData[index].type.toString().contains('AutoComplete')) {
                                        return filterAutoComplete(context, index);
                                      }
                                      ///DropDown
                                      else if (_orderBloc.listHeaderData[index].type.toString().contains('Dropdowns')) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 25),
                                          child: Column(
                                            children: [
                                              Visibility(
                                                visible: _orderBloc.listHeaderData[index].selectValue != null || _orderBloc.listHeaderData[index].defaultValue != null,
                                                child: Row(
                                                  children: [
                                                    Text('${_orderBloc.listHeaderData[index].title}',style: TextStyle(color: _orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey,fontSize: 11),),
                                                    const SizedBox(width: 4,),
                                                    Visibility(
                                                        visible: _orderBloc.listHeaderData[index].nullable == false ,
                                                        child:const  Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 30,
                                                width: double.infinity,
                                                child: DropdownButtonHideUnderline(
                                                  child: ButtonTheme(
                                                    // alignedDropdown: true,
                                                    child: DropdownButton<String>(
                                                      underline: Container(color:Colors.red, height:10.0),
                                                      value:  _orderBloc.listHeaderData[index].selectValue != null ? _orderBloc.listHeaderData[index].selectValue?.code
                                                      // ignore: prefer_null_aware_operators
                                                          :(_orderBloc.listHeaderData[index].defaultValue != null? _orderBloc.listHeaderData[index].defaultValue?.trim() : null ),
                                                      iconSize: 25,
                                                      icon: (null),
                                                      style:const  TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 13,
                                                      ),
                                                      hint:  Text(
                                                        _orderBloc.listHeaderData[index].title.toString().trim() +
                                                            (_orderBloc.listHeaderData[index].nullable == false? ' *' : ''),
                                                        style: TextStyle(color:_orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey,fontSize: 11),),
                                                      onChanged: (String? newValue) {
                                                        setState(() {
                                                          _orderBloc.listHeaderData[index].textEditingController.text = newValue.toString();
                                                          _orderBloc.listHeaderData[index].selectValue =  ReportFieldLookupResponseData(code: newValue, name: newValue,);
                                                          _orderBloc.listHeaderData[index].c  = true;
                                                        });
                                                      },
                                                      items: _orderBloc.listHeaderData[index].options?.map((item) {
                                                        return DropdownMenuItem(
                                                          value: item.value.toString().trim(),
                                                          child: Text(
                                                            item.title.toString().trim(),
                                                            style:const  TextStyle(fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                                        );
                                                      }).toList() ?? [],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 0,),
                                              Container(color:Colors.grey, height:1.0)
                                            ],
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                    itemCount: _orderBloc.listHeaderData.length),
                              ),
                            ),
                            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Const.isGetAdvanceOrderInfo == true ?
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10,bottom: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: subColor
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        if(isExpaned == true){
                                          isExpaned = false;
                                          resizeToAvoidBottomInset = true;
                                        }else{
                                          isExpaned = true;
                                          resizeToAvoidBottomInset = false;
                                          _orderBloc.add(GetOrderInfoEvent(widget.codeProduction,widget.listObjectJson.toString().trim().replaceAll('null', ''),widget.updateValues??false));
                                        }
                                      });
                                    },
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          isExpaned == false ? 'Xem thêm thông tin' : 'Thu gọn thông tin',
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: (){
                                    saveInfo();
                                  },
                                  child: Container(
                                    height: 45,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: mainColor
                                    ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Text(
                                            widget.title,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),
                                          ),
                                          const SizedBox(width: 5,),
                                          const Icon(Icons.shopping_cart_outlined,color: Colors.white,size: 18,)
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) :
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10,bottom: 25),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: subColor
                            ),
                            child: GestureDetector(
                              onTap: (){
                                saveInfo();
                              },
                              child: Container(
                                height: 45,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color: mainColor
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14),
                                      ),
                                      const SizedBox(width: 5,),
                                      const Icon(Icons.shopping_cart_outlined,color: Colors.white,size: 18,)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  String idNVKD = '';
  String nameNVKD = '';


  customSelect(String? title,bool editAction,{
    TextEditingController? controller, String? hintText,VoidCallback? onTap,String? values
  }){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10,),
        Text(title.toString(),style:  TextStyle(color: mainColor,fontSize: 13,fontStyle: FontStyle.italic),),
        const SizedBox(height: 10,),
        editAction == true
            ?
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Container(
            height: 45,width: double.infinity,
            padding: const EdgeInsets.only(left: 4,top: 0,right: 4,bottom: 0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey)
            ),
            child: TextField(
              autofocus: false,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: Colors.black, fontSize: 13),
              controller: controller,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                  fillColor: transparent,
                  hintText: hintText.toString(),
                  hintStyle: const TextStyle(color: accent),
                  suffixIcon: const Icon(EneftyIcons.edit_outline,size: 15,color: Colors.grey),
                  // suffixIconConstraints: BoxConstraints(maxWidth: 20),
                  contentPadding: const EdgeInsets.only(left: 5,bottom: 10, top: 0,right: 5)
              ),
            ),
          ),
        )
            :
        InkWell(
          onTap: onTap,
          child: Container(
              height: 45,
              width: double.infinity,
              padding: const EdgeInsets.only(left: 16,top: 8,right: 16,bottom: 7),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(values.toString().replaceAll('null', ''),style: const TextStyle(fontSize: 12,color: Colors.black),maxLines: 1,)),
                  const Icon(EneftyIcons.search_normal_outline,size: 16,color: Colors.black,),
                ],
              )
          ),
        )
      ],
    );
  }

  String otherInfo = '';
  void saveInfo(){
    if(Const.typeProduction == true){
      if(Const.checkPriceAddToCard == true){
        if(priceInput <= 0){
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, sản phẩm này chưa có giá bán');
          return;
        }
      }
    }
    if(valueInput > 0){
      if(widget.inventoryStore == true){
        saveOtherInfo();
      }
      else{
        if(Const.inStockCheck == false){
          if(Const.typeProduction == true && !typeValues.contains('Thường')){
            saveOtherInfo();
          }
          else{
            if(valueInput <= widget.quantityStock && valueInput !=0){
              saveOtherInfo();
            }
            else{
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vượt quá số lượng hiện có rồi');
            }
          }
        }
        else if(Const.inStockCheck == true){
          if(Const.typeProduction == true && typeValues.contains('Thường')){
            if(valueInput <= widget.quantityStock && valueInput !=0){
              saveOtherInfo();
            }
            else{
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vượt quá số lượng hiện có rồi');
            }
          }
          else{
            saveOtherInfo();
          }
        }
      }
    }
    else{
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn không được để trống hoặc bằng 0');
    }
  }

  saveOtherInfo(){
    if(_orderBloc.listHeaderData.isNotEmpty){
      List<ListObjectJson> listEntityClass = [];
      for (var element in _orderBloc.listHeaderData) {
        ListObjectJson entityItem = ListObjectJson(
            key: element.colName.toString().trim(),
            values: element.textEditingController.text
        );
        listEntityClass.add(entityItem);
      }
      otherInfo = json.encode(listEntityClass);
    }
    print(widget.listDvt.join(','));
    Navigator.pop(context,[
      valueInput,
      unitOfCalculation,
      codeStore,
      nameStore,
      priceInput,
      typeValues.contains('Sản xuất') ? 1 : typeValues.contains('Chế biến') ? 2 : 0,
      giaGui,
      nameProductionEdited,
      codeUnit,
      nameUnit,
      note,
      otherInfo,
      unitTransfer,
      idNVKD,
      nameNVKD,
      nuocsxController.text,
      quycachController.text,
      widget.listDvt.join(',')
    ]);
  }
  Widget genderStore() {
    // ✅ Kiểm tra xem có đang thêm sản phẩm tặng không (dựa vào title)
    final isGiftProduct = widget.title.toString().contains('tặng') || widget.title.toString().contains('Tặng');
    
    // ✅ Nếu là sản phẩm tặng, dùng lockStockInItemGift; nếu không, dùng lockStockInItem
    final isLocked = isGiftProduct ? Const.lockStockInItemGift : Const.lockStockInItem;
    
    // ✅ Luôn hiển thị thông tin kho (nếu đã chọn)
    // Chỉ disable chức năng chọn kho khi bị khóa
    if (isLocked == true) {
      // Bị khóa: Chỉ hiển thị kho đã chọn (nếu có), không cho phép chọn mới
      return nameStore.toString().trim().isNotEmpty && nameStore.toString().trim() != 'null'
          ? Align(
              alignment: Alignment.centerLeft,
              child: Text(
                nameStore.toString().trim(),
                style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '',
                style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
    }
    
    // Không bị khóa: Cho phép chọn kho
    return widget.listStock.isEmpty
        ? const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hết kho khả dụng',
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : PopupMenuButton(
            shape: const TooltipShape(),
            padding: EdgeInsets.zero,
            offset: const Offset(0, 40),
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<Widget>>[
                PopupMenuItem<Widget>(
                  child: Container(
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    height: 250,
                    width: 320,
                    child: Scrollbar(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 10,),
                        itemCount: widget.listStock.length,
                        itemBuilder: (context, index) {
                          final trans = widget.listStock[index].tenKho.toString().trim();
                          return ListTile(
                            minVerticalPadding: 1,
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    trans.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                                Text(
                                    'Tồn: ${widget.listStock[index].ton13.toString().trim()}',
                                    style: const TextStyle(color: Colors.blueGrey, fontSize: 12))
                              ],
                            ),
                            subtitle: const Divider(height: 1,),
                            onTap: () {
                              nameStore = widget.listStock[index].tenKho.toString().trim();
                              codeStore = widget.listStock[index].maKho.toString().trim();
                              setState(() {});
                              // FocusScope.of(context).requestFocus(focusNodeContent);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ];
            },
            child: SizedBox(
                height: 35, //width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    nameStore.toString().trim(),
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
          );
  }

  Widget genderUnitOfCalculation() {
    return widget.listDvt.isEmpty
        ? const Align(alignment: Alignment.centerLeft,child: Text('',style: TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 1,overflow: TextOverflow.ellipsis,))
        : PopupMenuButton(
      shape: const TooltipShape(),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Widget>>[
          PopupMenuItem<Widget>(
            child: Container(
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              height: 250,
              width: 320,
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10,),
                  itemCount: widget.listDvt.length,
                  itemBuilder: (context, index) {
                    final trans = widget.listDvt[index].toString().trim();
                    return ListTile(
                      minVerticalPadding: 1,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              trans.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              maxLines: 1,overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                      subtitle:const Divider(height: 1,),
                      onTap: () {
                        setState(() {
                          unitOfCalculation = widget.listDvt[index].toString().trim();
                        });
                        // FocusScope.of(context).requestFocus(focusNodeContent);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ];
      },
      child: SizedBox(
          height: 35,//width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(unitOfCalculation.toString().trim().replaceAll('null', ''),style: const TextStyle(color: Colors.blueGrey,fontSize: 13),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),)),
    );
  }

  Widget genderManyUnitAllow() {
    // Nếu cấu hình KHÔNG cho phép nhiều đơn vị tính → không hiển thị popup chọn
    if (Const.manyUnitAllow != true) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '',
          style: TextStyle(color: Colors.blueGrey, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return widget.listQuyDoiDonViTinh.isEmpty
        ? const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '',
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : PopupMenuButton(
      shape: const TooltipShape(),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Widget>>[
          PopupMenuItem<Widget>(
            child: Container(
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              height: 250,
              width: 320,
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10,),
                  itemCount: widget.listQuyDoiDonViTinh.length,
                  itemBuilder: (context, index) {
                    final trans = widget.listQuyDoiDonViTinh[index].dvt.toString().trim();
                    return ListTile(
                      minVerticalPadding: 1,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              trans.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              maxLines: 1,overflow: TextOverflow.fade,
                            ),
                          ),
                          Text(
                              'HS: ${(widget.listQuyDoiDonViTinh[index].heSo.toString().trim().replaceAll('null', '').isNotEmpty ? widget.listQuyDoiDonViTinh[index].heSo.toString().trim() : '1')}', style: const TextStyle(color: Colors.blueGrey,fontSize: 12))
                        ],
                      ),
                      subtitle:const Divider(height: 1,),
                      onTap: () {
                        unitOfCalculation = widget.listQuyDoiDonViTinh[index].dvt.toString().trim();
                        unitTransfer = (widget.listQuyDoiDonViTinh[index].heSo.toString());
                        setState(() {});
                        // FocusScope.of(context).requestFocus(focusNodeContent);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ];
      },
      child: SizedBox(
          height: 35,//width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(unitOfCalculation.toString().trim().replaceAll('null', ''),style: const TextStyle(color: Colors.blueGrey,fontSize: 13),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),)),
    );
  }

  Widget genderTypes() {
    return
    PopupMenuButton(
      shape: const TooltipShape(),
      padding: EdgeInsets.zero,
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<Widget>>[
          PopupMenuItem<Widget>(
            child: Container(
              decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              height: 250,
              width: 320,
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 10,),
                  itemCount: listType.length,
                  itemBuilder: (context, index) {
                    final trans = listType[index].toString().trim();
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              trans.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              maxLines: 1,overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                      subtitle: const Divider(height: 1,),
                      onTap: () {
                        setState(() {
                          typeValues = trans;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ];
      },
      child: SizedBox(
          height: 20,//width: double.infinity,
          child: Const.isGiaGui == true ?
            Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(child: Text(typeValues.toString(),style: const TextStyle(color: Colors.blueGrey,fontSize: 12),)),
              const SizedBox(width: 10,),
              const Icon(EneftyIcons.arrow_bottom_outline)
            ],
          )
              : Align(
              alignment: Alignment.centerLeft,
              child: Text(typeValues.toString().trim(),style: const TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),)),
    );
  }

  dateTimeOther(BuildContext context,int index){
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: SizedBox(
        height: 55,
        child: Column(
          children: [
            Row(
              children: [
                Text(_orderBloc.listHeaderData[index].title?.trim()??'',
                    style: TextStyle(fontSize: 11, color: _orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey)),
                const SizedBox(width: 4,),
                Visibility(
                    visible: _orderBloc.listHeaderData[index].nullable == false ,
                    child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
              ],
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: Container(
                padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: grey.withOpacity(0.8),width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(8))
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          const SizedBox(width: 5,),
                          Text(_orderBloc.listHeaderData[index].textEditingController.text.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                        child: InkWell(
                          onTap: (){
                            Utils.dateTimePickerCustom(context).then((value){
                              if(value != null){
                                setState(() {
                                  _orderBloc.listHeaderData[index].textEditingController = TextEditingController();
                                  _orderBloc.listHeaderData[index].textEditingController.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  _orderBloc.listHeaderData[index].textEditingController.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  _orderBloc.listHeaderData[index].selectValue = ReportFieldLookupResponseData(
                                    code: _orderBloc.listHeaderData[index].textEditingController.text,
                                    name: _orderBloc.listHeaderData[index].textEditingController.text,
                                  );
                                  _orderBloc.listHeaderData[index].c  = true;
                                });
                              }
                            });
                          },
                          child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dateTimeFrom(BuildContext context,int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: SizedBox(
        height: 55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Từ ngày',
                    style: TextStyle(fontSize: 11, color: _orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey)),
                const SizedBox(width: 4,),
                Visibility(
                    visible: _orderBloc.listHeaderData[index].nullable == false ,
                    child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
              ],
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: Container(
                padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: grey.withOpacity(0.8),width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(8))
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          const Text('Từ ngày: ',style:  TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                          const SizedBox(width: 5,),
                          Text(_orderBloc.listHeaderData[index].textEditingController.text.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                        child: InkWell(
                          onTap: (){
                            Utils.dateTimePickerCustom(context).then((value){
                              if(value != null){
                                setState(() {
                                  _orderBloc.listHeaderData[index].textEditingController.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  _orderBloc.listHeaderData[index].selectValue =  ReportFieldLookupResponseData(code: _orderBloc.listHeaderData[index].textEditingController.text, name: _orderBloc.listHeaderData[index].textEditingController.text,);
                                  _orderBloc.listHeaderData[index].c  = true;
                                });
                              }
                            });
                          },
                          child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dateTimeTo(BuildContext context,int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 25,bottom: 10),
      child: SizedBox(
        height: 55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Tới ngày',
                    style: TextStyle(fontSize: 11, color: _orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey)),
                const SizedBox(width: 4,),
                Visibility(
                    visible: _orderBloc.listHeaderData[index].nullable == false ,
                    child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
              ],
            ),
            const SizedBox(height: 5,),
            Expanded(
              child: Container(
                padding:const EdgeInsets.only(left: 12,right: 2,top: 10,bottom: 10),
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: grey.withOpacity(0.8),width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(8))
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: [
                          const Text('Tới ngày: ',style:  TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,),
                          const SizedBox(width: 5,),
                          Text(_orderBloc.listHeaderData[index].textEditingController.text.toString(),style: const TextStyle(color: Colors.black,fontSize: 12),textAlign: TextAlign.center,maxLines: 1,overflow: TextOverflow.ellipsis,),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                        child: InkWell(
                          onTap: (){
                            Utils.dateTimePickerCustom(context).then((value){
                              if(value != null){
                                setState(() {
                                  _orderBloc.listHeaderData[index].textEditingController.text = Utils.parseStringDateToString(value.toString(), Const.DATE_TIME_FORMAT,Const.DATE_SV_FORMAT);
                                  _orderBloc.listHeaderData[index].selectValue = ReportFieldLookupResponseData(code: _orderBloc.listHeaderData[index].textEditingController.text, name: _orderBloc.listHeaderData[index].textEditingController.text,);
                                  _orderBloc.listHeaderData[index].c  = true;
                                });
                              }
                            });
                          },
                          child: const Icon(Icons.event,color: Colors.blueGrey,size: 22,),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterLookup(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: SizedBox(
        height: 50,
        child: Column(
          children: [
            Visibility(
              visible: _orderBloc.listHeaderData[index].selectValue != null ||
                  _orderBloc.listHeaderData[index].defaultValue != null,
              child: Row(
                children: [
                  Text('${_orderBloc.listHeaderData[index].title}',style: TextStyle(color: _orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey,fontSize: 11),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: _orderBloc.listHeaderData[index].nullable == false ,
                      child: const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  isEnable: false,
                  textInputAction: TextInputAction.done,
                  controller: _orderBloc.listHeaderData[index].textEditingController,
                  isNull : _orderBloc.listHeaderData[index].nullable ,
                  color: _orderBloc.listHeaderData[index].selectValue != null ? black : Colors.grey,
                  onChanged: (text){
                    _orderBloc.listHeaderData[index].listItemPush = text;
                  },
                  labelText: _orderBloc.listHeaderData[index].selectValue != null ? null
                      : (
                      _orderBloc.listHeaderData[index].defaultValue ?? _orderBloc.listHeaderData[index].title),

                ),
                Positioned(
                    top: 0,right: 0,bottom: 1,
                    child: Container(
                      height: 50,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8)
                      ),
                      child: InkWell(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (context) => OptionReportFilter(controller: _orderBloc.listHeaderData[index].controller!,
                                  listItem: _orderBloc.listHeaderData[index].listItemPush != null
                                      ?
                                  _orderBloc.listHeaderData[index].listItemPush.toString() : '',show: true,)).then((value) {//listItem: widget.listRPLayout[index].selectValue.code
                              if (value != null) {
                                setState(() {
                                  List<String> geek = <String>[];
                                  _orderBloc.listHeaderData[index].listItem = value;
                                  _orderBloc.listHeaderData[index].listItem?.forEach((element) {
                                    ///sau co sửa code hay name thì tuỳ
                                    geek.add(element.code.toString().trim());
                                  });
                                  String geek2 = geek.join(",");
                                  _orderBloc.listHeaderData[index].textEditingController = TextEditingController();
                                  _orderBloc.listHeaderData[index].textEditingController.text = geek2;
                                  _orderBloc.listHeaderData[index].listItemPush = geek2;
                                  _orderBloc.listHeaderData[index].selectValue =  ReportFieldLookupResponseData(code: geek2, name: '',);
                                  // widget.listRPLayout[index].listItem = value;
                                  _orderBloc.listHeaderData[index].c = true;
                                });
                              }
                            });
                          },
                          child: const Icon(Icons.search)),
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget textInput(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Container(
        color: Colors.transparent,
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              // visible: _orderBloc.listHeaderData[index].selectValue != null || _orderBloc.listHeaderData[index].defaultValue != null,
              child: Row(
                children: [
                  Text('${_orderBloc.listHeaderData[index].title}',style: TextStyle(color: _orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey,fontSize: 13),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: _orderBloc.listHeaderData[index].nullable == false ,
                      child: const Text('*',style: TextStyle(fontSize: 12,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  isEnable: true,
                  controller: _orderBloc.listHeaderData[index].textEditingController,
                  isNull : _orderBloc.listHeaderData[index].nullable ,
                  color: _orderBloc.listHeaderData[index].selectValue != null ? black : (_orderBloc.listHeaderData[index].defaultValue != null ? Colors.grey : Colors.black) ,//,
                  hintText: 'Vui lòng nhập thông tin',
                  onChanged: (text){
                    _orderBloc.listHeaderData[index].selectValue =  ReportFieldLookupResponseData(code: text, name: text,);
                    _orderBloc.listHeaderData[index].c = true;
                  },
                ),
                const Positioned(
                    top: 0,right: 0,bottom: 0,
                    child: SizedBox(
                      height: 50,
                      width: 40,
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget numberInput(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 45,
        child: Column(
          children: [
            Visibility(
              // visible: _orderBloc.listHeaderData[index].selectValue != null || _orderBloc.listHeaderData[index].defaultValue != null,
              child: Row(
                children: [
                  Text('${_orderBloc.listHeaderData[index].title}',style: TextStyle(color: _orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey,fontSize: 13),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: _orderBloc.listHeaderData[index].nullable == false ,
                      child: const Text('*',style: TextStyle(fontSize: 12,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  isEnable: true,
                  controller: _orderBloc.listHeaderData[index].textEditingController,
                  isNull : _orderBloc.listHeaderData[index].nullable ,
                  color: _orderBloc.listHeaderData[index].selectValue != null ? black : _orderBloc.listHeaderData[index].defaultValue != null ? Colors.grey : Colors.black ,
                  hintText: (_orderBloc.listHeaderData[index].defaultValue ?? _orderBloc.listHeaderData[index].title),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  inputFormatter: [Const.FORMAT_DECIMA_NUMBER],
                  onChanged: (text){
                    _orderBloc.listHeaderData[index].selectValue =  ReportFieldLookupResponseData(code: text, name: text,);
                    _orderBloc.listHeaderData[index].c = true;
                  },
                ),
                const Positioned(
                    top: 0,right: 0,bottom: 0,
                    child: SizedBox(
                      height: 50,
                      width: 40,
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget filterAutoComplete(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Visibility(
              // visible: _orderBloc.listHeaderData[index].selectValue != null || _orderBloc.listHeaderData[index].defaultValue != null,
              child: Row(
                children: [
                  Text('${_orderBloc.listHeaderData[index].title}',style: TextStyle(color: _orderBloc.listHeaderData[index].nullable == false? Colors.red : Colors.grey,fontSize: 11),),
                  const SizedBox(width: 4,),
                  Visibility(
                      visible: _orderBloc.listHeaderData[index].nullable == false ,
                      child:const Text('*',style: TextStyle(fontSize: 11,color: Colors.red),)),
                ],
              ),
            ),
            Stack(
              children: [
                TextFieldWidget2(
                  maxLine: 1,
                  isEnable: true,
                  textInputAction: TextInputAction.done,
                  isNull : _orderBloc.listHeaderData[index].nullable ,
                  color: _orderBloc.listHeaderData[index].selectValue != null ? black : Colors.grey,
                  controller: _orderBloc.listHeaderData[index].textEditingController,
                  onChanged: (text){
                    _orderBloc.listHeaderData[index].textEditingController = TextEditingController();
                    _orderBloc.listHeaderData[index].textEditingController.text = text!;
                  },
                  labelText: _orderBloc.listHeaderData[index].selectValue != null ?
                  null
                      : (_orderBloc.listHeaderData[index].defaultValue ?? _orderBloc.listHeaderData[index].title),
                ),
                Positioned(
                    top: 0,right: 0,bottom: 1,
                    child: Container(
                      height: 50,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8)
                      ),
                      child: InkWell(
                          onTap: (){
                            showDialog(
                                context: context,
                                builder: (context) => OptionReportFilter(controller: _orderBloc.listHeaderData[index].controller!,show: false, listItem: '',)).then((value) {
                              if (value != null) {
                                setState(() {
                                  _orderBloc.listHeaderData[index].textEditingController = TextEditingController();
                                  _orderBloc.listHeaderData[index].textEditingController.text =  '${value[0].toString().trim()} ( ${value[1].toString().trim()} )';
                                  _orderBloc.listHeaderData[index].selectValue =  ReportFieldLookupResponseData(code: value[0].toString(), name: value[1].toString(),);
                                  _orderBloc.listHeaderData[index].c = true;
                                });
                              }
                            });
                          },
                          child:const Icon(Icons.search,size: 18,)),
                    )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
