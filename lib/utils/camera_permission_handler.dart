import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../themes/colors.dart';

/// 📸 Camera Permission Handler với UX tốt
/// 
/// Features:
/// ✅ Educational Rationale - Giải thích TẠI SAO cần quyền
/// ✅ Progressive Flow - Từng bước hướng dẫn rõ ràng
/// ✅ Non-blocking - Cho phép từ chối nhưng vẫn dùng các tính năng khác
/// ✅ Helpful Guide - Hướng dẫn mở Settings nếu permanently denied
/// ✅ Consistent Design - Giống các app lớn
/// ✅ Singleton Check - Tránh multiple dialogs khi có nhiều camera widgets
class CameraPermissionHandler {
  // ✅ Singleton pattern để tránh check permission nhiều lần đồng thời
  static bool _isChecking = false;
  static List<Function(bool)> _pendingCallbacks = [];
  
  // ✅ Flags để tránh show multiple dialogs/bottom sheets
  static bool _isShowingRationale = false;
  static bool _isShowingBottomSheet = false;
  
  /// 🎯 Main method - Xử lý toàn bộ flow camera permission
  static Future<bool> handleCameraPermission(BuildContext context) async {
    // ✅ Debug: Log caller info
    final stackTrace = StackTrace.current;
    final callerInfo = stackTrace.toString().split('\n')[1]; // Get first line after current
    
    // ✅ Nếu đang check, chờ kết quả từ check hiện tại
    if (_isChecking) {
      debugPrint('⏳ Camera permission already checking, waiting for result...');
      debugPrint('   Called from: $callerInfo');
      debugPrint('   Pending callbacks: ${_pendingCallbacks.length}');
      return await _waitForCurrentCheck();
    }
    
    // ✅ Set flag checking
    _isChecking = true;
    debugPrint('🔍 Starting NEW camera permission check...');
    debugPrint('   Called from: $callerInfo');
    
    try {
      // 1. Check current status
      PermissionStatus status = await Permission.camera.status;
      
      if (status.isGranted) {
        debugPrint('✅ Camera permission already granted');
        _notifyAndReset(true);
        return true; // ✅ Đã có quyền
      }
    
      // 2. Chưa hỏi bao giờ -> Show rationale trước
      if (status.isDenied) {
        final shouldRequest = await _showCameraPermissionRationale(context);
        if (shouldRequest != true) {
          _showCameraPermissionSnackbar(context); // Soft reminder
          _notifyAndReset(false);
          return false;
        }
        
        // 3. Request permission
        final result = await Permission.camera.request();
        
        if (result.isGranted) {
          _showSuccessSnackbar(context);
          _notifyAndReset(true);
          return true; // ✅ Được cấp quyền
        } else if (result.isPermanentlyDenied) {
          _showCameraPermissionBottomSheet(context); // Show guide
          _notifyAndReset(false);
          return false;
        } else {
          _showCameraPermissionSnackbar(context);
          _notifyAndReset(false);
          return false;
        }
      }
      
      // 4. Permanently denied -> Show guide to Settings
      if (status.isPermanentlyDenied) {
        _showCameraPermissionBottomSheet(context);
        _notifyAndReset(false);
        return false;
      }
      
      _notifyAndReset(false);
      return false;
    } catch (e) {
      // ✅ Handle any errors
      debugPrint('❌ Error in permission check: $e');
      _notifyAndReset(false);
      return false;
    }
  }
  
  /// ⏳ Wait for current permission check to complete
  static Future<bool> _waitForCurrentCheck() async {
    final completer = Completer<bool>();
    _pendingCallbacks.add((bool result) {
      completer.complete(result);
    });
    return completer.future;
  }
  
  /// 📢 Notify all waiting callbacks
  static void _notifyCallbacks(bool result) {
    debugPrint('📢 Notifying ${_pendingCallbacks.length} pending callbacks with result: $result');
    for (var callback in _pendingCallbacks) {
      try {
        callback(result);
      } catch (e) {
        debugPrint('❌ Error in callback: $e');
      }
    }
    _pendingCallbacks.clear();
  }
  
  /// 🔄 Notify và reset flag (atomic operation)
  static void _notifyAndReset(bool result) {
    _notifyCallbacks(result);
    _isChecking = false;
    debugPrint('🏁 Permission check completed, flag reset. Result: $result');
  }

