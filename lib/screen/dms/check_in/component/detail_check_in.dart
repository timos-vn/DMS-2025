import 'package:dms/screen/dms/check_in/component/map.dart';
import 'package:dms/screen/dms/check_in/component/rolling_switch_custom.dart';
import 'package:dms/widget/custom_check_out.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dms/model/entity/app_settings.dart';
import 'package:dms/screen/dms/check_in/check_in_bloc.dart';
import 'package:dms/screen/dms/check_in/check_in_event.dart';
import 'package:dms/services/location_service.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/extension/upper_case_to_title.dart';
import 'package:dms/utils/utils.dart';

import '../../../../model/database/data_local.dart';
import '../../../../model/network/response/detail_checkin_response.dart';
import '../../../../model/network/response/list_checkin_response.dart';
import '../../../../themes/colors.dart';
import '../../../../utils/images.dart';
import '../album/album_screen.dart';
import '../check_in_state.dart';
import '../inventory/inventory_screen.dart';
import '../order/order_from_check_in_screen.dart';
import '../ticket/ticket_screen.dart';


class DetailCheckInScreen extends StatefulWidget {
  final int idCheckIn;
  final DateTime dateCheckIn;
  final List<AppSettings> listAppSettings;
  final bool view;
  final bool isCheckInSuccess;
  final bool isSynSuccess;
  final List<ListAlbum> listAlbumOffline;
  final List<ListAlbumTicketOffLine> listAlbumTicketOffLine;
  final String ngayCheckin;
  final String tgHoanThanh;
  final int numberTimeCheckOut;
  final ListCheckIn item;
  final bool isGpsFormCustomer;

  const DetailCheckInScreen({super.key,required this.listAlbumOffline,required this.listAlbumTicketOffLine,
    required this.idCheckIn, required this.dateCheckIn,
    required this.listAppSettings,required this.view,required this.isCheckInSuccess,required this.isSynSuccess,
    required this.ngayCheckin,required this.tgHoanThanh,required this.item ,required this.numberTimeCheckOut,
    this.isGpsFormCustomer = false,
  });

  @override
  _DetailCheckInScreenState createState() => _DetailCheckInScreenState();
}

class _DetailCheckInScreenState extends State<DetailCheckInScreen> with TickerProviderStateMixin {

  late CheckInBloc _bloc;
  late TabController tabController;
  final format = DateFormat.jm();


  final GlobalKey<AlbumImageScreenState> _imageScreenState = GlobalKey();

