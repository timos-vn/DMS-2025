import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dms/utils/const.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';

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
  Future<XFile> prepareImageForUpload(File file) async {
    try {
      // ✅ Kiểm tra file có tồn tại và có thể đọc được không
      if (!await file.exists()) {
        throw Exception('File does not exist: ${file.path}');
      }
      
      // ✅ Kiểm tra file size
      final fileSize = await file.length();
      debugPrint('📸 Original file size: ${fileSize} bytes');
      
      if (fileSize == 0) {
        throw Exception('File is empty: ${file.path}');
      }
      
      debugPrint('✅ Using original image without compression:');
      debugPrint('   - File path: ${file.absolute.path}');
      debugPrint('   - File size: ${fileSize} bytes');
      
      // ✅ Trả về file gốc trực tiếp
      return XFile(file.path);
    } catch (e) {
      debugPrint('Error preparing image: $e');
      debugPrint('File path: ${file.path}');
      debugPrint('File exists: ${await file.exists()}');
      throw Exception('Failed to prepare image: ${e.toString()}');
    }
  }
  void _updateLocationAndImageEvent(UpdateLocationAndImageEvent event, Emitter<DetailShippingState> emitter)async{
    try {
      // ✅ Kiểm tra có file để upload không
      if (listFileInvoice.isEmpty) {
        debugPrint('❌ No images to upload - listFileInvoice is empty');
        emitter(UploadImageFailure('Không có ảnh nào để upload'));
        return;
      }
      
      // ✅ Kiểm tra có base64 data không (có thể null nếu chưa gen)
      if (listFileInvoiceSave.isEmpty) {
        debugPrint('❌ No base64 data - listFileInvoiceSave is empty');
        emitter(UploadImageFailure('Không có dữ liệu ảnh để upload'));
        return;
      }
      
      // ✅ Kiểm tra tính nhất quán giữa file và base64 data
      if (listFileInvoice.length != listFileInvoiceSave.length) {
        debugPrint('❌ Data inconsistency:');
        debugPrint('   - Files count: ${listFileInvoice.length}');
        debugPrint('   - Base64 count: ${listFileInvoiceSave.length}');
        emitter(UploadImageFailure('Dữ liệu ảnh không nhất quán, vui lòng chụp lại'));
        return;
      }
      
      // ✅ Gen base64 cho các file chưa có base64 (lazy loading)
      debugPrint('🔄 Generating base64 for images that need it...');
      for (int i = 0; i < listFileInvoiceSave.length; i++) {
        if (listFileInvoiceSave[i].pathBase64 == null) {
          try {
            debugPrint('   - Generating base64 for image ${i + 1}/${listFileInvoiceSave.length}');
            String? base64Result = Utils.base64Image(listFileInvoice[i]);
            if (base64Result != null && base64Result.isNotEmpty) {
              listFileInvoiceSave[i].pathBase64 = base64Result;
              debugPrint('   - ✅ Base64 generated: ${base64Result.length} chars');
            } else {
              debugPrint('   - ❌ Failed to generate base64 for image ${i + 1}');
              emitter(UploadImageFailure('Không thể tạo dữ liệu ảnh cho ảnh ${i + 1}'));
              return;
            }
          } catch (e) {
            debugPrint('   - ❌ Error generating base64 for image ${i + 1}: $e');
            emitter(UploadImageFailure('Lỗi khi tạo dữ liệu ảnh cho ảnh ${i + 1}'));
            return;
          }
        } else {
          debugPrint('   - ✅ Base64 already exists for image ${i + 1}');
        }
      }
      
      // ✅ Log thông tin để debug
      debugPrint('✅ Starting upload with:');
      debugPrint('   - Files count: ${listFileInvoice.length}');
      debugPrint('   - Base64 count: ${listFileInvoiceSave.length}');
      for (int i = 0; i < listFileInvoice.length; i++) {
        debugPrint('   - File ${i + 1}: ${listFileInvoice[i].path}');
        debugPrint('   - Base64 ${i + 1}: ${listFileInvoiceSave[i].pathBase64?.length ?? 0} chars');
      }
      
      // ✅ Kiểm tra lat/long null và sử dụng giá trị mặc định
      final latValue = lat ?? '0.0';
      final longValue = long ?? '0.0';
      final addressValue = currentAddress ?? '';
      
      // ✅ Emit progress khi bắt đầu chuẩn bị dữ liệu
      emitter(UploadImageProgress(progress: 0.1, message: 'Đang chuẩn bị dữ liệu...'));
      
      // ✅ Emit progress khi đang chuẩn bị ảnh
      emitter(UploadImageProgress(progress: 0.3, message: 'Đang chuẩn bị ảnh...'));
      
      // ✅ Chuẩn bị tất cả ảnh gốc với error handling
      List<MultipartFile> originalFiles = [];
      for (int i = 0; i < listFileInvoice.length; i++) {
        try {
          debugPrint('Preparing original image ${i + 1}/${listFileInvoice.length}');
          XFile originalFile = await prepareImageForUpload(listFileInvoice[i]);
          MultipartFile multipartFile = await MultipartFile.fromFile(
            originalFile.path,
            filename: originalFile.path.split('/').last,
          );
          originalFiles.add(multipartFile);
        } catch (e) {
          debugPrint('Failed to prepare image ${i + 1}: $e');
          // ✅ Bỏ qua file lỗi và tiếp tục với file khác
          continue;
        }
      }
      
      // ✅ Kiểm tra có ít nhất một file được chuẩn bị thành công không
      if (originalFiles.isEmpty) {
        emitter(UploadImageFailure('Không thể chuẩn bị được ảnh nào'));
        return;
      }
      
      var formData = FormData.fromMap(
          {
            "stt_rec": event.sstRec,
            "latLong": "$latValue,$longValue", // ✅ Sử dụng giá trị đã kiểm tra
            "address": addressValue, // ✅ Sử dụng giá trị đã kiểm tra
            "ListFile": originalFiles, // ✅ Sử dụng danh sách file gốc
          }
      );
      
      // ✅ Emit progress khi đang upload
      emitter(UploadImageProgress(progress: 0.7, message: 'Đang upload ảnh...'));
      
      // ✅ Gọi API với retry mechanism
      DetailShippingState state = await _uploadWithRetry(formData, _accessToken!, emitter);
      
      // ✅ Emit progress 100% trước khi hoàn thành
      emitter(UploadImageProgress(progress: 1.0, message: 'Hoàn thành!'));
      
      // ✅ Đợi 0.5s để user thấy progress 100%
      await Future.delayed(const Duration(milliseconds: 500));
      
      // ✅ Emit state cuối cùng
      emitter(state);
      
    } catch (e) {
      // ✅ Xử lý lỗi và emit upload failure state
      debugPrint('Error in _updateLocationAndImageEvent: $e');
      emitter(UploadImageFailure('Lỗi khi upload ảnh: ${e.toString()}'));
    }
  }

  void _getLocationEvent(GetLocationEvent event, Emitter<DetailShippingState> emitter)async{
    emitter(DetailShippingLoading());
    // getUserLocation();
    emitter(GetLocationSuccess());
  }

  late StreamSubscription<Position> positionStream;


  /// ✅ Upload với retry mechanism
  Future<DetailShippingState> _uploadWithRetry(FormData formData, String accessToken, Emitter<DetailShippingState> emitter) async {
    const int maxRetries = 3;
    const List<int> retryDelays = [2, 5, 10]; // seconds
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        debugPrint('🔄 Upload attempt ${attempt + 1}/$maxRetries');
        
        // ✅ Emit progress cho retry
        if (attempt > 0) {
          emitter(UploadImageProgress(
            progress: 0.7 + (attempt * 0.1), 
            message: 'Thử lại lần ${attempt + 1}/$maxRetries...'
          ));
        }
        
        // ✅ Tăng timeout cho mạng yếu
        final networkFactory = NetWorkFactory(context);
        final response = await networkFactory.updateLocationAndImageTransit(
          formData, 
          accessToken
        );
        
        debugPrint('✅ Upload successful on attempt ${attempt + 1}');
        return _handleUpdateLocationAndImage(response);
        
      } catch (e) {
        debugPrint('❌ Upload attempt ${attempt + 1} failed: $e');
        
        // ✅ Nếu là lần cuối, throw error
        if (attempt == maxRetries - 1) {
          throw Exception('Upload failed after $maxRetries attempts: $e');
        }
        
        // ✅ Đợi trước khi retry
        final delay = retryDelays[attempt];
        debugPrint('⏳ Waiting ${delay}s before retry...');
        
        // ✅ Emit progress cho retry delay
        emitter(UploadImageProgress(
          progress: 0.7 + (attempt * 0.1), 
          message: 'Mạng yếu, thử lại sau ${delay}s...'
        ));
        
        await Future.delayed(Duration(seconds: delay));
      }
    }
    
    throw Exception('Upload failed after $maxRetries attempts');
  }

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