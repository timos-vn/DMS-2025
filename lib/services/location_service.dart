import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../model/database/data_local.dart';
import '../utils/utils.dart';

/// Service chuyên nghiệp để xử lý tất cả logic liên quan đến vị trí
class LocationService {
  static const int _maxRetries = 3;
  static const Duration _totalTimeout = Duration(seconds: 90); // Total timeout cho toàn bộ quá trình
  static const double _maxAccuracyThreshold = 200.0; // Tăng threshold lên 200m để user-friendly hơn
  static const double _fallbackAccuracyThreshold = 500.0; // Fallback threshold tăng lên 500m
  
  /// Lấy vị trí với retry mechanism thông minh
  static Future<LocationResult> getLocationWithRetry({
    bool forceFresh = true,
    int maxRetries = _maxRetries,
    Function(String)? onProgress, // Callback để hiển thị progress
  }) async {
    print('📍 LocationService: Starting location retrieval...');
    
    // Kiểm tra permission trước
    onProgress?.call('Đang kiểm tra quyền truy cập vị trí...');
    bool hasPermission = await _checkLocationPermission();
    if (!hasPermission) {
      return LocationResult.failure(
        error: 'Không có quyền truy cập vị trí. Vui lòng cấp quyền trong cài đặt.',
        details: 'Location permission denied',
      );
    }
    
    // Kiểm tra GPS có bật không
    onProgress?.call('Đang kiểm tra GPS...');
    bool isGpsEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isGpsEnabled) {
      return LocationResult.failure(
        error: 'GPS chưa được bật. Vui lòng bật GPS và thử lại.',
        details: 'GPS not enabled',
      );
    }
    
    if (forceFresh) {
      _clearLocationCache();
    }
    
