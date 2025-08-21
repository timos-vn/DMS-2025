import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:dms/extension/extension_compare_date.dart';
import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/personnel/time_keeping/time_keeping_bloc.dart';
import 'package:dms/screen/personnel/time_keeping/time_keeping_event.dart';
import 'package:dms/screen/personnel/time_keeping/time_keeping_state.dart';
import 'package:dms/utils/extension/upper_case_to_title.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/custom_widget.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../driver_transfer/helper/constant.dart';
import '../../../driver_transfer/helper/location_service.dart';
import '../../../model/network/response/time_keeping_data_response.dart';
import '../../../themes/colors.dart';
import '../../../utils/const.dart';
import '../../../utils/images.dart';
import '../../../utils/utils.dart';
import 'component/about.dart';
import 'component/baseState.dart';
import 'component/home_test.dart';
import 'component/moves.dart';
import 'component/time_keeping_out_line.dart';

class TimeKeepingScreen extends StatefulWidget {
  const TimeKeepingScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _TimeKeepingScreenState createState() => _TimeKeepingScreenState();
}

class _TimeKeepingScreenState extends State<TimeKeepingScreen> {

  late TimeKeepingBloc _bloc;

  late final ValueNotifier<List<ListTimeKeepingHistory>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool isUserInList = false;


  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    // _controller.play();
    _selectedDay = _focusedDay;
    _bloc = TimeKeepingBloc(context);
    isUserInList = DataLocal.listVipMemberFirebase.any((member) => member.userId == Const.userId);
    _bloc.add(GetPrefsTimeKeeping());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String timeIn = '';
  String timeOut = '';
  String reason = '';
  String description = '';

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _rangeStart = null; // Important to clean those
      _rangeEnd = null;

