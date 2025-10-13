import 'package:camera/camera.dart';
import 'package:dms/utils/camera_permission_handler.dart';
import 'package:flutter/material.dart';

class CameraCustomUI extends StatefulWidget {
  final bool showZoomControls;
  
  const CameraCustomUI({
    super.key,
    this.showZoomControls = true, // ✅ Mặc định hiển thị zoom controls
  });

  @override
  State<CameraCustomUI> createState() => _CameraCustomUIState();
}

class _CameraCustomUIState extends State<CameraCustomUI>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool isCameraReady = false;
  bool isTakingPicture = false;
  double _currentZoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _minZoomLevel = 1.0;
  bool _isZooming = false; // ✅ Flag để track zoom state
  
  // ✅ Cache permission status để tránh nháy màn hình
  bool _isCheckingPermission = true; // Loading state khi đang check
  bool _hasPermission = false;

  late final AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    // ✅ Đảm bảo mounting trước khi check permission
    if (!mounted) return;
    
    // ✅ Sử dụng CameraPermissionHandler với UX tốt hơn
    final hasPermission = await CameraPermissionHandler.handleCameraPermission(context);
    
    // ✅ Check mounted lại sau async operation
    if (!mounted) return;
    
    // ✅ Update state 1 lần duy nhất để tránh nháy màn hình
    setState(() {
      _isCheckingPermission = false;
      _hasPermission = hasPermission;
    });
    
    if (!hasPermission) {
      debugPrint('❌ Camera permission not granted - showing empty state');
      return;
    }

    debugPrint('✅ Camera permission granted - initializing camera');
    
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('❌ No cameras available');
        return;
      }
      await _onNewCameraSelected(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint('❌ Error setting up cameras: $e');
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription cameraDescription) async {
    final oldController = _controller;

    setState(() {
      isCameraReady = false;
      _controller = null;
    });

    await Future.delayed(const Duration(milliseconds: 100)); // Let widget rebuild without preview
    await oldController?.dispose();

    final newController = CameraController(
      cameraDescription,
      ResolutionPreset.max,   // ✅ Sử dụng độ phân giải tối đa
      enableAudio: false,
    );

    try {
      await newController.initialize();
      if (!mounted) return;

      // ✅ Lấy thông tin zoom levels
      _maxZoomLevel = await newController.getMaxZoomLevel();
      _minZoomLevel = await newController.getMinZoomLevel();
      _currentZoomLevel = 1.0; // ✅ Bắt đầu với zoom 1.0x (tự nhiên)

      setState(() {
        _controller = newController;
        isCameraReady = true;
        _selectedCameraIndex = _cameras.indexOf(cameraDescription);
      });
      
      // ✅ Debug preview size
      debugPrint('📱 Camera Preview Size: ${newController.value.previewSize}');
      debugPrint('📱 Camera Aspect Ratio: ${newController.value.aspectRatio}');
    } catch (e) {
      debugPrint('Error initializing new camera: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    _flipController.forward(from: 0);
    final newIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _onNewCameraSelected(_cameras[newIndex]);
  }

  // ✅ Method để zoom in
  Future<void> _zoomIn() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    final newZoomLevel = (_currentZoomLevel + 0.5).clamp(_minZoomLevel, _maxZoomLevel);
    await _setZoomLevel(newZoomLevel);
  }

  // ✅ Method để zoom out
  Future<void> _zoomOut() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    final newZoomLevel = (_currentZoomLevel - 0.5).clamp(_minZoomLevel, _maxZoomLevel);
    await _setZoomLevel(newZoomLevel);
  }

  // ✅ Method để set zoom level cụ thể
  Future<void> _setZoomLevel(double zoomLevel) async {
    try {
      await _controller!.setZoomLevel(zoomLevel);
      setState(() {
        _currentZoomLevel = zoomLevel;
      });
    } catch (e) {
      debugPrint('Error setting zoom level: $e');
    }
  }

  // ✅ Method để reset zoom về mặc định
  Future<void> _resetZoom() async {
    await _setZoomLevel(_minZoomLevel);
  }

  // ✅ Method xử lý pinch zoom
  void _handleScaleStart(ScaleStartDetails details) {
    _isZooming = true;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!_isZooming || _controller == null || !_controller!.value.isInitialized) return;
    
    // ✅ Tính toán zoom level dựa trên scale
    final double scale = details.scale;
    final double newZoomLevel = (_currentZoomLevel * scale).clamp(_minZoomLevel, _maxZoomLevel);
    
    setState(() {
      _currentZoomLevel = newZoomLevel;
    });
    
    // ✅ Apply zoom level
    _controller!.setZoomLevel(_currentZoomLevel);
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _isZooming = false;
  }

  // ✅ Method xử lý double tap để reset zoom
  void _handleDoubleTap() {
    _resetZoom();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || isTakingPicture) return;

    try {
      setState(() => isTakingPicture = true);
      final file = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, file);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    } finally {
      setState(() => isTakingPicture = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ State 1: Đang check permission - Show loading NGAY
    if (_isCheckingPermission) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Đang kiểm tra quyền camera...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ State 2: Không có permission - Show Empty State
    if (!_hasPermission) {
      return Scaffold(
        body: CameraPermissionHandler.buildCameraPermissionEmptyState(
          context,
          onRetry: () {
            // Reset và check lại
            setState(() {
              _isCheckingPermission = true;
            });
            _setupCamera();
          },
        ),
      );
    }

    // ✅ State 3: Có permission nhưng camera chưa ready - Show loading
    final previewSize = _controller?.value.previewSize;
    if (!isCameraReady || _controller == null || !_controller!.value.isInitialized || previewSize == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Đang khởi động camera...',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ State 4: Everything ready - Show Camera Preview
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ Camera Preview - sử dụng Container đơn giản
          Center(
            child: AnimatedBuilder(
              animation: _flipController,
              builder: (context, child) {
                final angle = _flipController.value * 3.14;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: GestureDetector(
                    onScaleStart: _handleScaleStart,
                    onScaleUpdate: _handleScaleUpdate,
                    onScaleEnd: _handleScaleEnd,
                    onDoubleTap: _handleDoubleTap, // ✅ Double tap để reset zoom
                    child: CameraPreview(_controller!),
                  ),
                );
              },
            ),
          ),

          // ✅ Zoom Controls (có thể ẩn)
          if (widget.showZoomControls) ...[
            // Zoom Level Indicator - hiển thị ở góc trên bên trái
            Positioned(
              top: 100,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentZoomLevel.toStringAsFixed(1)}x',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            // Zoom Controls - hiển thị ở bên phải
            Positioned(
              right: 24,
              top: 100,
              child: Column(
                children: [
                  // Zoom In Button
                  FloatingActionButton.small(
                    onPressed: _zoomIn,
                    backgroundColor: Colors.black54,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  // Zoom Out Button
                  FloatingActionButton.small(
                    onPressed: _zoomOut,
                    backgroundColor: Colors.black54,
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  // Reset Zoom Button
                  FloatingActionButton.small(
                    onPressed: _resetZoom,
                    backgroundColor: Colors.black54,
                    child: const Icon(Icons.refresh, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // ✅ Zoom Slider - hiển thị ở dưới cùng
            Positioned(
              bottom: 120,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white30,
                          thumbColor: Colors.white,
                          overlayColor: Colors.white24,
                          trackHeight: 2.0,
                        ),
                        child: Slider(
                          value: _currentZoomLevel,
                          min: _minZoomLevel,
                          max: _maxZoomLevel,
                          onChanged: (value) {
                            setState(() {
                              _currentZoomLevel = value;
                            });
                            _controller?.setZoomLevel(value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],



          // Nút chụp hình
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _takePicture,
                backgroundColor: Colors.white,
                child: const Icon(Icons.camera, color: Colors.black),
              ),
            ),
          ),

          // Nút chuyển camera
          Positioned(
            top: 28,
            left: 24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: ()=> Navigator.pop(context),
            ),
          ), Positioned(
            top: 28,
            right: 24,
            child: IconButton(
              icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white, size: 32),
              onPressed: _switchCamera,
            ),
          ),
        ],
      ),
    );
  }
}
