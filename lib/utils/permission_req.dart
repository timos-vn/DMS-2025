import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckPermission{

  static Future<bool> checkPermission()async{
    bool isGrantCamera = false;
    Map<Permission, PermissionStatus> permissionRequestResult = await [Permission.locationAlways,Permission.locationWhenInUse,Permission.location].request();
    if (permissionRequestResult[Permission.location] == PermissionStatus.granted) {
      isGrantCamera = true;
    }
    else {
      if (await Permission.camera.isPermanentlyDenied) {
        Geolocator.openLocationSettings();
      } else {
        isGrantCamera = false;
      }
    }
   return isGrantCamera;
  }
  static Future<Position> getLocation2() async{
    // Test if location services are enabled.
    print('test');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('test1');
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    print('test2');
    if (permission == LocationPermission.denied) {
      print('test3');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(Exception('Location permissions are permanently denied.'));
      }

      if (permission == LocationPermission.denied) {
        print('test4');
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error(Exception('Location permissions are denied.'));
      }
    }
    print('test5');
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}