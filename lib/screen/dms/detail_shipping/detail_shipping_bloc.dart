import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

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
  /// ✅ Chuẩn bị ảnh với compression tối ưu dựa trên kích thước file
  Future<XFile> prepareImageForUpload(File file) async {
    try {
      // ✅ Kiểm tra file có tồn tại và có thể đọc được không
      if (!await file.exists()) {
        throw Exception('File does not exist: ${file.path}');
      }
      
      // ✅ Kiểm tra file size
      final fileSize = await file.length();
      debugPrint('📸 Original file size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      
      if (fileSize == 0) {
        throw Exception('File is empty: ${file.path}');
      }
      
      // ✅ Nếu file < 500KB, không cần compress
      const maxSizeWithoutCompression = 500 * 1024; // 500KB
      if (fileSize < maxSizeWithoutCompression) {
        debugPrint('✅ File nhỏ, không cần compress');
        return XFile(file.path);
      }
      
      // ✅ Compress ảnh với quality phù hợp
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // ✅ Điều chỉnh quality dựa trên kích thước file
      int quality = 85; // Mặc định
      if (fileSize > 5 * 1024 * 1024) { // > 5MB
        quality = 60; // Compress mạnh hơn
      } else if (fileSize > 2 * 1024 * 1024) { // > 2MB
        quality = 70;
      } else if (fileSize > 1 * 1024 * 1024) { // > 1MB
        quality = 80;
      }
      
      debugPrint('🔄 Compressing image with quality: $quality%');
      
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1920, // Giới hạn width tối đa
        minHeight: 1080, // Giới hạn height tối đa
      );
      
      if (result == null) {
        debugPrint('⚠️ Compression failed, using original file');
        return XFile(file.path);
      }
      
      final compressedSize = await result.length();
      final compressionRatio = ((1 - compressedSize / fileSize) * 100).toStringAsFixed(1);
      
      debugPrint('✅ Compression completed:');
      debugPrint('   - Original: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('   - Compressed: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('   - Saved: $compressionRatio%');
      
      return result;
    } catch (e) {
      debugPrint('❌ Error preparing image: $e');
      debugPrint('   - File path: ${file.path}');
      debugPrint('   - File exists: ${await file.exists()}');
      // ✅ Fallback về file gốc nếu compression lỗi
      return XFile(file.path);
    }
  }
  
  /// ✅ Tính timeout động dựa trên kích thước file và số lượng file
  Duration calculateUploadTimeout(List<File> files) {
    int totalSize = 0;
    for (var file in files) {
      totalSize += file.lengthSync();
    }
    
    // ✅ Tính timeout: 1 phút cho mỗi MB + 2 phút buffer
    final sizeInMB = totalSize / (1024 * 1024);
    final baseTimeout = (sizeInMB * 60).round(); // 1 phút/MB
    final timeoutSeconds = (baseTimeout + 120).clamp(60, 600); // Tối thiểu 1 phút, tối đa 10 phút
    
    debugPrint('⏱️ Calculated timeout: ${timeoutSeconds}s for ${sizeInMB.toStringAsFixed(2)} MB');
    
    return Duration(seconds: timeoutSeconds);
  }
  void _updateLocationAndImageEvent(UpdateLocationAndImageEvent event, Emitter<DetailShippingState> emitter)async{
    try {
      // ✅ Kiểm tra token còn hay không
      if (_accessToken == null || _accessToken!.isEmpty) {
        debugPrint('❌ Access token is null/empty in _updateLocationAndImageEvent');
        emitter(UploadImageFailure('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'));
        return;
      }

      // ✅ Kiểm tra có file để upload không
      if (listFileInvoice.isEmpty) {
        debugPrint('❌ No images to upload - listFileInvoice is empty');
        emitter(UploadImageFailure('Không có ảnh nào để upload'));
        return;
      }
      
      // ✅ Kiểm tra tính nhất quán giữa file và metadata (để đồng bộ với các luồng khác)
      if (listFileInvoice.length != listFileInvoiceSave.length) {
        debugPrint('❌ Data inconsistency:');
        debugPrint('   - Files count: ${listFileInvoice.length}');
        debugPrint('   - Metadata count: ${listFileInvoiceSave.length}');
        emitter(UploadImageFailure('Dữ liệu ảnh không nhất quán, vui lòng chụp lại'));
        return;
      }
      
      // ✅ Tính timeout động dựa trên kích thước file
      final uploadTimeout = calculateUploadTimeout(listFileInvoice);
      
      // ✅ Emit progress khi bắt đầu chuẩn bị dữ liệu
      emitter(UploadImageProgress(progress: 0.1, message: 'Đang chuẩn bị dữ liệu...'));
      
      // ✅ Log thông tin để debug (không gen base64 vì không cần cho multipart upload)
      debugPrint('✅ Starting upload with:');
      debugPrint('   - Files count: ${listFileInvoice.length}');
      for (int i = 0; i < listFileInvoice.length; i++) {
        final fileSize = await listFileInvoice[i].length();
        debugPrint('   - File ${i + 1}: ${listFileInvoice[i].path} (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
      }
      
      // Kiểm tra lat/long null và sử dụng giá trị mặc định
      final latValue = lat ?? '0.0';
      final longValue = long ?? '0.0';
      final addressValue = currentAddress ?? '';

      // Nếu chưa lấy được GPS, không gửi toạ độ (tránh 0.0,0.0 gây khó debug)
      if (latValue == '0.0' && longValue == '0.0') {
        debugPrint('Invalid GPS coordinates (0.0,0.0) - aborting upload');
        emitter(UploadImageFailure('Không lấy được vị trí GPS. Vui lòng bật GPS và thử lại.'));
        return;
      }
      
      // ✅ Emit progress khi đang chuẩn bị và compress ảnh
      emitter(UploadImageProgress(progress: 0.2, message: 'Đang nén ảnh...'));
      
      // ✅ Chuẩn bị và compress tất cả ảnh với error handling
      List<MultipartFile> preparedFiles = [];
      int successCount = 0;
      for (int i = 0; i < listFileInvoice.length; i++) {
        try {
          final progress = 0.2 + (i / listFileInvoice.length * 0.1);
          emitter(UploadImageProgress(
            progress: progress, 
            message: 'Đang xử lý ảnh ${i + 1}/${listFileInvoice.length}...'
          ));
          
          debugPrint('🔄 Preparing image ${i + 1}/${listFileInvoice.length}');
          XFile preparedFile = await prepareImageForUpload(listFileInvoice[i]);
          
          MultipartFile multipartFile = await MultipartFile.fromFile(
            preparedFile.path,
            filename: preparedFile.path.split('/').last,
          );
          preparedFiles.add(multipartFile);
          successCount++;
        } catch (e) {
          debugPrint('⚠️ Failed to prepare image ${i + 1}: $e');
          // ✅ Bỏ qua file lỗi và tiếp tục với file khác
          continue;
        }
      }
      
      // ✅ Kiểm tra có ít nhất một file được chuẩn bị thành công không
      if (preparedFiles.isEmpty) {
        emitter(UploadImageFailure('Không thể chuẩn bị được ảnh nào'));
        return;
      }
      
      if (successCount < listFileInvoice.length) {
        debugPrint('⚠️ Warning: Only $successCount/${listFileInvoice.length} images prepared successfully');
      }
      
      var formData = FormData.fromMap(
          {
            "stt_rec": event.sstRec,
            "latLong": "$latValue,$longValue",
            "address": addressValue,
            "ListFile": preparedFiles,
          }
      );
      
      // ✅ Emit progress khi đang upload
      emitter(UploadImageProgress(progress: 0.4, message: 'Đang upload ảnh...'));
      
      // ✅ Gọi API với retry mechanism và timeout động
      DetailShippingState state = await _uploadWithRetry(
        formData, 
        _accessToken!, 
        emitter,
        timeout: uploadTimeout,
      );
      
      // ✅ Emit progress 100% trước khi hoàn thành
      emitter(UploadImageProgress(progress: 1.0, message: 'Hoàn thành!'));
      
      // ✅ Đợi 0.5s để user thấy progress 100%
      await Future.delayed(const Duration(milliseconds: 500));
      
      // ✅ Emit state cuối cùng
      emitter(state);
      
    } catch (e) {
      // ✅ Xử lý lỗi và emit upload failure state
      debugPrint('❌ Error in _updateLocationAndImageEvent: $e');
      String errorMessage = 'Lỗi khi upload ảnh: ${e.toString()}';
      
      // ✅ Cải thiện thông báo lỗi
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        errorMessage = 'Upload quá lâu. Vui lòng kiểm tra kết nối mạng và thử lại.';
      } else if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
      }
      
      emitter(UploadImageFailure(errorMessage));
    }
  }

  void _getLocationEvent(GetLocationEvent event, Emitter<DetailShippingState> emitter)async{
    emitter(DetailShippingLoading());
    // getUserLocation();
    emitter(GetLocationSuccess());
  }

  late StreamSubscription<Position> positionStream;


  /// ✅ Upload với retry mechanism, progress tracking và adaptive timeout
  Future<DetailShippingState> _uploadWithRetry(
    FormData formData, 
    String accessToken, 
    Emitter<DetailShippingState> emitter, {
    Duration? timeout,
  }) async {
    const int maxRetries = 3;
    // Exponential backoff: 2s, 4s, 8s
    int getRetryDelay(int attempt) => (2 * (1 << attempt)).clamp(2, 30);
    
    // ✅ Sử dụng timeout động hoặc mặc định 8 phút
    final uploadTimeout = timeout ?? const Duration(minutes: 8);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        debugPrint('🔄 Upload attempt ${attempt + 1}/$maxRetries');
        debugPrint('   - Timeout: ${uploadTimeout.inSeconds}s');
        
        // ✅ Emit progress cho retry
        if (attempt > 0) {
          emitter(UploadImageProgress(
            progress: 0.4 + (attempt * 0.15), 
            message: 'Thử lại lần ${attempt + 1}/$maxRetries...'
          ));
        }
        
        // ✅ Tạo progress callback để track upload thực tế
        int lastSent = 0;
        int? totalSize;
        
        // ✅ Upload với timeout động và progress tracking
        final networkFactory = NetWorkFactory(context);
        final response = await networkFactory.updateLocationAndImageTransit(
          formData, 
          accessToken,
          onSendProgress: (sent, total) {
            lastSent = sent;
            totalSize = total;
            
            // ✅ Tính progress thực tế (0.4 - 0.95)
            if (total > 0) {
              final realProgress = 0.4 + (sent / total * 0.55);
              emitter(UploadImageProgress(
                progress: realProgress.clamp(0.4, 0.95),
                message: 'Đang upload ảnh... ${(sent / total * 100).toStringAsFixed(0)}%'
              ));
            }
          }
        ).timeout(
          uploadTimeout,
          onTimeout: () {
            throw Exception('Upload timeout sau ${uploadTimeout.inSeconds}s. Vui lòng kiểm tra kết nối mạng.');
          },
        );
        
        debugPrint('✅ Upload successful on attempt ${attempt + 1}');
        // debugPrint('   - Total size: ${totalSize != null ? '${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB' : 'unknown'}');
        debugPrint('   - Sent: ${lastSent != 0 ? '${(lastSent / 1024 / 1024).toStringAsFixed(2)} MB' : 'unknown'}');
        
        return _handleUpdateLocationAndImage(response);
        
      } catch (e) {
        debugPrint('❌ Upload attempt ${attempt + 1} failed: $e');
        
        // ✅ Kiểm tra loại lỗi
        String errorMessage = e.toString();
        bool isTimeout = errorMessage.contains('timeout') || 
                        errorMessage.contains('Timeout') ||
                        errorMessage.contains('timed out');
        bool isNetworkError = errorMessage.contains('SocketException') ||
                             errorMessage.contains('Network') ||
                             errorMessage.contains('Failed host lookup') ||
                             errorMessage.contains('Connection refused');
        
        // ✅ Nếu là lần cuối, throw error với message chi tiết
        if (attempt == maxRetries - 1) {
          if (isTimeout) {
            throw Exception('Upload timeout sau nhiều lần thử. Vui lòng kiểm tra kết nối mạng và thử lại.');
          } else if (isNetworkError) {
            throw Exception('Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.');
          } else {
            throw Exception('Upload thất bại sau $maxRetries lần thử: ${e.toString()}');
          }
        }
        
        // ✅ Đợi trước khi retry với exponential backoff
        final delay = getRetryDelay(attempt);
        debugPrint('⏳ Waiting ${delay}s before retry...');
        
        // ✅ Emit progress cho retry delay với message phù hợp
        String retryMessage;
        if (isTimeout) {
          retryMessage = 'Mạng chậm, thử lại sau ${delay}s...';
        } else if (isNetworkError) {
          retryMessage = 'Mất kết nối, thử lại sau ${delay}s...';
        } else {
          retryMessage = 'Thử lại sau ${delay}s...';
        }
        
        emitter(UploadImageProgress(
          progress: 0.4 + (attempt * 0.15), 
          message: retryMessage
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