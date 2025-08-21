import 'dart:async';

import 'package:dms/model/database/data_local.dart';
import 'package:dms/screen/dms/check_in/check_in_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_picker/map_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../themes/colors.dart';
import '../check_in_bloc.dart';
import '../check_in_event.dart';

class MapView extends StatefulWidget {
  final String? title;
  final String latStart;
  final String longStart;
  final double latEnd;
  final double longEnd;
  final double metter;

  const MapView({Key? key, required this.latStart, required this.longStart,
    required this.latEnd, required this.longEnd, required this.metter, this.title}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  late CheckInBloc _bloc;
  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();
  late CameraPosition cameraPosition;

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  final Set<Polyline> _polylines = <Polyline>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cameraPosition = CameraPosition(
      target: LatLng(widget.latStart.isNotEmpty ? double.parse(widget.latStart.toString()) : 41.311158,
          widget.longStart.isNotEmpty ? double.parse(widget.longStart.toString()) : 69.279737),
      zoom: 14.4746,
    );
    _bloc = CheckInBloc(context);
    _bloc.add(GetPrefsCheckIn());
  }

  void setPolyLines() async {
    polylineCoordinates.clear();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: 'AIzaSyCw9jgxvsK9XgpRnOmTtDxg5fO_P6QK3NI', request: PolylineRequest(origin:  PointLatLng(
    double.parse(widget.latStart),
    double.parse(widget.longStart)
    ), destination:  PointLatLng(
        widget.latEnd,
        widget.longEnd
    ), mode: TravelMode.driving,)
    );
    print('result: ${result.status}');
    if (result.status == 'OK') {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      setState(() {
        _polylines.add(
            Polyline(
                width: 3,
                polylineId: const PolylineId('polyLine'),
                color: Colors.deepPurpleAccent,
                points: polylineCoordinates
            )
        );
      });
      // animateTo(widget.latLngStartPoint.latitude,widget.latLngStartPoint.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocProvider(
        create: (context) => _bloc,
        child: BlocListener<CheckInBloc, CheckInState>(
            listener: (context, state) {

            }, child: BlocBuilder<CheckInBloc, CheckInState>(
            builder: (
                BuildContext context,
                CheckInState state,
                ) {
              return Center(
                child: AlertDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Check-in vị trí bất thường',
                          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      InkWell(
                        onTap: ()=>  Navigator.pop(context,["Back"]),
                        child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                    color: Colors.grey,
                                    width: 0.2
                                )
                            ),
                            child: const Icon(Icons.cancel,color: red,size: 20,) ),
                      ),
                    ],
                  ),
                  content: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                              "Đôi khi thiết bị sẽ định vị sai vị trí. Đừng lo lắng, việc check-in vị trí bất thường này sẽ được hệ thống ghi nhận",
                              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            // Placeholder(
                            //   child: buildGoogleMaps(context),
                            // )
                            SizedBox(
                              height: 220,
                                width: MediaQuery.of(context).size.width ,
                                child: buildGoogleMaps(context)),
                            Padding(
                              padding: const EdgeInsets.only(top: 5,bottom: 5),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Vị trí lựa chọn: ',
                                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                          0xff555a55)),
                                    ),
                                    TextSpan(
                                      text: _bloc.addressDifferent.toString().trim(),
                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5,bottom: 15),
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Khoảng cách bất thường: ',
                                      style: TextStyle(fontWeight: FontWeight.normal,fontSize: 12,color:  Color(
                                          0xff555a55)),
                                    ),
                                    TextSpan(
                                      text: '${widget.metter.toStringAsFixed(2).toString()} met',
                                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                  DataLocal.addressDifferent = DataLocal.addressCheckInCustomer;
                                  DataLocal.latDifferent = widget.latEnd;
                                  DataLocal.longDifferent = widget.longEnd;
                                  Navigator.pop(context,['Accepted']);
                                },
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: mainColor,
                                  borderRadius: const BorderRadius.all(Radius.circular(10))
                                ),
                                child: Center(
                                  child: Text( widget.title.toString().replaceAll('null', '').isNotEmpty ?  widget.title.toString() : 'Tiếp tục check-in',style: TextStyle(fontSize: 13,color: Colors.white,fontWeight: FontWeight.bold),),
                                ),
                              ),
                            ),
                          ])),
                ),
              );
            })),
      )
    );
  }

  Widget buildGoogleMaps(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        MapPicker(
          // pass icon widget
          iconWidget: SvgPicture.asset(
            "assets/location_icon.svg",
            height: 30,
          ),
          //add map picker controller
          mapPickerController: mapPickerController,
          child: GoogleMap(
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            // hide location button
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            //  camera position
            initialCameraPosition: cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              setPolyLines();
            },
            onCameraMoveStarted: () {
              // notify map is moving
              mapPickerController.mapMoving!();
              _bloc.add(CheckingLocationDifferent(addressDifferent: "checking ..."));
            },
            onCameraMove: (cameraPosition) {
              this.cameraPosition = cameraPosition;
            },
            polylines: _polylines,
            onCameraIdle: () async {
              // notify map stopped moving
              mapPickerController.mapFinishedMoving!();
              //get address name from camera position
              List<Placemark> placemarks = await placemarkFromCoordinates(
                cameraPosition.target.latitude,
                cameraPosition.target.longitude,
              );
              // update the ui with the address
              _bloc.add(GetLocationDifferent(addressDifferent: '${placemarks.first.street}, ${placemarks.first.subAdministrativeArea}', lat: cameraPosition.target.latitude,long: cameraPosition.target.longitude));
            },
          ),
        ),
        // Positioned(
        //   top: MediaQuery.of(context).viewPadding.top + 20,
        //   width: MediaQuery.of(context).size.width - 50,
        //   height: 50,
        //   child: TextFormField(
        //     maxLines: 3,
        //     textAlign: TextAlign.center,
        //     readOnly: true,
        //     decoration: const InputDecoration(
        //         contentPadding: EdgeInsets.zero, border: InputBorder.none),
        //     controller: textController,
        //     style: TextStyle(fontSize: 13,fontWeight: FontWeight.bold),
        //   ),
        // ),
      ],
    );
  }
}
