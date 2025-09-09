import 'dart:convert';

import 'package:dms/screen/qr_code/component/scanner_panel_widget.dart';
import 'package:dms/screen/qr_code/component/view_infor_card.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/barcode_scanner_widget.dart';
import 'package:dms/widget/custom_choose_function.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:vibration/vibration.dart';

import '../../../model/network/response/qr_code_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../qr_code_bloc.dart';
import '../qr_code_event.dart';
import '../qr_code_sate.dart';


class QRCodeGeneratorWidget extends StatefulWidget {
  const QRCodeGeneratorWidget({Key? key,}) : super(key: key);

  @override
  State<QRCodeGeneratorWidget> createState() => _MyHomePageState();
}
class _MyHomePageState extends State<QRCodeGeneratorWidget> with TickerProviderStateMixin {
  late QRCodeBloc _bloc;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR3');

  late TabController tabController;
  bool isScan = false;
  int indexSelected = 0;
  QrcodeResponse qrcodeResponse = QrcodeResponse();
  String valuesCheck = '';


  final PanelController _panelController = PanelController();
  String key = '';
  bool clickUpdateLocation = false;
  String titleApp = 'Đặt QRcode vào khung';

  bool isLoad = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = QRCodeBloc(context);
    tabController = TabController(vsync: this, length: Const.listFunctionQrCode.length);
    _bloc.add(GetCameraEvent());
  }

  @override
  void dispose() {
    // Stop camera when leaving the screen
    BarcodeScannerWidget.globalKey.currentState?.stopCamera();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocListener<QRCodeBloc,QRCodeState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetQuantityForTicketSuccess){
            if(state.allowCreate == true){
              print('adx 0');
              showDialog(
                  context: context,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: CustomChooseFunction(
                        title: 'Chức năng Phiếu',
                        content: 'Vui lòng chọn chức năng để thao tác', keyFnc: key.toString(),
                      ),
                    );
                  }).then((value) {
                isLoad = false;
                if(!Utils.isEmpty(value) && value[0] == 'Yeah'){
                  key = value[1].toString();
                  if(value[1].toString() == '#6'){
                    setState(() {
                      _panelController.animatePanelToPosition(1.0);
                    });
                  }else{
                    // Stop camera before navigating
                    BarcodeScannerWidget.globalKey.currentState?.stopCamera();
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewInformationCardScreen(
                      ruleActionInformationCard: _bloc.ruleActionInformationCard,
                      listItemCard: _bloc.listItemCard,
                      masterInformationCard: _bloc.masterInformationCard,
                      keyFunction: key ,
                      nameCard:  Const.listFunctionQrCode[indexSelected].description.toString(),
                      formatProvider: _bloc.formatProvider,
                    ))).then((value) {
                      // Restart camera when returning
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          BarcodeScannerWidget.globalKey.currentState?.startCamera();
                        }
                      });
                      buildFunc(indexSelected);
                    });
                  }
                }
                else{
                  buildFunc(indexSelected);
                }
              });
            }else{
              isLoad = false;
              lastScannedValue = null;
              valuesBarcode = '';
              Utils.showCustomToast(context, Icons.warning_amber, 'Không thể tạo phiếu, do số lượng đã đủ');
            }
          }
          else if(state is GetInformationCardSuccess){
            if(state.updateLocation == true){
              BarcodeScannerWidget.globalKey.currentState?.stopCamera();
            }
            if( _bloc.ruleActionInformationCard.status == 2){
              if(Const.allowCreateTicketShipping){
                _bloc.add(GetQuantityForTicketEvent(sttRec: _bloc.masterInformationCard.sttRec.toString(), key: key.toString()));
              }
              else{
                print('adx 1');
                showDialog(
                    context: context,
                    builder: (context) {
                      return WillPopScope(
                        onWillPop: () async => false,
                        child: CustomChooseFunction(
                          title: 'Chức năng Phiếu',
                          content: 'Vui lòng chọn chức năng để thao tác', keyFnc: key.toString(),
                        ),
                      );
                    }).then((value) {
                  isLoad = false;
                  if(!Utils.isEmpty(value) && value[0] == 'Yeah'){
                    key = value[1].toString();
                    if(value[1].toString() == '#6'){
                      setState(() {
                        _panelController.animatePanelToPosition(1.0);
                      });
                    }else{
                      // Stop camera before navigating
                      BarcodeScannerWidget.globalKey.currentState?.stopCamera();
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewInformationCardScreen(
                        ruleActionInformationCard: _bloc.ruleActionInformationCard,
                        listItemCard: _bloc.listItemCard,
                        masterInformationCard: _bloc.masterInformationCard,
                        keyFunction: key ,
                        nameCard:  Const.listFunctionQrCode[indexSelected].description.toString(),
                        formatProvider: _bloc.formatProvider,
                      ))).then((value) {
                        // Restart camera when returning
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            BarcodeScannerWidget.globalKey.currentState?.startCamera();
                          }
                        });
                        buildFunc(indexSelected);
                      });
                    }
                  }
                  else{
                    buildFunc(indexSelected);
                  }
                });
              }
            }
            else if(_bloc.ruleActionInformationCard.status == 1){
              // buildFunc(indexSelected);
              setState(() {
                isLoad = false;
                _panelController.animatePanelToPosition(1.0);
              });
            }
            else{
              isLoad = false;
              lastScannedValue = null;
              valuesBarcode = '';
              Utils.showCustomToast(context, Icons.warning_amber, 'Bạn không có quyền truy cập');
            }
          }
          else if (state is GetKeyBySttRecSuccess) {
            titleApp = state.title.toString();
            viewTicket(state.valuesKey.toString(), valuesBarcode);
          }
          else if(state is QRCodeFailure){
            isLoad = false;
            valuesBarcode = '';
            lastScannedValue = null;
            Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
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

  void viewTicket(String valuesKey, String barcode) async {
    final String cleanedKey = valuesKey.trim().replaceAll('null', '');
    if (cleanedKey.isNotEmpty && cleanedKey != '0') {
      _bloc.add(GetInformationCardEvent(
        idCard: qrcodeResponse.sttRec.toString(),
        key: cleanedKey,
      ));
    } else {
      isLoad = false;
      Utils.showCustomToast(context, Icons.warning_amber, 'Bạn đang chọn sai phiếu nè');
    }
  }


  buildScreen(context,QRCodeState state){
    return SizedBox(
        height: MediaQuery.of(context).size.height,
        width:  MediaQuery.of(context).size.width,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: subColor,
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            title: const Text('QRCode', style: TextStyle(color: Colors.white,),),
            centerTitle: true,
            elevation: 0,
          ),
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color:  Colors.black,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: subColor,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 5),
                        SizedBox(
                          height: 35,width: double.infinity,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  clickUpdateLocation = true;
                                  _bloc.add(GetInformationCardEvent(idCard: 'A000001219HDA',key: '#5',updateLocation: true));
                                },
                                child: Container(
                                  height: 35,
                                  width: 125,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(color:clickUpdateLocation == true ? Colors.white : Colors.grey,width: 1),
                                      borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(EneftyIcons.location_outline,color: clickUpdateLocation == true ? Colors.white : Colors.grey,size: 15,),
                                      Text('  Cập nhật vị trí'
                                        ,style: TextStyle(color:clickUpdateLocation == true ? Colors.white : Colors.grey),),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  height: 35,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                      side: const BorderSide(width: 1.0,
                                        color:   Colors.white ,
                                      ),
                                    ),
                                    onPressed: () async{

                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.qr_code_2_rounded, color:  Colors.white  ),
                                        const SizedBox(width: 3,),
                                        Text(titleApp.toString().trim(),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal)),
                                      ],
                                    ),
                                  ),
                                  // child: TabBar(
                                  //   controller: tabController,
                                  //   unselectedLabelColor: white,
                                  //   labelColor: orange,
                                  //   labelStyle: const TextStyle(fontWeight: FontWeight.normal),
                                  //   isScrollable: true,
                                  //   padding: EdgeInsets.zero,
                                  //   indicator:const BoxDecoration(color: Colors.transparent, borderRadius:  BorderRadius.all(Radius.circular(10))),
                                  //   tabs: List<Widget>.generate(Const.listFunctionQrCode.length, (int index) {
                                  //     return Tab(
                                  //       child:  OutlinedButton(
                                  //         style: OutlinedButton.styleFrom(
                                  //           shape: RoundedRectangleBorder(
                                  //             borderRadius: BorderRadius.circular(16.0),
                                  //           ),
                                  //           side: BorderSide(width: 1.0,
                                  //             color: (indexSelected == index && clickUpdateLocation == false) ? Colors.white : Colors.grey.withOpacity(0.2),
                                  //           ),
                                  //         ),
                                  //         onPressed: () async{
                                  //           buildFunc(index);
                                  //         },
                                  //         child: Row(
                                  //           children: [
                                  //             Icon(Icons.qr_code_2_rounded, color: (indexSelected == index && clickUpdateLocation == false) ? Colors.white  : Colors.grey,),
                                  //             const SizedBox(width: 3,),
                                  //             Text(Const.listFunctionQrCode[index].description.toString().trim(),
                                  //                 style: TextStyle(
                                  //                     color: (indexSelected == index && clickUpdateLocation == false)
                                  //                         ? Colors.white
                                  //                         : Colors.grey,
                                  //                     fontSize: 15,
                                  //                     fontWeight: FontWeight.normal)),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     );
                                  //   }),
                                  // ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Center(child: buildScanner())),
              ]),
        ));
  }

  buildScanner(){
    return SlidingUpPanel(
      maxHeight: MediaQuery.of(context).size.height * .90,
      minHeight: (valuesCheck == key.toString().trim() &&  valuesBarcode.isNotEmpty) ? MediaQuery.of(context).size.height * .30 : 0,
      parallaxEnabled: true,
      controller: _panelController,
      parallaxOffset: .5,
      isDraggable: (valuesCheck == key.toString().trim() &&  valuesBarcode.isNotEmpty),
      panelBuilder: (ScrollController sc){
        return ScannerPanelWidget(
          confirmInformationCard: confirmInformationCard,
          ruleActionInformationCard: _bloc.ruleActionInformationCard,
          listItemCard: _bloc.listItemCard,
          masterInformationCard: _bloc.masterInformationCard,
          scrollController: sc, keyFunction: key.toString(), qrCodeBloc: _bloc,);
      },
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
      body: buildCamera(),
    );
  }
  String valuesBarcode = '';
  String? lastScannedValue;
  void confirmInformationCard(){
    buildFunc(indexSelected);
  }

  buildFunc(int index){
    clickUpdateLocation = false;
    titleApp = 'Đặt QRcode vào khung';
    setState(() {
      indexSelected = index;
      valuesBarcode = '';
      lastScannedValue = null;
    });
    _panelController.close();
  }

  buildCamera(){
    return BarcodeScannerWidget(
        framePadding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height/2),
        onBarcodeDetected: (String values) async {
          final trimmedValue = values.trim();

          // Nếu mã giống lần trước hoặc đang trong trạng thái loading, thì bỏ qua
          if (trimmedValue.isEmpty || isLoad || trimmedValue == lastScannedValue) {
            return;
          }

          lastScannedValue = trimmedValue;

          if ((await Vibration.hasVibrator()) ?? false) {
            Vibration.vibrate();
          }

          valuesBarcode = trimmedValue;

          if (trimmedValue.contains('key')) {
            try {
              final body = json.decode(trimmedValue);
              qrcodeResponse = QrcodeResponse.fromJson(body);
              valuesCheck = Const.listFunctionQrCode[indexSelected].key.toString().trim();

              if (qrcodeResponse.sttRec.toString().replaceAll('null', '').isNotEmpty) {
                isLoad = true;
                _bloc.add(GetKeyBySttRecEvent(sttRec: qrcodeResponse.sttRec.toString()));
              }
            } catch (e) {
              Utils.showCustomToast(context, Icons.warning_amber, 'Lỗi đọc mã QR');
            }
          } else {
            Utils.showCustomToast(context, Icons.warning_amber, 'Sai định dạng mã quét');
          }
        }

    );
  }
}
