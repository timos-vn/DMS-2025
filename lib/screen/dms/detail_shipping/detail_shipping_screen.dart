import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:dms/model/network/request/order_create_checkin_request.dart';
import 'package:dms/screen/dms/detail_shipping/widget/barcode_scanner_popup.dart';
import 'package:dms/widget/custom_camera.dart';
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dms/screen/dms/detail_shipping/detail_shipping_state.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../../custom_lib/view_only_image.dart';
import '../../../driver_transfer/helper/location_service.dart';
import '../../../model/database/data_local.dart';
import '../../../model/network/response/get_item_detail_shipping_response.dart';
import '../../../model/network/response/list_status_order_response.dart';
import '../../../utils/const.dart';
import '../../../utils/images.dart';
import 'detail_shipping_bloc.dart';
import 'detail_shipping_event.dart';

class DetailShippingScreen extends StatefulWidget {
  final String? sttRec;
  final String? maCT;
  final String? nameCustomer;
  const DetailShippingScreen({Key? key,this.sttRec,this.maCT,this.nameCustomer}) : super(key: key);

  @override
  _DetailShippingScreenState createState() => _DetailShippingScreenState();
}

class _DetailShippingScreenState extends State<DetailShippingScreen> {

  late DetailShippingBloc _bloc;
  bool confirm = false;
  String statusValues = '';
  late LatLng current;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = DetailShippingBloc(context);
    _bloc.currentAddress = '';
    _bloc.add(GetPrefs());
    if(DataLocal.listStatus.isNotEmpty == true){
      currentCodecStatus = DataLocal.listStatus[0];
      idStatus = currentCodecStatus.status.toString();
    }
  }

  void init(StateSetter myState)async{
    location.getLocation().then((onValue)async{
      current = LatLng(onValue.latitude!, onValue.longitude!);
      List<Placemark> placePoint = await placemarkFromCoordinates(onValue.latitude!, onValue.longitude!);
      String currentAddress1 = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
      _bloc.lat = onValue.latitude!.toString();
      _bloc.long = onValue.longitude!.toString();
      _bloc.currentAddress = currentAddress1;
      myState(()=>print('New: ${_bloc.currentAddress}'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: confirm == true
            ?
        FloatingActionButton(
          onPressed:() {
            confirmShippingEvent(context: context,title: 'Xác nhận phiếu giao vận');
          } ,
          backgroundColor: subColor,
          tooltip: 'Increment',
          child: const Icon(Icons.check,color: Colors.white,),
        )
            :
        Container(),
      ),
      body: BlocListener<DetailShippingBloc, DetailShippingState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            _bloc.add(GetItemShippingEvent(widget.sttRec.toString()));
          }
          else if(state is ConfirmShippingSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Xác nhận thành công');
            Navigator.pop(context);
          }else if(state is GetItemShippingSuccess){
            for (var element in DataLocal.listStatus) {
              if(element.status.toString().trim().replaceAll('null', '') == _bloc.masterItem?.status.toString().trim().replaceAll('null', '')){
                statusValues = element.statusname.toString().trim().replaceAll('null', '');
                break;
              }
            }
            confirm = _bloc.masterItem?.status == "0" ? true :  false;
            setState(() {});
          }else if(state is DetailShippingFailure){
            Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString().trim());
          }
          else if(state is UpdateLocationAndImageSuccess){
            _bloc.add(ConfirmShippingEvent(
                sstRec:  _bloc.masterItem?.sttRec,
                status: int.parse(idStatus),
                typePayment: idTypePayment,
                desc: _noteController.text,
                soPhieuXuat: _bloc.masterItem?.qrYN == 1 ? soPhieuXuat : ''
            ));
          }
          else if(state is UploadImageProgress){
            // ✅ Hiển thị progress dialog khi upload ảnh
            _showUploadProgressDialog(context, state.progress, state.message);
          }
          else if(state is UploadImageFailure){
            // ✅ Hiển thị popup retry khi upload thất bại
            _showUploadRetryDialog(context, state.error);
          }
        },
        child: BlocBuilder<DetailShippingBloc, DetailShippingState>(
          bloc: _bloc,
          builder: (BuildContext context,DetailShippingState state){
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is GetListShippingEmpty,
                  child: const Center(
                    child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                  ),
                ),
                Visibility(
                  visible: state is DetailShippingLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,DetailShippingState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: Column(
              children: [
                Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        const SizedBox(
                          height: 35,
                          child: Center(child: Text(' Tổng số lượng ')),
                        ),
                        SizedBox(
                          height: 35,
                          child:Center(child: Text('${_bloc.masterItem?.tSoLuong} SP',style: const TextStyle(fontSize: 12,color: Colors.black),textAlign: TextAlign.center,maxLines: 2,overflow: TextOverflow.ellipsis,)) ,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const SizedBox(
                          height: 35,
                          child: Center(child: Text(' Tổng thanh toán ')),
                        ),
                        SizedBox(
                          height: 35,
                          child:Center(child: Text('${Utils.formatMoney(_bloc.masterItem?.tTtNt??0).toString()} VNĐ',style: const TextStyle(fontSize: 12,color: Colors.black),textAlign: TextAlign.center,maxLines: 2,overflow: TextOverflow.ellipsis,)) ,
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const SizedBox(
                          height: 35,
                          child: Center(child: Text(' Trạng thái ')),
                        ),
                        SizedBox(
                          height: 35,
                          child:Center(child: Text(statusValues.toString(),style: const TextStyle(fontSize: 12.5,color: Colors.purple),textAlign: TextAlign.center,maxLines: 2,overflow: TextOverflow.ellipsis,)) ,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Text('Danh sách chi tiết',style: TextStyle(color:Colors.blueGrey,fontSize: 12),),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      // controller: _scrollController,
                      padding: EdgeInsets.zero,
                      separatorBuilder: (BuildContext context, int index)=>Container(),
                      itemBuilder: (BuildContext context, int index){
                        return GestureDetector(
                            onTap: (){
                              showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) {
                                    return InputQuantityShipping(quantity: _bloc.listItemDetailShipping[index].soLuong ,title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
                                  }).then((values){
                                if(values != null){
                                  for (var element in _bloc.listItemDetailShipping) {
                                    if(element.sttRec0.toString().trim() == _bloc.listItemDetailShipping[index].sttRec0.toString().trim()){
                                      setState(() {
                                        _bloc.listItemDetailShipping[index].soLuongGiao = double.parse(values[0]??'0');
                                      });
                                    }
                                  }
                                }
                              });
                            },
                            child: buildItem(_bloc.listItemDetailShipping[index]));
                      },
                      itemCount: _bloc.listItemDetailShipping.length //length == 0 ? length : _hasReachedMax ? length : length + 1,
                  ),
                ),
                const SizedBox(height: 55,)
              ],
            ),
          )
        ],
      ),
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
            onTap: ()=> Navigator.pop(context),
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
              child: Text(
                _bloc.masterItem?.tenKh?.toString()??'Chi tiết phiếu',
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 50,
            child: Icon(
              Icons.how_to_reg,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(DettailItemShipping item){
    return Padding(
      padding: const EdgeInsets.only(bottom: 6,top: 0,left: 10,right: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 10,
        child: Container(
          // color: subColor.withOpacity(0.2),
          padding: const EdgeInsets.only(left: 8,right: 8,top: 8,bottom: 8),
          width: double.infinity,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6), // Image border
                child: SizedBox.fromSize(
                  size: const Size.fromRadius(36), // Image radius
                  child: CachedNetworkImage(
                    imageUrl: img,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('[${item.maVt.toString().replaceAll('null', '')}] ${item.tenVt.toString().replaceAll('null', '')}',style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),maxLines: 4,overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: 5,),
                    Text(item.tenKho.toString().replaceAll('null', ''),style: const TextStyle(color: Colors.black,fontWeight: FontWeight.normal),maxLines: 2,overflow: TextOverflow.ellipsis,),
                    const SizedBox(height: 5,),
                    Text('Số lượng: ${item.soLuong} ${item.dvt}',style: const TextStyle(color: Colors.blueGrey,fontSize: 11),),
                    const SizedBox(height: 5,),
                    Text('Số lượng giao: ${item.soLuongGiao} ${item.dvt}',style: const TextStyle(color: Colors.blueGrey,fontSize: 11),),
                    const SizedBox(height: 5,),
                    Text('Số lượng đã giao: ${item.soLuongDaGiao} ${item.dvt}',style: const TextStyle(color: Colors.blueGrey,fontSize: 11),),
                    const SizedBox(height: 5,),
                    Text('Số lượng thực giao: ${item.soLuongThucGiao} ${item.dvt}',style: const TextStyle(color: Colors.blueGrey,fontSize: 11),),
                    const SizedBox(height: 5,),
                    Text('Tổng thanh toán: ${Utils.formatMoney(item.tienNt2)} VNĐ',style: const TextStyle(color: Colors.blueGrey,fontSize: 11),),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void confirmShippingEvent({
    required BuildContext context,
    required String title
  }){
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (builder){
          return StatefulBuilder(
            builder: (BuildContext context,StateSetter myState){
              return Container(
                height: (MediaQuery.of(context).size.height * 0.80) + (MediaQuery.of(context).viewInsets.bottom/1.5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25.0),
                    topRight: Radius.circular(25.0),
                  ),
                ),
                child:  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding:const EdgeInsets.only(left: 16,right: 16,top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                height: 5,
                                width: 60,
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.all(Radius.circular(24))
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: ()=>Navigator.pop(context),
                                      child: const SizedBox(
                                          height: 30,
                                          width: 40,
                                          child: Icon(Icons.clear,color: Colors.black,)),
                                    ),
                                    Text(title.toString(),style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                    GestureDetector(
                                      onTap: () => (_bloc.masterItem?.qrYN == 1 && Const.scanQRCodeForInvoicePXB) ?
                                        openScanner(context, myState) : null ,
                                      child: SizedBox(
                                          height: 30,
                                          width: 40,
                                          child: Icon(Icons.qr_code_scanner_outlined,color: (_bloc.masterItem?.qrYN == 1 && Const.scanQRCodeForInvoicePXB) ? Colors.black : Colors.transparent,)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 5,),
                                Container(
                                  height: 35,
                                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  padding: const EdgeInsets.only(left: 8,right: 20),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(child: Text('Loại thanh toán',
                                          style: TextStyle(fontSize: 13,color: accent)),),
                                      PopupMenuButton<String>(
                                        itemBuilder: (context){
                                          return codeTypePayment.map((e) => PopupMenuItem<String>(
                                                value: e,
                                                child: Text(
                                                  e.toString().trim(),
                                                  style: const TextStyle(color:subColor,fontSize: 13),
                                                ),
                                              ))
                                              .toList();
                                        },
                                          iconSize: 24, elevation: 16,
                                          onSelected: (data) {
                                            currentCodeTypePayment = data;
                                            if(currentCodeTypePayment.contains('Công nợ')){
                                              idTypePayment = 2;
                                            }else if(currentCodeTypePayment.contains('Tiền mặt')){
                                              idTypePayment = 1;
                                            }else{
                                              idTypePayment = 3;
                                            }
                                            myState(() {});
                                          },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currentCodeTypePayment.toString().trim(),
                                              style: const TextStyle(color:subColor,fontSize: 13),
                                            ),
                                            const Icon(Icons.arrow_drop_down, color: subColor),
                                          ],
                                        ),
                                          ),
                                    ],
                                  ),
                                ),
                                DataLocal.listStatus.isNotEmpty == true
                                    ?
                                Container(
                                  height: 35,
                                  margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                  padding: const EdgeInsets.only(left: 8,right: 20),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(7),),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(child: Text('Trạng thái phiếu',
                                          style: TextStyle(fontSize: 13,color: accent)),),
                                      PopupMenuButton<ListStatusOrderResponseData>(
                                          itemBuilder: (context){
                                            return DataLocal.listStatus.map((e) => PopupMenuItem<ListStatusOrderResponseData>(
                                              value: e,
                                              child: Text(
                                                e.statusname.toString().trim(),
                                                style: const TextStyle(color:subColor,fontSize: 13),
                                              ),
                                            ))
                                                .toList();
                                          },
                                          iconSize: 24, elevation: 16,
                                          onSelected: (data) {
                                            currentCodecStatus = data;
                                            idStatus = currentCodecStatus.status.toString();
                                            // print('id: $idStatus - name: ${currentCodecStatus.statusname.toString()}');
                                            myState(() {
                                            });
                                          },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              currentCodecStatus.statusname.toString().trim(),
                                              style: const TextStyle(color:subColor,fontSize: 13),
                                            ),
                                            const Icon(Icons.arrow_drop_down, color: subColor),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                                    :
                                Container(),
                                const SizedBox(height: 7,),
                                Visibility(
                                  visible: _bloc.masterItem?.qrYN == 1 && Const.scanQRCodeForInvoicePXB,
                                  child: Text('Số phiếu xuất: ${soPhieuXuat.toString().replaceAll('null', '')}'),
                                ),
                                const SizedBox(height: 7,),
                                Row(
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.location_history,size: 22,color: Colors.blue,),
                                        SizedBox(width: 5,),
                                        Text('Location: ')
                                      ],
                                    ),
                                    Expanded(child: Text(_bloc.currentAddress.toString().replaceAll('null', ''),style: const TextStyle(color: Colors.blueGrey,fontSize: 13),))
                                  ],
                                ),
                                buildAttachFileInvoice(myState),

                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  height: 45,
                                  width: double.infinity,
                                  child:  TextField(
                                    maxLines: 1,
                                    controller: _noteController,
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(borderSide: BorderSide(color: grey, width: 1),),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: grey, width: 1),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: grey, width: 1),
                                      ),
                                      contentPadding: EdgeInsets.only(left: 8,bottom: 15),
                                      hintText: 'Hãy ghi lại điều gì đó của bạn vào đây',
                                      hintStyle: TextStyle(fontStyle: FontStyle.italic,color: Colors.grey,fontSize: 12,),
                                    ),
                                    focusNode: _noteFocus,
                                    keyboardType: TextInputType.text,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(fontSize: 14),
                                    //textInputAction: TextInputAction.none,
                                  ) ,
                                ),
                                const SizedBox(height: 22,),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16,right: 16,top: 30,bottom: 30),
                                  child: GestureDetector(
                                    onTap: _isImageLoading ? null : (){ // ✅ Disable khi đang loading
                                      if(Const.isDeliveryPhotoRange == true) {
                                        if (idStatus != '4') {
                                          if(_bloc.listFileInvoice.isNotEmpty){
                                            final String latLong = (_bloc.masterItem?.latLong ?? '').replaceAll('null', '').trim();
                                            print('🚚 Debug latLong raw: ${_bloc.masterItem?.latLong} -> cleaned: $latLong');

                                            // Hỗ trợ cả chuỗi "lat,lng" và URL Google Maps chứa "@lat,lng"
                                            double? lat;
                                            double? lng;

                                            if (latLong.contains('@')) {
                                              // Lấy phần sau '@' đến dấu '/' tiếp theo
                                              final afterAt = latLong.split('@').last;
                                              final coordChunk = afterAt.split('/').first;
                                              final parts = coordChunk.split(',');
                                              if (parts.length >= 2) {
                                                lat = double.tryParse(parts[0].trim());
                                                lng = double.tryParse(parts[1].trim());
                                              }
                                            } else {
                                              final parts = latLong.split(',');
                                              if (parts.length >= 2) {
                                                lat = double.tryParse(parts[0].trim());
                                                lng = double.tryParse(parts[1].trim());
                                              }
                                            }

                                            if(lat != null && lng != null){
                                              print('🚚 Parsed lat/lng: $lat , $lng');
                                              if((Utils.getDistance(lat, lng, current) < Const.deliveryPhotoRange)){
                                                Navigator.pop(context,['Accepted']);
                                              }else{
                                                Utils.showCustomToast(context, Icons.warning_amber, 'Khoảng cách giao hàng quá xa so với vị trí Khách hàng');
                                              }
                                            }else{
                                              Utils.showCustomToast(context, Icons.warning_amber, 'Toạ độ khách hàng không hợp lệ');
                                            }
                                          }
                                          else{
                                            Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng chụp ảnh trước khi xác nhận phiếu');
                                          }
                                          }else{
                                          Navigator.pop(context, ['Accepted']);    
                                          }
                                          }
                                          else{
                                            Navigator.pop(context,['Accepted','NoDelivery']);
                                        }
                                    },
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        height: 45.0,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(18.0),
                                            color: _isImageLoading ? Colors.grey : subColor // ✅ Đổi màu khi loading
                                        ),
                                        child: Center(
                                          child: _isImageLoading 
                                            ? Row( // ✅ Hiển thị loading indicator
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'Đang xử lý ảnh...',
                                                    style: TextStyle(fontSize: 14, color: white),
                                                  ),
                                                ],
                                              )
                                            : const Text(
                                                'Xác nhận',
                                                style: TextStyle(fontSize: 16, color: white,),
                                                textAlign: TextAlign.left,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
              );
            },
          );
        }
    ).then((value) {
      if(value != null){
        if(value[0] == 'Accepted'){
          if(_bloc.masterItem?.qrYN == 1){
            if(soPhieuXuat.toString().replaceAll('null', '').isNotEmpty){
              createTicket();
            }else{
              Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng quét mã Phiếu xuất');
            }
          }
          else{
            createTicket();
          }
        }
      }
    });
  }

  void createTicket(){
    if(Const.isDeliveryPhotoRange){
      // ✅ Sử dụng method validation
      if (!_validateImageData()) {
        Utils.showCustomToast(context, Icons.warning_amber, 'Dữ liệu ảnh không hợp lệ, vui lòng chụp lại');
        return;
      }
      
      debugPrint('✅ Validation passed, calling UpdateLocationAndImageEvent');
      _bloc.add(UpdateLocationAndImageEvent(sstRec: _bloc.masterItem!.sttRec.toString()));
    }else{
      debugPrint('✅ Validation passed, calling ConfirmShippingEvent');
      _bloc.add(ConfirmShippingEvent(
          sstRec:  _bloc.masterItem?.sttRec,
          status: int.parse(idStatus),
          typePayment: idTypePayment,
          desc: _noteController.text,
          soPhieuXuat: _bloc.masterItem?.qrYN == 1 ? soPhieuXuat : ''
      ));
    }
  }

  String soPhieuXuat = '';


  /// ✅ Kiểm tra file ảnh có hợp lệ không (ngay sau khi chụp)
  Future<bool> _validateImageFile(File file) async {
    try {
      debugPrint('🔍 Validating image file: ${file.path}');
      
      // ✅ Kiểm tra file có tồn tại không
      if (!await file.exists()) {
        debugPrint('❌ File does not exist');
        return false;
      }
      
      // ✅ Kiểm tra file size
      final fileSize = await file.length();
      if (fileSize == 0) {
        debugPrint('❌ File is empty');
        return false;
      }
      
      if (fileSize < 1024) { // < 1KB
        debugPrint('❌ File too small: $fileSize bytes');
        return false;
      }
      
      if (fileSize > 10 * 1024 * 1024) { // > 10MB
        debugPrint('❌ File too large: $fileSize bytes');
        return false;
      }
      
      // ✅ Kiểm tra file có thể đọc được bytes không
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        debugPrint('❌ File bytes is empty');
        return false;
      }
      
      // ✅ Kiểm tra base64 encoding có thành công không (chỉ test, không lưu)
      String? base64Result = Utils.base64Image(file);
      if (base64Result == null || base64Result.isEmpty) {
        debugPrint('❌ Base64 encoding test failed');
        return false;
      }
      
      if (base64Result.length < 100) {
        debugPrint('❌ Base64 test result too short: ${base64Result.length} chars');
        return false;
      }
      
      debugPrint('✅ Image file validation passed:');
      debugPrint('   - File size: $fileSize bytes');
      debugPrint('   - Bytes length: ${bytes.length}');
      debugPrint('   - Base64 test length: ${base64Result.length} (will be regenerated on upload)');
      
      return true;
      
    } catch (e) {
      debugPrint('❌ Error validating image file: $e');
      return false;
    }
  }

  /// ✅ Kiểm tra tính hợp lệ của dữ liệu ảnh
  bool _validateImageData() {
    debugPrint('🔍 Validating image data:');
    debugPrint('   - Files count: ${_bloc.listFileInvoice.length}');
    debugPrint('   - Base64 count: ${_bloc.listFileInvoiceSave.length}');
    
    // Kiểm tra có ảnh không
    if (_bloc.listFileInvoice.isEmpty) {
      debugPrint('❌ No images found');
      return false;
    }
    
    // Kiểm tra có base64 data không
    if (_bloc.listFileInvoiceSave.isEmpty) {
      debugPrint('❌ No base64 data found');
      return false;
    }
    
    // Kiểm tra tính nhất quán
    if (_bloc.listFileInvoice.length != _bloc.listFileInvoiceSave.length) {
      debugPrint('❌ Data inconsistency detected');
      return false;
    }
    
    // ✅ Kiểm tra từng base64 có hợp lệ không (có thể null nếu chưa gen)
    for (int i = 0; i < _bloc.listFileInvoiceSave.length; i++) {
      final base64Data = _bloc.listFileInvoiceSave[i].pathBase64;
      // ✅ Base64 có thể null nếu chưa được gen (lazy loading)
      if (base64Data != null && base64Data.isEmpty) {
        debugPrint('❌ Empty base64 data at index $i');
        return false;
      }
    }
    
    debugPrint('✅ All image data is valid');
    return true;
  }

  void openScanner(BuildContext context,StateSetter myState) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const BarcodeScannerPopup(),
    );

    if (result != null) {
      myState(() {
        soPhieuXuat = Utils.extractSttRec(result);
        print(soPhieuXuat);
      });
    }
  }


  final imagePicker = ImagePicker();
  Timer? _timer;
  int start = 3;

  bool waitingLoad = false;

  void startTimer(StateSetter myState) {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          waitingLoad = false;
          _isImageLoading = false; // ✅ Reset loading state khi hoàn thành
          myState(() {});
          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }

  Future getImage(StateSetter myState) async {
    try {
      // ✅ Sử dụng await thay vì .then() để code dễ đọc hơn
      final value = await PersistentNavBarNavigator.pushNewScreen(
        context, 
        screen: const CameraCustomUI(
          showZoomControls: true, // ✅ Hiển thị zoom controls để user có thể tùy chỉnh
        )
      );
      
      if (value != null) {
        XFile image = value;
        
        // ✅ Kiểm tra XFile có hợp lệ không
        if (image.path.isEmpty) {
          Utils.showCustomToast(context, Icons.error_outline, 'Đường dẫn ảnh không hợp lệ');
          return;
        }

        // ✅ Kiểm tra file có tồn tại không
        final file = File(image.path);
        if (!await file.exists()) {
          Utils.showCustomToast(context, Icons.error_outline, 'File ảnh không tồn tại');
          return;
        }
        
        // ✅ Kiểm tra file có thể đọc được không
        try {
          final fileSize = await file.length();

          if (fileSize == 0) {

            Utils.showCustomToast(context, Icons.error_outline, 'File ảnh bị lỗi (rỗng)');
            return;
          }
          
          // ✅ Kiểm tra file size quá lớn (ví dụ: > 10MB)
          if (fileSize > 10 * 1024 * 1024) {

            Utils.showCustomToast(context, Icons.error_outline, 'File ảnh quá lớn (>10MB)');
            return;
          }
          
          // ✅ Kiểm tra file size quá nhỏ (có thể là file lỗi)
          if (fileSize < 1024) { // < 1KB
            Utils.showCustomToast(context, Icons.error_outline, 'File ảnh quá nhỏ, có thể bị lỗi');
            return;
          }
          
        } catch (e) {
          Utils.showCustomToast(context, Icons.error_outline, 'Không thể đọc file ảnh');
          return;
        }
        
        // ✅ Sử dụng method validation tổng hợp
        bool isValidFile = await _validateImageFile(file);
        if (!isValidFile) {
          Utils.showCustomToast(context, Icons.error_outline, 'File ảnh không hợp lệ, vui lòng chụp lại');
          return;
        }

        myState(() {
          try {
            // ✅ Set loading state
            _isImageLoading = true;
            start = 2;
            waitingLoad = true;
            startTimer(myState);
            
            // ✅ Chỉ lưu file, không gen base64 ngay (tối ưu performance)
            try {
              // ✅ Thêm file vào danh sách
              _bloc.listFileInvoice.add(file);
              
              // ✅ Tạo placeholder cho base64 (sẽ gen khi upload)
              ListImageInvoice itemImage = ListImageInvoice(
                pathBase64: null, // ✅ Không gen base64 ngay
                nameImage: image.name
              );
              _bloc.listFileInvoiceSave.add(itemImage);
              
              // ✅ Log để debug
              file.length().then((size) => debugPrint('   - File size: $size bytes'));
              
            } catch (e) {
              debugPrint('❌ Error adding image to list: $e');
              Utils.showCustomToast(context, Icons.error_outline, 'Lỗi khi lưu ảnh, vui lòng thử lại');
            }
            
          } catch (e) {
            Utils.showCustomToast(context, Icons.error_outline, 'Lỗi khi xử lý ảnh: ${e.toString()}');
          }
        });
        
        // ✅ Kiểm tra và init location nếu cần
        if (_bloc.currentAddress.toString().isEmpty) {
          init(myState);
        }
      }
    } catch (e) {
      Utils.showCustomToast(context, Icons.error_outline, 'Lỗi khi chọn ảnh: ${e.toString()}');
    }
  }

  buildAttachFileInvoice(StateSetter myState){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: subColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: (){
                getImage(myState);
                // _bloc.add(GetCameraEvent());
              },
              child: Container(padding: const EdgeInsets.only(left: 10,right: 15,top: 8,bottom: 8),
                height: 40,
                width: double.infinity,
                color: Colors.amber.withOpacity(0.4),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Ảnh của bạn',style: TextStyle(color: Colors.black,fontSize: 13),),
                    Icon(Icons.add_a_photo_outlined,size: 20,),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16,),
            // GalleryImage(imageUrls: [],),
            _bloc.listFileInvoice.isEmpty ? const SizedBox(height: 100,width: double.infinity,child: Center(child: Text('Hãy chọn thêm hình ảnh của bạn từ thư viện ảnh hoặc từ camera',style: TextStyle(color: Colors.blueGrey,fontSize: 12),textAlign: TextAlign.center,),),) :
            SizedBox(
              height: 120,
              width: double.infinity, 
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: _bloc.listFileInvoice.length,
                    itemBuilder: (context,index){
                      return (start > 1 && waitingLoad == true && _bloc.listFileInvoice.length == (index + 1)) ? const SizedBox(height: 100,width: 80,child: PendingAction()) : GestureDetector(
                        onTap: (){
                          openImageFullScreen(index,_bloc.listFileInvoice[index]);
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
                                    /*semanticContainer: true,
                                    margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),*/
                                    child: Image.file(
                                      _bloc.listFileInvoice[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 6,right: 6,
                                child: InkWell(
                                  onTap: (){
                                    myState(() {
                                      // ✅ Xóa file và base64 data
                                      _bloc.listFileInvoice.removeAt(index);
                                      _bloc.listFileInvoiceSave.removeAt(index);
                                      
                                      // ✅ Reset loading state nếu không còn ảnh nào đang load
                                      if (_bloc.listFileInvoice.isEmpty) {
                                        _isImageLoading = false;
                                        waitingLoad = false;
                                      }
                                      
                                      debugPrint('🗑️ Image deleted:');
                                      debugPrint('   - Remaining files: ${_bloc.listFileInvoice.length}');
                                      debugPrint('   - Remaining base64: ${_bloc.listFileInvoiceSave.length}');
                                    });
                                  },
                                  child: Container(
                                    height: 20,width: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black.withOpacity(.7),
                                    ),
                                    child: const Icon(Icons.clear,color: Colors.white,size: 12,),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }

                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // to open gallery image in full screen
  void openImageFullScreen(final int indexOfImage, File fileImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryImageViewWrapperViewOnly(
          titleGallery: "Zoom Image",
          galleryItemsFile: fileImage,
          viewNetWorkImage: false,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: indexOfImage,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }


  final List<String> codeTypePayment = [
    'Công nợ',
    'Tiền mặt',
    'Chuyển khoản'
  ];

  String currentCodeTypePayment = 'Công nợ';
  ListStatusOrderResponseData currentCodecStatus = ListStatusOrderResponseData();
  int idTypePayment = 2;
  String idStatus = "";
  final _noteController = TextEditingController();
  final FocusNode _noteFocus = FocusNode();
  bool _isUploadProgressDialogShowing = false; // ✅ Flag để tránh hiển thị nhiều dialog
  double _currentProgress = 0.0; // ✅ Lưu progress hiện tại
  String _currentMessage = ''; // ✅ Lưu message hiện tại
  bool _isImageLoading = false; // ✅ Flag để track trạng thái loading ảnh

  /// Hiển thị dialog progress khi upload ảnh
  void _showUploadProgressDialog(BuildContext context, double progress, String message) {
    // ✅ Cập nhật progress và message hiện tại
    _currentProgress = progress;
    _currentMessage = message;
    
    // ✅ Chỉ hiển thị dialog nếu chưa có dialog nào đang hiển thị
    if (!_isUploadProgressDialogShowing) {
      _isUploadProgressDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              // ✅ Cập nhật dialog state khi progress thay đổi
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setDialogState(() {});
              });
              
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Sử dụng AnimatedBuilder để smooth progress
                    AnimatedBuilder(
                      animation: AlwaysStoppedAnimation(_currentProgress),
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _currentProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _currentProgress >= 1.0 ? Colors.green : Colors.blue
                          ),
                          strokeWidth: 4.0,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentMessage,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _currentProgress >= 1.0 ? Colors.green : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // ✅ Hiển thị percentage với animation
                    AnimatedBuilder(
                      animation: AlwaysStoppedAnimation(_currentProgress),
                      builder: (context, child) {
                        return Text(
                          '${(_currentProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: _currentProgress >= 1.0 ? Colors.green : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                    // ✅ Hiển thị checkmark khi hoàn thành
                    if (_currentProgress >= 1.0) ...[
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ).then((_) {
        _isUploadProgressDialogShowing = false; // ✅ Reset flag khi dialog đóng
        _currentProgress = 0.0; // ✅ Reset progress
        _currentMessage = ''; // ✅ Reset message
      });
    } else {
      // ✅ Nếu dialog đã hiển thị, chỉ cần trigger rebuild
      // Dialog sẽ tự động cập nhật với _currentProgress và _currentMessage mới
    }
  }

  /// Hiển thị dialog retry khi upload ảnh thất bại
  void _showUploadRetryDialog(BuildContext context, String error) {
    // Đóng progress dialog trước và reset flag
    Navigator.of(context).pop();
    _isUploadProgressDialogShowing = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lỗi upload ảnh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn hãy upload lại',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Chi tiết lỗi: $error',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Không retry, user chọn hủy
              },
              child: Text(
                'Hủy',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // ✅ Retry upload ảnh
                _bloc.add(UpdateLocationAndImageEvent(sstRec: _bloc.masterItem!.sttRec.toString()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Xác nhận',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}
