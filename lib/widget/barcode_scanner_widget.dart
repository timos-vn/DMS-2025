import 'package:dms/utils/camera_permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final ValueChanged<String> onBarcodeDetected;
  final EdgeInsets framePadding;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    this.framePadding = const EdgeInsets.all(0),
  });

  // ✅ Loại bỏ static globalKey để tránh xung đột giữa các màn hình

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget>
    with TickerProviderStateMixin {
  late final MobileScannerController cameraController;
  late final AnimationController lineController;
  bool isProcessing = false;
  bool isImagePickerActive = false; // ✅ Flag để tránh gọi Image Picker nhiều lần
  
  // ✅ Camera permission states - Fix flickering
  bool _isCheckingPermission = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    
    // ✅ Debug: Log widget creation
    final stackTrace = StackTrace.current;
    final callerInfo = stackTrace.toString().split('\n')[1];
    debugPrint('🎬 BarcodeScannerWidget initState()');
    debugPrint('   Widget hash: ${this.hashCode}');
    debugPrint('   Created from: $callerInfo');
    
    cameraController = MobileScannerController();
    
    lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // ✅ Check permission TRƯỚC KHI start camera
    _checkPermissionAndStartCamera();
  }
  
  /// ✅ Check camera permission và start camera
  Future<void> _checkPermissionAndStartCamera() async {
    if (!mounted) return;
    
    // Check permission với UI handler
    final hasPermission = await CameraPermissionHandler.handleCameraPermission(context);
    
    if (!mounted) return;
    
    // ✅ Update state 1 lần duy nhất
    setState(() {
      _isCheckingPermission = false;
      _hasPermission = hasPermission;
    });
    
    if (!hasPermission) {
      debugPrint('❌ BarcodeScannerWidget: No camera permission');
      return;
    }
    
    debugPrint('✅ BarcodeScannerWidget: Permission granted, starting camera');
    
    // Delay trước khi start camera
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (mounted) {
      startCamera();
    }
  }

  @override
  void dispose() {
    isImagePickerActive = false; // ✅ Reset flag khi dispose
    cameraController.dispose();
    lineController.dispose();
    super.dispose();
  }

  void startCamera() {
    try {
      if (mounted) {
        cameraController.start();
        debugPrint('BarcodeScannerWidget: Camera started manually');
      }
    } catch (e) {
      debugPrint('BarcodeScannerWidget: Error starting camera: $e');
      // ✅ Hiển thị thông báo lỗi cho user
      if (mounted) {
        showMessage('Lỗi khởi động camera: ${e.toString()}');
      }
    }
  }
  
  void stopCamera() {
    try {
      if (mounted) {
        cameraController.stop();
        debugPrint('BarcodeScannerWidget: Camera stopped');
      }
    } catch (e) {
      debugPrint('BarcodeScannerWidget: Error stopping camera: $e');
      // ✅ Không hiển thị thông báo lỗi khi dừng camera vì user không cần biết
    }
  }
  void scanFromGalleryPublic() => scanFromGallery();

  Future<void> scanFromGallery() async {
    // ✅ Kiểm tra nếu Image Picker đang active
    if (isImagePickerActive) {
      debugPrint('BarcodeScannerWidget: Image picker is already active, ignoring request');
      return;
    }

    try {
      isImagePickerActive = true; // ✅ Set flag
      
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      
      if (picked == null) {
        isImagePickerActive = false; // ✅ Reset flag
        return;
      }

      final BarcodeCapture? capture =
      await cameraController.analyzeImage(picked.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final String? code = capture.barcodes.first.rawValue;
        if (code != null && code.isNotEmpty) {
          handleScan(code);
        } else {
          showMessage("Mã barcode không hợp lệ.");
        }
      } else {
        showMessage("Không phát hiện mã barcode trong ảnh."); 
      }
    } catch (e) {
      debugPrint('Lỗi khi phân tích ảnh: $e');
      showMessage("Đã xảy ra lỗi khi xử lý ảnh.");
    } finally {
      isImagePickerActive = false; // ✅ Reset flag trong mọi trường hợp
    }
  }

  void handleScan(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      widget.onBarcodeDetected(code);
    } catch (e) {
      debugPrint('Error in barcode detection: $e');
    }

    // Shorter delay to allow continuous scanning
    await Future.delayed(const Duration(milliseconds: 800));
    isProcessing = false;
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// ✅ Hiển thị popup xác nhận refresh camera khi gặp lỗi
  void _showCameraErrorDialog(BuildContext context, dynamic error) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho phép đóng bằng cách tap bên ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Lỗi Camera'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Camera gặp sự cố và cần được khởi động lại.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chi tiết lỗi:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bạn có muốn thử khởi động lại camera không?',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Không làm gì, để user tự xử lý
              },
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _refreshCamera();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Refresh camera với logic cải tiến
  void _refreshCamera() {
    try {
      debugPrint('BarcodeScannerWidget: Refreshing camera...');
      
      // Dừng camera hiện tại
      if (mounted) {
        cameraController.stop();
      }
      
      // Đợi một chút rồi khởi động lại
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          startCamera();
          debugPrint('BarcodeScannerWidget: Camera refreshed successfully');
        }
      });
    } catch (e) {
      debugPrint('BarcodeScannerWidget: Error refreshing camera: $e');
      if (mounted) {
        showMessage('Không thể khởi động lại camera: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ STATE 1: Đang check permission - Show loading
    if (_isCheckingPermission) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Đang kiểm tra quyền camera...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    // ✅ STATE 2: Không có permission - Show Empty State
    if (!_hasPermission) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.no_photography, color: Colors.white54, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Không có quyền camera',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Vui lòng cấp quyền để quét mã vạch',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  // Retry permission check
                  setState(() => _isCheckingPermission = true);
                  _checkPermissionAndStartCamera();
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Cấp quyền'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // ✅ STATE 3: Có permission - Show Scanner
    return Stack(
      children: [
        /// 🎥 Live Camera View
        MobileScanner(
          controller: cameraController,
          fit: BoxFit.cover,
          onDetect: (capture) {
            try {
              for (final barcode in capture.barcodes) {
                final String? code = barcode.rawValue;
                if (code != null && code.isNotEmpty) {
                  handleScan(code);
                  break; // Only process first valid barcode
                }
              }
            } catch (e) {
              debugPrint('Error in onDetect: $e');
              // Continue scanning even if there's an error
            }
          },
          errorBuilder: (context, error) {
            debugPrint('MobileScanner error: $error');
            // ✅ Hiển thị popup xác nhận refresh camera
            // WidgetsBinding.instance.addPostFrameCallback((_) {
            //   _showCameraErrorDialog(context, error);
            // });
            return Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 50),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý lỗi camera...',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        /// 🖼 Nút chọn ảnh từ thư viện
        Positioned(
          top: 40,
          right: 20,
          child: FloatingActionButton.small(
            heroTag: "pick_image",
            backgroundColor: Colors.white,
            onPressed: scanFromGallery,
            child: const Icon(Icons.photo_library),
          ),
        ),

        /// 🟩 Overlay scan khung và dòng kẻ
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double frameSize = constraints.maxWidth * 0.6;
              return Center(
                child: Padding(
                  padding: widget.framePadding,
                  child: SizedBox(
                    width: frameSize,
                    height: frameSize,
                    child: Stack(
                      children: [
                        // Khung viền
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.greenAccent,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        // Dòng kẻ đỏ di chuyển
                        AnimatedBuilder(
                          animation: lineController,
                          builder: (context, child) {
                            final double lineY =
                                lineController.value * frameSize;
                            return Positioned(
                              top: lineY,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: Colors.redAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
