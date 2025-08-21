import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:dms/screen/personnel/time_keeping/time_keeping_event.dart';
import 'package:dms/screen/personnel/time_keeping/time_keeping_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../../../model/network/request/time_keeping_history_request.dart';
import '../../../model/network/request/time_keeping_request.dart';
import '../../../model/network/response/time_keeping_data_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';

class TimeKeepingBloc extends Bloc<TimeKeepingEvent,TimeKeepingState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  List<File> listFileImage = [];
  String? lat;
  String? long;

  int indexBanner = 0;
  String? _userId;
  String currentAddress = '';
  // Position? currentLocation;
  String publicIP = '';
  TimeKeepingDataResponseMaster master = TimeKeepingDataResponseMaster();
  List<ListTimeKeepingHistory> listDataTimeKeeping = [];

  TimeKeepingBloc(this.context) : super(InitialTimeKeepingState()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefsTimeKeeping>(_getPrefs);
    on<TimeKeepingFromUserEvent>(_timeKeepingFromUserEvent);
    on<LoadingTimeKeeping>(_loadingTimeKeeping);
    on<ListDataTimeKeepingFromUserEvent>(_getListDataTimeKeepingFromUserEvent);
    on<CheckLocationTimeKeepingEvent>(_checkLocationTimeKeepingEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetPrefsTimeKeeping event, Emitter<TimeKeepingState> emitter)async{
    emitter(InitialTimeKeepingState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    _userId = box.read(Const.USER_ID);
    emitter(GetPrefsSuccess());
  }


  void _checkLocationTimeKeepingEvent(CheckLocationTimeKeepingEvent event, Emitter<TimeKeepingState> emitter)async{
    emitter(TimeKeepingLoading());

    if(publicIP.toString().replaceAll('null', '').isNotEmpty){
      emitter(CheckWifiSuccess());
    }else{
      emitter(TimeKeepingFailure('Mã lỗi 1582 - Lỗi connect thiết bị'));
    }
  }


  void _getListDataTimeKeepingFromUserEvent(ListDataTimeKeepingFromUserEvent event, Emitter<TimeKeepingState> emitter)async{
    emitter(TimeKeepingLoading());
    TimeKeepingHistoryRequest request = TimeKeepingHistoryRequest(
        datetime: event.datetime,
    );
    TimeKeepingState state =  _handleTimeKeepingData(await _networkFactory!.listTimeKeepingHistory(request,_accessToken!));
    emitter(state);
  }

  Future<XFile> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // giảm chất lượng xuống ~70%
    );

    return result!;
  }

  void _timeKeepingFromUserEvent(TimeKeepingFromUserEvent event, Emitter<TimeKeepingState> emitter)async{
    emitter(TimeKeepingLoading());
    if(event.isMeetCustomer){
      var formData = FormData.fromMap(
          {
            "datetime": event.datetime,
            "latLong": '$lat,$long',
            "address": currentAddress,
            "note": event.desc,
            "qrCode": event.qrCode,
            "uId": event.uId,
            "isWifi": event.isWifi,
            "isUserVIP": event.isUserVIP,
            "ListFile": await Future.wait(
                listFileImage.map((file) async {
                  XFile compress = await compressImage(file);
                  return await MultipartFile.fromFile(compress.path,filename: compress.path);
                })
            ),
          }
      );
      TimeKeepingState state = _handleTimeKeeping(await _networkFactory!.checkOutInTimeKeeping(formData,_accessToken!));
      emitter(state);
    }else{
      TimeKeepingRequest request = TimeKeepingRequest(
        datetime: event.datetime,
        latLong: '$lat,$long',
        address: currentAddress,
        note: event.desc,
        qrCode: event.qrCode,
        uId: event.uId,
        isWifi: event.isWifi,
        isUserVIP: event.isUserVIP
      );
      TimeKeepingState state =  _handleTimeKeeping(await _networkFactory!.checkOutInTimeKeepingType2(request,_accessToken.toString()));
      emitter(state);
    }
  }

  void _loadingTimeKeeping(LoadingTimeKeeping event, Emitter<TimeKeepingState> emitter)async{
    emitter(TimeKeepingLoading());
    // emitter(InitialTimeKeepingState());
    try {
      // final result2 = await InternetAddress.lookup('https://api.ipify.org?format=json');
      // print(result2);
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        publicIP = await getPublicIP().whenComplete(() => add(CheckLocationTimeKeepingEvent()));
      }
    } on SocketException catch (_) {
      print('not connected');
      emitter(TimeKeepingError());
    }
    // getUserLocation().whenComplete(() => add(CheckLocationTimeKeepingEvent()));
  }

  Future<String> getPublicIP() async {
    print("response 123:");
    final response = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    print("response: $response");
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print(json['ip']);
      return json['ip'];
    } else {
      throw Exception('Failed to load IP address');
    }
  }


  TimeKeepingState _handleTimeKeepingData(Object data,) {
    if (data is String) return TimeKeepingFailure('Úi, ${data.toString()}');
    try {
      TimeKeepingDataResponse response = TimeKeepingDataResponse.fromJson(data as Map<String,dynamic>);
      master = response.master!;
      listDataTimeKeeping = response.listTimeKeepingHistory!;
      return TimeKeepingDataSuccess();
    } catch (e) {
      print(e.toString());
      return TimeKeepingFailure('Úi, ${e.toString()}');
    }
  }

  TimeKeepingState _handleTimeKeeping(Object data,) {
    if (data is String) return TimeKeepingFailure('Úi, ${data.toString()}');
    try {
      return TimeKeepingSuccess();
    } catch (e) {
      // return TimeKeepingSuccess();

      return TimeKeepingFailure('Úi, ${e.toString()}');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
}



int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
        (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}