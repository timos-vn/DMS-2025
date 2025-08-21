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

  static final globalKey = GlobalKey<_BarcodeScannerWidgetState>();

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget>
    with TickerProviderStateMixin {
  late final MobileScannerController cameraController;
  late final AnimationController lineController;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();

    lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    cameraController.dispose();
    lineController.dispose();
    super.dispose();
  }

  void startCamera() => cameraController.start();
  void stopCamera() => cameraController.stop();
  void scanFromGalleryPublic() => scanFromGallery();

  Future<void> scanFromGallery() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
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
    }
  }

  void handleScan(String code) async {
    if (isProcessing) return;
    isProcessing = true;

    widget.onBarcodeDetected(code);

    await Future.delayed(const Duration(seconds: 1));
    isProcessing = false;
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// 🎥 Live Camera View
        MobileScanner(
          controller: cameraController,
          fit: BoxFit.cover,
          onDetect: (capture) {
            for (final barcode in capture.barcodes) {
              final String? code = barcode.rawValue;
              if (code != null && code.isNotEmpty) {
                handleScan(code);
              }
            }
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
