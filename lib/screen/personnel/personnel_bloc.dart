import 'package:dms/screen/personnel/personnel_event.dart';
import 'package:dms/screen/personnel/personnel_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

import '../../model/network/request/time_keeping_request.dart';
import '../../model/network/response/get_list_employee_response.dart';
import '../../model/network/services/network_factory.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';

class PersonnelBloc extends Bloc<PersonnelEvent, PersonnelState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;

  final box = GetStorage();

  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  int totalPager = 0;
  String? userId;
  String? currentAddress;
  Position? currentLocation;
  bool isShowCancelButton = false;
  List<TotalOrder> totalOrder = [];
  List<ListEmployee> listEmployee = [];
  int totalUnreadNotification = 0;

  PersonnelBloc(this.context) : super(InitialPersonnelState()) {
    _networkFactory = NetWorkFactory(context);
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userId = box.read(Const.USER_ID);
    totalUnreadNotification = box.read(Const.TOTAL_UNREAD_NOTIFICATION) ?? 0;
    on<GetListEmployeeEvent>(_getListEmployee);
    // on<TimeKeepingFromUserEvent>(_timeKeepingFromUserEvent);
    // on<LoadingTimeKeeping>(_loadingTimeKeeping);
    on<CheckShowCloseEvent>(_checkShowCloseEvent);
    on<GetTotalUnreadNotificationEvent>(_getTotalUnreadNotification);
  }

  void _getListEmployee(
      GetListEmployeeEvent event, Emitter<PersonnelState> emitter) async {
    emitter(PersonnelLoading());
    PersonnelState state = _handleGetListEmployee(await _networkFactory!
        .getListEmployee(
            _accessToken.toString(),
            event.pageIndex,
            20,
            event.userId.toString(),
            event.keySearch.toString(),
            event.typeAction));
    emitter(state);
  }

  void _checkShowCloseEvent(
      CheckShowCloseEvent event, Emitter<PersonnelState> emitter) async {
    emitter(PersonnelLoading());
    isShowCancelButton = !Utils.isEmpty(event.text);
    emitter(InitialPersonnelState());
  }

  // void _timeKeepingFromUserEvent(
  //     TimeKeepingFromUserEvent event, Emitter<PersonnelState> emitter) async {
  //   emitter(InitialPersonnelState());
  //   TimeKeepingRequest request = TimeKeepingRequest(
  //       datetime: event.datetime,
  //       userName: userId,
  //       location: currentAddress,
  //       latLong: '${currentLocation?.latitude},${currentLocation?.longitude}',
  //       descript: '',
  //       note: '',
  //       uId: event.uId,
  //       qrCode: event.qrCode);
  //   PersonnelState state = _handleTimeKeeping(
  //       await _networkFactory!.timeKeeping(request, _accessToken!));
  //   emitter(state);
  // }

  // void _loadingTimeKeeping(
  //     LoadingTimeKeeping event, Emitter<PersonnelState> emitter) async {
  //   emitter(PersonnelLoading());
  //   getUserLocation().whenComplete(() => add(
  //       TimeKeepingFromUserEvent(DateTime.now().toString(), '0', event.uId)));
  // }

  int totalMyOder = 0;
  int totalEmployeeOder = 0;

  PersonnelState _handleGetListEmployee(
    Object data,
  ) {
    if (data is String) return TimeKeepingFailure('Úi, ${data.toString()}');
    try {
      ListEmployeeResponse response =
          ListEmployeeResponse.fromJson(data as Map<String, dynamic>);
      totalOrder = response.totalOrder!;
      if (totalOrder.isNotEmpty) {
        totalMyOder = totalOrder[0].slDon!;
        totalEmployeeOder = totalOrder[0].slDonNv!;
      }
      listEmployee = response.listEmployee!;
      totalPager = response.totalPage!;
      if (listEmployee.isNotEmpty) {
        return GetListEmployeeEventSuccess();
      } else {
        return EmptyEmployeeState();
      }
    } catch (e) {
      return TimeKeepingFailure('Úi, ${e.toString()}');
    }
  }

  PersonnelState _handleTimeKeeping(
    Object data,
  ) {
    if (data is String) return TimeKeepingFailure('Úi, ${data.toString()}');
    try {
      return TimeKeepingSuccess();
    } catch (e) {
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
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<PersonnelState> getUserLocation() async {
    currentLocation = await _determinePosition();
    // final coordinates = new Coordinates(currentLocation?.latitude, currentLocation?.longitude);
    // var addresses = await Geocoder2.local.findAddressesFromCoordinates(coordinates);
    // currentAddress = addresses.first.addressLine.toString();
    return GetLocationSuccess();
  }

  void _getTotalUnreadNotification(GetTotalUnreadNotificationEvent event,
      Emitter<PersonnelState> emitter) async {
    emitter(PersonnelLoading());

    try {
      Object data = await _networkFactory!.getTotalUnreadNotification(
        _accessToken!,
      );

      if (data is Map<String, dynamic>) {
        if (data['recordUnRead'] != null && data['recordUnRead'] is int) {
          int recordUnRead = data['recordUnRead'];
          totalUnreadNotification = recordUnRead;
          box.write(Const.TOTAL_UNREAD_NOTIFICATION, recordUnRead);
          emitter(GetTotalUnreadNotificationSuccess());
        } else {
          emitter(PersonnelFailure(''));
        }
      }
    } catch (e) {
      emitter(PersonnelFailure('Úi: ${e.toString()}'));
    }
  }
}
