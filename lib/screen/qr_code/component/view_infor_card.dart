
import 'package:dms/model/network/response/get_list_history_dnnk_response.dart';
import 'package:dms/screen/qr_code/qr_code_bloc.dart';
import 'package:dms/screen/qr_code/qr_code_sate.dart';
import 'package:dms/widget/barcode_scanner_widget.dart';
import 'package:dms/widget/custom_confirm_2.dart';
import 'package:dms/widget/custom_update_barcode.dart';
import 'package:dms/widget/input_quantity_shipping_popup.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../../../model/network/request/update_item_barcode_request.dart';
import '../../../model/network/request/update_quantity_warehouse_delivery_card_request.dart';
import '../../../model/network/response/get_info_card_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/images.dart';
import '../../../utils/utils.dart';
import '../../filter/filter_page.dart';
import '../qr_code_event.dart';

class ViewInformationCardScreen extends StatefulWidget {
  final String nameCard;
  final FormatProvider formatProvider;
  final List<ListItem> listItemCard;
  final RuleActionInfoCard ruleActionInformationCard;
  final MasterInfoCard masterInformationCard;
  final String keyFunction;

  const ViewInformationCardScreen({super.key, required this.formatProvider,required this.nameCard, required this.masterInformationCard, required this.ruleActionInformationCard,
    required this.listItemCard,
    required this.keyFunction});

  @override
  State<ViewInformationCardScreen> createState() => _ViewInformationCardScreenState();
}

class _ViewInformationCardScreenState extends State<ViewInformationCardScreen> with TickerProviderStateMixin{

  late TabController tabController;
  late QRCodeBloc _bloc;
  bool checkItemExits = false;

  bool viewQRCode = true;
  List<ListItem> listItemCard = [];
  String licensePlates = '';
  int indexSelected = -1;
  String codeTransfer = '';String nameTransfer = '';
  int tabIndex = 0;
  List<String> listIconsV4 = ['Sản phẩm','Lịch sử','Thông tin'];
  List<String> listIcons =  ['Sản phẩm','Thông tin'];

