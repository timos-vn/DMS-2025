import 'dart:convert';

import 'package:dms/screen/qr_code/qr_code_bloc.dart';
import 'package:dms/screen/qr_code/qr_code_sate.dart';
import 'package:dms/widget/barcode_scanner_widget.dart';
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../model/network/request/item_location_modify_requset.dart';
import '../../../model/network/response/qr_code_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import '../qr_code_event.dart';

class UpdateItemPosition extends StatefulWidget {

  const UpdateItemPosition({Key? key}) : super(key: key);

  @override
  State<UpdateItemPosition> createState() => _UpdateItemPositionState();
}

class _UpdateItemPositionState extends State<UpdateItemPosition> {


  String idLocation = '';
  late QRCodeBloc _bloc;


  bool checkItemExits = false;

  bool viewQRCode = true;
  int indexSelected = -1;
  QrcodeResponse qrcodeResponse = QrcodeResponse();
  List<ItemLocationModifyRequestDetail> listItem = [];
  int typeNXT = 1;
  String currentDecodingTypeName = 'Nhập hàng';
  final List<String> codecTypeNames = [
    'Nhập hàng',
    'Xuất hàng',
  ];

  String valuesBarcode = '';
  bool isProcessing = false;
  
  // ✅ Camera instance riêng cho màn hình này
  final GlobalKey _cameraKey = GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = QRCodeBloc(context);

  }

  @override
  void dispose() {
    // ✅ Stop camera safely when leaving the screen
    try {
      (_cameraKey.currentState as dynamic)?.stopCamera();
      debugPrint('=== UpdateItemPosition: Camera stopped in dispose ===');
    } catch (e) {
      debugPrint('=== UpdateItemPosition: Error stopping camera in dispose: $e ===');
    }
    
    _bloc.close();
    super.dispose();
  }

  void handleBarcodeScan(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    if(valuesBarcode.toString().trim() != code.toString().trim() && valuesBarcode.toString().trim() != 'qrcode'){
      valuesBarcode = '';
    }else if(describeEnum(valuesBarcode).toString().trim() != 'qrcode'){
      valuesBarcode = code.toString().trim();
    }
    if(describeEnum(valuesBarcode).toString().trim() != 'qrcode' && valuesBarcode.toString().trim() != code.toString().trim()){
      _bloc.add(GetInformationItemFromBarCodeEvent(barcode: code.toString(), pallet: ''));
    }
    else{
      final body = json.decode(code);
      qrcodeResponse = QrcodeResponse.fromJson(body);
      idLocation = qrcodeResponse.maVt.toString().trim();
      Utils.showCustomToast(context, Icons.check_circle_outline, 'Vị trí: $idLocation');
      if(listItem.isNotEmpty){
        for (var element in listItem) {
          element.maViTri = idLocation.toString();
        }
      }
      _bloc.add(RefreshUpdateItemBarCodeEvent());
    }

    await Future.delayed(const Duration(milliseconds: 1000));
    isProcessing = false;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey_100,
      body: BlocListener<QRCodeBloc,QRCodeState>(
        bloc: _bloc,
        listener: (context,state){
         if(state is QRCodeFailure){
            Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
          }
          if(state is ItemLocationModifySuccess){
            listItem.clear();
            idLocation = '';
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật thành công');
          }
          else if(state is GetInformationItemFromBarCodeSuccess){
            ItemLocationModifyRequestDetail item = ItemLocationModifyRequestDetail(
              maVt: _bloc.informationProduction.maVt.toString().trim(),
              maViTri: idLocation.toString(),
              soLuong: _bloc.informationProduction.soLuong,
              nxt: typeNXT,
              teVt: _bloc.informationProduction.tenVt.toString().trim(),
                qrCode: _bloc.informationProduction.maIn.toString().trim()
            );

            if(listItem.isNotEmpty){
              for (var element in listItem) {
                if(element.maVt.toString().trim() == _bloc.informationProduction.maVt.toString().trim()){
                  element.maViTri = idLocation.toString();
                  checkItemExits = true;
                  break;
                }
              }
              if(checkItemExits == false){
                listItem.add(item);
              }
            }
            else{
              listItem.add(item);
            }
            checkItemExits = false;
            _bloc.add(RefreshUpdateItemBarCodeEvent());
          }
        },
        child: BlocBuilder<QRCodeBloc,QRCodeState>(
            bloc: _bloc,
            builder: (BuildContext context,QRCodeState state){
              return  Stack(
                children: [
                  buildScreen(context, state),
                  Visibility(
                    visible: state is QRCodeLoading,
                    child: const PendingAction(),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }

  buildScreen(context,QRCodeState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          buildAppBar(),
          Visibility(
            visible: viewQRCode == true,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                height: 200, width: double.infinity,
                child: buildCamera(),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          Container(
            height: 45,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
            padding: const EdgeInsets.only(left: 8,right: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: grey, width: 1)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Loại cập nhật',
                    style: TextStyle(fontSize: 13,color: accent)),
                DropdownButton<String>(
                    value: currentDecodingTypeName,
                    icon: const Icon(Icons.arrow_drop_down, color: subColor),
                    iconSize: 24, elevation: 16,
                    style: const TextStyle(color: Colors.black, fontSize: 13),
                    underline: Container(
                      height: 1,
                      color: subColor,
                    ),
                    onChanged: (data) {
                      if (data != null) {
                        setState(() {
                          currentDecodingTypeName = data;
                          if(currentDecodingTypeName == 'Nhập hàng'){
                            typeNXT = 1;
                          }else{
                            typeNXT = 2;
                          }
                        });
                      }
                    },
                    items: codecTypeNames
                        .map<DropdownMenuItem<String>>(
                            (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                                color: e == currentDecodingTypeName
                                    ? subColor
                                    : null),
                          ),
                        ))
                        .toList()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12,top: 16,bottom: 10),
            child: Row(
              children: [
                const Icon(EneftyIcons.location_add_outline,size: 20,color: accent,),
                const SizedBox(width: 15,),
                Text('Vị trí Nhập/Xuất hàng: $idLocation',style: const TextStyle(color: subColor,fontSize: 15,fontWeight: FontWeight.bold),),
              ],
            ),
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.only(left: 3,right: 3),
                        child: Text(
                          'Danh sách sản phẩm',
                          style: TextStyle(fontWeight: FontWeight.normal,color: Colors.blueGrey),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  Expanded(
                    child: listItem.isNotEmpty ?  ListView.separated(
                        key: const Key('KeyList2'),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemBuilder: (_, index) {
                          return Slidable(
                            key: const ValueKey(1),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              dragDismissible: false,
                              children: [
                                SlidableAction(
                                  onPressed:(_) {
                                    showDialog(
                                        barrierDismissible: true,
                                        context: context,
                                        builder: (context) {
                                          return const InputQuantityShipping(title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
                                        }).then((values){
                                      if(values != null){
                                        setState(() {
                                          listItem[index].soLuong = double.parse(values[0]??'0');
                                        });
                                        Utils.showCustomToast(context, EneftyIcons.check_outline, 'Cập nhật thành công');
                                      }
                                    });
                                  },
                                  borderRadius:const BorderRadius.all(Radius.circular(8)),
                                  padding:const EdgeInsets.all(10),
                                  backgroundColor: Colors.indigoAccent,
                                  foregroundColor: Colors.white,
                                  icon: EneftyIcons.card_edit_outline,
                                  label: 'Sửa',
                                ),
                                SlidableAction(
                                  onPressed:(_) {
                                    setState(() {
                                      listItem.removeAt(index);
                                    });
                                    Utils.showCustomToast(context, EneftyIcons.trash_outline, 'Xoá thành công');
                                  },
                                  borderRadius:const BorderRadius.all(Radius.circular(8)),
                                  padding:const EdgeInsets.all(10),
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  icon: EneftyIcons.trash_outline,
                                  label: 'Xoá',
                                ),
                              ],
                            ),
                            child: Card(
                              semanticContainer: true,
                              margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '[${listItem[index].maVt}] ${listItem[index].teVt}',
                                            style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                                            maxLines: 2,overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 5,),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 6,bottom: 5),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const Icon(EneftyIcons.card_pos_outline,color: Colors.grey,size: 15,),
                                                const SizedBox(width: 5,),
                                                Expanded(
                                                  child: Text('${listItem[index].qrCode}',
                                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 6,bottom: 5),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                const Icon(EneftyIcons.calendar_remove_outline,color: Colors.grey,size: 15,),
                                                const SizedBox(width: 5,),
                                                Text('Số lượng: ${listItem[index].soLuong}',
                                                  textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) {
                          return const SizedBox(height: 8);
                        },
                        itemCount: listItem.length) : const Center(child: Text('Danh sách trống'),),
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                ],
              )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 10),
            child: GestureDetector(
              onTap: (){
                if(listItem.isNotEmpty && idLocation.isNotEmpty){
                  _bloc.add(ItemLocationModifyEvent(listItem: listItem, typeFunction: '2'));
                }else{
                  Utils.showCustomToast(context, Icons.warning_amber, 'Úi, Kiểm tra lại thông tin bạn êi');
                }

              },
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24)
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Xác nhận'
                      ,style: TextStyle(color: Colors.white),),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  customPayment({required String title,required String value}){
    return Padding(
      padding: const EdgeInsets.only(left: 12,right: 12,bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
          Text(value,style: const TextStyle(color: subColor,fontWeight: FontWeight.bold),),
        ],
      ),
    );
  }

  customView(IconData icon, String title, bool showDivider, FontWeight fontWeight){
    return Padding(
      padding: EdgeInsets.only(left: 12,right: 0,bottom: showDivider == true ? 5 : 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 18,),
              Text(title,
                style: TextStyle(fontWeight: fontWeight,color: subColor),
              ),
            ],
          ),
          SizedBox(height: showDivider == true ? 5 : 10,),
          Visibility(
              visible: showDivider == true,
              child: const Divider(color: Colors.grey))
        ],
      ),
    );
  }

  buildCamera(){
    return BarcodeScannerWidget(
      key: _cameraKey,
      onBarcodeDetected: handleBarcodeScan,
    );
  }

  buildAppBar(){
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor,Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(5, 35, 12,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){

              Navigator.pop(context);
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: InkWell(
                onTap: (){
                  setState(() {
                    viewQRCode = false;
                    // ✅ Camera sẽ được quản lý bởi widget riêng của màn hình
                  });
                  var formatter = NumberFormat('#,##,000');
                  print(formatter.format(16987));
                  print(NumberFormat('#,##0').format(231548));
                  print(NumberFormat('#,##0.00').format(231548));
                  print(NumberFormat('#,##0').format(231548));
                  print(NumberFormat('#,##0.00').format(231548));
                  print(NumberFormat('#,##0.00000').format(231548));
                  print(NumberFormat(Const.amountFormat).format(231548));
                  print('02315123555482B920231211'.substring(16,24));
                  DateTime dateTime = DateTime.parse('02315123555482B920231211'.substring(16,24));
                  print(dateTime.toString());
                },
                child: const Text(
                  'Cập nhật vị trí cho vật tư',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                  maxLines: 1,overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.event,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }
}
