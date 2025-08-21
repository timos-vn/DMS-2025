import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraCustomUI extends StatefulWidget {
  const CameraCustomUI({super.key});

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
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      debugPrint('Camera permission not granted');
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }
      await _onNewCameraSelected(_cameras[_selectedCameraIndex]);
    } catch (e) {
      debugPrint('Error setting up cameras: $e');
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
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await newController.initialize();
      if (!mounted) return;

      setState(() {
        _controller = newController;
        isCameraReady = true;
        _selectedCameraIndex = _cameras.indexOf(cameraDescription);
      });
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
    final previewSize = _controller?.value.previewSize;

    if (!isCameraReady || _controller == null || !_controller!.value.isInitialized || previewSize == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                  child: OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    alignment: Alignment.center,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: previewSize.height,
                        height: previewSize.width,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

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
