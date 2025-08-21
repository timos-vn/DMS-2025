import 'dart:async';
import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../../model/network/request/confirm_shipping_request.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/const.dart';
import '../../api/api_net.dart';
import '../../api/api_utils.dart';
import '../../api/models/order_detail_model.dart';
import '../../api/models/order_model.dart';
import '../../helper/constant.dart';
import '../../helper/location_service.dart';
import 'employee_order.dart';
import 'order_marker.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({key, required this.networkFactory});

  final NetWorkFactory networkFactory;

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> with WidgetsBindingObserver {
  final employeeKey = GlobalKey();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  DateTime date = DateTime.now();
  static const CameraPosition kLocation =
      CameraPosition(target: LatLng(21.0227784, 105.8163641), zoom: 14.4746);
  List<GlobalKey> orderKey = [];
  Set<Marker> orderMarkers = <Marker>{};
  List<OrderModel> listOrder = [];
  Set<Polyline> polylines = {};
  bool load = true;
  String curOrder = '';
  late LatLng current;
  ui.AppLifecycleState state = AppLifecycleState.resumed;
  late NetWorkFactoryApi netWorkFactoryApi;

  String? _accessToken;
  final box = GetStorage();

  @override
  void initState() {
    netWorkFactoryApi = NetWorkFactoryApi(context);
    _accessToken = box.read(Const.ACCESS_TOKEN);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkPermissionAlways(employeeKey).then((values){
        print('result: $values');
        init();
      });
      //
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(ui.AppLifecycleState s) {
    Timer(const Duration(milliseconds: 3200), () {
      if (!mounted) {
        return;
      }
      setState(() {
        state = s;
      });
    });
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    double paddingTop = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      key: employeeKey,
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
          if (orderKey.isNotEmpty) OrderMarker(listKey: orderKey, listOrder: listOrder),
          Container(color: Colors.white, height: double.infinity, width: double.infinity),
          GoogleMap(
              initialCameraPosition: kLocation,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              compassEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              polylines: polylines,
              markers: orderMarkers),
          Positioned(top: paddingTop + 10, left: kPadding, right: kPadding, child: _action()),
          load ? const SizedBox() : Positioned(bottom: 130, left: 0, right: 0, child: _start()),
          load
              ? const SizedBox()
              : AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  top: paddingTop + 80,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height - 80 - paddingTop,
                  child: EmployeeOrder(
                      key: ValueKey(curOrder),
                      height: MediaQuery.of(context).size.height - 80 - paddingTop,
                      date: date,
                      active: initData.isStart,
                      listOrder: listOrder,
                      confirmOrder: confirmOrder,
                      onDirection: onDirection,
                      onChooseDate: onChooseDate,
                      name: '${user.dataUser!.firstName!} ${user.dataUser!.lastName!}', )),
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
        // GestureDetector(
        //   onTap: () async {
        //     await Permission.locationAlways.request().then((value) {
        //       print('vales isDenied: ${value.isDenied}');
        //       print('vales isGranted: ${value.isGranted}');
        //       print('vales isPermanentlyDenied: ${value.isPermanentlyDenied}');
        //       if (value.isGranted) {
        //         Navigator.pop(context);
        //       }
        //     });
        //     print('open setting');
        //   },
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

  _start() {
    if (initData.isStart) return const SizedBox();
    return Container(
        height: 104,
        width: 104,
        decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: blue, width: 2.5),
            shape: BoxShape.circle),
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
          onTap: onStart,
          child: Container(
            height: 94,
            width: 94,
            decoration: const BoxDecoration(color: orange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: setText('Bắt đầu', 16, fontWeight: FontWeight.w700, color: white),
          ),
        ));
  }


  void init() async {
    showLoaderDialog(context);
    location.getLocation().then((value) async {
      current = LatLng(value.latitude!, value.longitude!);
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newLatLng(current));
      await netWorkFactoryApi.getInit(user.token.toString()).then((res){
        if (mounted) {
          setState(() {
            initData = res;
            load = false;
          });
          netWorkFactoryApi.getMyOrderToday(token: user.token,dateForm: DateFormat('yyyy-MM-dd').format(Const.dateFrom).toString(),dateTo: DateFormat('yyyy-MM-dd').format(Const.dateTo).toString()).then((value) async {
            if (mounted) {
              setState(() {
                listOrder.addAll(value);
                orderKey.addAll(List.generate(value.length, (index) => GlobalKey()));
              });
              if (value.isNotEmpty) {
                curOrder = listOrder.every((element) => element.status == "1")
                    ? ''
                    : listOrder.firstWhere((element) => element.status == "0").id.toString();
                getOrder();
                if (initData.target != null) {
                  curOrder = initData.target!.orderId.toString();
                  onReloadDirection();
                } else if (initData.isStart && curOrder != '') {
                  updateTarget(id: curOrder, token: user.token).then((_) {
                    onReloadDirection();
                  });
                }
                print('change Location user - 100');
                listenLocation(onReloadDirection);
              }
              cancelLoaderDialog(context);
            }
          }).onError((error, stackTrace) {
            cancelLoaderDialog(context);
          });
        }
      });
      // await getInit(token: user.token).then((res) {
      //   if (mounted) {
      //     setState(() {
      //       initData = res;
      //       load = false;
      //     });
      //     print('AKCM ');
      //     getMyOrderToday(token: user.token).then((value) async {
      //       print('AKCM 1');
      //       if (mounted) {
      //         setState(() {
      //           print('AKCM');
      //           listOrder.addAll(value);
      //           orderKey.addAll(List.generate(value.length, (index) => GlobalKey()));
      //           print(listOrder.length);
      //         });
      //         if (value.isNotEmpty) {
      //           curOrder = listOrder.every((element) => element.status == 1)
      //               ? ''
      //               : listOrder.firstWhere((element) => element.status == 0).id.toString();
      //           getOrder();
      //           if (initData.target != null) {
      //             curOrder = initData.target!.orderId.toString();
      //             onReloadDirection();
      //           } else if (initData.isStart && curOrder != '') {
      //             updateTarget(id: curOrder, token: user.token).then((_) {
      //               onReloadDirection();
      //             });
      //           }
      //           listenLocation(onReloadDirection);
      //         }
      //         cancelLoaderDialog(context);
      //       }
      //     }).onError((error, stackTrace) {
      //       cancelLoaderDialog(context);
      //     });
      //   }
      // });
    });
  }

  void getOrder() {
    if(listOrder.isNotEmpty){
      Future.delayed(const Duration(milliseconds: 500), () async {
        await Future.wait(List.generate(listOrder.length, (i) async {
          Marker m = await generateOrderMarker(i);
          orderMarkers.add(m);
        })).whenComplete(() {
          if (mounted) {
            setState(() {});
          }
        });
      });
    }
  }

  Future<Marker> generateOrderMarker(int index) async {
    final RenderRepaintBoundary boundary =
        orderKey[index].currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Tăng kích thước của hình ảnh
    final ui.Codec codec = await ui.instantiateImageCodec(pngBytes, targetWidth: 70, targetHeight: 70);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image resizedImage = frameInfo.image;

    final ByteData? resizedByteData = await resizedImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List resizedPngBytes = resizedByteData!.buffer.asUint8List();

    return Marker(
        zIndex: 1000.0 - index,
        markerId: MarkerId(index.toString()),
        icon: BitmapDescriptor.fromBytes(pngBytes),
        position: LatLng(listOrder[index].lat!, listOrder[index].lng!),
        onTap: () {});
  }

  void onStart() {
    startSession(lng: current.longitude, lat: current.latitude, token: user.token).then((value) {
      setState(() {
        initData.isStart = true;
        onReloadDirection().whenComplete(() {
          _setMapFitToTour(polylines);
        });
      });
    });
  }

  void onChooseDate(ObjDateFunc dateTime) {
    showLoaderDialog(context);
    netWorkFactoryApi.getMyOrderToday(token: user.token,dateForm: dateTime.startDate.toString(),dateTo: dateTime.endDate.toString()).then((value) async {
      setState(() {
        listOrder.clear();
        orderKey.clear();
        listOrder.addAll(value);
        orderKey.addAll(List.generate(value.length, (index) => GlobalKey()));
      });
      getOrder();
      onReloadDirection();
      cancelLoaderDialog(context);
    }).onError((error, stackTrace) {
      cancelLoaderDialog(context);
    });
  }

  void onDirection(OrderModel item) {
    showLoaderDialog(context);
    updateTarget(id: item.id, token: user.token).then((res) {
      netWorkFactoryApi.getMyOrderToday(token: user.token,dateForm: DateFormat('yyyy-MM-dd').format(Const.dateFrom).toString(),dateTo: DateFormat('yyyy-MM-dd').format(Const.dateTo).toString()).then((value) async {
        setState(() {
          listOrder.clear();
          orderKey.clear();
          listOrder.addAll(value);
          orderKey.addAll(List.generate(value.length, (index) => GlobalKey()));
          curOrder = item.id!;
        });
        getOrder();
        if(item.lat.toString().replaceAll('null', '').isNotEmpty && item.lng.toString().replaceAll('null', '').isNotEmpty){
          onReloadDirection();
        }else{
          polylines.clear();
        }
        cancelLoaderDialog(context);
      }).onError((error, stackTrace) {
        cancelLoaderDialog(context);
      });
    });
  }

  Future<void> onReloadDirection() async {
    if (state == AppLifecycleState.resumed) {

      netWorkFactoryApi.getDirection(token: user.token,  ).then((direction) {
        if(direction.data != null && direction.data is !String && direction.status != 500){
          var polylinePoints = direction.data!.routes!.first.overviewPolyline!.polylinePoints!
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList();
          if (mounted) {
            setState(() {
              polylines.clear();
              polylines.add(Polyline(
                  polylineId: const PolylineId('polyline'),
                  color: blue,
                  width: 3,
                  points: polylinePoints));
            });
          }
        }
        else{
          // cancelLoaderDialog(context);
        }
      });
    }
  }

  void confirmOrder(OrderDetailModel order) async {
    showLoaderDialog(context);
    List<DsLine> dsLine = <DsLine>[];
    for (var element in order.details!) {
      DsLine item = DsLine(
          sttRec:  element.id.toString(),
          sttRec0: element.sttRec0,
          soLuong: element.deliveryQuantity
      );
      dsLine.add(item);
    }
    ConfirmShippingRequest request = ConfirmShippingRequest(
        lat: current.latitude,lng: current.longitude,
        dsLine: dsLine,
        typePayment: order.typePayment,
        status: order.statusTicket,
        desc: order.desc,
        isCheckConfirm: order.xacNhanYN
    );
    await netWorkFactoryApi.updateOrder(id: order.id.toString(), token: user.token, request: request).then((value) {
      cancelLoaderDialog(context);
      Navigator.pop(context);
      netWorkFactoryApi.getMyOrderToday(token: user.token,dateForm: DateFormat('yyyy-MM-dd').format(Const.dateFrom).toString(),dateTo: DateFormat('yyyy-MM-dd').format(Const.dateTo).toString()).then((value) async {
        if (mounted) {
          setState(() {
            listOrder.clear();
            orderKey.clear();
            listOrder.addAll(value);
            orderKey.addAll(List.generate(value.length, (index) => GlobalKey()));
          });
          getOrder();
          curOrder = listOrder.every((element) => element.status == "1")
              ? ''
              : listOrder.firstWhere((element) => element.status == "0").id.toString();
          polylines.clear();
        }
      });
    }).onError((error, stackTrace) {
      cancelLoaderDialog(context);
      if (error is DioError) {
        showDialog(
            context: context,
            builder: (c) {
              return CupertinoAlertDialog(
                title: Text('err: ${error.response!.data}'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
                ],
              );
            });
      }
    });

    var formData = FormData.fromMap(
        {
          "stt_rec": order.id,
          "latLong": "${order.lat},${order.long}",
          "address": order.address,
        }
    );

    if(order.listFile != null){
      for (var element in order.listFile!) {
        formData.files.addAll([
          MapEntry("ListFile",await MultipartFile.fromFile(element.path))
        ]);
      }
    }
    else{
      const MapEntry("ListFile","");
    }
    await widget.networkFactory.updateLocationAndImageTransit(formData, _accessToken.toString(),).then((value) {
      cancelLoaderDialog(context);
      // Navigator.pop(context);
    }).onError((error, stackTrace) {
      cancelLoaderDialog(context);
      if (error is DioError) {
        showDialog(
            context: context,
            builder: (c) {
              return CupertinoAlertDialog(
                title: Text(error.response!.data),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Đóng', style: TextStyle(color: Colors.blue, fontSize: 15)))
                ],
              );
            });
      }
    });

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
                    stopListen();
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

  void _setMapFitToTour(Set<Polyline> p) {
    Future.delayed(
      const Duration(seconds: 1),
      () async {
        double minLat = p.first.points.first.latitude;
        double minLong = p.first.points.first.longitude;
        double maxLat = p.first.points.first.latitude;
        double maxLong = p.first.points.first.longitude;
        for (var poly in p) {
          for (var point in poly.points) {
            if (point.latitude < minLat) minLat = point.latitude;
            if (point.latitude > maxLat) maxLat = point.latitude;
            if (point.longitude < minLong) minLong = point.longitude;
            if (point.longitude > maxLong) maxLong = point.longitude;
          }
        }
        final GoogleMapController controller = await _controller.future;
        controller.moveCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(southwest: LatLng(minLat, minLong), northeast: LatLng(maxLat, maxLong)),
            70));
      },
    );
  }
}