      _rangeSelectionMode = RangeSelectionMode.toggledOff;
      if( _bloc.listDataTimeKeeping.isNotEmpty){
        ListTimeKeepingHistory item = _bloc.listDataTimeKeeping.firstWhere((element) => Utils.parseDateTToString(element.dateTime.toString(), Const.DATE_SV_FORMAT_2) == Utils.parseDateToString(selectedDay, Const.DATE_SV_FORMAT_2));
        if(item.id != null){
          timeIn = item.timeIn.toString().trim();
          timeOut = item.timeOut.toString().trim();
          reason = item.reason.toString().trim();
          description = item.description.toString().trim();
        }
      }
      setState(() {});
    }
  }

  late Timer _timer = Timer(const Duration(milliseconds: 1), () {});
  int start = 3;
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer =  Timer.periodic(
      oneSec,
          (Timer timer) {
        if (start == 0) {

          setState(() {});
          timer.cancel();
        } else {
          start--;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          floatingActionButton: _selectedDay!.isSameDate(DateTime.now()) || DataLocal.listVipMemberFirebase.any((member) => member.userId == Const.userId) ?
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: FloatingActionButton(
              onPressed:() {
                showDialog(
                    context: context,
                    builder: (context) {
                      return WillPopScope(
                        onWillPop: () async => true,
                        child: CustomQuestionTimeKeeping(
                          showTwoButton: true,
                          isUserInList: isUserInList,
                          iconData: isUserInList ? EneftyIcons.star_2_outline : Icons.warning_amber_outlined,
                          title: isUserInList ? "Chào mừng VIP Member" : 'Bạn đang thực hiện chấm công!!!',
                          content: isUserInList ? 'VIP PRO - Hãy chấm công theo cách của bạn' : 'Thời gian chấm công: ${DateTime.now().hour}:${DateTime.now().minute < 10 ? ('0${DateTime.now().minute}') :DateTime.now().minute  }:${DateTime.now().second}',
                        ),
                      );
                    }).then((value)async{
                  if(value != null){
                    if(!Utils.isEmpty(value) && value == 'Location'){
                      showLoaderDialog(context);
                      init();
                    }else if(!Utils.isEmpty(value) && value == 'Wifi'){
                      _bloc.publicIP = '';
                      _bloc.add(LoadingTimeKeeping(uId: Const.uId));
                    }
                  }
                });
              } ,
              backgroundColor: mainColor,
              tooltip: 'Increment',
              child: const Icon(Icons.app_registration,color: Colors.white,),
            ),
          )
               : Container(),
          body: BlocListener<TimeKeepingBloc,TimeKeepingState>(
            bloc: _bloc,
            listener: (context, state){
              if(state is GetPrefsSuccess){
                _bloc.add(ListDataTimeKeepingFromUserEvent(datetime: DateTime.now().toString()));
              }
              else if(state is TimeKeepingError){
                showDialog(
                    context: context,
                    builder: (context) {
                      return WillPopScope(
                        onWillPop: () async => false,
                        child: const CustomQuestionComponent(
                          showTwoButton: false,
                          iconData: Icons.wifi_off,
                          title: 'No Internet',
                          content: 'Vui lòng kiểm tra mạng Wifi của bạn',
                        ),
                      );
                    });
              }
              else if(state is TimeKeepingDataSuccess){
                if(_bloc.listDataTimeKeeping.any((element) => Utils.parseDateTToString(element.dateTime.toString(), Const.DATE_SV_FORMAT_2) == Utils.parseDateToString(_selectedDay!, Const.DATE_SV_FORMAT_2)) == true){
                  if( _bloc.listDataTimeKeeping.isNotEmpty){
                    ListTimeKeepingHistory item = _bloc.listDataTimeKeeping.firstWhere((element) => Utils.parseDateTToString(element.dateTime.toString(), Const.DATE_SV_FORMAT_2) == Utils.parseDateToString(_selectedDay!, Const.DATE_SV_FORMAT_2));
                    if(item.id != null){
                      timeIn = item.timeIn.toString().trim();
                      timeOut = item.timeOut.toString().trim();
                      reason = item.reason.toString().trim();
                      description = item.description.toString().trim();
                    }
                  }
                }
              }
              else if(state is TimeKeepingSuccess){
                Utils.showCustomToast(context, Icons.check_circle_outline, 'Yeah, Đã ghi nhận thời gian chấm công 😘');
                startTimer();
                _bloc.add(ListDataTimeKeepingFromUserEvent(datetime: DateTime.now().toString()));
              }
              else if(state is TimeKeepingFailure){
                Utils.showCustomToast(context, Icons.warning_amber_outlined, state.error);
              }
              else if(state is CheckWifiSuccess){
                if(isUserInList){
                  final randomTime = Utils.generateSmartRandomTime(date: _selectedDay!,timeIn: timeIn,timeOut: timeOut);
                  _bloc.add(TimeKeepingFromUserEvent(datetime: randomTime.toString(),qrCode:  '0',uId:  Const.uId, desc: '', isWifi: true, isMeetCustomer: false, isUserVIP: isUserInList));
                }
                else{
                  if(_bloc.publicIP.toString().replaceAll('null', '').trim() == _bloc.master.ipSettup.toString().replaceAll('null', '').trim()){
                    _bloc.add(TimeKeepingFromUserEvent(datetime:  DateTime.now().toString(),qrCode:  '0',uId:  Const.uId, desc: '', isWifi: true, isMeetCustomer: false, isUserVIP: isUserInList));
                  }
                  else{
                    Utils.showCustomToast(context, Icons.warning_amber, 'Úi, hãy đổi sang Wifi của CTY nhé 😘');
                  }
                }
              }
            },
            child: BlocBuilder<TimeKeepingBloc,TimeKeepingState>(
              bloc: _bloc,
              builder: (BuildContext context, TimeKeepingState state){
                return Stack(
                  children: [
                    buildBody(context, state),
                    Visibility(
                      visible: state is TimeKeepingLoading,
                      child: const PendingAction(),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void init()async{
    location.getLocation().then((onValue)async{
      List<Placemark> placePoint = await placemarkFromCoordinates(onValue.latitude!, onValue.longitude!);
      String currentAddress1 = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
      double distance = 0;
      double distanceSetUp = 0;
      distanceSetUp = _bloc.master.distance.toString().replaceAll('null', '').isNotEmpty ? double.parse(_bloc.master.distance.toString()) : 0 ;

      if(_bloc.master.location.toString().replaceAll('null', '').isNotEmpty){
        double lat1 = 0;
        lat1 = double.parse(_bloc.master.location.toString().split(',').first);
        double lon1 = 0;
        lon1 = double.parse(_bloc.master.location.toString().split(',').last);
        distance = Utils.haversine(lat1, lon1, onValue.latitude!, onValue.longitude!);

        cancelLoaderDialog(context);
        if(isUserInList ? true : distance <= distanceSetUp){
          if (isUserInList) {
            final randomTime = Utils.generateSmartRandomTime(date: _selectedDay!,timeIn: timeIn,timeOut: timeOut);
            final newCoord = Utils.generateRandomCoordinateNearby(
              originLat: lat1,
              originLon: lon1,
              maxDistanceInMeters: distanceSetUp,
            );
            _bloc.lat = newCoord['lat'].toString();
            _bloc.long = newCoord['lon'].toString();
            _bloc.currentAddress = '262 Nguyễn Huy Tưởng, Thanh Xuân, Hà Nội';
            _bloc.add(TimeKeepingFromUserEvent(datetime: randomTime.toString(),qrCode:  '0',uId:  Const.uId, desc: '', isWifi: false, isMeetCustomer: false, isUserVIP: isUserInList));
          }
          else {
            _bloc.lat = lat1.toString();
            _bloc.long = lon1.toString();
            _bloc.currentAddress = currentAddress1;
            _bloc.add(TimeKeepingFromUserEvent(datetime: DateTime.now().toString(),qrCode:  '0',uId:  Const.uId, desc: '', isWifi: false, isMeetCustomer: false, isUserVIP: isUserInList));
          }
        }else{
          Utils.showCustomToast(context, Icons.warning_amber, 'Khoảng cách của bạn quá xa công ty');
        }
      }else{
        cancelLoaderDialog(context);
        Utils.showCustomToast(context, Icons.warning_amber, 'Công ty bạn làm việc không cần chấm công');
      }
      setState(()=>print('New: ${_bloc.currentAddress}'));
    });
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degrees to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Future<String> getPublicIP() async {
    final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['ip'];
    } else {
      throw Exception('Failed to load IP address');
    }
  }


  buildBody(BuildContext context,TimeKeepingState state){
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.shade200,
                        offset: const Offset(2, 4),
                        blurRadius: 5,
                        spreadRadius: 2)
                  ],
                  // gradient: const LinearGradient(
                  //     begin: Alignment.centerLeft,
                  //     end: Alignment.centerRight,
                  //     colors: [Color.fromARGB(255, 150, 185, 229),Color.fromARGB(255, 150, 185, 229)])
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TableCalendar<Event>(
                    rowHeight: 60,
                    daysOfWeekHeight: 20,
                    availableGestures: AvailableGestures.horizontalSwipe,
                    simpleSwipeConfig: const SimpleSwipeConfig(
                      verticalThreshold: 0.2,
                      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, _) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              // borderRadius: BorderRadius.circular(150)
                            ),
                            // margin: const EdgeInsets.all(4.0),
                            width: 35,
                            height: 35,
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) ? Colors.red : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                        selectedBuilder: (context, date, _) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: Container(
                              decoration:  const BoxDecoration(
                                color: subColor,
                                shape: BoxShape.circle,
                                // borderRadius: BorderRadius.circular(150)
                              ),
                              // margin: const EdgeInsets.all(4.0),
                              width: 35,
                              height: 35,
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        todayBuilder: (context, date, _) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.4),
                                shape: BoxShape.circle,
                                // borderRadius: BorderRadius.circular(150)
                              ),
                              // margin: const EdgeInsets.all(4.0),
                              width: 35,
                              height: 35,
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        markerBuilder: (context,date, event){
                          if(_bloc.listDataTimeKeeping.any((element) => Utils.parseDateTToString(element.dateTime.toString(), Const.DATE_SV_FORMAT_2) == Utils.parseDateToString(date, Const.DATE_SV_FORMAT_2)) == true){
                            ListTimeKeepingHistory item = _bloc.listDataTimeKeeping.firstWhere((element) => Utils.parseDateTToString(element.dateTime.toString(), Const.DATE_SV_FORMAT_2) == Utils.parseDateToString(date, Const.DATE_SV_FORMAT_2));
                            if(item.id != null){
                              if(/*date.weekday == DateTime.saturday ||*/ date.weekday == DateTime.sunday){
                                return  Container(
                                  margin: const EdgeInsets.only(top: 0,bottom: 0),
                                  padding: const EdgeInsets.all(1),
                                  height: 12,
                                  child: Icon(MdiIcons.comment,color: Colors.transparent,size: 20,),
                                );
                              }
                              else{
                                if(item.timeIn.toString().replaceAll('null', '').isNotEmpty && item.timeOut.toString().replaceAll('null', '').isNotEmpty){
                                  if(item.isMeetCustomer == 0){
                                    if(item.isStatus == 0){
                                      return  Container(
                                        margin: const EdgeInsets.only(top: 35,bottom: 0),
                                        padding: const EdgeInsets.all(1),
                                        height: 12,
                                        child:  Icon(MdiIcons.emoticonHappyOutline,color: Colors.blue,size: 18,),
                                      );
                                    }
                                    else{
                                      return  Container(
                                        margin: const EdgeInsets.only(top: 35,bottom: 0),
                                        padding: const EdgeInsets.all(1),
                                        height: 12,
                                        child:  Icon(MdiIcons.emoticonCoolOutline,color: Colors.purple,size: 18,),
                                      );
                                    }
                                  }
                                  else{
                                    if(item.isMeetCustomer != null){
                                      return  Container(
                                        margin: const EdgeInsets.only(top: 35,bottom: 0),
                                        padding: const EdgeInsets.all(1),
                                        height: 12,
                                        child:  const Icon(Icons.accessible_outlined,color: Colors.orange,size: 18,),
                                      );
                                    }
                                  }
                                }
                                if(DateTime.now().isBeforeMont(date)) {
                                  if(item.timeIn.toString().replaceAll('null', '').isEmpty && item.timeOut.toString().replaceAll('null', '').isEmpty){
                                    return  Container(
                                      margin: const EdgeInsets.only(top: 35,bottom: 0),
                                      padding: const EdgeInsets.all(1),
                                      height: 12,
                                      child: Icon(MdiIcons.emoticonSadOutline,color: Colors.red,size: 18,),
                                    );
                                  }
                                 else{
                                    return  Container(
                                      margin: const EdgeInsets.only(top: 35,bottom: 0),
                                      padding: const EdgeInsets.all(1),
                                      height: 12,
                                      child: Icon(MdiIcons.emoticonPoop,color: Colors.transparent,size: 18,),
                                    );
                                  }
                                }
                                else {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 35,bottom: 0),
                                    padding: const EdgeInsets.all(1),
                                    height: 12,
                                    child: Icon(MdiIcons.emoticonPoop,color: Colors.transparent,size: 18),
                                  );
                                }
                              }
                            }
                            else {
                              return  Container(
                                margin: const EdgeInsets.only(top: 0,bottom: 0),
                                padding: const EdgeInsets.all(1),
                                height: 12,
                                child: Icon(MdiIcons.comment,color: Colors.blueGrey.withOpacity(0.2),size: 20),
                              );
                            }
                          }
                          else{
                            return Container(
                              margin: const EdgeInsets.only(top: 0,bottom: 0),
                              padding: const EdgeInsets.all(1),
                              height: 12,
                              child: Icon(MdiIcons.emoticonPoop,color: Colors.transparent,size: 20),
                            );
                          }
                        }
                    ),
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    formatAnimationCurve: Curves.elasticInOut,
                    formatAnimationDuration: const Duration(milliseconds: 500),
                    calendarFormat: _calendarFormat,
                    rangeSelectionMode: _rangeSelectionMode,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onHeaderTapped: (_){
                      print(_);
                    },
                    pageJumpingEnabled: false,
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
                      markersAutoAligned: true,
                        // markerMargin: EdgeInsets.only(bottom: 100),
                        // markersOffset: PositionedOffset(bottom: 100),
                        todayTextStyle: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16),
                        weekendTextStyle: GoogleFonts.montserrat(
                            color: Colors.red,
                            fontSize: 16),
                        outsideTextStyle: const TextStyle(color: Colors.white),
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
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }

                    },
                    onPageChanged: (focusedDay) {
                      if(_bloc.listDataTimeKeeping.isNotEmpty){
                        _bloc.listDataTimeKeeping.clear();
                      }
                      _bloc.add(ListDataTimeKeepingFromUserEvent(datetime: Utils.parseDateToString(focusedDay, Const.DATE_SV_FORMAT_2)));
                      // setState(() {
                      _focusedDay = focusedDay;
                      // });
                    },
                  ),
                  const Divider(color: Colors.white,),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Container(
                          height: 55,
                          padding: const EdgeInsets.only(top: 5,left: 8,right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CircleAvatar(
                                radius: 25,
                                backgroundImage: AssetImage(avatarStore),
                                backgroundColor: Colors.transparent,
                              ),
                              const SizedBox(width: 5,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_bloc.master.tenNv.toString(),style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                    const SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Icon(MdiIcons.accountBoxOutline,color: Colors.blueGrey,size: 18,),
                                        const SizedBox(width: 8,),
                                        Text( isUserInList ? 'VIP TEAM' :
                                          _bloc.master.viTri.toString()
                                          ,style: TextStyle(color: isUserInList ? Colors.red : const Color(0xff0162c1) ,fontWeight: FontWeight.w700,fontSize: 11),maxLines: 1,overflow: TextOverflow.ellipsis,),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: (){
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
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(25),
                                                  topLeft: Radius.circular(25)
                                              )
                                          ),
                                          margin: MediaQuery.of(context).viewInsets,
                                          child: FractionallySizedBox(
                                            heightFactor: 0.7,
                                            child: StatefulBuilder(
                                              builder: (BuildContext context,StateSetter myState){
                                                return Padding(
                                                  padding: const EdgeInsets.only(top: 10,bottom: 0),
                                                  child: Container(
                                                    decoration: const BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                            topRight: Radius.circular(25),
                                                            topLeft: Radius.circular(25)
                                                        )
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 8.0,left: 16,right: 16),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              const Icon(Icons.check,color: Colors.white,),
                                                              const Text('Thông tin cá nhân',style: TextStyle(color: Colors.black,fontWeight: FontWeight.w800),),
                                                              InkWell(
                                                                  onTap: ()=> Navigator.pop(context),
                                                                  child: const Icon(Icons.close,color: Colors.black,)),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 5,),
                                                        const Divider(color: Colors.blueGrey,),
                                                        const SizedBox(height: 5,),
                                                        Expanded(
                                                          child: DefaultTabController(
                                                            length: 3,
                                                            child: Scaffold(
                                                              backgroundColor: Colors.white,
                                                              appBar: TabBar(
                                                                indicatorColor: const Color(0xff9AB8AC),
                                                                labelColor: Colors.black,
                                                                unselectedLabelColor: Colors.black54,
                                                                // indicatorPadding: EdgeInsets.symmetric(horizontal: getFontSize(context,20,)),
                                                                tabs: [
                                                                  Tab( child: Text('About',style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900,fontSize: getFontSize(context,13)),),),
                                                                  Tab(child: Text('Base State',style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900,fontSize: getFontSize(context,13)),),),
                                                                  // Tab(child: Text('Evaluation',style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900,fontSize: getFontSize(context,13)),),),
                                                                  Tab(child: Text('Moves',style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900,fontSize: getFontSize(context,13),)),),
                                                                ],
                                                              ),
                                                              body: TabBarView(
                                                                children: [
                                                                  About(
                                                                  phepDaNghi:_bloc.master.phepDn.toString(),
                                                                  phepConLai:_bloc.master.phepCl.toString(),
                                                                  userName:_bloc.master.tenNv,
                                                                  phoneNumber:_bloc.master.dienThoai,
                                                                  birthDay:_bloc.master.ngaySinh,
                                                                  dayIn:_bloc.master.ngayVao,
                                                                  officialDate:_bloc.master.ngayChinhThuc,
                                                                  address:_bloc.master.diaChi,
                                                                  workingPosition:_bloc.master.viTri,
                                                                  totalWorking:_bloc.master.tCong.toString(),
                                                                  ),
                                                                  BaseState(),
                                                                  // _evalutionSection(),
                                                                  Moves(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                                        border: Border.all(color: Colors.red,width: 1.1)
                                    ),
                                    height: 30,
                                    child: const Center(child: Text('View profile',style: TextStyle(fontWeight: FontWeight.w500,color: Colors.red,fontSize: 12.5),)),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 15,child: Divider(color: Colors.blueGrey.withOpacity(0.2),)),
                            Padding(
                              padding: const EdgeInsets.only(left: 4,right: 4),
                              child: Text(DateFormat.yMMMMEEEEd('vi').format(_selectedDay??DateTime.now()).toString().toTitleCase(), style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500,fontSize: 12),),
                            ),
                            Expanded(child: Divider(color: Colors.blueGrey.withOpacity(0.2),)),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 12,top: 12,bottom: 16),
                          child: Text('Lịch sử chấm công của bạn', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                        ),
                        buildInfo(context),
                        Visibility(
                          visible: (reason.isNotEmpty && reason.isNotEmpty),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10,top: 12,right: 6),
                            child: Text("Lý do: $description",style: const TextStyle(color: Colors.red),),
                          ),
                        ),
                        const SizedBox(height: 5,),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Text('1. ',style: TextStyle(color: grey,fontSize: 11),),
                              const SizedBox(width: 2,),
                              Icon(MdiIcons.emoticonHappyOutline,color: Colors.blue,size: 18,),
                              const SizedBox(width: 10,),
                              const Text('Ngày bạn đã chấm công',style: TextStyle(color: grey,fontSize: 11)),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                          child: Row(
                            children: [
                              const Text('2. ',style: TextStyle(color: grey,fontSize: 11),),
                              const SizedBox(width: 2,),
                              Icon(MdiIcons.emoticonCoolOutline,color: Colors.purple,size: 18,),
                              const SizedBox(width: 10,),
                              const Text('Ngày bạn đi muộn về sớm',style: TextStyle(color: grey,fontSize: 11),),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                        //   child: Row(
                        //     children: [
                        //       Text('3. ',style: TextStyle(color: grey,fontSize: 11),),
                        //       SizedBox(width: 2,),
                        //       Icon(MdiIcons.emoticonPoop,color: Colors.transparent,size: 18,),
                        //       SizedBox(width: 10,),
                        //       Text('Ngày bạn quên chấm công',style: TextStyle(color: grey,fontSize: 11),),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                          child: Row(
                            children: [
                              const Text('3. ',style: TextStyle(color: grey,fontSize: 11),),
                              const SizedBox(width: 2,),
                              Icon(MdiIcons.emoticonSadOutline,color: Colors.red,size: 18,),
                              const SizedBox(width: 10,),
                              const Text('Ngày bạn nghỉ',style: TextStyle(color: grey,fontSize: 11),),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                          child: Row(
                            children: [
                              Text('4. ',style: TextStyle(color: grey,fontSize: 11),),
                              SizedBox(width: 2,),
                              Icon(Icons.accessible_outlined,color: Colors.orange,size: 18,),
                              SizedBox(width: 10,),
                              Text('Ngày bạn đi công tác',style: TextStyle(color: grey,fontSize: 11),),
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
        ],
      ),
    );
  }

  Widget buildInfo(BuildContext context) {
    return (reason.isNotEmpty && reason.isNotEmpty)
        ?
    Table(
      border: TableBorder.all(color: Colors.grey.withOpacity(0.6)),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30,right: 30),
              height: 35,
              child: const Center(child: Text('Time-in')),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: SizedBox(
                height: 35,
                // width: 32,
                child: Center(
                    child:
                    Text(
                  (timeIn.isNotEmpty && timeIn != 'null')
                      ?
                      Utils.parseDateTToString(timeIn.toString(), Const.TIME2)
                      :
                      'Bạn nghỉ hay đã quên chấm công?',style:  timeIn.toString() != '' ? const TextStyle(color: Colors.black,fontSize: 12.5) : const TextStyle(fontSize: 12.5,color: Colors.blueGrey) ,
                )),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const SizedBox(
              height: 35,
              child: Center(child: Text('Time-out')),
            ),
            SizedBox(
              height: 35,
              child: Center(child: Text(
                (timeOut.isNotEmpty && timeOut != 'null')
                      ?
                  Utils.parseDateTToString(timeOut.toString(), Const.TIME2)
                      :
                  'Bạn nghỉ hay đã quên chấm công?',style:  timeOut.toString() != '' ? const TextStyle(color: Colors.black,fontSize: 12.5) : const TextStyle(fontSize: 12.5,color: Colors.blueGrey) ,
              )),
            ),
          ],
        ),
        TableRow(
          children: [
            const SizedBox(
              height: 35,
              child: Center(child: Text('Reason',)),
            ),
            SizedBox(
              height: 35,
              child: Center(child: Text(
                  reason.toString(),style: const TextStyle(color: Colors.red,fontSize: 12.5)
              )),
            ),
          ],
        ),
      ],
    )
    :
    Table(
      border: TableBorder.all(color: Colors.grey.withOpacity(0.6)),
      columnWidths: const {
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 30,right: 30),
              height: 35,
              child: const Center(child: Text('Time-in')),
            ),
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.top,
              child: SizedBox(
                height: 35,
                // width: 32,
                child: Center(child: Text(
                  (timeIn.isNotEmpty && timeIn != 'null')
                      ?
                  Utils.parseDateTToString(timeIn.toString(), Const.TIME2)
                      :
                  'Bạn nghỉ hay đã quên chấm công?',style:  timeIn.toString() != '' ? const TextStyle(color: Colors.black,fontSize: 12.5) : const TextStyle(fontSize: 12.5,color: Colors.blueGrey) ,
                )),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const SizedBox(
              height: 35,
              child: Center(child: Text('Time-out')),
            ),
            SizedBox(
              height: 35,
              child: Center(child: Text(
                (timeOut.isNotEmpty && timeOut != 'null')
                    ?
                Utils.parseDateTToString(timeOut.toString(), Const.TIME2)
                    :
                'Bạn nghỉ hay đã quên chấm công?',style:  timeOut.toString() != '' ? const TextStyle(color: Colors.black,fontSize: 12.5) : const TextStyle(fontSize: 12.5,color: Colors.blueGrey) ,
              )),
            ),
          ],
        ),
      ],
    )
    ;
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
                DateFormat.yMMMM('vi').format(_focusedDay).toTitleCase(),
                style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Colors.white,),
                maxLines: 1,overflow: TextOverflow.fade,
              ),
            ),
          ),
          InkWell(
            onTap: ()=> PersistentNavBarNavigator.pushNewScreen(context,
                screen: const MoveScreen(),
                withNavBar: false).then((value){
                  if(value != null && value[0] == 'Yeah'){
                    startTimer();
                    _bloc.add(ListDataTimeKeepingFromUserEvent(datetime: DateTime.now().toString()));
                  }
            }),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.output,
                size: 25,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
