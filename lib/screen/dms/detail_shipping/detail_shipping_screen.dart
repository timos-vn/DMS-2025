import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
                    Text('[${item.maVt.toString().replaceAll('null', '')}] ${item.tenVt.toString().replaceAll('null', '')}',style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),maxLines: 2,overflow: TextOverflow.ellipsis,),
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
                                    onTap: (){
                                      if(Const.isDeliveryPhotoRange == true){
                                        if(idStatus != '4'){
                                          if(_bloc.listFileInvoice.isNotEmpty){
                                            String? latLong = '';
                                            latLong = _bloc.masterItem?.latLong.toString().replaceAll('null', '');
                                            if(latLong.toString().trim().isNotEmpty){
                                              if((Utils.getDistance(double.parse(_bloc.masterItem!.latLong.toString().split(',')[0]), double.parse(_bloc.masterItem!.latLong.toString().split(',')[1]),current) < Const.deliveryPhotoRange)){
                                                Navigator.pop(context,['Accepted']);
                                              }else{
                                                Utils.showCustomToast(context, Icons.warning_amber, 'Khoảng cách giao hàng quá xa so với vị trí Khách hàng');
                                              }
                                            }
                                            else{
                                              Navigator.pop(context,['Accepted']);
                                            }
                                          }
                                          else{
                                            Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng chụp ảnh trước khi xác nhận phiếu');
                                          }
                                        }else{
                                          Navigator.pop(context,['Accepted']);
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
                                            color: subColor
                                        ),
                                        child: const Center(
                                          child: Text(
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
      _bloc.add(UpdateLocationAndImageEvent(sstRec: _bloc.masterItem!.sttRec.toString()));
    }
    _bloc.add(ConfirmShippingEvent(
        sstRec:  _bloc.masterItem?.sttRec,
        status: int.parse(idStatus),
        typePayment: idTypePayment,
        desc: _noteController.text,
        soPhieuXuat: _bloc.masterItem?.qrYN == 1 ? soPhieuXuat : ''
    ));
  }

  String soPhieuXuat = '';

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
  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 3;

  bool waitingLoad = false;

  void startTimer(StateSetter myState) {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {
          waitingLoad = false;
          myState(() {});
          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }

  Future getImage(StateSetter myState)async {
    PersistentNavBarNavigator.pushNewScreen(context, screen: const CameraCustomUI()).then((value){
      if(value != null){
        XFile image = value;
        myState(() {
          if(image != null){
            start = 2;waitingLoad  = true;
            startTimer(myState);
            _bloc.listFileInvoice.add(File(image.path));
            ListImageInvoice itemImage = ListImageInvoice(
                pathBase64: Utils.base64Image(File(image.path)).toString(),
                nameImage: image.name
            );
            _bloc.listFileInvoiceSave.add(itemImage);
          }
          if(_bloc.currentAddress.toString().isEmpty){
            init(myState);
          }
        });
      }
    });
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
                                      _bloc.listFileInvoice.removeAt(index);
                                      _bloc.listFileInvoiceSave.removeAt(index);
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

}
