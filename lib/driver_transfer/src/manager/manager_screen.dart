import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:socket_io_client/socket_io_client.dart';

import '../../api/api_utils.dart';
import '../../api/models/employee_model.dart';
import '../../api/models/order_model.dart';
import '../../helper/constant.dart';
import '../../helper/date_picker.dart';
import '../employee/employee_order.dart';
import '../employee/order_marker.dart';
import 'employee_list.dart';
import 'employee_marker.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  Location location = Location();
  bool calendarActive = false, listActive = false;
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  DateTime date = DateTime.now();
  static const CameraPosition kLocation =
      CameraPosition(target: LatLng(21.0227784, 105.8163641), zoom: 14.4746);
  EmployeeModel? employee;
  List<GlobalKey> listKey = [];
  List<EmployeeModel> listEmployee = [];
  List<GlobalKey> orderKey = [];
  List<OrderModel> listOrder = [];
  Set<Marker> markers = <Marker>{};
  Set<Marker> orderMarkers = <Marker>{};
  Set<Marker> actualMarkers = <Marker>{};
  late LatLng current;
  Set<Polyline> polylines = {};
  bool isRelity = false;

  @override
  void initState() {
    getLocation();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getData();
      initSocket();
    });
    super.initState();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  void getLocation() async {
    await location.getLocation().then((value) async {
      if (mounted) {
        setState(() {
          current = LatLng(value.latitude!, value.longitude!);
        });
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(CameraUpdate.newLatLng(current));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark),
      ),
      body: Stack(
        children: [
          if (listEmployee.isNotEmpty)
            EmployeeMarker(key: UniqueKey(), listKey: listKey, listEmployee: listEmployee),
          if (listOrder.isNotEmpty)
            OrderMarker(key: UniqueKey(), listKey: orderKey, listOrder: listOrder),
          Container(color: Colors.white, height: double.infinity, width: double.infinity),
          GoogleMap(
              initialCameraPosition: kLocation,
              zoomControlsEnabled: false,
              compassEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              polylines: polylines,
              markers: employee == null ? markers : orderMarkers),
          Positioned(top: paddingTop + 10, left: kPadding, right: kPadding, child: _action()),
          AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              top: employee != null ? paddingTop + 80 : MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height - 80 - paddingTop,
              child: EmployeeOrder(
                key: UniqueKey(),
                height: MediaQuery.of(context).size.height - 80 - paddingTop,
                date: date,
                onClear: onClear,
                name: '${employee?.firstName} ${employee?.lastName}',
                listOrder: listOrder,
                isReality: isRelity,
                changePolylines: changePolylines,
              )),
          AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              top: listActive ? paddingTop + 80 : MediaQuery.of(context).size.height,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height - 80 - paddingTop,
              child: EmployeeList(
                key: ValueKey(employee?.id),
                employee: employee,
                listEmployee: listEmployee,
                onPick: onPick,
                selectDate: selectDate,
              )),
        ],
      ),
    );
  }

  _action() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => employeeList(),
          child: Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(color: listActive ? blue : white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Image(image: userAsset, height: 23, color: listActive ? white : black),
          ),
        ),
        // const SizedBox(width: 15),
        // GestureDetector(
        //   onTap: () => logOut(),
        //   child: Container(
        //     height: 45,
        //     width: 45,
        //     decoration: const BoxDecoration(color: white, shape: BoxShape.circle),
        //     alignment: Alignment.center,
        //     child: const Icon(Icons.power_settings_new, size: 26),
        //   ),
        // ),
      ],
    );
  }

  void getData() async {
    showLoaderDialog(context);
    await getEmployee(token: user.token).then((value) async {
      setState(() {
        listEmployee = value;
        listKey = List.generate(value.length, (index) => GlobalKey());
      });
      cancelLoaderDialog(context);
      Future.delayed(const Duration(milliseconds: 500), () async {
        await Future.wait(List.generate(listKey.length, (i) async {
          Marker m = await generateMarker(i);
          markers.add(m);
        })).whenComplete(() => setState(() {}));
      });
    }).onError((error, stackTrace) {
      showLoaderDialog(context);
    });
  }

  void onClear() {
    socket.off('change-location-by-employee-id-${employee!.employeeId}');
    setState(() {
      employee = null;
      listActive = true;
      listOrder.clear();
      orderMarkers.clear();
      orderKey.clear();
      polylines.clear();
    });
  }

  void onPick(int index) async {
    setState(() {
      listActive = false;
      employee = listEmployee[index];
      actualMarkers.clear();
    });

    socket.on('change-location-by-employee-id-${listEmployee[index].employeeId}', (data) async {
      getOrder(index);
    });
    showLoaderDialog(context);
    getOrder(index).then((value) {
      cancelLoaderDialog(context);
    }).onError((error, stackTrace) {
      cancelLoaderDialog(context);
    });
  }

  Future<void> getOrder(int index) async {
    await getEmployeeOrder(
            id: employee!.employeeId, date: date.toString().substring(0, 10), token: user.token)
        .then((value) async {
      setState(() {
        listOrder.clear();
        listOrder.addAll(value);
        orderMarkers.clear();
        orderKey.clear();
        orderKey.addAll(List.generate(value.length, (index) => GlobalKey()));
      });

      if (listOrder.isNotEmpty) {
        final GoogleMapController controller = await _controller.future;
        await controller
            .animateCamera(CameraUpdate.newLatLng(LatLng(employee!.lat!, employee!.lng!)));
        getPolylines(index);
        Future.delayed(const Duration(milliseconds: 500), () async {
          await Future.wait(List.generate(listOrder.length, (i) async {
            Marker m = await generateOrderMarker(i);
            orderMarkers.add(m);
          })).whenComplete(() => setState(() {}));
        });
      }
    });
  }

  void changePolylines() {
    if (isRelity) {
      setState(() {
        orderMarkers = orderMarkers.difference(actualMarkers);
        isRelity = !isRelity;
      });
    } else {
      if (actualMarkers.isEmpty) {
        showLoaderDialog(context);
        getEmployeeRoute(
                id: employee!.employeeId, date: date.toString().substring(0, 10), token: user.token)
            .then((value) async {
          await Future.wait(List.generate(value.length, (i) async {
            Marker m = await generateActualMarker(value[i]);
            actualMarkers.add(m);
          })).whenComplete(() {
            setState(() {
              orderMarkers.addAll(actualMarkers);
            });
            cancelLoaderDialog(context);
          });
        }).onError((error, stackTrace) {
          cancelLoaderDialog(context);
        });
      } else {
        setState(() {
          orderMarkers.addAll(actualMarkers);
          isRelity = !isRelity;
        });
      }
    }
  }

  void employeeList() async {
    setState(() {
      listActive = !listActive;
    });
  }

  void selectDate() async {
    await showMaterialModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      builder: (context) => CustomDatePicker(date: date),
    ).then((val) {
      setState(() {
        if (val is DateTime) {
          date = val;
        }
      });
    });
  }

  void getPolylines(index) {
    getEmployeeDirection(id: employee!.employeeId, token: user.token).then((direction) async {
      listEmployee[index].lat = direction.currentLocation!.lat!;
      listEmployee[index].lng = direction.currentLocation!.lng!;
      Marker m = await generateMarker(index);
      orderMarkers.removeWhere((element) => element.markerId.value == 'employee#$index');
      orderMarkers.add(m);
      var polylinePoints = direction.data!.routes!.first.overviewPolyline!.polylinePoints!
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();
      setState(() {
        polylines.clear();
        polylines.add(Polyline(
            polylineId: const PolylineId('polyline'),
            color: blue,
            width: 3,
            points: polylinePoints));
      });
    });
  }

  Future<Marker> generateMarker(int index) async {
    final RenderRepaintBoundary boundary =
        listKey[index].currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return Marker(
        markerId: MarkerId('employee#$index'),
        icon: BitmapDescriptor.fromBytes(pngBytes),
        position: LatLng(listEmployee[index].lat!, listEmployee[index].lng!),
        onTap: () => onPick(index));
  }

  Future<Marker> generateOrderMarker(int index) async {
    final RenderRepaintBoundary boundary =
        orderKey[index].currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();
    return Marker(
        zIndex: 1000.0 - index,
        markerId: MarkerId(index.toString()),
        anchor: const Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(pngBytes),
        position: LatLng(listOrder[index].lat!, listOrder[index].lng!),
        onTap: () {});
  }

  Future<Marker> generateActualMarker(EmployeeModel item) async {
    final bitmapIcon = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(8, 8)),
        'packages/itinerary_monitoring/assets/circle.png');
    return Marker(
        zIndex: 1000.0 - item.id!,
        markerId: MarkerId(item.id.toString()),
        anchor: const Offset(0.5, 0.5),
        icon: bitmapIcon,
        position: LatLng(item.lat!, item.lng!),
        onTap: () {});
  }

  void logOut() {
    showDialog(
        context: context,
        builder: (c) {
          return CupertinoAlertDialog(
            title: const Text('Bạn chắc chắn muốn đăng xuất'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    socket.dispose();
                    // SharedPreferences.getInstance().then((pref) => pref.remove('account'));
                    // Navigator.pushAndRemoveUntil(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => const SignInSSE()),
                    //     (route) => route.isFirst);
                  },
                  child:
                      const Text('Đăng xuất', style: TextStyle(color: Colors.blue, fontSize: 15))),
              TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                  },
                  child: const Text('Đóng', style: TextStyle(color: Colors.red, fontSize: 15)))
            ],
          );
        });
  }

  late Socket socket;

  void initSocket() {
    socket = io(
        'https://sse.gover.vn',
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect()
            .enableForceNewConnection()
            .setReconnectionAttempts(5)
            .setExtraHeaders({'token': user.token}) // optional
            .build());
    socket.connect();

    socket.on('change-location-employee', (data) async {
      var value =
          List<EmployeeModel>.from(jsonDecode(data['data']).map((x) => EmployeeModel.fromJson(x)));
      setState(() {
        listEmployee = value;
        listKey = List.generate(value.length, (index) => GlobalKey());
      });
      Future.delayed(const Duration(milliseconds: 500), () async {
        await Future.wait(List.generate(listKey.length, (i) async {
          Marker m = await generateMarker(i);
          markers.add(m);
        })).whenComplete(() => setState(() {}));
      });
    });
  }
}
