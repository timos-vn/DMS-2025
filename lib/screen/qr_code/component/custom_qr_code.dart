import 'dart:convert';

import 'package:dms/screen/qr_code/component/scanner_panel_widget.dart';
import 'package:dms/screen/qr_code/component/update_item_position.dart';
import 'package:dms/screen/qr_code/component/view_infor_card.dart';
import 'package:dms/widget/barcode_scanner_widget.dart';
import 'package:dms/utils/utils.dart';
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
class _MyHomePageState extends State<QRCodeGeneratorWidget> with TickerProviderStateMixin, WidgetsBindingObserver {
  late QRCodeBloc _bloc;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR3');

  late TabController tabController;
  bool isScan = false;
  int indexSelected = 0;
  QrcodeResponse qrcodeResponse = QrcodeResponse();
  String valuesCheck = '';

  final PanelController _panelController = PanelController();
  String keyFunction = '';
  bool clickUpdateLocation = false;
  String titleApp = 'Đặt QRcode vào khung';

  bool isLoad = false;
  bool _isRecreatingCamera = false; // Flag để tránh recreate nhiều lần
  bool _didChangeDependenciesCalled = false; // ✅ Flag để tránh didChangeDependencies gọi nhiều lần
  
  // ✅ Camera instance riêng cho màn hình này
  GlobalKey _cameraKey = GlobalKey();
  Key _cameraWidgetKey = UniqueKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = QRCodeBloc(context);
    tabController = TabController(vsync: this, length: Const.listFunctionQrCode.length);
    // ✅ REMOVED: Không cần gọi GetCameraEvent vì BarcodeScannerWidget tự check permission
    // _bloc.add(GetCameraEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // ✅ Chỉ recreate camera 1 lần duy nhất
    if (_didChangeDependenciesCalled) {
      debugPrint('didChangeDependencies - already called, skipping camera recreation');
      return;
    }
    
    _didChangeDependenciesCalled = true;
    debugPrint('didChangeDependencies - recreating camera for screen focus (ONCE)');
    
