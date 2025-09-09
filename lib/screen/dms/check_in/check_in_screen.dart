// ignore_for_file: library_private_types_in_public_api, unrelated_type_equality_checks

import 'dart:io' show Platform;
import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/dms/check_in/component/map.dart';
import 'package:dms/screen/dms/check_in/search_task/search_task_screen.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:dms/widget/question_checkin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:dms/screen/dms/check_in/check_in_event.dart';
import 'package:dms/screen/dms/check_in/component/detail_check_in.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/extension/upper_case_to_title.dart';
import 'package:dms/utils/utils.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/database/dbhelper.dart';
import '../../../model/entity/item_check_in.dart';
import '../../../model/network/response/detail_checkin_response.dart';
import '../../../model/network/response/list_checkin_response.dart';
import '../../../themes/colors.dart';
import '../../personnel/time_keeping/component/home_test.dart';
import 'package:dms/extension/extension_compare_date.dart';
import '../../sell/cart/confirm_order_screen.dart';
import '../sale_out/sale_out_screen.dart';
import 'check_in_bloc.dart';
import 'check_in_state.dart';


class CheckInScreen extends StatefulWidget {
  final List<ItemCheckInOffline> listCheckInToDay;
  final List<ListAlbum> listAlbumOffline;
  final List<ListAlbumTicketOffLine> listAlbumTicketOffLine;
  final bool reloadData;
  final String userId;
  const CheckInScreen({Key? key,required this.listCheckInToDay, required this.listAlbumTicketOffLine,
    required this.listAlbumOffline,required this.reloadData,
    required this.userId
  }) : super(key: key);

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {

  late CheckInBloc _bloc;
  String currencyCode = 'VND';
  CalendarFormat _calendarFormat = CalendarFormat.week;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final _controller = ScrollController();

  final ScrollController? controller  = ScrollController();

  ListCheckIn itemSelect = ListCheckIn();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DataLocal.currentLocations = null;
    _bloc = CheckInBloc(context);
    _bloc.add(GetPrefsCheckIn());
    _bloc.listCheckInOffline = widget.listCheckInToDay;
    _selectedDay = _focusedDay;
  }

  DatabaseHelper db = DatabaseHelper();

  bool isToday = true;

  @override
  void dispose() {
    super.dispose();

  }

