import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dms/utils/const.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../../model/network/request/confirm_shipping_request.dart';
import '../../../model/network/request/get_item_shipping_request.dart';
import '../../../model/network/request/order_create_checkin_request.dart';
import '../../../model/network/response/get_item_detail_shipping_response.dart';
import '../../../model/network/services/network_factory.dart';
import '../../../utils/utils.dart';
import 'detail_shipping_event.dart';
import 'detail_shipping_state.dart';

class DetailShippingBloc extends Bloc<DetailShippingEvent,DetailShippingState>{
  NetWorkFactory? _networkFactory;
  BuildContext context;

  List<File> listFileInvoice = [];
  List<ListImageInvoice> listFileInvoiceSave = [];
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  MasterDetailItemShipping? masterItem = MasterDetailItemShipping();
  List<DettailItemShipping> listItemDetailShipping = <DettailItemShipping>[];

  String? currentAddress;
  Position? position2;
  Position? currentLocation;

  DetailShippingBloc(this.context) : super(DetailShippingInitial()){
    _networkFactory = NetWorkFactory(context);
    on<GetPrefs>(_getPrefs);
    on<GetItemShippingEvent>(_getItemShippingEvent);
    on<ConfirmShippingEvent>(_confirmShippingEvent);
    on<GetLocationEvent>(_getLocationEvent);
    on<UpdateLocationAndImageEvent>(_updateLocationAndImageEvent);
  }
  Future<XFile> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: Const.percentQuantityImage, // Sử dụng chất lượng ảnh từ API
    );

    return result!;
  }
  void _updateLocationAndImageEvent(UpdateLocationAndImageEvent event, Emitter<DetailShippingState> emitter)async{
    emitter(DetailShippingLoading());
    var formData = FormData.fromMap(
        {
          "stt_rec": event.sstRec,
          "latLong": "$lat,$long",
          "address": currentAddress,
          "ListFile": await Future.wait(
              listFileInvoice.map((file) async {
                XFile compress = await compressImage(file);
                return await MultipartFile.fromFile(compress.path,filename: compress.path);
              })
          ),
        }
    );
    // if(listFileInvoice.isNotEmpty){
    //   for (var element in listFileInvoice) {
    //     formData.files.addAll([
    //       MapEntry("ListFile",await MultipartFile.fromFile(element.path))
    //     ]);
    //   }
    // }
    // else{
    //   const MapEntry("ListFile","");
    // }
    // print('done: $formData');
    DetailShippingState state = _handleUpdateLocationAndImage(await _networkFactory!.updateLocationAndImageTransit(formData,_accessToken!));
    emitter(state);
  }

  void _getLocationEvent(GetLocationEvent event, Emitter<DetailShippingState> emitter)async{
    emitter(DetailShippingLoading());
    // getUserLocation();
    emitter(GetLocationSuccess());
  }

  late StreamSubscription<Position> positionStream;

  String? lat;
  String? long;
  getUserLocation() async {
    positionStream =
        Utils.getPositionStream().listen((Position position) async{
          List<Placemark> placePoint = await placemarkFromCoordinates(position.latitude,position.longitude);
          String currentAddress1 = "${placePoint[0].name}, ${placePoint[0].thoroughfare}, ${placePoint[0].subAdministrativeArea}, ${placePoint[0].administrativeArea}";
          lat = position.latitude.toString();
          long = position.longitude.toString();
          currentAddress = currentAddress1;
          currentLocation = position;
          stopListenLocation();
        });
  }

  void stopListenLocation(){
    positionStream.cancel();
  }

  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<DetailShippingState> emitter)async{
    emitter(DetailShippingInitial());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    emitter(GetPrefsSuccess());
  }

  void _getItemShippingEvent(GetItemShippingEvent event, Emitter<DetailShippingState> emitter)async{
    emitter(DetailShippingLoading());
    GetItemShippingRequest request = GetItemShippingRequest(
      sttRec: event.sstRec,
    );
    DetailShippingState state = _handleGetListShipping(await _networkFactory!.getItemDetailShipping(request,_accessToken!));
    emitter(state);
  }

  void _confirmShippingEvent(ConfirmShippingEvent event, Emitter<DetailShippingState> emitter)async{
    emitter(DetailShippingLoading());
    List<DsLine> dsLine = <DsLine>[];
    for (var element in listItemDetailShipping) {
      DsLine item = DsLine(
          sttRec:  event.sstRec,
          sttRec0: element.sttRec0,
          soLuong:  element.soLuongGiao
      );
      dsLine.add(item);
    }
    ConfirmShippingRequest request = ConfirmShippingRequest(
        dsLine: dsLine,
        typePayment: event.typePayment,
        status: event.status,
        desc:event.desc.toString(),
        soPhieuXuat: event.soPhieuXuat
    );

    DetailShippingState state = _handleConfirmShipping(await _networkFactory!.confirmDetailShipping(request,_accessToken!));
    emitter(state);
  }

  DetailShippingState _handleGetListShipping(Object data){
    if(data is String) return DetailShippingFailure('Úi, ${data.toString()}');
    try{
      GetItemShippingResponse response = GetItemShippingResponse.fromJson(data as Map<String,dynamic>);
      listItemDetailShipping = response.data?.dettail??[];
      if(listItemDetailShipping.isNotEmpty){
        for (var element in listItemDetailShipping) {
          element.soLuongGiao = element.soLuongThucGiao??0;
        }
      }
      masterItem = response.data?.master;
      if(listItemDetailShipping.isEmpty){
        return GetListShippingEmpty();
      }else{
        return GetItemShippingSuccess();
      }
    }catch(e){
      return DetailShippingFailure('Úi, ${e.toString()}');
    }
  }

  DetailShippingState _handleConfirmShipping(Object data){
    if(data is String) return DetailShippingFailure('Úi, ${data.toString()}');
    try{
      return ConfirmShippingSuccess();
    }catch(e){
      return DetailShippingFailure('Úi, ${e.toString()}');
    }
  }

  DetailShippingState _handleUpdateLocationAndImage(Object data){
    if(data is String) return DetailShippingFailure('Úi, ${data.toString()}');
    try{
      return UpdateLocationAndImageSuccess();
    }catch(e){
      return DetailShippingFailure('Úi, ${e.toString()}');
    }
  }

}