    // Delay để đảm bảo context đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _recreateCameraWidget();
      }
    });
  }

  @override
  void didUpdateWidget(QRCodeGeneratorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart camera when widget is updated
    debugPrint('didUpdateWidget - restarting camera');
    _restartCameraWithRetry();
  }


  /// Recreate camera widget hoàn toàn (dùng khi pause/resume)
  void _recreateCameraWidget() {
    final stackTrace = StackTrace.current;
    final callerInfo = stackTrace.toString().split('\n').take(3).join('\n   ');
    debugPrint('=== Recreating camera widget completely ===');
    debugPrint('   Called from:\n   $callerInfo');
    
    if (!mounted || _isRecreatingCamera) {
      debugPrint('=== Skipping camera recreate - already in progress or not mounted ===');
      return;
    }
    
    _isRecreatingCamera = true;
    
    // Reset scan states để có thể quét lại
    lastScannedValue = null;
    valuesBarcode = '';
    isLoad = false;
    
    // Stop camera trước khi recreate
    try {
      (_cameraKey.currentState as dynamic)?.stopCamera();
    } catch (e) {
      debugPrint('=== Error stopping camera before recreate: $e ===');
    }
    
    // ✅ Single delay và setState để tránh tạo 2 widgets
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) {
        _isRecreatingCamera = false;
        return;
      }
      
      // ✅ Chỉ 1 setState duy nhất, reset flag ngay trong đó
      setState(() {
        _cameraKey = GlobalKey();
        _cameraWidgetKey = UniqueKey();
        _isRecreatingCamera = false; // ✅ Reset trong setState
      });
      
      debugPrint('=== Camera widget recreated successfully ===');
      // buildFunc sẽ được gọi tự động bởi setState → build()
    });
  }

  @override
  void dispose() {
    // ✅ Stop camera safely when leaving the screen
    WidgetsBinding.instance.removeObserver(this);
    try {
      (_cameraKey.currentState as dynamic)?.stopCamera();
      debugPrint('=== CustomQRCode: Camera stopped in dispose ===');
    } catch (e) {
      debugPrint('=== CustomQRCode: Error stopping camera in dispose: $e ===');
    }
    
    // ✅ Reset processing state when leaving screen
    isLoad = false;
    _isRecreatingCamera = false;
    debugPrint('=== CustomQRCode disposed - reset states ===');
    
    tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      // ✅ Force recreate camera when app resumes
      debugPrint('App resumed - force recreating camera');
      _recreateCameraWidget();
    } else if (state == AppLifecycleState.paused) {
      // ✅ Stop camera when app is paused
      debugPrint('App paused - stopping camera');
      (_cameraKey.currentState as dynamic)?.stopCamera();
    }
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        // Reset scan states và recreate camera when back to this screen
        debugPrint('WillPopScope - resetting scan states and recreating camera for back navigation');
        lastScannedValue = null;
        valuesBarcode = '';
        isLoad = false;
        _recreateCameraWidget();
        return true;
      },
      child: Scaffold(
        body: BlocListener<QRCodeBloc,QRCodeState>(
          bloc: _bloc,
          listener: (context,state){
          if(state is GetQuantityForTicketSuccess){
            if(state.allowCreate == true){
              showDialog(
                  context: context,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: CustomChooseFunction(
                        title: 'Chức năng Phiếu',
                        content: 'Vui lòng chọn chức năng để thao tác', keyFnc: keyFunction.toString(),
                      ),
                    );
                  }).then((value) {
                isLoad = false;
                if(!Utils.isEmpty(value) && value[0] == 'Yeah'){
                  keyFunction = value[1].toString();
                  if(value[1].toString() == '#6'){
                    setState(() {
                      _panelController.animatePanelToPosition(1.0);
                    });
                  }else{
                    try {
                      (_cameraKey.currentState as dynamic)?.stopCamera();
                      debugPrint('=== CustomQRCode: Camera stopped before navigation ===');
                      // Đợi một chút để camera được dừng hoàn toàn
                      Future.delayed(const Duration(milliseconds: 500), () {
                        // Camera đã được dừng, tiếp tục navigation
                      });
                    } catch (e) {
                      debugPrint('Error stopping camera: $e');
                    }
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewInformationCardScreen(
                        ruleActionInformationCard: _bloc.ruleActionInformationCard,
                        listItemCard: _bloc.listItemCard,
                        masterInformationCard: _bloc.masterInformationCard,
                        keyFunction: keyFunction ,
                        nameCard: titleApp.toString(),
                        bloc: _bloc, // Truyền bloc instance
                        formatProvider: _bloc.formatProvider,
                    ))).then((value) {
                        _panelController.close();
                        clickUpdateLocation = false;
                        valuesBarcode = '';
                        lastScannedValue = '';
                        _recreateCameraWidget();
                    });
                  }
                }
                else{
                  buildFunc(indexSelected);
                }
              });
            }
            else{
              isLoad = false;
              lastScannedValue = null;
              valuesBarcode = '';
              Utils.showCustomToast(context, Icons.warning_amber, 'Không thể tạo phiếu, do số lượng đã đủ');
            }
          }
          else if(state is GetInformationCardSuccess){
            if(state.updateLocation == true){
              (_cameraKey.currentState as dynamic)?.stopCamera();
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const UpdateItemPosition())).then((value){
                setState(() {
                  _panelController.close();
                  clickUpdateLocation = false;
                  valuesBarcode = '';
                  lastScannedValue = '';
                  _recreateCameraWidget();
                });
              });
            }
            else if( _bloc.ruleActionInformationCard.status == 2){
              if((keyFunction == '#7'|| keyFunction == '#3' || keyFunction == '#1') && !Const.allowCreateTicketShipping){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewInformationCardScreen(
                  ruleActionInformationCard: _bloc.ruleActionInformationCard,
                  listItemCard: _bloc.listItemCard,
                  masterInformationCard: _bloc.masterInformationCard,
                  keyFunction: keyFunction ,
                  nameCard: titleApp.toString(),
                  bloc: _bloc, // Truyền bloc instance
                  formatProvider: _bloc.formatProvider,
                ))).then((value) {
                  _panelController.close();
                  clickUpdateLocation = false;
                  valuesBarcode = '';
                  lastScannedValue = '';
                  _recreateCameraWidget();
                });
              }
              else{
                if(Const.allowCreateTicketShipping){
                  _bloc.add(GetQuantityForTicketEvent(sttRec: _bloc.masterInformationCard.sttRec.toString(), key: keyFunction.toString()));
                }
                else{
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: CustomChooseFunction(
                            title: 'Chức năng Phiếu',
                            content: 'Vui lòng chọn chức năng để thao tác', keyFnc: keyFunction.toString(),
                          ),
                        );
                      }).then((value) {
                    isLoad = false;
                    if(!Utils.isEmpty(value) && value[0] == 'Yeah'){
                      keyFunction = value[1].toString();
                      if(value[1].toString() == '#6'){
                        setState(() {
                          _panelController.animatePanelToPosition(1.0);
                        });
                      }else{
                        // ✅ Dừng camera an toàn trước khi chuyển màn hình
                        try {
                          (_cameraKey.currentState as dynamic)?.stopCamera();
                          debugPrint('=== CustomQRCode: Camera stopped before navigation ===');
                          // Đợi một chút để camera được dừng hoàn toàn
                          Future.delayed(const Duration(milliseconds: 500), () {
                            // Camera đã được dừng, tiếp tục navigation
                          });
                        } catch (e) {
                          debugPrint('Error stopping camera: $e');
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewInformationCardScreen(
                          ruleActionInformationCard: _bloc.ruleActionInformationCard,
                          listItemCard: _bloc.listItemCard,
                          masterInformationCard: _bloc.masterInformationCard,
                          keyFunction: keyFunction ,
                          nameCard: titleApp.toString(),
                          bloc: _bloc, // Truyền bloc instance
                          formatProvider: _bloc.formatProvider,
                        ))).then((value) {
                          _panelController.close();
                          clickUpdateLocation = false;
                          valuesBarcode = '';
                          lastScannedValue = '';
                          _recreateCameraWidget();
                        });
                      }
                    }
                    else{
                      buildFunc(indexSelected);
                    }
                  });
                }
              }
            }
            else if(_bloc.ruleActionInformationCard.status == 1){
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
            keyFunction = state.valuesKey.toString();
            viewTicket(state.valuesKey.toString(), valuesBarcode);
          }
          else if(state is QRCodeFailure){
            isLoad = false;
            valuesBarcode = '';
            lastScannedValue = null;
            Utils.showCustomToast(context, Icons.check_circle_outline, state.error.toString());
          }
          else if(state is GetInformationItemFromBarCodeNotSuccess){
            _showUnknownTicketDialog(state.barcode);
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
        )
      )
    ));
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
            iconTheme: const IconThemeData(
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
      minHeight: (valuesCheck == keyFunction.toString().trim() &&  valuesBarcode.isNotEmpty) ? MediaQuery.of(context).size.height * .30 : 0,
      parallaxEnabled: true,
      controller: _panelController,
      parallaxOffset: .5,
      isDraggable: (valuesCheck == keyFunction.toString().trim() &&  valuesBarcode.isNotEmpty),
      panelBuilder: (ScrollController sc){
        return ScannerPanelWidget(
          confirmInformationCard: confirmInformationCard,
          ruleActionInformationCard: _bloc.ruleActionInformationCard,
          listItemCard: _bloc.listItemCard,
          masterInformationCard: _bloc.masterInformationCard,
          scrollController: sc, keyFunction: keyFunction.toString(), qrCodeBloc: _bloc,);
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

  buildFunc(int index) async {
    if (!mounted) return;
    
    clickUpdateLocation = false;
    titleApp = 'Đặt QRcode vào khung';
    setState(() {
      indexSelected = index;
      valuesBarcode = '';
      lastScannedValue = null;
      isLoad = false; // Reset loading state
    });
    _panelController.close();
    
    // ✅ Reset dữ liệu cũ để cho phép quét dữ liệu mới
    _bloc.add(ResetDataEvent());
    
    // Debug camera state
    debugPrint('buildFunc - camera key: ${_cameraKey.toString()}');
    debugPrint('buildFunc - camera state: ${_cameraKey.currentState}');
    debugPrint('buildFunc - reset scan states: lastScannedValue=null, valuesBarcode="", isLoad=false');
    debugPrint('buildFunc - reset old data to allow new scan');
    debugPrint('buildFunc - camera will start automatically');
  }


  buildCamera(){
    return Container(
      key: _cameraWidgetKey, // ✅ Force rebuild với unique key
      child: BarcodeScannerWidget(
        key: _cameraKey, // ✅ Sử dụng camera key riêng
        framePadding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height/2),
        onBarcodeDetected: (String values) async {
          final trimmedValue = values.trim();

          // Nếu mã giống lần trước hoặc đang trong trạng thái loading, thì bỏ qua
          if (trimmedValue.isEmpty || isLoad || (lastScannedValue != null && trimmedValue == lastScannedValue)) {
            return;
          }

          lastScannedValue = trimmedValue;

          if (await Vibration.hasVibrator() == true) {
            Vibration.vibrate();
          }

          valuesBarcode = trimmedValue;

          // Xử lý barcode thông thường (không phải QR code chứa 'key')
          if (!trimmedValue.contains('key')) {
            // Gọi hàm xử lý barcode từ ViewInformationCardScreen
            _handleBarcodeScan(trimmedValue);
            return;
          }

          // Xử lý QR code chứa 'key' (logic cũ)
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
            Utils.showCustomToast(context, Icons.warning_amber, 'Sai định dạng mã quét - ');
          }
        }

      ),
    );
  }

  // Hàm xử lý barcode thông thường
  void _handleBarcodeScan(String barcode) {
    // Gọi trực tiếp hàm xử lý barcode từ ViewInformationCardScreen
    ViewInformationCardScreen.handleBarcodeScanStatic(
      barcode, 
      _bloc, 
      Const.listFunctionQrCode[indexSelected].key.toString(),
      context
    );
  }

  /// Restart camera với retry mechanism và force rebuild
  void _restartCameraWithRetry({int retryCount = 0, int maxRetries = 3}) {
    if (!mounted) return;
    
    debugPrint('=== Attempting to restart camera (attempt ${retryCount + 1}/$maxRetries) ===');
    
    // Force recreate camera widget với unique key mới
    setState(() {
      _cameraKey = GlobalKey();
      _cameraWidgetKey = UniqueKey();
    });
    
    // Sử dụng addPostFrameCallback để đảm bảo widget đã được build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      Future.delayed(Duration(milliseconds: 300 + (retryCount * 100)), () {
        if (!mounted) return;
        
        try {
          // Kiểm tra xem camera key có tồn tại không
          final cameraState = _cameraKey.currentState;
          if (cameraState == null) {
            debugPrint('=== Camera state is null, retrying... ===');
            if (retryCount < maxRetries - 1) {
              _restartCameraWithRetry(retryCount: retryCount + 1, maxRetries: maxRetries);
            } else {
              debugPrint('=== Max retries reached, force rebuilding widget ===');
              setState(() {
                _cameraWidgetKey = UniqueKey();
              });
              buildFunc(indexSelected);
            }
            return;
          }
          
          // Thử start camera
          (cameraState as dynamic)?.startCamera();
          debugPrint('=== Camera restarted successfully ===');
          buildFunc(indexSelected);
          
        } catch (e) {
          debugPrint('=== Error restarting camera: $e ===');
          if (retryCount < maxRetries - 1) {
            debugPrint('=== Retrying camera restart... ===');
            _restartCameraWithRetry(retryCount: retryCount + 1, maxRetries: maxRetries);
          } else {
            debugPrint('=== Max retries reached, force rebuilding widget ===');
            setState(() {
              _cameraWidgetKey = UniqueKey();
            });
            buildFunc(indexSelected);
          }
        }
      });
    });
  }
  /// Hiển thị popup xác nhận khi phiếu không xác định
  void _showUnknownTicketDialog(String barcode) {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng bằng cách tap outside
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Barcode không xác định',
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
                'Không tìm thấy thông tin cho barcode:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  barcode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Bạn có muốn tiếp tục quét barcode khác không?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                // Có thể thêm logic khác nếu cần
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
                Navigator.of(context).pop(); // Đóng dialog
                // Reset để cho phép quét barcode mới
                setState(() {
                  valuesBarcode = '';
                  buildFunc(indexSelected);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Tiếp tục quét',
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