    // Thêm total timeout cho toàn bộ quá trình
    try {
      return await Future.any([
        _performLocationRetrieval(maxRetries, onProgress),
        Future.delayed(_totalTimeout, () => LocationResult.failure(
          error: 'Timeout: Không thể lấy vị trí GPS trong ${_totalTimeout.inSeconds} giây. Vui lòng kiểm tra cài đặt định vị.',
          details: 'Location timeout',
        )),
      ]);
    } catch (e) {
      return LocationResult.failure(error: 'Lỗi không xác định: $e', details: e.toString());
    }
  }

  // Method riêng để thực hiện location retrieval
  static Future<LocationResult> _performLocationRetrieval(int maxRetries, Function(String)? onProgress) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('📍 Attempt $attempt/$maxRetries');
        onProgress?.call('Đang lấy vị trí GPS... (Lần thử $attempt/$maxRetries)');
        
        // Progressive accuracy strategy
        LocationAccuracy accuracy = _getAccuracyForAttempt(attempt);
        Duration timeout = _getTimeoutForAttempt(attempt);
        
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: timeout,
          forceAndroidLocationManager: true,
        );
        
        print('📍 GPS Result: accuracy=${position.accuracy}m, lat=${position.latitude}, lng=${position.longitude}');
        
        // Validate position
        LocationValidationResult validation = _validatePosition(position, attempt);
        
        if (validation.isValid) {
          onProgress?.call('Đang lấy địa chỉ...');
          // Get address
          String address = await _getAddressFromPosition(position);
          
          // Update cache
          _updateLocationCache(position, address);
          
          onProgress?.call('Hoàn thành!');
          return LocationResult.success(
            position: position,
            address: address,
            accuracy: position.accuracy,
            attempt: attempt,
          );
        } else if (attempt == maxRetries) {
          // Last attempt - accept even if accuracy is low
          print('📍 Final attempt: accepting position with accuracy ${position.accuracy}m');
          onProgress?.call('Chấp nhận vị trí với độ chính xác thấp...');
          String address = await _getAddressFromPosition(position);
          _updateLocationCache(position, address);
          
          return LocationResult.success(
            position: position,
            address: address,
            accuracy: position.accuracy,
            attempt: attempt,
            warning: 'GPS accuracy thấp (${position.accuracy.toStringAsFixed(0)}m)',
          );
        } else {
          print('📍 Position rejected: ${validation.reason}');
          onProgress?.call('Vị trí không chính xác, thử lại...');
          await Future.delayed(Duration(seconds: attempt * 2)); // Progressive delay
        }
        
      } catch (e) {
        print('📍 Attempt $attempt failed: $e');
        if (attempt == maxRetries) {
          return LocationResult.failure(
            error: 'Không thể lấy vị trí GPS sau $maxRetries lần thử',
            details: e.toString(),
          );
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    return LocationResult.failure(
      error: 'Tất cả các lần thử lấy vị trí đều thất bại',
    );
  }
  
  /// Tính toán khoảng cách với validation
  static DistanceResult calculateDistance({
    required String customerLatLong,
    required Position currentPosition,
    int maxAllowedDistance = 300,
  }) {
    try {
      // Validate input
      if (customerLatLong.isEmpty || customerLatLong == 'null') {
        return DistanceResult.failure('Tọa độ khách hàng không hợp lệ');
      }
      
      // Parse coordinates
      List<String> coords = customerLatLong.split(',');
      if (coords.length != 2) {
        return DistanceResult.failure('Định dạng tọa độ không đúng');
      }
      
      double customerLat = double.tryParse(coords[0].trim()) ?? 0;
      double customerLng = double.tryParse(coords[1].trim()) ?? 0;
      
      if (customerLat == 0 || customerLng == 0) {
        return DistanceResult.failure('Tọa độ khách hàng không hợp lệ');
      }
      
      // Calculate distance
      double distance = Utils.getDistance(customerLat, customerLng, currentPosition);
      
      // Calculate accuracy buffer
      double accuracyBuffer = _calculateAccuracyBuffer(currentPosition.accuracy);
      double effectiveMaxDistance = maxAllowedDistance + accuracyBuffer;
      
      print('📍 Distance: ${distance.toStringAsFixed(2)}m');
      print('📍 Max allowed: ${maxAllowedDistance}m');
      print('📍 Accuracy buffer: ${accuracyBuffer.toStringAsFixed(2)}m');
      print('📍 Effective max: ${effectiveMaxDistance.toStringAsFixed(2)}m');
      
      bool isWithinRange = distance <= effectiveMaxDistance;
      
      return DistanceResult.success(
        distance: distance,
        isWithinRange: isWithinRange,
        maxAllowedDistance: maxAllowedDistance,
        accuracyBuffer: accuracyBuffer,
        effectiveMaxDistance: effectiveMaxDistance,
        currentAccuracy: currentPosition.accuracy,
      );
      
    } catch (e) {
      return DistanceResult.failure('Lỗi tính toán khoảng cách: $e');
    }
  }
  
  /// Kiểm tra xem có nên cho phép check-in không
  static CheckInValidationResult validateCheckIn({
    required String customerLatLong,
    required Position? currentPosition,
    int maxAllowedDistance = 300,
  }) {
    if (currentPosition == null) {
      return CheckInValidationResult.failure(
        'Chưa lấy được vị trí GPS. Vui lòng thử lại.',
        showRetry: true,
      );
    }
    
    // Check GPS accuracy
    if (currentPosition.accuracy > _fallbackAccuracyThreshold) {
      return CheckInValidationResult.failure(
        'GPS không chính xác (${currentPosition.accuracy.toStringAsFixed(0)}m). Vui lòng di chuyển ra ngoài trời và thử lại.',
        showRetry: true,
        accuracy: currentPosition.accuracy,
      );
    }
    
    // Calculate distance
    DistanceResult distanceResult = calculateDistance(
      customerLatLong: customerLatLong,
      currentPosition: currentPosition,
      maxAllowedDistance: maxAllowedDistance,
    );
    
    if (!distanceResult.isSuccess) {
      return CheckInValidationResult.failure(
        distanceResult.error ?? 'Lỗi tính toán khoảng cách',
        showRetry: true,
      );
    }
    
    if (distanceResult.isWithinRange == true) {
      return CheckInValidationResult.success(
        distance: distanceResult.distance!,
        accuracy: currentPosition.accuracy,
      );
    } else {
      return CheckInValidationResult.distanceExceeded(
        distance: distanceResult.distance!,
        maxAllowed: distanceResult.maxAllowedDistance!,
        accuracy: currentPosition.accuracy,
        showMap: true,
      );
    }
  }
  
  // Private helper methods
  
  static LocationAccuracy _getAccuracyForAttempt(int attempt) {
    switch (attempt) {
      case 1: return LocationAccuracy.high;
      case 2: return LocationAccuracy.medium;
      case 3: return LocationAccuracy.low;
      default: return LocationAccuracy.low;
    }
  }
  
  static Duration _getTimeoutForAttempt(int attempt) {
    switch (attempt) {
      case 1: return const Duration(seconds: 20);
      case 2: return const Duration(seconds: 15);
      case 3: return const Duration(seconds: 10);
      default: return const Duration(seconds: 10);
    }
  }
  
  static LocationValidationResult _validatePosition(Position position, int attempt) {
    if (position.accuracy == null) {
      return LocationValidationResult.invalid('Không có thông tin độ chính xác GPS');
    }
    
    double maxAccuracy = attempt == 1 ? _maxAccuracyThreshold : _fallbackAccuracyThreshold;
    
    if (position.accuracy! > maxAccuracy) {
      return LocationValidationResult.invalid(
        'GPS accuracy quá thấp: ${position.accuracy!.toStringAsFixed(0)}m (yêu cầu ≤ ${maxAccuracy.toStringAsFixed(0)}m)'
      );
    }
    
    return LocationValidationResult.valid();
  }
  
  static double _calculateAccuracyBuffer(double? accuracy) {
    if (accuracy == null) return 50.0; // Default buffer
    
    // Buffer = 50% of accuracy, max 100m
    return min(accuracy * 0.5, 100.0);
  }
  
  static Future<String> _getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.name}, ${place.thoroughfare}, ${place.subAdministrativeArea}, ${place.administrativeArea}";
      }
    } catch (e) {
      print('📍 Error getting address: $e');
    }
    
    return 'Địa chỉ không xác định';
  }
  
  static void _clearLocationCache() {
    print('📍 Clearing location cache...');
    DataLocal.currentLocations = null;
    DataLocal.latLongLocation = '';
    DataLocal.addressCheckInCustomer = '';
    DataLocal.addressDifferent = '';
    DataLocal.latDifferent = 0;
    DataLocal.longDifferent = 0;
  }

  // Method kiểm tra permission vị trí
  static Future<bool> _checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
      
      return true;
    } catch (e) {
      print('Error checking location permission: $e');
      return false;
    }
  }
  
  static void _updateLocationCache(Position position, String address) {
    DataLocal.currentLocations = position;
    DataLocal.latLongLocation = '${position.latitude},${position.longitude}';
    DataLocal.addressCheckInCustomer = address;
  }
}