  /// 📖 Educational Rationale Dialog - Giải thích TẠI SAO cần quyền
  static Future<bool?> _showCameraPermissionRationale(BuildContext context) async {
    // ✅ Nếu đang show rationale dialog, trả về false
    if (_isShowingRationale) {
      debugPrint('⚠️ Rationale dialog already showing, skipping...');
      return false;
    }
    
    _isShowingRationale = true;
    debugPrint('📖 Showing camera permission rationale dialog');
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: orange, size: 28),
            SizedBox(width: 12),
            Text('Cần quyền Camera', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ứng dụng cần quyền truy cập camera để:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildPermissionReason(Icons.qr_code_scanner, 'Quét mã QR code/barcode'),
            _buildPermissionReason(Icons.photo_camera, 'Chụp ảnh sản phẩm'),
            _buildPermissionReason(Icons.inventory, 'Ghi nhận hình ảnh kiểm kê'),
            _buildPermissionReason(Icons.document_scanner, 'Quét phiếu giao hàng'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.security, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chúng tôi không lưu trữ hay chia sẻ hình ảnh của bạn',
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: grey,
            ),
            child: const Text('Từ chối', style: TextStyle(fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              foregroundColor: white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Cho phép', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    
    // ✅ Reset flag khi dialog đóng
    _isShowingRationale = false;
    debugPrint('🔄 Rationale dialog dismissed, flag reset. Result: $result');
    
    return result;
  }

  /// 📋 Bottom Sheet với Hướng Dẫn Chi Tiết
  static void _showCameraPermissionBottomSheet(BuildContext context) {
    // ✅ Nếu đang show bottom sheet, không show thêm
    if (_isShowingBottomSheet) {
      debugPrint('⚠️ Bottom sheet already showing, skipping...');
      return;
    }
    
    _isShowingBottomSheet = true;
    debugPrint('📋 Showing camera permission bottom sheet');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, size: 48, color: orange),
            ),
            const SizedBox(height: 16),
            
            // Title
            const Text(
              'Cấp quyền Camera',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              'Bạn đã từ chối quyền camera. Để sử dụng tính năng quét QR, vui lòng làm theo hướng dẫn:',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
            const SizedBox(height: 24),
            
            // Steps
            _buildStepItem(1, 'Bấm nút "Mở Cài đặt" bên dưới'),
            _buildStepItem(2, 'Chọn mục "Quyền" (Permissions)'),
            _buildStepItem(3, 'Tìm và bật quyền "Camera"'),
            _buildStepItem(4, 'Quay lại ứng dụng để sử dụng'),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Để sau', style: TextStyle(color: grey, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      openAppSettings(); // Mở Settings
                    },
                    icon: const Icon(Icons.settings, size: 20),
                    label: const Text('Mở Cài đặt', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      foregroundColor: white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).then((_) {
      // ✅ Reset flag khi bottom sheet bị đóng
      _isShowingBottomSheet = false;
      debugPrint('🔄 Bottom sheet dismissed, flag reset');
    });
  }

  /// 🎨 Widget - Permission Reason Item
  static Widget _buildPermissionReason(IconData icon, String reasonText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 20, color: greenColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reasonText, 
              style: const TextStyle(fontSize: 15, color: text),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Widget - Step Item
  static Widget _buildStepItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: orange,
            child: Text(
              '$step', 
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                color: white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// 📱 Snackbar - Soft reminder khi từ chối
  static void _showCameraPermissionSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.camera_alt, color: white, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Cần quyền Camera',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Để quét mã QR và chụp ảnh',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        action: SnackBarAction(
          label: 'Cấp quyền',
          textColor: Colors.yellow,
          onPressed: () async {
            final result = await Permission.camera.request();
            if (result.isPermanentlyDenied) {
              openAppSettings();
            } else if (result.isGranted) {
              _showSuccessSnackbar(context);
            }
          },
        ),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// ✅ Success Snackbar
  static void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: white, size: 20),
            SizedBox(width: 12),
            Text(
              'Đã cấp quyền Camera thành công!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: greenColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// 🎨 Widget - Empty State (dùng trong camera screen)
  static Widget buildCameraPermissionEmptyState(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.no_photography_outlined,
                        size: 80,
                        color: Colors.white54,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Không thể truy cập Camera',
                style: TextStyle(
                  color: white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Ứng dụng cần quyền truy cập camera để quét mã QR và chụp ảnh',
                style: TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Primary Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final granted = await handleCameraPermission(context);
                    if (granted && onRetry != null) {
                      onRetry();
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Cấp quyền Camera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: white,
                    foregroundColor: black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Secondary Button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Quay lại',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📊 Widget - Permission Banner (dùng trong màn hình chính)
  static Widget buildPermissionBanner(BuildContext context) {
    return MaterialBanner(
      backgroundColor: Colors.orange.shade100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Icon(Icons.warning_amber, color: Colors.orange.shade900, size: 28),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quyền Camera bị từ chối',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Một số tính năng sẽ bị hạn chế',
            style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final granted = await handleCameraPermission(context);
            if (granted) {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            }
          },
          child: Text(
            'Cài đặt', 
            style: TextStyle(
              color: Colors.orange.shade900, 
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
          },
          child: const Text(
            'Đóng', 
            style: TextStyle(color: grey, fontSize: 14),
          ),
        ),
      ],
    );
  }

  /// 🔍 Check Permission Status (Utility method)
  static Future<PermissionStatus> checkCameraPermissionStatus() async {
    return await Permission.camera.status;
  }

  /// ❓ Check if should show rationale
  static Future<bool> shouldShowRationale() async {
    final status = await Permission.camera.status;
    return status.isDenied; // Chưa hỏi hoặc vừa từ chối
  }
}

