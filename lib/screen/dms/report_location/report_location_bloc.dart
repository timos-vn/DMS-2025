import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';

import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';
import '../../../utils/utils.dart';
import 'report_location_event.dart';
import 'report_location_sate.dart';

class ReportLocationBloc extends Bloc<ReportLocationEvent,ReportLocationState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;
  String? _accessToken;
  String get accessToken => _accessToken!;
  String? _refreshToken;
  String get refreshToken => _refreshToken!;


  bool isGrantCamera = false;
  String? codeCustomer,nameCustomer,phoneCustomer;
  String? time;
  File? _file;
  File get file => _file!;
  String? currentAddress;
  Position? position2;
  Position? currentLocation;

  List<File> listFileInvoice = [];


  ReportLocationBloc(this.context) : super(InitialReportLocationState()){
    _networkFactory = NetWorkFactory(context);
    on<GetReportLocationPrefs>(_getPrefs);
    on<GetUserInfoEvent>(_getUserInfoEvent);
    on<RefreshEvent>(_refreshEvent);
    on<GetLocationEvent>(_getLocationEvent);
    on<ReportLocationFromUserEvent>(_reportLocationFromUserEvent);
    on<GetCameraEvent>(_getCameraEvent);
  }
  final box = GetStorage();
  void _getPrefs(GetReportLocationPrefs event, Emitter<ReportLocationState> emitter)async{
    emitter(InitialReportLocationState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getUserInfoEvent(GetUserInfoEvent event, Emitter<ReportLocationState> emitter)async{
    emitter(ReportLocationLoading());
    codeCustomer = event.codeCustomer;
    nameCustomer = event.nameCustomer;
    phoneCustomer = event.phoneCustomer;
    emitter(GetUserInfoSuccess());
  }

  void _refreshEvent(RefreshEvent event, Emitter<ReportLocationState> emitter)async{
    emitter(ReportLocationLoading());
    emitter(InitialReportLocationState());
  }

  void _getLocationEvent(GetLocationEvent event, Emitter<ReportLocationState> emitter)async{
    emitter(ReportLocationLoading());
    getUserLocation();
    emitter(GetLocationSuccess());
  }

  void _reportLocationFromUserEvent(ReportLocationFromUserEvent event, Emitter<ReportLocationState> emitter)async{
    emitter(ReportLocationLoading());
    // ReportLocationRequest request = ReportLocationRequest(
    //     datetime: event.datetime,
    //     customer: event.customer,
    //     latLong: '${currentLocation?.latitude},${currentLocation?.longitude}',
    //     location: event.location,
    //     description: event.description,
    //     note: event.note,
    //     namePath: event.namePath,
    //     nameFile: event.nameFile,
    //     image: Utils.base64Image(event.image)
    // );

    var formData = FormData.fromMap(
        {
          "Datetime": event.datetime,
          "Customer": event.customer,
          "LatLong":'${currentLocation?.latitude},${currentLocation?.longitude}',
          "Location":event.location.toString(),
          "Description":event.description.toString(),
          "Note":event.note.toString(),
        }
    );
    if(listFileInvoice.isNotEmpty){
      for (var element in listFileInvoice) {
        formData.files.addAll([
          MapEntry("ListFile",await MultipartFile.fromFile(element.path))
        ]);
      }
    }else{
      const MapEntry("ListFile","");
    }

    ReportLocationState sate =  _handleCheckIn(await _networkFactory!.reportLocationV2(formData,_accessToken!));
    emitter(sate);
  }

  void _getCameraEvent(GetCameraEvent event, Emitter<ReportLocationState> emitter)async{
    emitter(InitialReportLocationState());
    Map<Permission, PermissionStatus> permissionRequestResult = await [Permission.location,Permission.camera].request();
    if (permissionRequestResult[Permission.camera] == PermissionStatus.granted) {
      isGrantCamera = true;
      emitter(GrantCameraPermission());
    }
    else {
      if (await Permission.camera.isPermanentlyDenied) {
        emitter(InitialReportLocationState());
      } else {
        isGrantCamera = false;
        emitter(EmployeeScanFailure('Vui lòng cấp quyền truy cập Camera.'));
      }
    }
  }

  ReportLocationState _handleCheckIn(Object data,) {
    if (data is String) return ReportLocationFailure(data);
    try {
      return ReportLocationSuccess();
    } catch (e) {
      return ReportLocationFailure(e.toString());
    }
  }

  late StreamSubscription<Position> positionStream;

  getUserLocation() async {
    positionStream =
        Utils.getPositionStream().listen((Position position) async{
          List<Placemark> placePoint = await placemarkFromCoordinates(position.latitude,position.longitude);
          String currentAddress1 = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
          currentAddress = currentAddress1;
          time = DateFormat("HH:mm:ss").format(DateTime.now()).toString();
          currentLocation = position;
          stopListenLocation();
        });
  }

  void stopListenLocation(){
    positionStream.cancel();
  }

  // void testLocation()async{
  //   //20.9559517,107.0986001
  //   List<Placemark> placePoint = await placemarkFromCoordinates(16.0415884,108.2431961);
  //   String currentAddress1 = "${placePoint[0].name}, "
  //       "${placePoint[0].thoroughfare}, "
  //       "${placePoint[0].subAdministrativeArea}, "
  //       "${placePoint[0].administrativeArea},"
  //       " ${placePoint[0].subThoroughfare},"
  //       " ${placePoint[0].country},"
  //       " ${placePoint[0].street},"
  //       "${placePoint[0].isoCountryCode},"
  //       "${placePoint[0].locality},"
  //       "${placePoint[0].postalCode},";
  //   print(currentAddress1);
  // }


  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  }

  // getUserLocation() async {
  //   currentLocation = await locateUser();
  //   List<Placemark> placePoint = await placemarkFromCoordinates(currentLocation!.latitude,currentLocation!.longitude);
  //   currentAddress = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
  //   time = DateFormat("HH:mm:ss").format(DateTime.now()).toString();
  // }

}