  String valuesBarcode = '';
  bool isProcessing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = QRCodeBloc(context);
    listItemCard.addAll(widget.listItemCard);
    tabController = TabController(vsync: this, length: widget.keyFunction != '#4' ? listIcons.length :  listIconsV4.length);
    tabController.addListener(() {
      setState(() {
        tabIndex = tabController.index;
      });
    });
    if(widget.keyFunction == '#4'){
      _bloc.add(GetListHistoryDNNKEvent(sttRec: widget.masterInformationCard.sttRec.toString()));
    }
  }

  @override
  void dispose() {
    // Stop camera when leaving the screen
    BarcodeScannerWidget.globalKey.currentState?.stopCamera();
    tabController.dispose();
    super.dispose();
  }

  void handleBarcodeScan(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    if (widget.keyFunction == '#4') {
      if (indexSelected >= 0) {
        String kg = "0";
        String expirationDate = '';

        if (widget.formatProvider.canYn == 1) {
          kg = NumberFormat(widget.formatProvider.soThapPhan.toString())
              .format(double.parse(code.substring(widget.formatProvider.canTu!.toInt(), widget.formatProvider.canDen!.toInt())));
        }
        if (widget.formatProvider.hsdYn == 1) {
          expirationDate = code.substring(widget.formatProvider.hsdTu!.toInt(), widget.formatProvider.hsdDen!.toInt());
        }

        listItemCard[indexSelected].qrCode = code;
        listItemCard[indexSelected].soLuong = double.parse(kg);
        listItemCard[indexSelected].expirationDate = expirationDate;

        _bloc.listHistoryDNNK.add(GetListHistoryDNNKResponseData(
          maVt: listItemCard[indexSelected].maVt,
          tenVt: listItemCard[indexSelected].tenVt,
          sttRec: listItemCard[indexSelected].sttRec,
          index: 0,
          barcode: code,
          soCan: double.parse(kg),
          hsd: expirationDate,
        ));

        _bloc.add(RefreshUpdateItemBarCodeEvent());
        if (!valuesBarcode.contains(code)) {
          valuesBarcode = code;
          _bloc.add(RefreshUpdateItemBarCodeEvent());
        }

        Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật Barcode thành công');
      } else {
        Utils.showCustomToast(context, Icons.warning_amber, 'Vui lòng chọn 1 sản phẩm để cập nhật');
      }
    } else if (widget.keyFunction == '#3') {
      if (!valuesBarcode.contains(code)) {
        valuesBarcode = code;
        _bloc.add(GetInformationItemFromBarCodeEvent(barcode: valuesBarcode));
      }
    } else if (widget.keyFunction == '#1') {
      _bloc.add(GetInformationItemFromBarCodeEvent(barcode: code));
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
          if(state is UpdateQuantityInWarehouseDeliveryCardSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật phiếu thành công');
            Navigator.pop(context);
          }
          else if(state is QRCodeFailure){
            Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
          }
          else if(state is CreateDeliverySuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Tạo phiếu thành công');
            Navigator.pop(context);
          }
          else if(state is UpdateItemBarCodeSuccess){
            if(state.action == 1){
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật Barcode thành công');
            }else{
              Utils.showCustomToast(context, Icons.check_circle_outline, 'Xác nhận phiếu thành công');
              Navigator.pop(context);
            }

          }
          else if(state is ConfirmPostPNFSuccess){
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật phiếu thành công');
            Navigator.pop(context);
          }
          else if(state is GetInformationItemFromBarCodeSuccess){
            valuesBarcode = '';
            if (widget.keyFunction == '#1') {
              if (indexSelected >= 0) {
                listItemCard[indexSelected].qrCode = valuesBarcode;
                listItemCard[indexSelected].soLuong = state.informationProduction.soLuong ?? 0;
                listItemCard[indexSelected].expirationDate = state.informationProduction.hsd;
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Cập nhật thông tin thành công');
              }
            }

            else{
              if(listItemCard.isNotEmpty){
                for (var element in listItemCard) {
                  if(element.maVt.toString().trim() == _bloc.informationProduction.maVt.toString().trim()){
                    checkItemExits = true;
                    break;
                  }
                }
                if(checkItemExits == false){
                  Utils.showCustomToast(context, Icons.warning_amber, 'Sản phẩm này của bạn không tồn tại');
                }else{
                  Utils.showCustomToast(context, Icons.check_circle_outline, 'Kiểm tra thành công');
                }
              }else{
                Utils.showCustomToast(context, Icons.warning_amber, 'Phiếu của bạn đang trống');
              }
            }
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildAppBar(),
        Visibility(
          visible: viewQRCode == true,
          child: SizedBox(
            height: 200, width: double.infinity,
            child: buildCamera(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10,right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  const Text(
                    'Danh sách sản phẩm ',
                    style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 5,),
                  Text(
                    widget.keyFunction.toString().trim().replaceAll('null', ''),
                    style: const TextStyle(fontSize: 12.0,color: subColor),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: IconButton(
                  icon: Icon(
                    EneftyIcons.scan_outline,
                    color: viewQRCode ? Colors.green : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      viewQRCode = !viewQRCode;
                      if (viewQRCode) {
                        BarcodeScannerWidget.globalKey.currentState?.startCamera();
                      } else {
                        BarcodeScannerWidget.globalKey.currentState?.stopCamera();
                      }
                    });
                  },
                ),
              )
            ],
          ),
        ),
        Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.0),
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 2)),
                    ),
                    child: TabBar(
                      controller: tabController,
                      unselectedLabelColor: Colors.grey.withOpacity(0.8),
                      labelColor: Colors.red,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      isScrollable: false,
                      indicatorPadding: const EdgeInsets.all(0),
                      indicatorColor: Colors.red,
                      dividerColor: Colors.red,automaticIndicatorColorAdjustment: true,
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                      indicator: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              style: BorderStyle.solid,
                              color: Colors.red,
                              width: 2
                          ),
                        ),
                      ),
                      tabs: List<Widget>.generate(widget.keyFunction != '#4' ? listIcons.length :  listIconsV4.length, (int index) {
                        return Tab(
                          text: widget.keyFunction != '#4' ? listIcons[index] : listIconsV4[index],
                        );
                      }),
                      onTap: (index){
                        // setState(() {
                        //   tabIndex = index;
                        // });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        color: grey_100,
                        child: TabBarView(
                            controller: tabController,
                            children: List<Widget>.generate(widget.keyFunction != '#4' ? listIcons.length :  listIconsV4.length, (int index) {
                              for (int i = 0; i <= (widget.keyFunction != '#4' ? listIcons.length :  listIconsV4.length); i++) {
                                if(index == 0){
                                  return buildListItem();
                                }else if(index == 1 && widget.keyFunction == '#4'){
                                  return buildListItemHistory();
                                }else{
                                  return buildInfo();
                                }
                              }
                              return const Text('');
                            })),
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.keyFunction == '#4' && widget.ruleActionInformationCard.status.toString() != '1',
                  child:  Container(
                    height: 70,width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: (){
                                  if(tabIndex == 0){
                                    List<UpdateItemBarCodeRequestDetail> _listItem = [];
                                    int indexItem = 0;
                                    for (var element in listItemCard) {
                                      indexItem = indexItem + 1;
                                      _listItem.add(UpdateItemBarCodeRequestDetail(
                                          maVt: element.maVt,
                                          indexItem: indexItem,
                                          barcode: element.qrCode,
                                          maKho:  element.maKho,
                                          maLo:  element.maLo,
                                          soCan:  element.soLuong.toString(),
                                          hsd:  element.expirationDate,
                                          sttRec: widget.masterInformationCard.sttRec.toString()
                                      ));
                                    }
                                    _bloc.add(UpdateItemBarCodeEvent(
                                        listItem: _listItem,
                                        sttRec: widget.masterInformationCard.sttRec.toString(),
                                        action: 1
                                    ));
                                  }
                                  else{

                                  }
                                },
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: tabIndex == 0 ? Colors.black: Colors.grey ,
                                      borderRadius: BorderRadius.circular(24)
                                  ),
                                  child: const Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Cập nhật số lượng',style: TextStyle(color: Colors.white),),
                                    ],
                                  ),
                                )
                            )
                        ),
                        const SizedBox(width: 10,),
                        Expanded(
                            child: GestureDetector(
                                onTap: (){
                                  if(tabIndex != 0){
                                    List<UpdateItemBarCodeRequestDetail> _listItem = [];
                                    int indexItem = 0;
                                    for (var element in _bloc.listHistoryDNNK) {
                                      indexItem = indexItem + 1;
                                      _listItem.add(UpdateItemBarCodeRequestDetail(
                                          maVt: element.maVt,
                                          indexItem: indexItem,
                                          barcode: element.barcode,
                                          maKho: '',
                                          maLo:  '',
                                          soCan:  element.soCan.toString(),
                                          hsd:  element.hsd,
                                          sttRec: widget.masterInformationCard.sttRec.toString()
                                      ));
                                    }
                                    _bloc.add(UpdateItemBarCodeEvent(
                                        listItem: _listItem,
                                        sttRec: widget.masterInformationCard.sttRec.toString(),
                                        action: 2
                                    ));
                                  }
                                  else{

                                  }
                                },
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: tabIndex != 0 ? Colors.black : Colors.grey,
                                      borderRadius: BorderRadius.circular(24)
                                  ),
                                  child: const Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                     'Xác nhận'
                                        ,style: TextStyle(color: Colors.white),),
                                    ],
                                  ),
                                )
                            )
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.keyFunction != '#4' ,
                  child:  GestureDetector(
                    onTap: (){
                      if(widget.keyFunction.toString().trim() == '#1'){
                        if(listItemCard.isNotEmpty){
                          List<UpdateQuantityInWarehouseDeliveryCardDetail> listItemUpdate = [];
                          for (var element in listItemCard) {
                            UpdateQuantityInWarehouseDeliveryCardDetail item = UpdateQuantityInWarehouseDeliveryCardDetail(
                                sttRec: element.sttRec,
                                sttRec0: element.sttRec0,
                                count: element.soLuong,
                                codeProduction: element.maVt
                            );
                            listItemUpdate.add(item);
                          }
                          _bloc.add(UpdateQuantityInWarehouseDeliveryCardEvent(
                              licensePlates: licensePlates,
                              listItem: listItemUpdate
                          ));
                        }
                        else{
                          Utils.showCustomToast(context, Icons.warning_amber, 'Phiếu của bạn không có gì để cập nhật cả');
                        }
                      }
                      else if(widget.keyFunction.toString().trim() == '#3'){
                        _bloc.add(ConfirmPostPNFEvent(sttRec: widget.masterInformationCard.sttRec.toString()));
                      }
                      else if(widget.keyFunction.toString().trim() == '#6'){
                        _bloc.add(CreateDeliveryEvent(sttRec: widget.masterInformationCard.sttRec.toString(),licensePlates: licensePlates, codeTransfer: codeTransfer));
                      }
                    },
                    child: Container(
                      height: 70,width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(24)
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.keyFunction == '#1' ?
                                      'Cập nhật số lượng'
                                          :
                                      widget.keyFunction == '#3' ?  'Xác nhận'
                                          :
                                      widget.keyFunction == '#6' ?  'Lên phiếu giao hàng'
                                          :
                                      'Cập nhật thông tin phiếu'
                                      ,style: const TextStyle(color: Colors.white),),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }

  buildListItem(){
    return ListView.separated(
        key: const Key('KeyListItems'),
        shrinkWrap: true,
        physics: listItemCard.length > 1 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (_, index) {
          if(index != indexSelected){
            listItemCard[index].isMark = 0;
          }
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
                          return UpdateBarCode(
                            barcode: listItemCard[index].qrCode.toString(),
                            hsd: listItemCard[index].expirationDate.toString(),
                          );
                        }).then((value){
                      if(value != null){
                        setState(() {
                          listItemCard[index].qrCode = value[0].toString();
                          listItemCard[index].expirationDate = value[1].toString();
                          GetListHistoryDNNKResponseData item = GetListHistoryDNNKResponseData(
                              maVt:  listItemCard[index].maVt,
                              tenVt:  listItemCard[index].tenVt,
                              sttRec:  listItemCard[index].sttRec,
                              index:  0,
                              barcode: value[0].toString(),
                              soCan: listItemCard[index].soLuong,
                              hsd: value[1].toString()
                          );
                          _bloc.listHistoryDNNK.add(item);
                        });
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
              ],
            ),
            child: GestureDetector(
              onTap: (){
                if(widget.keyFunction == '#4' || widget.keyFunction == '#1'){
                  setState(() {
                    if(listItemCard[index].isMark == 1){
                      listItemCard[index].isMark = 0;
                      indexSelected = -1;
                    }
                    else{
                      listItemCard[index].isMark = 1;
                      indexSelected = index;
                    }
                  });
                }
              },
              child: Card(
                semanticContainer: true,
                margin: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                child: Row(
                  children: [
                    Visibility(
                      visible: widget.keyFunction != '#4',
                      child: Container(
                        width: 100,
                        height: 130,
                        decoration: const BoxDecoration(
                            borderRadius:BorderRadius.all( Radius.circular(6),)
                        ),
                        child: const Icon(EneftyIcons.image_outline,size: 50,weight: 0.6,),
                        //Image.network('https://i.pinimg.com/564x/49/77/91/4977919321475b060fcdd89504cee992.jpg',fit: BoxFit.contain,),
                      ),),
                    Visibility(
                      visible: widget.keyFunction == '#4' || widget.keyFunction == '#1',
                      child: SizedBox(
                        width: 50,
                        child: Transform.scale(
                          scale: 1,
                          alignment: Alignment.topLeft,
                          child: Checkbox(
                            value: listItemCard[index].isMark == 0 ? false : true,
                            onChanged: (b){
                              setState(() {
                                if(listItemCard[index].isMark == 1){
                                  listItemCard[index].isMark = 0;
                                  indexSelected = -1;
                                }
                                else{
                                  listItemCard[index].isMark = 1;
                                  indexSelected = index;
                                }
                              });
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
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '[${listItemCard[index].maVt.toString().trim()}] ${listItemCard[index].tenVt.toString().toUpperCase()}',
                              style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                              maxLines: 2,overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5,),
                            Padding(
                              padding: const EdgeInsets.only(right: 6,bottom: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(EneftyIcons.scan_outline,color: Colors.grey,size: 15,),
                                  const SizedBox(width: 5,),
                                  Expanded(
                                    child: Text(listItemCard[index].qrCode??'Chưa cập nhật QRCode',
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
                                  Text(listItemCard[index].expirationDate??'Chưa cập nhật hạn sử dụng',
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(EneftyIcons.shopping_cart_outline,size: 15,color: Colors.grey),
                                const SizedBox(width: 7,),
                                Expanded(
                                  child: Text(listItemCard[index].tenKho??'Kho đang cập nhật',
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  height: 13,
                                  width: 1.5,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Loại: ${listItemCard[index].cheBien == 1 ? 'Chế biến' : listItemCard[index].sanXuat == 1 ? 'Sản xuất' :'Thường'}',
                                        style:const TextStyle(color: Colors.blueGrey,fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 13,
                                  width: 1.5,
                                  color: Colors.grey,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Đơn vị: ${listItemCard[index].tenDvt}',
                                        style:const TextStyle(color: Colors.blueGrey,fontSize: 12,),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5,right: 0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 35,
                                      padding: const EdgeInsets.only(left: 5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '\$ ${Utils.formatMoneyStringToDouble(listItemCard[index].tien??0)}',
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(color: Colors.black, fontSize: 14,fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              color: Colors.transparent,
                                              width: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 35,
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                              qty = listItemCard[index].soLuong??0;
                                              if(qty > 1){
                                                setState(() {
                                                  qty = qty - 1;
                                                  listItemCard[index].soLuong = qty;
                                                });
                                              }
                                            },
                                            child: const SizedBox(width:25,child: Icon(FluentIcons.subtract_12_filled,size: 15,))),
                                        GestureDetector(
                                          onTap: (){
                                            showDialog(
                                                barrierDismissible: true,
                                                context: context,
                                                builder: (context) {
                                                  return const InputQuantityShipping(title: 'Vui lòng nhập số lượng thay đổi',desc: 'Nếu số lượng không thay đổi thì bạn không cần sửa.',);
                                                }).then((values){
                                              if(values != null){
                                                setState(() {
                                                  listItemCard[index].soLuong = double.parse(values[0]??'0');
                                                });
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text("${listItemCard[index].soLuong??0} ",
                                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                            onTap: (){
                                              double qty = 0;
                                              qty = listItemCard[index].soLuong??0;
                                              setState(() {
                                                qty = qty + 1;
                                                listItemCard[index].soLuong = qty;
                                              });
                                            },
                                            child: const SizedBox(width:25,child: Icon(FluentIcons.add_12_filled,size: 15))),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
        itemCount: listItemCard.length);
  }

  buildListItemHistory(){
    return _bloc.listHistoryDNNK.isNotEmpty ? ListView.separated(
        key: const Key('KeyListHistoryItem'),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (_, index) {
          return Slidable(
            key: const ValueKey(2),
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
                          return const CustomConfirm2(
                            title: 'Bạn sẽ xoá Barcode này',
                            content: 'Hãy chắc chắn là bạn muốn điều này!',
                          );
                        }).then((value){
                      if(value != null && value[0] == 'confirm'){
                        setState(() {
                          _bloc.listHistoryDNNK.removeAt(index);
                        });
                      }
                    });
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
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 80,
                    decoration: const BoxDecoration(
                        borderRadius:BorderRadius.all( Radius.circular(6),)
                    ),
                    child: const Icon(EneftyIcons.image_outline,size: 50,weight: 0.6,),
                    //Image.network('https://i.pinimg.com/564x/49/77/91/4977919321475b060fcdd89504cee992.jpg',fit: BoxFit.contain,),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10,right: 6,bottom: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '[${_bloc.listHistoryDNNK[index].maVt.toString().trim()}] ${_bloc.listHistoryDNNK[index].tenVt.toString().toUpperCase()}',
                            style:const TextStyle(color: subColor, fontSize: 12.5, fontWeight: FontWeight.w600,),
                            maxLines: 2,overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.only(right: 6,bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(EneftyIcons.scan_outline,color: Colors.grey,size: 15,),
                                const SizedBox(width: 5,),
                                Expanded(
                                  child: Text(_bloc.listHistoryDNNK[index].barcode??'Chưa cập nhật QRCode',
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.only(right: 6,bottom: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(EneftyIcons.activity_outline,color: Colors.grey,size: 15,),
                                const SizedBox(width: 5,),
                                Expanded(
                                  child: Text('SL: ${_bloc.listHistoryDNNK[index].soCan.toString()}',
                                    textAlign: TextAlign.left, style: const TextStyle(color: Colors.blueGrey,fontSize: 11),
                                    maxLines: 1, overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) {
          return const SizedBox(height: 8);
        },
        itemCount: _bloc.listHistoryDNNK.length) : const Center(
      child: Text('Úi, hãy cập nhật thông tin sản phẩm đã nhé',style: TextStyle(color: grey,fontSize: 12),),
    );
  }

  buildInfo(){
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 15),
            child: Container(
              color: grey_100,
              child: Column(
                children: [
                  const SizedBox(height: 5,),
                  Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(8, 0, 8,0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundImage: AssetImage(avatarStore),
                          backgroundColor: Colors.transparent,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(child: Text(
                                  '[${!Utils.isEmpty(widget.masterInformationCard.maKh.toString()) && widget.masterInformationCard.maKh.toString().trim() != 'null' ? widget.masterInformationCard.maKh.toString().trim() :widget.masterInformationCard.maNcc.toString().trim()}]  '
                                      '${(!Utils.isEmpty(widget.masterInformationCard.tenKh.toString()) && widget.masterInformationCard.tenKh.toString().trim() != 'null') ? widget.masterInformationCard.tenKh.toString().trim() : widget.masterInformationCard.tenNcc.toString().trim()}',
                                  style: const TextStyle(color: subColor,fontWeight: FontWeight.bold,fontSize: 13),maxLines: 2,overflow: TextOverflow.ellipsis,),),
                                const SizedBox(height: 5,),
                                Row(
                                  children: [
                                    const Icon(EneftyIcons.card_pos_outline,color: Colors.blueGrey,size: 18,),
                                    const SizedBox(width: 8,),
                                    Text(
                                      '${widget.masterInformationCard.sttRec}'
                                      ,style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                  ],
                                ),
                                const SizedBox(height: 5,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(EneftyIcons.calendar_3_outline,color: Colors.blueGrey,size: 18,),
                                        const SizedBox(width: 8,),
                                        Text(
                                          '${widget.masterInformationCard.ngayCt}'
                                          ,style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text('${widget.masterInformationCard.statusname}',
                                          style: const TextStyle(color: Color(0xff0162c1)  ,fontWeight: FontWeight.w700,fontSize: 11)),
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
                  const SizedBox(height: 5,),
                  InkWell(
                    onTap: (){
                      if(Const.allowChangeTransfer == true){
                        showDialog(
                            context: context,
                            builder: (context) => const FilterScreen(controller: 'dmnvbh_lookup',
                              listItem: null,show: false,)).then((value){
                          if(value != null){
                            setState(() {
                              codeTransfer = value[0];
                              nameTransfer = value[1];
                            });
                          }
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12,right: 0,bottom: 5 ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(EneftyIcons.truck_fast_outline),
                                    const SizedBox(width: 18,),
                                    Text('Vận chuyển: ${widget.masterInformationCard.tenHtvc.toString().trim()}',
                                      style: const TextStyle(fontWeight: FontWeight.normal,color: subColor),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: Const.allowChangeTransfer == true,
                                child: InkWell(
                                  child: Row(
                                    children: [
                                      Text(
                                        nameTransfer.isNotEmpty ? nameTransfer : 'Tài xế của bạn',
                                        style: const TextStyle(color: subColor),
                                      ),
                                      const SizedBox(width: 5,),
                                      const Icon(EneftyIcons.search_normal_outline,size: 15,color: accent,),
                                      const SizedBox(width: 5,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5 ),
                          const Divider(color: Colors.grey)
                        ],
                      ),
                    ),
                  ),
                  customView(EneftyIcons.note_2_outline, 'Ghi chú: ${widget.masterInformationCard.dienGiai.toString().trim()}', false, FontWeight.normal),
                ],
              ),
            ),
          ),
          customPayment(title: 'Code',value: '${widget.masterInformationCard.soCt}'),
          Visibility(
            visible: widget.keyFunction.toString().trim() != '#6' && widget.keyFunction.toString().trim() != '#1',
            child: customPayment(title: 'Tổng số lượng',value: '${widget.masterInformationCard.tSoLuong}'),),
          Visibility(
            visible: widget.keyFunction.toString().trim() != '#6' && widget.keyFunction.toString().trim() != '#1',
            child:  customPayment(title: 'Tổng thanh toán',value: '\$${Utils.formatMoneyStringToDouble(widget.masterInformationCard.tTT??0)}'.toString().trim()),),
          const SizedBox(
            height: 5.0,
          )
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
      key: BarcodeScannerWidget.globalKey,
      onBarcodeDetected: handleBarcodeScan,
      framePadding: const EdgeInsets.symmetric(vertical: 16),
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
                    BarcodeScannerWidget.globalKey.currentState?.stopCamera();
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
                  DateTime dateTime = DateTime.parse('${'02315123555482B920231211'.substring(16,24)}');
                  print(dateTime.toString());
                },
                child: Text(
                  widget.nameCard.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
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