// Result classes

class LocationResult {
  final bool isSuccess;
  final Position? position;
  final String? address;
  final double? accuracy;
  final int? attempt;
  final String? warning;
  final String? error;
  final String? details;
  
  LocationResult._({
    required this.isSuccess,
    this.position,
    this.address,
    this.accuracy,
    this.attempt,
    this.warning,
    this.error,
    this.details,
  });
  
  factory LocationResult.success({
    required Position position,
    required String address,
    required double? accuracy,
    required int attempt,
    String? warning,
  }) {
    return LocationResult._(
      isSuccess: true,
      position: position,
      address: address,
      accuracy: accuracy,
      attempt: attempt,
      warning: warning,
    );
  }
  
  factory LocationResult.failure({
    required String error,
    String? details,
  }) {
    return LocationResult._(
      isSuccess: false,
      error: error,
      details: details,
    );
  }
}

class DistanceResult {
  final bool isSuccess;
  final double? distance;
  final bool? isWithinRange;
  final int? maxAllowedDistance;
  final double? accuracyBuffer;
  final double? effectiveMaxDistance;
  final double? currentAccuracy;
  final String? error;
  
  DistanceResult._({
    required this.isSuccess,
    this.distance,
    this.isWithinRange,
    this.maxAllowedDistance,
    this.accuracyBuffer,
    this.effectiveMaxDistance,
    this.currentAccuracy,
    this.error,
  });
  
  factory DistanceResult.success({
    required double distance,
    required bool isWithinRange,
    required int maxAllowedDistance,
    required double accuracyBuffer,
    required double effectiveMaxDistance,
    required double? currentAccuracy,
  }) {
    return DistanceResult._(
      isSuccess: true,
      distance: distance,
      isWithinRange: isWithinRange,
      maxAllowedDistance: maxAllowedDistance,
      accuracyBuffer: accuracyBuffer,
      effectiveMaxDistance: effectiveMaxDistance,
      currentAccuracy: currentAccuracy,
    );
  }
  
  factory DistanceResult.failure(String error) {
    return DistanceResult._(
      isSuccess: false,
      error: error,
    );
  }
}

class CheckInValidationResult {
  final bool isSuccess;
  final bool isDistanceExceeded;
  final double? distance;
  final double? accuracy;
  final int? maxAllowed;
  final String? error;
  final bool showRetry;
  final bool showMap;
  
  CheckInValidationResult._({
    required this.isSuccess,
    required this.isDistanceExceeded,
    this.distance,
    this.accuracy,
    this.maxAllowed,
    this.error,
    this.showRetry = false,
    this.showMap = false,
  });
  
  factory CheckInValidationResult.success({
    required double distance,
    required double? accuracy,
  }) {
    return CheckInValidationResult._(
      isSuccess: true,
      isDistanceExceeded: false,
      distance: distance,
      accuracy: accuracy,
    );
  }
  
  factory CheckInValidationResult.distanceExceeded({
    required double distance,
    required int maxAllowed,
    required double? accuracy,
    required bool showMap,
  }) {
    return CheckInValidationResult._(
      isSuccess: false,
      isDistanceExceeded: true,
      distance: distance,
      accuracy: accuracy,
      maxAllowed: maxAllowed,
      showMap: showMap,
    );
  }
  
  factory CheckInValidationResult.failure(
    String error, {
    bool showRetry = false,
    double? accuracy,
  }) {
    return CheckInValidationResult._(
      isSuccess: false,
      isDistanceExceeded: false,
      error: error,
      showRetry: showRetry,
      accuracy: accuracy,
    );
  }
}

class LocationValidationResult {
  final bool isValid;
  final String? reason;
  
  LocationValidationResult._({
    required this.isValid,
    this.reason,
  });
  
  factory LocationValidationResult.valid() {
    return LocationValidationResult._(isValid: true);
  }
  
  factory LocationValidationResult.invalid(String reason) {
    return LocationValidationResult._(isValid: false, reason: reason);
  }
}
