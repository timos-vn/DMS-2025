import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import '../api/api_utils.dart';
import 'constant.dart';

bool serviceEnabled = true;
PermissionStatus permissionGranted = PermissionStatus.granted;
PermissionStatus status = PermissionStatus.granted;
bool access = serviceEnabled == true && status == PermissionStatus.granted;
LatLng? lastPosition;

loc.Location location = loc.Location();
StreamSubscription<loc.LocationData>? _locationSubscription;

Future<bool> isAccess() async {
  serviceEnabled = await location.serviceEnabled();
  permissionGranted = await Permission.locationWhenInUse.status;
  // print("serviceEnabled: $serviceEnabled");
  // print('permissionGranted: $permissionGranted');
  return serviceEnabled && permissionGranted.isGranted;
}

Future<void> checkService() async {
  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return;
    }
  }
}

Future<void> checkPermissionWhile(GlobalKey key) async {
  permissionGranted = await Permission.locationWhenInUse.status;
  // print('check permissionGranted: ${permissionGranted.isGranted}');
  // print('check permissionGranted: ${permissionGranted.isDenied}');
  // print('check permissionGranted: ${permissionGranted.isPermanentlyDenied}');
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await Permission.locationWhenInUse.request();
    // print('acb: 1 ${permissionGranted == PermissionStatus.granted}');
    // print('acb: 1 ${PermissionStatus.granted}');
    // print('acb: 1 ${permissionGranted}');
    if (permissionGranted == PermissionStatus.granted) {
      Navigator.pop(key.currentContext!);
      return;
    }
  }
  if (permissionGranted.isPermanentlyDenied) {
    showDialog(
        context: key.currentContext!,
        builder: (c) {
          return CupertinoAlertDialog(
            title: const Text('Vui lòng cấp quyền vị trí'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                    openAppSettings();
                  },
                  child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
            ],
          );
        });
  }
}
bool isEnable = false;
Future<bool> checkPermissionAlways(GlobalKey key) async {
  status = await Permission.locationAlways.status;
  if (!status.isGranted) {

    showDialog(
        context: key.currentContext!,
        builder: (c) {
          return CupertinoAlertDialog(
            title: const Text('Vui lòng cấp quyền vị trí thành luôn cho phép'),
            actions: <Widget>[
              TextButton(
                  onPressed: () async {
                    // await Permission.locationAlways.request().then((value) {
                    if(isEnable){
                      Navigator.pop(c,true);
                    }else{
                      await Permission.locationAlways.request().then((value) {
                        if (value.isGranted) {
                          Navigator.pop(c,value);
                        }else{
                          openAppSettings();
                        }
                        isEnable = value.isGranted;
                      });
                    }
                  },
                  child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
            ],
          );
        });
    return isEnable;
  }
  else{
    return false;
  }
}

void listenLocation(Function func) {
  print('change Location user 0');
  location.enableBackgroundMode();
  location.changeSettings(
      accuracy: loc.LocationAccuracy.low,
      interval: initData.isTimeCallApi! * 1000);
  _locationSubscription = location.onLocationChanged.handleError((dynamic err) {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }).listen((loc.LocationData current) {
    print('change Location user 1');
    if (initData.isStart && !initData.isEnd!) {
      if (calculateDistance(lastPosition, LatLng(current.latitude!, current.longitude!)) > 5) {
        lastPosition = LatLng(current.latitude!, current.longitude!);
        print('change Location user 2');
        updateLocation(lat: current.latitude, lng: current.longitude, token: user.token)
            .then((value) => func());
      }
    }
  });
}

double calculateDistance(LatLng? start, LatLng end) {
  if (start == null) {
    return 6;
  } else {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((end.latitude - start.latitude) * p) / 2 +
        cos(start.latitude * p) *
            cos(end.latitude * p) *
            (1 - cos((end.longitude - start.longitude) * p)) /
            2;
    return 12742000 * asin(sqrt(a));
  }
}

Future<void> stopListen() async {
  await _locationSubscription?.cancel();
  _locationSubscription = null;
}

void serviceDialog(GlobalKey key, bool canPop) {
  stopListen();
  if (canPop) {
    Navigator.popUntil(key.currentContext!, (route) => route.isFirst);
  }
  showDialog(
      context: key.currentContext!,
      builder: (c) {
        return CupertinoAlertDialog(
          title: const Text('Vui lòng bật định vị'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
          ],
        );
      });
}

void permissionDialog(GlobalKey key, bool canPop) {
  stopListen();
  if (canPop) {
    Navigator.popUntil(key.currentContext!, (route) => route.isFirst);
  }
  showDialog(
      context: key.currentContext!,
      builder: (c) {
        return CupertinoAlertDialog(
          title: const Text('Vui lòng cấp quyền vị trí'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
          ],
        );
      });
}