  Future<void> _openGoogleMapsWithAddress(String address) async {
    final String trimmed = address.replaceAll('null', '').trim();
    if (trimmed.isEmpty) {
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Địa chỉ trống, không thể mở Google Maps');
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mở bản đồ'),
        content: Text('Bạn có muốn mở bản đồ với địa chỉ:\n\n$trimmed'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mở'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final String encoded = Uri.encodeComponent(trimmed);

    if (Platform.isIOS) {
      final Uri iosAppUri = Uri.parse('comgooglemaps://?q=$encoded');
      try {
        if (await canLaunchUrl(iosAppUri)) {
          await launchUrl(iosAppUri, mode: LaunchMode.externalApplication);
          return;
        }
        // Fallback to Apple Maps if Google Maps app is not available
        final Uri appleMapsUri = Uri.parse('http://maps.apple.com/?q=$encoded');
        if (await canLaunchUrl(appleMapsUri)) {
          await launchUrl(appleMapsUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    } else if (Platform.isAndroid) {
      final Uri androidGeoUri = Uri.parse('geo:0,0?q=$encoded');
      try {
        if (await canLaunchUrl(androidGeoUri)) {
          await launchUrl(androidGeoUri, mode: LaunchMode.externalApplication);
          return;
        }
      } catch (_) {}
    }

    final Uri webUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    try {
      final launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (!launched) {
        Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Không thể mở Google Maps');
      }
    } catch (_) {
      Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Không thể mở Google Maps');
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
      if(!DateTime.now().isSameDate(_selectedDay??_focusedDay)){
        isToday = false;
      }else{
        isToday = true;
      }
      if(_bloc.listCheckInOther.isNotEmpty){
        _bloc.listCheckInOther.clear();
      }
      if(Const.checkInOnline == true){
        _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
      }else{
        if(!DateTime.now().isSameDate(_selectedDay??_focusedDay)){
          _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<CheckInBloc,CheckInState>(
        bloc: _bloc,
        listener: (context,state){
          if(state is GetPrefsSuccess){
            if(widget.reloadData == true){
              _bloc.add(GetListTaskOffLineEvent(reloadData: true));
            }else{
              if(Const.checkInOnline == true){
                _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
              }else{
                _bloc.add(UpdateListCheckIn());
              }
            }
          }
          else if(state is GetListTaskOffLineSuccess){
            if(state.reloadData == true){
              if(Const.checkInOnline == true){
                _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
              }else{
                _bloc.add(UpdateListCheckIn());
              }
            }
          }
          else if(state is CheckInFailure){
            Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error.toString());
          }
          else if(state is UpdateListCheckInSuccess){
            _bloc.getUserLocation();
          }
          else if(state is GetTimeCheckOutSaveSuccess){
            /// Đã check-in thành công
            if(state.itemSelect.isCheckInSuccessful == true){
              pushNewDetailScreen(item: state.itemSelect,view: true, isCheckInSuccess: true);
            }
            /// Chưa check-in
            else{
              if(_bloc.listAppSettings.isEmpty){
                pushNewDetailScreen(item: state.itemSelect,view: false, isCheckInSuccess: false);
              }
              else {
                if(_bloc.listAppSettings[0].id == ('${state.itemSelect.id.toString().trim()}${state.itemSelect.maKh.toString().trim()}')){
                  pushNewDetailScreen(item: state.itemSelect,view: false, isCheckInSuccess: false);
                }
                else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: CustomQuestionCheckInComponent(
                            showTwoButton: true,
                            iconData: Icons.warning_amber_outlined,
                            title: 'Bạn đang check-in tại: ${_bloc.listAppSettings[0].name}',
                            content: 'Nếu bạn nhấn vào Check-in bạn sẽ chuyển sang địa điểm check-in mới. Dữ liệu ở địa điểm cũ sẽ vẫn được lưu cho tới khi bạn quay lại check-out.',
                            nameButtonOne: 'Xem',
                            nameButtonTwo: 'Check-in',
                          ),
                        );
                      }).then((value)async{
                    if(!Utils.isEmpty(value) && value == 'Yeah'){
                      db.deleteAllAppSettings();
                      _bloc.listAppSettings.clear();
                      if(DataLocal.listInventoryLocal.isNotEmpty){
                        DataLocal.listInventoryLocal.clear();
                      }
                      if(DataLocal.listFileAlbum.isNotEmpty){
                        DataLocal.listFileAlbum.clear();
                      }
                      DataLocal.latLongLocation = '';
                      DataLocal.addressCheckInCustomer = '';
                      DataLocal.addImageToAlbumRequest = false;
                      DataLocal.addImageToAlbum = false;
                      DataLocal.listInventoryIsChange = true;
                      DataLocal.listOrderProductIsChange = true;
                      pushNewDetailScreen(item: state.itemSelect,view: false, isCheckInSuccess: false);
                    }
                    else{
                      pushNewDetailScreen(item: state.itemSelect,view: true, isCheckInSuccess: false);
                    }
                  });
                }
              }
            }
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

  void pushNewDetailScreen({required ListCheckIn item,required bool view,required bool isCheckInSuccess}){
    PersistentNavBarNavigator.pushNewScreen(context, screen: DetailCheckInScreen(
      idCheckIn: item.id ?? 0,
      dateCheckIn: _selectedDay!,
      listAppSettings: _bloc.listAppSettings,
      view: view,
      isCheckInSuccess: isCheckInSuccess,
      listAlbumOffline: widget.listAlbumOffline,
      listAlbumTicketOffLine: widget.listAlbumTicketOffLine,
      ngayCheckin: (item.ngayCheckin != "null" && item.ngayCheckin != '' && item.ngayCheckin != null) ? DateTime.tryParse(item.ngayCheckin.toString()).toString() : '',
      tgHoanThanh: (item.tgHoanThanh != null && item.tgHoanThanh != 'null' && item.tgHoanThanh != '') ? item.tgHoanThanh! : '',
      numberTimeCheckOut: Const.checkInOnline == true ?
      ((item.timeCheckOut.toString() != '' && item.timeCheckOut.toString() != 'null' ) ? int.parse(item.timeCheckOut.toString()) : 0)
          :
      item.numberTimeCheckOut??0 ,
      isSynSuccess: item.isSynSuccessful??false,
      item: item,
    )).then((value) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent
      ));
      if(value != '' && value != null && value == 'RELOAD'){
        if(DateTime.now().isSameDate(_selectedDay??_focusedDay)){
          if(Const.checkInOnline == false){
            _bloc.add(UpdateListCheckIn());
          }else{
            _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
          }
        }else{
          _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
        }
      }
    });
  }

  buildBody(BuildContext context,CheckInState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TableCalendar<Event>(
                    rowHeight: 70,
                    daysOfWeekHeight: 20,
                    // isMargin: 0,
                    simpleSwipeConfig: const SimpleSwipeConfig(
                      verticalThreshold: 0.2,
                      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
                    ),
                    calendarBuilders: CalendarBuilders(
                      // todayBuilder: (context, date, _){
                      //   return Padding(
                      //     padding: const EdgeInsets.only(bottom: 11),
                      //     child: Container(
                      //       decoration: new BoxDecoration(
                      //         color: mainColor.withOpacity(0.8),
                      //         shape: BoxShape.circle,
                      //       ),
                      //       // margin: const EdgeInsets.all(4.0),
                      //       width: 45,
                      //       height: 45,
                      //       child: Center(
                      //         child: Text(
                      //           '${date.day}',
                      //           style: TextStyle(
                      //             fontSize: 16.0,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // },
                        selectedBuilder: (context, date, _) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: Container(
                              decoration:  BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                shape: BoxShape.circle,
                                // borderRadius: BorderRadius.circular(150)
                              ),
                              // margin: const EdgeInsets.all(4.0),
                              width: 45,
                              height: 45,
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        markerBuilder: (context,date, event){
                          return Container(
                            // margin: const EdgeInsets.only(top: 10,bottom: 0),
                            // padding: const EdgeInsets.all(1),
                            //height: 12,
                            //child: Icon(MdiIcons.emoticonPoop,color: Colors.blueGrey.withOpacity(0.5),),
                          );
                        }
                    ),
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    // rangeStartDay: _rangeStart,
                    // rangeEndDay: _rangeEnd,
                    formatAnimationCurve: Curves.elasticInOut,
                    formatAnimationDuration: const Duration(milliseconds: 500),
                    calendarFormat: _calendarFormat,
                    rangeSelectionMode: _rangeSelectionMode,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onHeaderTapped: (_){
                      //print(_);
                    },
                    locale: 'vi',
                    daysOfWeekStyle: DaysOfWeekStyle(
                        weekendStyle: GoogleFonts.montserrat(
                          color: Colors.red,
                        ),
                        weekdayStyle: GoogleFonts.montserrat(
                          color: Colors.black,
                        )
                    ),
                    headerVisible: false,
                    // headerStyle: HeaderStyle(
                    //   leftChevronIcon: Icon(Icons.arrow_back_ios, size: 15, color: Colors.black),
                    //   rightChevronIcon: Icon(Icons.arrow_forward_ios, size: 15, color: Colors.black),
                    //   titleTextStyle: GoogleFonts.montserrat(
                    //       color: Colors.yellow,
                    //       fontSize: 16),
                    //   titleCentered: true,
                    //   formatButtonDecoration: BoxDecoration(
                    //     color: Colors.white60,
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   formatButtonVisible: false,
                    //   formatButtonTextStyle: GoogleFonts.montserrat(
                    //       color: Colors.black,
                    //       fontSize: 13,
                    //       fontWeight: FontWeight.bold),
                    // ),
                    calendarStyle: CalendarStyle(
                      // selectedTextStyle: TextStyle(
                      //   backgroundColor: Colors.white,
                      //   color: mainColor
                      // ),
                        todayTextStyle: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 16),
                        weekendTextStyle: GoogleFonts.montserrat(
                            color: Colors.red,
                            fontSize: 16),
                        outsideTextStyle: const TextStyle(color: Colors.blueGrey),
                        withinRangeTextStyle: const TextStyle(color: Colors.grey),
                        defaultTextStyle: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: 16),
                        canMarkersOverflow: true,
                        outsideDaysVisible: false,
                        holidayTextStyle: const TextStyle(
                            color: Colors.yellow
                        )
                    ),
                    onDaySelected: _onDaySelected,
                    // onRangeSelected: _onRangeSelected,
                    onFormatChanged: (format) {

                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                  Expanded(
                    child: ListView.builder(
                      primary: controller == null,
                      controller: controller,
                      itemCount: 1,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return StickyHeader(
                          controller: controller, // Optional
                          header: GestureDetector(
                            onTap: (){
                              if(DateTime.now().isSameDate(_selectedDay??_focusedDay) == true){
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return WillPopScope(
                                        onWillPop: () async => false,
                                        child: const CustomQuestionComponent(
                                          showTwoButton: true,
                                          iconData: Icons.warning_amber_outlined,
                                          title: 'Đồng bộ dữ liệu',
                                          content: 'Quá trình đồng bộ sẽ lấy dữ liệu mới update vào danh sách đi check-in của bạn',
                                        ),
                                      );
                                    }).then((value)async{
                                  if(value != null){
                                    if(!Utils.isEmpty(value) && value == 'Yeah'){
                                      _bloc.add(GetListTaskOffLineEvent(reloadData: false));
                                    }
                                    else{
                                      // Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Xoa thanh cong');
                                      // db.deleteAllListCheckInOffline();
                                    }
                                  }
                                });
                              }
                            },
                            child: Container(
                              height: 50.0,
                              color: const Color(0xffeae9e9),
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              alignment: Alignment.centerLeft,
                              child: //index == 0 ?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(DateFormat.yMMMMEEEEd('vi').format(_focusedDay).toTitleCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                                  Visibility(
                                      visible: Const.checkInOnline == false,
                                      child: Icon(Icons.system_update, color: (DateTime.now().isSameDate(_selectedDay??_focusedDay)) == true ? Colors.grey : Colors.transparent,size: 20,)),
                                ],
                              )
                                  // :
                              // Text(DateFormat.yMMMMEEEEd('vi').format(_focusedDay.add(const Duration(days: 1))).toTitleCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),),
                            ),
                          ),
                          content: DateTime.now().isSameDate(_selectedDay??_focusedDay) == true
                              ?
                             (
                                 Const.checkInOnline == true
                                     ?
                                 buildViewOnline()
                                     :
                                 Column(
                            children: [
                              Visibility(
                                visible: _bloc.listCheckInOffline.isEmpty && DateTime.now().isSameDate(_selectedDay??_focusedDay) == false ,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16,horizontal: 18),
                                  child: Center(
                                    child: Text('Úi, Hôm nay không có KH nào cần check-in!!!',style: TextStyle(color: Colors.blueGrey,fontSize: 12)),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: _bloc.listCheckInOffline.isNotEmpty && DateTime.now().isSameDate(_selectedDay??_focusedDay) == true,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.vertical,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  controller: _controller,
                                  itemCount: _bloc.listCheckInOffline.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: (){
                                        _bloc.getUserLocation();
                                        itemSelect = ListCheckIn(
                                            id: (_bloc.listCheckInOffline[index].idCheckIn != "null" && _bloc.listCheckInOffline[index].idCheckIn != '') ? int.parse(_bloc.listCheckInOffline[index].idCheckIn.toString()) : 0,
                                            tieuDe: _bloc.listCheckInOffline[index].tieuDe,
                                            ngayCheckin: _bloc.listCheckInOffline[index].ngayCheckin,
                                            maKh: _bloc.listCheckInOffline[index].maKh,
                                            tenCh: _bloc.listCheckInOffline[index].tenCh,
                                            diaChi: _bloc.listCheckInOffline[index].diaChi,
                                            dienThoai: _bloc.listCheckInOffline[index].dienThoai,
                                            gps: _bloc.listCheckInOffline[index].gps,
                                            trangThai: _bloc.listCheckInOffline[index].trangThai,
                                            tgHoanThanh: _bloc.listCheckInOffline[index].tgHoanThanh,
                                            lastCheckOut: _bloc.listCheckInOffline[index].lastChko,
                                            isCheckInSuccessful: _bloc.listCheckInOffline[index].trangThai?.trim() == 'Hoàn thành' ? true : false,
                                            latLong: _bloc.listCheckInOffline[index].latlong,
                                            numberTimeCheckOut: _bloc.listCheckInOffline[index].numberTimeCheckOut,
                                            isSynSuccessful: _bloc.listCheckInOffline[index].isSynSuccessful == 1 ? true : false,
                                            timeCheckOut:  _bloc.listCheckInOffline[index].timeCheckOut,
                                        );
                                        showBottomSheet(itemSelect);
                                      },
                                      child: Container(
                                          height: 147,
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 12.0,
                                            vertical: 4.0,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width:13,
                                                decoration: BoxDecoration(
                                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12),bottomLeft: Radius.circular(12)),
                                                    color: _bloc.listAppSettings.isNotEmpty
                                                        ?
                                                    (_bloc.listAppSettings[0].id == (_bloc.listCheckInOffline[index].id.toString().trim()))  ?  Colors.red :  Colors.deepPurple
                                                        :
                                                    Colors.red
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: grey_100,
                                                    borderRadius: const BorderRadius.only(topRight: Radius.circular(12),bottomRight: Radius.circular(12)),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(left: 8,right: 12,top: 10,bottom: 4),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Flexible(child: Text('${_bloc.listCheckInOffline[index].tieuDe}',style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),),
                                                            const SizedBox(width: 5,),
                                                            const Text(//'${_bloc.listCheckInToDay[index].gps != '' ? _bloc.listCheckInToDay[index].gps : 0}'
                                                              '0 Km',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.red),)
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                             Icon(MdiIcons.store,color: subColor,size: 16,),
                                                            const SizedBox(width: 5,),
                                                            Flexible(child: Text('${_bloc.listCheckInOffline[index].tenCh}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                             Icon(MdiIcons.mapMarkerRadiusOutline,color: subColor,size: 16,),
                                                            const SizedBox(width: 5,),
                                                            Expanded(child: Text('${_bloc.listCheckInOffline[index].diaChi}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                                            const SizedBox(width: 5,),
                                                            IconButton(
                                                              onPressed: (_bloc.listCheckInOffline[index].diaChi?.replaceAll('null', '').trim().isNotEmpty == true) 
                                                                ? () => _openGoogleMapsWithAddress(_bloc.listCheckInOffline[index].diaChi ?? '') 
                                                                : null,
                                                              icon: Icon(
                                                                MdiIcons.mapOutline, 
                                                                color: (_bloc.listCheckInOffline[index].diaChi?.replaceAll('null', '').trim().isNotEmpty == true) 
                                                                  ? Colors.blueGrey 
                                                                  : Colors.grey, 
                                                                size: 20,
                                                              ),
                                                              tooltip: 'Mở bản đồ',
                                                              splashRadius: 20,
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                             Icon(MdiIcons.phoneClassic,color: subColor,size: 16,),
                                                            const SizedBox(width: 5,),
                                                            Flexible(child: Text('${_bloc.listCheckInOffline[index].dienThoai}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          children: [
                                                             Icon(MdiIcons.calendarCheckOutline,color: subColor,size: 16,),
                                                            const SizedBox(width: 5,),
                                                            Text.rich(
                                                                TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: _bloc.listCheckInOffline[index].trangThai?.trim() == 'Hoàn thành'
                                                                            ?
                                                                        'Checked: ${(_bloc.listCheckInOffline[index].tgHoanThanh == null || _bloc.listCheckInOffline[index].tgHoanThanh == "") ? '' : Utils.parseDateTToString(_bloc.listCheckInOffline[index].tgHoanThanh.toString(), Const.DATE_SV_FORMAT_4)} '
                                                                            :
                                                                        'Chưa viếng thăm',
                                                                        style:TextStyle(
                                                                          color: _bloc.listCheckInOffline[index].trangThai?.trim() == 'Hoàn thành' ? Colors.blueAccent : Colors.red,
                                                                          fontSize: 12,),
                                                                      ),
                                                                      TextSpan(
                                                                        text: (_bloc.listCheckInOffline[index].isSynSuccessful.toString() != '' && _bloc.listCheckInOffline[index].isSynSuccessful.toString() != 'null' && _bloc.listCheckInOffline[index].isSynSuccessful == 1) ?
                                                                        '(Chưa đồng bộ dữ liệu)' : '',
                                                                        style: const TextStyle(
                                                                          color: Colors.red,
                                                                          fontSize: 12,),
                                                                      )
                                                                    ]
                                                                )
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        Row(
                                                          children: [
                                                            Icon(MdiIcons.history,color: subColor,size: 16,),
                                                            const SizedBox(width: 5,),
                                                            const Text(
                                                              'Lần viếng thăm gần đây: ',
                                                              style:TextStyle(
                                                                  color: Colors.black,
                                                                  fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                            Text((_bloc.listCheckInOffline[index].lastChko != null && _bloc.listCheckInOffline[index].lastChko != 'null')
                                                                ?
                                                            Utils.parseDateTToString(_bloc.listCheckInOffline[index].lastChko.toString(), Const.DATE_TIME_FORMAT)
                                                                :
                                                            'đang cập nhật',
                                                              style:const TextStyle(
                                                                  color:  Colors.blueGrey,
                                                                  fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                             )
                              :
                              buildViewOnline()
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible: Const.checkInOnline == true || DateTime.now().isSameDate(_selectedDay??_focusedDay) != true,
                      child: _bloc.totalPager > 0 ? _getDataPager() : Container(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildViewOnline(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
          visible: _bloc.listCheckInOther.isNotEmpty,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            scrollDirection: Axis.vertical,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            // controller: _controller,
            itemCount: _bloc.listCheckInOther.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: (){
                  _bloc.getUserLocation();
                  itemSelect = ListCheckIn(
                      id: _bloc.listCheckInOther[index].id!,
                      tieuDe: _bloc.listCheckInOther[index].tieuDe,
                      ngayCheckin: _bloc.listCheckInOther[index].ngayCheckin,
                      maKh: _bloc.listCheckInOther[index].maKh,
                      tenCh: _bloc.listCheckInOther[index].tenCh,
                      diaChi: _bloc.listCheckInOther[index].diaChi,
                      dienThoai: _bloc.listCheckInOther[index].dienThoai,
                      gps: _bloc.listCheckInOther[index].gps,
                      trangThai: _bloc.listCheckInOther[index].trangThai,
                      tgHoanThanh: _bloc.listCheckInOther[index].tgHoanThanh,
                      lastCheckOut: _bloc.listCheckInOther[index].lastCheckOut,
                      isCheckInSuccessful: _bloc.listCheckInOther[index].trangThai?.trim() == 'Hoàn thành' ? true : false,
                      latLong: _bloc.listCheckInOther[index].latLong,
                      numberTimeCheckOut: _bloc.listCheckInOther[index].numberTimeCheckOut,
                      isSynSuccessful: _bloc.listCheckInOther[index].isSynSuccessful == 1 ? true : false,
                      timeCheckOut:  _bloc.listCheckInOther[index].timeCheckOut,
                  );
                  showBottomSheet(itemSelect);
                },
                child: Container(
                    height: 147,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:13,
                          decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12),bottomLeft: Radius.circular(12)),
                              color: _bloc.listAppSettings.isNotEmpty
                                  ?
                              (_bloc.listAppSettings[0].id == (_bloc.listCheckInOther[index].id.toString().trim()))  ?  Colors.red :  Colors.deepPurple
                                  :
                              Colors.red
                          ),
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: grey_100,
                              borderRadius: const BorderRadius.only(topRight: Radius.circular(12),bottomRight: Radius.circular(12)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8,right: 12,top: 10,bottom: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(child: Text('${_bloc.listCheckInOther[index].tieuDe}',style:const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),),
                                      const SizedBox(width: 5,),
                                      const Text(//'${_bloc.listCheckInToDay[index].gps != '' ? _bloc.listCheckInToDay[index].gps : 0}'
                                        '0 Km',style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold,color: Colors.red),)
                                    ],
                                  ),
                                  const SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(MdiIcons.store,color: subColor,size: 16,),
                                      const SizedBox(width: 5,),
                                      Flexible(child: Text('${_bloc.listCheckInOther[index].tenCh}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                    ],
                                  ),
                                  const SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(MdiIcons.mapMarkerRadiusOutline,color: subColor,size: 16,),
                                      const SizedBox(width: 5,),
                                      Expanded(child: Text('${_bloc.listCheckInOther[index].diaChi}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                      const SizedBox(width: 5,),
                                      IconButton(
                                        onPressed: (_bloc.listCheckInOther[index].diaChi?.replaceAll('null', '').trim().isNotEmpty == true) 
                                          ? () => _openGoogleMapsWithAddress(_bloc.listCheckInOther[index].diaChi ?? '') 
                                          : null,
                                        icon: Icon(
                                          MdiIcons.mapOutline, 
                                          color: (_bloc.listCheckInOther[index].diaChi?.replaceAll('null', '').trim().isNotEmpty == true) 
                                            ? Colors.blueGrey 
                                            : Colors.grey, 
                                          size: 20,
                                        ),
                                        tooltip: 'Mở bản đồ',
                                        splashRadius: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5,),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                       Icon(MdiIcons.phoneClassic,color: subColor,size: 16,),
                                      const SizedBox(width: 5,),
                                      Flexible(child: Text('${_bloc.listCheckInOther[index].dienThoai}',style:const TextStyle(color: Colors.blueGrey,fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                                    ],
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        Icon(MdiIcons.calendarCheckOutline,color: subColor,size: 16,),
                                        const SizedBox(width: 5,),
                                        Text.rich(
                                            TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: _bloc.listCheckInOther[index].trangThai?.trim() == 'Hoàn thành'
                                                        ?
                                                    'Checked: ${(_bloc.listCheckInOther[index].tgHoanThanh == null || _bloc.listCheckInOther[index].tgHoanThanh == "") ? '' : Utils.parseDateTToString(_bloc.listCheckInOther[index].tgHoanThanh.toString(), Const.DATE_SV_FORMAT_4)} '
                                                        :
                                                    'Chưa viếng thăm',
                                                    style:TextStyle(
                                                      color: _bloc.listCheckInOther[index].trangThai?.trim() == 'Hoàn thành' ? Colors.blueAccent : Colors.red,
                                                      fontSize: 12,),
                                                  ),
                                                  TextSpan(
                                                    text: _bloc.listCheckInOther[index].isSynSuccessful == true ?
                                                    '(Chưa đồng bộ dữ liệu)' : '',
                                                    style: const TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 12,),
                                                  )
                                                ]
                                            )
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                  Row(
                                    children: [
                                      Icon(MdiIcons.history,color: subColor,size: 16,),
                                      const SizedBox(width: 5,),
                                      const Text(
                                        'Lần viếng thăm gần đây: ',
                                        style:TextStyle(
                                            color: Colors.black,
                                            fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                      Text((_bloc.listCheckInOther[index].lastCheckOut != null && _bloc.listCheckInOther[index].lastCheckOut != 'null')
                                          ?
                                      Utils.parseDateTToString(_bloc.listCheckInOther[index].lastCheckOut.toString(), Const.DATE_TIME_FORMAT)
                                          :
                                      'đang cập nhật',
                                        style:const TextStyle(
                                            color:  Colors.blueGrey,
                                            fontSize: 12),maxLines: 2,overflow: TextOverflow.ellipsis,),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ),
              );
            },
          ),
        ),
        Visibility(
            visible: _bloc.listCheckInOther.isEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Úi, Không có gì ở đây cả.',style: TextStyle(color: Colors.black)),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text('Gợi ý: Bấm nút ',style: TextStyle(color: Colors.blueGrey,fontSize: 12.5)),
                      Icon(Icons.search_outlined,color: Colors.blueGrey,size: 18,),
                      Text(' để tìm kiếm công viêc của bạn',style: TextStyle(color: Colors.blueGrey,fontSize: 12.5)),
                    ],
                  ),
                ],
              ),
            )
        ),
      ],
    );
  }

  int lastPage=0;
  int selectedPage=1;

  Widget _getDataPager() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Center(
        child: SizedBox(
          height: 57,
          width: double.infinity,
          child: Column(
            children: [
              const Divider(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16,right: 16,bottom: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                          onTap: (){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = 1;
                            });
                            _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
                          },
                          child: const Icon(Icons.skip_previous_outlined,color: Colors.grey)),
                      const SizedBox(width: 10,),
                      InkWell(
                          onTap: (){
                            if(selectedPage > 1){
                              setState(() {
                                lastPage = selectedPage;
                                selectedPage = selectedPage - 1;
                              });
                              _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
                            }
                          },
                          child: const Icon(Icons.navigate_before_outlined,color: Colors.grey,)),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index){
                              return InkWell(
                                onTap: (){
                                  setState(() {
                                    lastPage = selectedPage;
                                    selectedPage = index+1;
                                  });
                                  _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: selectedPage == (index + 1) ?  mainColor : Colors.white,
                                      borderRadius: const BorderRadius.all(Radius.circular(48))
                                  ),
                                  child: Center(
                                    child: Text((index + 1).toString(),style: TextStyle(color: selectedPage == (index + 1) ?  Colors.white : Colors.black),),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:(BuildContext context, int index)=> Container(width: 6,),
                            itemCount: _bloc.totalPager > 10 ? 10 : _bloc.totalPager),
                      ),
                      const SizedBox(width: 10,),
                      InkWell(
                          onTap: (){
                            if(selectedPage < _bloc.totalPager){
                              setState(() {
                                lastPage = selectedPage;
                                selectedPage = selectedPage + 1;
                              });
                              _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
                            }
                          },
                          child: const Icon(Icons.navigate_next_outlined,color: Colors.grey)),
                      const SizedBox(width: 10,),
                      InkWell(
                          onTap: (){
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = _bloc.totalPager;
                            });
                            _bloc.add(GetListCheckIn(dateTime: _selectedDay??_focusedDay, pageIndex: selectedPage,userId: widget.userId));
                          },
                          child: const Icon(Icons.skip_next_outlined,color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
            child: InkWell(
              onTap: ()=>_bloc.testLocation(),
              child: Center(
                child: Text(
                  DateFormat.yMMMM('vi').format(_focusedDay).toTitleCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                  maxLines: 1,overflow: TextOverflow.fade,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              PersistentNavBarNavigator.pushNewScreen(context, screen: SearchTaskScreen(dateTime: _selectedDay.toString(),listCheckInOffline: _bloc.listCheckInOffline,)).then((value){
                if(value != null && value[0] == 'Yeah'){
                  _bloc.getUserLocation();
                  ListCheckIn itemSelected = value[1] as ListCheckIn;
                  showBottomSheet(itemSelected);
                }
              });
            },
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.search_outlined,
                size: 25,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  void showBottomSheet(ListCheckIn itemSelect){
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        backgroundColor: Colors.white,
        builder: (builder){
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.42,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(25),
                    topLeft: Radius.circular(25)
                )
            ),
            margin: MediaQuery.of(context).viewInsets,
            child: StatefulBuilder(
              builder: (BuildContext context,StateSetter myState){
                return Padding(
                  padding: const EdgeInsets.only(top: 10,bottom: 0),
                  child: Container(
                    decoration:const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25)
                        )
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0,left: 8,right: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                  onTap: ()=> Navigator.pop(context),
                                  child: const Icon(Icons.close,color: Colors.white,)),
                              const Text('Thêm tuỳ chọn',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                              InkWell(
                                  onTap: ()=> Navigator.pop(context),
                                  child: Icon(Icons.clear,color: mainColor,)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5,),
                        const Divider(color: Colors.blueGrey,),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  // color: Colors.blueGrey,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: InkWell(
                                        onTap:()=>Navigator.pop(context,'1'),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: const [
                                                Text('Gọi cho Khách hàng',style: TextStyle(color: Colors.black),),
                                                Icon(Icons.phone_callback_outlined,color: subColor,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: InkWell(
                                        onTap:()=>Navigator.pop(context,'2'),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(isToday == true ? 'Check-in' : 'Xem thông tin',style:const TextStyle(color: Colors.black),),
                                                Icon(MdiIcons.watchImport,color: subColor,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: InkWell(
                                        onTap:()=>Navigator.pop(context,'3'),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Đặt hàng cho Khách hàng',style: TextStyle(color: Colors.black),),
                                                Icon(MdiIcons.cartArrowDown,color: subColor,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: InkWell(
                                        onTap:()=>Navigator.pop(context,'4'),
                                        child: Card(
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12,bottom: 10,left: 10,right: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Sale-out',style: TextStyle(color: Colors.black),),
                                                Icon(MdiIcons.chartBoxOutline,color: subColor,)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
    ).then((value)async{
      if(value != null){
        switch (value){
          case '1':
            if(itemSelect.dienThoai!.isNotEmpty){
              final Uri launchUri = Uri(
                scheme: 'tel',
                path: itemSelect.dienThoai!,
              );
              await launchUrl(launchUri);
            }
            else{
              Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Không tìm thấy SĐT của KH.');
            }
            break;
          case '2':
            if(isToday == true){
              if(itemSelect.latLong.toString().isNotEmpty && itemSelect.latLong.toString() != 'null' && _bloc.currentLocation != null && _bloc.currentLocation != 'null'){
                print('Checking location');
                print(Utils.getDistance(double.parse(itemSelect.latLong.toString().split(',')[0]), double.parse(itemSelect.latLong.toString().split(',')[1]),_bloc.currentLocation) < Const.distanceLocationCheckIn);
                if(Utils.getDistance(double.parse(itemSelect.latLong.toString().split(',')[0]), double.parse(itemSelect.latLong.toString().split(',')[1]),_bloc.currentLocation) < Const.distanceLocationCheckIn){
                  if(Const.checkInOnline == true){
                    if(DateTime.now().isSameDate(_selectedDay??_focusedDay) == true){
                      _bloc.add(GetTimeCheckOutSave(idCheckIn: itemSelect.id!, idCustomer: itemSelect.maKh.toString(),itemSelect: itemSelect));
                    }else{
                      pushNewDetailScreen(item: itemSelect, view: true, isCheckInSuccess: false);
                    }
                  }
                  else{
                    _bloc.add(GetTimeCheckOutSave(idCheckIn: itemSelect.id!, idCustomer: itemSelect.maKh!,itemSelect: itemSelect));
                  }
                }
                else{
                  Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Vị trí của bạn đang cách quá xa vị trí đã được lưu trước đó');
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context)=>BlocProvider.value(value: _bloc,
                        child: MapView(
                            latStart: itemSelect.latLong.toString().split(',')[0],
                            longStart: itemSelect.latLong.toString().split(',')[1],
                            latEnd: _bloc.currentLocation?.latitude??0,
                            longEnd: _bloc.currentLocation?.longitude??0,
                            metter: Utils.getDistance(double.parse(itemSelect.latLong.toString().split(',')[0]), double.parse(itemSelect.latLong.toString().split(',')[1]),_bloc.currentLocation),
                        ),)
                    ///8934988010039
                  ).then((value){
                    if(value != null && value[0] == "Accepted"){
                      _bloc.add(GetTimeCheckOutSave(idCheckIn: itemSelect.id!, idCustomer: itemSelect.maKh.toString(),itemSelect: itemSelect));
                    }
                  });
                }
              }
              else{
                _bloc.add(GetTimeCheckOutSave(idCheckIn: itemSelect.id!, idCustomer: itemSelect.maKh.toString(),itemSelect: itemSelect));
              }
            }
            else{
              pushNewDetailScreen(item: itemSelect, view: true, isCheckInSuccess: false);
            }
            break;
            case '3':
            if(itemSelect.tenCh.toString().trim() != 'null' || itemSelect.tenCh.toString().trim() != ''){
              itemSelect.tenCh = itemSelect.tieuDe;
            }
            PersistentNavBarNavigator.pushNewScreen(context, screen: ConfirmScreen(
                orderFromCheckIn: false,
                viewUpdateOrder: false,
                viewDetail: false,
                addInfoCheckIn: true,
                listIdGroupProduct: Const.listGroupProductCode,
                itemGroupCode: Const.itemGroupCode,
                listOrder: DataLocal.listOrderProductLocal,
                nameCustomer: itemSelect.tenCh,
                phoneCustomer: itemSelect.diaChi,
                addressCustomer: itemSelect.diaChi,
                codeCustomer: itemSelect.maKh,
                title: 'Đặt hàng',
                currencyCode: !Utils.isEmpty(currencyCode) ? currencyCode : Const.currencyList[0].currencyCode.toString(), loadDataLocal: false,
              ),withNavBar: false);
            break;
            case '4':
              PersistentNavBarNavigator.pushNewScreen(context, screen: SaleOutScreen(
                nameCustomer: itemSelect.tenCh,
                phoneCustomer: itemSelect.diaChi,
                addressCustomer: itemSelect.diaChi,
                codeCustomer: itemSelect.maKh,
              ),withNavBar: false);
            break;
        }
      }
    });
  }
}
