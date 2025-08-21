import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ServicesGeoLocation{

  Future<Position> getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
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
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }


  // Future<List<LatLng>> getListPolylineCoordinates(Position positionStartPoint, Position positionEndPoint) async {
  //   polylineCoordinates.clear();
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       ConfigApp.POLYLINE_KEY_GOOGLE,
  //       //Const.PLACE_KEY,
  //       PointLatLng(
  //           positionStartPoint.latitude,
  //           positionStartPoint.longitude
  //       ),
  //       PointLatLng(
  //           positionEndPoint.latitude,
  //           positionEndPoint.longitude
  //       )
  //   );
  //   print('result-: ${result.status}');
  //   statusDirection ='';
  //   if (result.status == 'OK') {
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   }else if(result.status == 'OVER_QUERY_LIMIT'){
  //     statusDirection = 'OVER_QUERY_LIMIT';
  //   }
  //   print(polylineCoordinates.length);
  //   distance();
  //   return polylineCoordinates;
  // }

  // void distance(){
  //   double totalDistance = 0.0;
  //   print(polylineCoordinates.length);
  //   for (int i = 0; i < polylineCoordinates.length - 1; i++) {
  //     totalDistance += Utils.calculateDistance(
  //       polylineCoordinates[i].latitude,
  //       polylineCoordinates[i].longitude,
  //       polylineCoordinates[i + 1].latitude,
  //       polylineCoordinates[i + 1].longitude,
  //     );
  //   }
  //   distanceInMeters = double.parse(totalDistance.toStringAsFixed(2));
  //   print('DISTANCE: ${distanceInMeters.toString()} km');
  // }
}