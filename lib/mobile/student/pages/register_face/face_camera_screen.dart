import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FaceCameraScreen extends StatefulWidget {
  final String? userId;

  const FaceCameraScreen({super.key, this.userId});

  @override
  State<FaceCameraScreen> createState() => _FaceCameraScreenState();
}

class _FaceCameraScreenState extends State<FaceCameraScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  bool _isDetecting = false;

  late final FaceDetector _faceDetector;
  int _currentStep = 0; // 0 = nhìn thẳng, 1 = trái, 2 = phải
  int _faceStableCount = 0;
  final int _requiredStableFrames = 8; // ~2 giây
  final List<String> _savedImages = [];

  bool _isFaceDetected = false;
  String _instructionText = "Đưa khuôn mặt vào khung hình";

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
      ),
    );
  }

  Future<void> _initCamera() async {
    final statusCamera = await Permission.camera.request();
    final statusStorage = await Permission.storage.request();

    if (!statusCamera.isGranted || !statusStorage.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần quyền Camera và Storage để tiếp tục')),
      );
      Navigator.pop(context);
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();

    if (!mounted) return;
    setState(() => _isCameraInitialized = true);

    _controller!.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || _isCapturing) return;
    _isDetecting = true;

    try {
      final camera = _controller!.description;
      final rotation =
          InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
              InputImageRotation.rotation0deg;

      final allBytes = <int>[];
      for (var plane in image.planes) allBytes.addAll(plane.bytes);
      final bytes = Uint8List.fromList(allBytes);

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes.first.bytesPerRow,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        _isFaceDetected = true;
        final face = faces.first;
        final angleY = face.headEulerAngleY ?? 0;

        bool isCorrectPose = false;
        if (_currentStep == 0 && angleY.abs() < 10) isCorrectPose = true;
        else if (_currentStep == 1 && angleY < -15 && angleY > -40) isCorrectPose = true;
        else if (_currentStep == 2 && angleY > 15 && angleY < 40) isCorrectPose = true;

        if (isCorrectPose) {
          _faceStableCount++;
          _instructionText = "Giữ mặt ổn định...";
          if (_faceStableCount >= _requiredStableFrames) {
            await _captureAndSaveImage();
            _faceStableCount = 0;
          }
        } else {
          _faceStableCount = 0;
          _instructionText = "Đưa khuôn mặt vào khung hình đúng hướng";
        }
      } else {
        _isFaceDetected = false;
        _faceStableCount = 0;
        _instructionText = "Đưa khuôn mặt vào khung hình";
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Lỗi nhận diện khuôn mặt: $e");
    } finally {
      _isDetecting = false;
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  Future<void> _captureAndSaveImage() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_currentStep >= 3) return;

    setState(() => _isCapturing = true);

    try {
      final XFile file = await _controller!.takePicture();

      // Lưu ảnh vào Gallery (Android 7+)
      final directory = await getTemporaryDirectory();
      final newPath = '${directory.path}/face_step${_currentStep + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
     await File(file.path).copy(newPath);

      

     

      _currentStep++;
      if (_currentStep == 1) _instructionText = "Bước 2/3: Nhìn sang trái";
      else if (_currentStep == 2) _instructionText = "Bước 3/3: Nhìn sang phải";
      else if (_currentStep == 3) {
        _instructionText = "Hoàn tất đăng ký khuôn mặt ✅";
        await _controller?.stopImageStream();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SuccessScreen()),
          );
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Lỗi khi chụp ảnh: $e");
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(height: topPadding, color: const Color(0xFF1470E2)),
          Container(
            width: screenWidth,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFF1470E2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Đăng ký khuôn mặt',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          Expanded(
            child: _isCameraInitialized
                ? Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 300,
                              height: 400,
                              color: Colors.black,
                              child: AspectRatio(
                                aspectRatio: _controller!.value.aspectRatio,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                            CustomPaint(
                              size: const Size(250, 330),
                              painter: FaceFramePainter(
                                isDetected: _isFaceDetected,
                                isCaptured: _currentStep > 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _instructionText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_savedImages.isNotEmpty)
                          Text(
                            "Đã lưu ${_savedImages.length}/3 ảnh",
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  )
                : const Center(child: CircularProgressIndicator(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}

class FaceFramePainter extends CustomPainter {
  final bool isDetected;
  final bool isCaptured;

  FaceFramePainter({this.isDetected = false, this.isCaptured = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCaptured
          ? Colors.green
          : isDetected
              ? Colors.blueAccent
              : Colors.white
      ..strokeWidth = isCaptured ? 6 : 3
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant FaceFramePainter oldDelegate) => true;
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              "Đăng ký khuôn mặt thành công!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