  List<String> listTabView = ['Kiểm tồn','Hình ảnh','Ticket','Đặt đơn'];



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent
    ));

    Const.selectedAlbumLock = false;
    tabController = TabController(length: listTabView.length, vsync: this);
    _bloc = CheckInBloc(context);
    _bloc.getUserLocation(
        lat: widget.item.gps.toString().replaceAll('null', '').isNotEmpty ? double.parse(widget.item.gps.toString().split(',').first) : 0,
        long: widget.item.gps.toString().replaceAll('null', '').isNotEmpty ? double.parse(widget.item.gps.toString().split(',').last) : 0,
        isCheck: widget.isGpsFormCustomer && widget.item.gps.toString().replaceAll('null', '').isNotEmpty
    );
    _bloc.add(GetPrefsCheckIn());

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<CheckInBloc,CheckInState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            if(widget.isCheckInSuccess == false){
              if(widget.view == true){
                 // _bloc.add(GetDetailCheckIn(idCheckIn: widget.idCheckIn, idCustomer: widget.idCustomer.toString()));
              }
              else{
                if(widget.listAppSettings.isEmpty){
                  // Kiểm tra xem DataLocal.dateTimeStartCheckIn có phải của khách hàng hiện tại không
                  // Nếu không, tạo thời gian check-in mới cho khách hàng này
                  String currentCheckInId = (widget.idCheckIn.toString().trim() + widget.item.maKh.toString().trim());
                  String dateTimeToUse;
                  
                  // Chỉ sử dụng DataLocal.dateTimeStartCheckIn nếu nó thuộc về khách hàng hiện tại
                  if(DataLocal.dateTimeStartCheckIn.isNotEmpty && DataLocal.idCurrentCheckIn == currentCheckInId){
                    dateTimeToUse = DataLocal.dateTimeStartCheckIn;
                  } else {
                    // Tạo thời gian check-in mới cho khách hàng này
                    dateTimeToUse = DateFormat("yyyy-MM-ddTHH:mm:ss").format(DateTime.now());
                    // Clear giá trị cũ để đảm bảo không bị nhầm lẫn
                    DataLocal.dateTimeStartCheckIn = '';
                  }
                  
                  _bloc.add(SaveTimeCheckOut(
                      latLong: widget.item.latLong.toString().trim(),
                      idCheckIn: widget.idCheckIn,
                      idCustomer: widget.item.maKh.toString().trim(),
                      nameStore: widget.item.tenCh.toString(),
                      dateTime: dateTimeToUse,
                      title: widget.item.tieuDe.toString().trim(),
                      ngayCheckIn: widget.dateCheckIn,
                      numberTimeCheckOut: widget.numberTimeCheckOut),);
                }
                else {
                  DataLocal.idCurrentCheckIn = (widget.idCheckIn.toString().trim() + widget.item.maKh.toString().trim());
                  if(Const.checkInOnline == true){
                    _bloc.add(GetDetailCheckInOnlineEvent(idCheckIn: widget.idCheckIn, idCustomer: widget.item.maKh.toString().trim()));
                  }
                }
              }
            }
            else{
            // call api inventory and list Album history
              if(Const.checkInOnline == true){
                _bloc.add(GetDetailCheckInOnlineEvent(idCheckIn: widget.idCheckIn, idCustomer: widget.item.maKh.toString().trim()));
              }
            }
          }
          else if(state is SaveTimeCheckOutSuccess || state is UpdateTimeCheckOutSuccess){
            if(DataLocal.listInventoryLocal.isNotEmpty){
              DataLocal.listInventoryLocal.clear();
            }if(DataLocal.listOrderProductLocal.isNotEmpty){
              DataLocal.listOrderProductLocal.clear();
            }
            if(Const.checkInOnline == true){
              _bloc.add(GetDetailCheckInOnlineEvent(idCheckIn: widget.idCheckIn, idCustomer: widget.item.maKh.toString().trim()));
            }else{
              _bloc.add(GetDetailCheckIn(idCheckIn: widget.idCheckIn, idCustomer: widget.item.maKh.toString().trim()));
            }
          }
          else if(state is CheckOutAddItemSuccess){
            _bloc.add(CheckOutInventoryStockOnline(idCustomer: widget.item.maKh.toString().trim(),idCheckIn: widget.idCheckIn,itemCheckIn: state.itemCheckIn));
          }
          else if(state is CheckOutSuccess){
            if(DataLocal.listInventoryLocal.isNotEmpty){
              DataLocal.listInventoryLocal.clear();
            }
            if(DataLocal.listFileAlbum.isNotEmpty){
              DataLocal.listFileAlbum.clear();
            }

            DataLocal.latLongLocation = '';
            DataLocal.addImageToAlbum = false;
            DataLocal.addressCheckInCustomer = '';
            DataLocal.listInventoryIsChange = true;
            Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Check-out thành công');
            Navigator.pop(context,'RELOAD');
          }
          else if(state is GetImageCheckInLocalSuccess){
            logic();
          }
          else if(state is CheckLocationSuccessState){
            _handleLocationValidationInDetail();
          }
        },
        child: BlocBuilder<CheckInBloc,CheckInState>(
          bloc: _bloc,
          builder: (BuildContext context, CheckInState state){
            return Stack(
              children: [
                buildBody(context,state),
                Visibility(
                  visible: state is CheckInLoading,
                  child: const PendingAction(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context,CheckInState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 7,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 15,child: Divider(color: Colors.blueGrey.withOpacity(0.2),)),
                    Padding(
                      padding: const EdgeInsets.only(left: 4,right: 4),
                      child: Text(DateFormat.yMMMMEEEEd('vi').format(widget.dateCheckIn).toString().toTitleCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500,fontSize: 12),),
                    ),
                    Expanded(child: Divider(color: Colors.blueGrey.withOpacity(0.2),)),
                  ],
                ),
                const SizedBox(height: 15,),
                buildItemLine(Icons.account_circle_outlined, (widget.item.tenCh.toString().trim().isEmpty || widget.item.tenCh.toString().trim() == '') ?'Chưa có tên chủ cửa hàng !' : widget.item.tenCh.toString().trim(),TextStyle(color: (widget.item.tenCh.toString().trim().isEmpty || widget.item.tenCh.toString().trim() == '') ? Colors.blueGrey : Colors.black,fontWeight: FontWeight.bold,fontSize: 12)),
                buildItemLine(Icons.phone, (widget.item.dienThoai.toString().trim().isEmpty || widget.item.dienThoai.toString().trim() == '')  ?'Chưa có SĐT cửa hàng !' : widget.item.dienThoai.toString().trim(),TextStyle(color: (widget.item.dienThoai.toString().trim().isEmpty || widget.item.dienThoai.toString().trim() == '') ? Colors.blueGrey : Colors.black,fontWeight: FontWeight.normal,fontSize: 12)),
                buildItemLine(Icons.location_on_outlined, (widget.item.diaChi.toString().trim().isEmpty || widget.item.diaChi.toString().trim() == '') ?'Chưa có địa chỉ cửa hàng !' : widget.item.diaChi.toString().trim(),TextStyle(color:  (widget.item.diaChi.toString().trim().isEmpty || widget.item.diaChi.toString().trim() == '') ? Colors.grey : subColor,fontSize: 12,fontStyle: FontStyle.italic),),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.alarm,color: subColor,size: 18,),
                                const SizedBox(width: 5,),
                                Expanded(
                                  child: Text('Time check-in:',style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: 13,),),
                                ),
                                Text((widget.item.trangThai == 'Hoàn thành' ? Utils.formatToTime(widget.ngayCheckin.toString()) :
                                (widget.isCheckInSuccess == false && widget.view == true)
                                    ?
                                'Locked'
                                    :
                                Utils.parseStringDateToString(DataLocal.dateTimeStartCheckIn,Const.DATE_SV ,Const.TIME).toString())
                                    ,
                                    style: GoogleFonts.montserrat(
                                      color:widget.view == true ? Colors.grey :  Colors.black,
                                      fontSize: 13,)),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                const Icon(Icons.alarm_off,color: subColor,size: 18,),
                                const SizedBox(width: 5,),
                                Expanded(
                                  child: Text('Time check-out:',style: GoogleFonts.montserrat(
                                    color: Colors.black,
                                    fontSize: 13,),),
                                ),
                                Text(
                                    // (widget.isToday == false && widget.view == true )
                                    //     ?
                                    // 'Locked'
                                    //     :
                                    ((widget.tgHoanThanh.toString() != 'null' && widget.tgHoanThanh.toString() != '') ?
                                    Utils.parseDateTToString(widget.tgHoanThanh.toString(), Const.TIME) : 'Locked'),
                                    style: GoogleFonts.montserrat(color: widget.view == true ? Colors.grey : ( _bloc.openStore == true ? Colors.black : Colors.blueGrey),
                                  fontSize: 13,decoration: _bloc.openStore == true ? TextDecoration.none : TextDecoration.lineThrough)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(width: 10,),
                    Transform.scale(
                      scale: 0.75,
                      child: RollingSwitchCustom(
                        value: _bloc.openStore,
                        width: 150,
                        textOn: 'Mở cửa',
                        textOff: 'Đóng cửa',
                        colorOn: Colors.deepOrange,
                        colorOff: Colors.blueGrey,
                        iconOn: Icons.done,
                        iconOff: Icons.alarm_off,
                        animationDuration: const Duration(milliseconds: 300),
                        onChanged: (bool state) {
                          if (widget.isCheckInSuccess == false && widget.view == false) {
                            _imageScreenState.currentState?.setState(() {
                              Const.selectedAlbumLock = _bloc.openStore;
                            });
                            Const.selectedAlbumLock = _bloc.openStore;
                            _bloc.add(ChangeStatusStoreOpen());
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15,),
                TabBar(
                  controller: tabController,
                  unselectedLabelColor: Colors.grey,
                  labelColor: const Color(0xff0162c1),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  isScrollable: false,
                  indicatorPadding: const EdgeInsets.all(0),
                  indicatorColor: Colors.orange,
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  indicator: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          style: BorderStyle.solid,
                          color: Color(0xff0162c1),
                          width: 2
                      ),
                    ),
                  ),
                  tabs: List<Widget>.generate(listTabView.length, (int index) {
                    return Tab(
                      text: listTabView[index].toString(),
                    );
                  }),
                ),
                Container(height: 10,color: const Color(0xffeaeaea),),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: TabBarView(
                        controller: tabController,
                        children: List<Widget>.generate(listTabView.length, (int index) {
                          if (index == 0) {
                            return InventoryControlScreen(
                              // isToday: widget.isToday,
                              idCheckIn: widget.idCheckIn,
                              idCustomer: widget.item.maKh.toString(),
                              view: widget.view,
                              isCheckInSuccess: widget.isCheckInSuccess,
                            );
                          }else if(index == 1){
                            return AlbumImageScreen(
                              key: _imageScreenState,
                              isCheckInSuccess: widget.isCheckInSuccess,
                              idCheckIn: widget.idCheckIn,
                              idCustomer: widget.item.maKh.toString(),
                              view: widget.view,
                              // listAlbum: Const.checkInOnline == true ? _bloc.listAlbum : widget.listAlbumOffline,
                              isSynSuccess: widget.isSynSuccess,
                            );
                          }
                          else if(index == 2){
                            return TicketScreen(
                              isCheckInSuccess: widget.isCheckInSuccess,
                              isSynSuccess: widget.isSynSuccess,
                              idCustomer: widget.item.maKh.toString(),
                              idCheckIn: widget.idCheckIn,
                              listAlbumTicketOffLine: Const.checkInOnline == true ? _bloc.listTicket : widget.listAlbumTicketOffLine,
                              view: widget.view,
                            );
                          }
                          else{
                            return OrderFromCheckInScreen(
                              nameCustomer: widget.item.tenCh.toString().trim(),
                              phoneCustomer: widget.item.dienThoai.toString(),
                              addressCustomer: widget.item.diaChi.toString(),
                              isCheckInSuccess: widget.isCheckInSuccess,
                              idCheckIn: widget.idCheckIn,
                              idCustomer: widget.item.maKh.toString(),
                              view: widget.view,
                              nameStore: widget.item.tieuDe.toString().trim(),
                            );
                          }
                        })),
                  ),
                ),
                Visibility(
                  visible: state is GetListSCheckInEmpty,
                  child: const Expanded(
                    child: Center(
                      child: Text('Úi, Không có gì ở đây cả!!!',style: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildItemLine(IconData icons, String title, TextStyle textStyle){
    return Padding(
      padding: const EdgeInsets.only(left: 14,right: 8,top: 0,bottom: 8),
      child: Row(
        children: [
          Icon(icons,color: subColor,size: 18,),
          const SizedBox(width: 5,),
          Flexible(child: Text(title,style: textStyle)),
        ],
      ),
    );
  }

  buildAppBar(){
    return Container(
      height: 130,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 42, 8,0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: (){
              // _bloc.getUserLocation();
            },
            child: const CircleAvatar(
              radius: 38,
              backgroundImage: AssetImage(avatarStore),
              backgroundColor: Colors.transparent,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12,bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Text(widget.item.tieuDe.toString().trim().isEmpty ? 'Đang cập nhật' : widget.item.tieuDe.toString().trim(),style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),maxLines: 1,overflow: TextOverflow.ellipsis,),),
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      Icon(MdiIcons.phoneClassic,color: Colors.blueGrey,size: 18,),
                      const SizedBox(width: 8,),
                      Text(widget.item.trangThai.toString().trim() == 'Hoàn thành'
                          ?
                      'Đã viếng thăm'
                          :
                      'Chưa viếng thăm'
                      ,style: TextStyle(color: widget.item.trangThai.toString().trim() == 'Hoàn thành' ? const Color(0xff0162c1) : Colors.red ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: (widget.isCheckInSuccess == false && widget.view == false && widget.item.trangThai.toString().trim() != 'Hoàn thành'),// && DataLocal.dateTimeStartCheckIn.isNotEmpty) ,
            child: GestureDetector(
              onTap: ()async{
                if(widget.isCheckInSuccess == false && widget.view == false){
                  if(widget.isGpsFormCustomer && widget.item.gps.toString().replaceAll('null', '').isNotEmpty){
                    _handleCheckInWithLocationValidation();
                  }else{
                    _bloc.add(GetImageLocalEvent());
                  }
                }
              },
              child: const Padding(
                padding: EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 35,
                  width: 40,
                  child: Icon(Icons.exit_to_app,color: Colors.blueGrey),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }



  // List<ImageCheckIn> listImageCheckIn=[];
  String nameAlbum = '';

  logic(){
    if(_bloc.openStore == false){
      if(DataLocal.addImageToAlbumRequest ==true){
       checkOut();
      }
      else{
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy thêm ảnh vào Album đóng cửa.');
      }
    }
    else {
      if(true/*DateTime.now().isAfter(Utils.parseStringToDate(DataLocal.dateTimeStartCheckIn, Const.DATE_SV).add(Duration(minutes: widget.numberTimeCheckOut)))*/){
        if(DataLocal.addImageToAlbum == true ){
          bool lock = false;
          for (var item in DataLocal.listItemAlbum) {
            if(item.ycAnhYn == true && !item.tenAlbum.toString().contains('đóng cửa')){
              if((_bloc.listImageCheckIn.any((element) => element.maAlbum.toString().trim() == item.maAlbum.toString().trim())) == true){
                lock = false;
              }else{
                lock = true;
              }
            }
            if(lock == true){
              nameAlbum = item.tenAlbum.toString().trim();
              break;
            }
          }
          if(lock == false){
            checkOut();
          }else{
            Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy thêm ảnh vào Album $nameAlbum');
          }
        }
        else{
          Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Hãy thêm ảnh vào Album của bạn.');
        }
      }else{
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn chưa đủ thời gian check-in tại 1 địa điểm');
      }
    }
  }

  void checkOut(){
    showDialog(
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: const CustomCheckOutComponent(
              showTwoButton: true,
              iconData: Icons.exit_to_app,
              title: 'Xác nhận Check-out',
              content: 'Hãy nhập nội dung công việc trước khi check-out nhé',
            ),
          );
        }).then((value)async{
      if(value != null){
        if(!Utils.isEmpty(value) && value[0] == 'Yeah'){
          _bloc.add(CheckOutInventoryStock(
              note: value[1],
              idCheckIn: widget.idCheckIn,
              idCustomer: widget.item.maKh.toString().trim(),
              openStore: _bloc.openStore,
              ngayCheckIn: widget.dateCheckIn,
              numberTimeCheckOut: widget.numberTimeCheckOut,
              item: widget.item,
              gps: '${_bloc.currentLocation?.latitude.toString()},${_bloc.currentLocation?.longitude.toString()}'
          ));
        }
      }
    });
  }

  // Method xử lý validation vị trí trong detail check-in
  void _handleLocationValidationInDetail() {
    try {
      print('📍 Detail: Starting location validation...');
      
      if (widget.item.gps.toString().isEmpty || 
          widget.item.gps.toString() == 'null') {
        print('📍 Detail: No customer coordinates, proceeding without location check');
        _bloc.add(GetImageLocalEvent());
        return;
      }
      
      // Validate check-in với LocationService
      CheckInValidationResult validation = LocationService.validateCheckIn(
        customerLatLong: widget.item.gps.toString(),
        currentPosition: _bloc.currentLocation,
        maxAllowedDistance: Const.distanceLocationCheckIn,
      );
      
      if (validation.isSuccess) {
        print('📍 Detail: Check-in validation successful: distance=${validation.distance!.toStringAsFixed(2)}m');
        _bloc.add(GetImageLocalEvent());
        
      } else if (validation.isDistanceExceeded) {
        print('📍 Detail: Distance exceeded: ${validation.distance!.toStringAsFixed(2)}m > ${validation.maxAllowed}m');
        _showDistanceExceededDialogInDetail(validation);
        
      } else {
        print('📍 Detail: Check-in validation failed: ${validation.error}');
        _showLocationErrorDialogInDetail(validation);
      }
      
    } catch (e) {
      print('❌ Detail: Check-in validation error: $e');
      Utils.showCustomToast(context, Icons.error_outline, 
        'Lỗi kiểm tra vị trí. Vui lòng thử lại.');
    }
  }

  // Method xử lý check-in với validation vị trí
  void _handleCheckInWithLocationValidation() {
    _handleLocationValidationInDetail();
  }
  
  // Hiển thị dialog khi khoảng cách vượt quá trong detail
  void _showDistanceExceededDialogInDetail(CheckInValidationResult validation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => BlocProvider.value(
        value: _bloc,
        child: MapView(
          latStart: widget.item.gps.toString().split(',')[0],
          longStart: widget.item.gps.toString().split(',')[1],
          latEnd: _bloc.currentLocation?.latitude??0,
          longEnd: _bloc.currentLocation?.longitude??0,
          metter: validation.distance!,
          title: 'Khoảng cách vượt quá cho phép',
        ),
      ),
    ).then((value) {
      if(value != null && value[0] == "Accepted"){
        _bloc.add(GetImageLocalEvent());
      }
    });
  }
  
  // Hiển thị dialog lỗi vị trí trong detail
  void _showLocationErrorDialogInDetail(CheckInValidationResult validation) {
    String message = validation.error ?? 'Lỗi không xác định';
    bool showRetry = validation.showRetry;
    
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Lỗi vị trí GPS'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (validation.accuracy != null) ...[
              const SizedBox(height: 8),
              Text('Độ chính xác GPS: ${validation.accuracy!.toStringAsFixed(0)}m', 
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          if (showRetry)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _bloc.getFreshLocation();
              },
              child: const Text('Thử lại'),
            ),
        ],
      ),
    );
  }
}

// extension EnumExt on FloatingActionButtonLocation {
//   /// Get Value of The SpeedDialDirection Enum like Up, Down, etc. in String format
//   String get value => toString().split(".")[1];
// }