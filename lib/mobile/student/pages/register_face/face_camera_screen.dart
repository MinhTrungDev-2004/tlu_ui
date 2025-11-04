import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/main_appbar.dart';
import 'face_succes_register_screen.dart';

class FaceCameraScreen extends StatefulWidget {
  final String? userId;

  const FaceCameraScreen({super.key, this.userId});

  @override
  State<FaceCameraScreen> createState() => _FaceCameraScreenState();
}

class _FaceCameraScreenState extends State<FaceCameraScreen> {
  CameraController? _controller;
  late final FaceDetector _faceDetector;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  bool _isFaceDetected = false;
  bool _isCapturing = false;

  int _currentStep = 0;
  int _faceStableCount = 0;
  final int _requiredStableFrames = 8;
  final List<String> _savedImages = [];

  String _instructionText = "Đưa khuôn mặt vào khung hình";

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableTracking: true,
      ),
    );
  }

  Future<void> _initCamera() async {
    final statusCamera = await Permission.camera.request();
    if (!statusCamera.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cần quyền Camera để tiếp tục')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy camera nào')),
      );
      Navigator.pop(context);
      return;
    }

    final frontCamera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _controller = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();

    if (!mounted) return;
    setState(() => _isCameraInitialized = true);

    await _controller!.startImageStream(_processCameraImage);
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || _isCapturing) return;
    _isDetecting = true;

    try {
      final rotation = InputImageRotationValue.fromRawValue(
              _controller!.description.sensorOrientation) ??
          InputImageRotation.rotation0deg;

      final allBytes = <int>[];
      for (final plane in image.planes) {
        allBytes.addAll(plane.bytes);
      }

      final inputImage = InputImage.fromBytes(
        bytes: Uint8List.fromList(allBytes),
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
        // ✅ Chỉnh step 2 và step 3 mở rộng góc
        if (_currentStep == 0 && angleY.abs() < 10) {
          _instructionText = "Bước 1/3: Nhìn thẳng và giữ ổn định";
          isCorrectPose = true;
        } else if (_currentStep == 1 && angleY < -10 && angleY > -40) {
          _instructionText = "Bước 2/3: Nhìn sang trái";
          isCorrectPose = true;
        } else if (_currentStep == 2 && angleY > 10 && angleY < 40) {
          _instructionText = "Bước 3/3: Nhìn sang phải";
          isCorrectPose = true;
        } else {
          _instructionText = "Đưa khuôn mặt đúng hướng";
        }

        if (isCorrectPose) {
          _faceStableCount++;
          if (_faceStableCount >= _requiredStableFrames) {
            await _captureAndSaveImage();
            _faceStableCount = 0;
          }
        } else {
          _faceStableCount = 0;
        }
      } else {
        _isFaceDetected = false;
        _instructionText = "Đưa khuôn mặt vào khung hình";
        _faceStableCount = 0;
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Lỗi nhận diện: $e");
    } finally {
      _isDetecting = false;
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> _captureAndSaveImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;
    if (_currentStep >= 3) return;

    setState(() => _isCapturing = true);

    try {
      await _controller!.stopImageStream();
      final XFile file = await _controller!.takePicture();

      final dir = await getTemporaryDirectory();
      final savedPath =
          '${dir.path}/face_${_currentStep + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(file.path).copy(savedPath);

      final url = await _uploadImageToFirebase(savedFile, _currentStep);
      if (url.isNotEmpty) _savedImages.add(url);

      _currentStep++;

      if (_currentStep < 3) {
        await _controller!.startImageStream(_processCameraImage);
      } else {
        await _updateUserFaceData();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const FaceRegisterSuccessScreen()),
          );
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Lỗi chụp ảnh: $e");
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<String> _uploadImageToFirebase(File image, int index) async {
    try {
      if (widget.userId == null) return '';
      final ref = FirebaseStorage.instance
          .ref()
          .child('faces/${widget.userId}/face_${index + 1}.jpg');
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Lỗi upload: $e");
      return '';
    }
  }

  Future<void> _updateUserFaceData() async {
    if (widget.userId == null) return;
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).set({
      'face_images': _savedImages,
      'is_face_registered': true,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildMainAppBar(
        context: context,
        title: "Đăng ký khuôn mặt",
        showBack: true,
      ),
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: SizedBox(
                          width: 300,
                          height: 400,
                          child: AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: CameraPreview(_controller!),
                          ),
                        ),
                      ),
                      CustomPaint(
                        size: const Size(260, 340),
                        painter: FaceFramePainter(
                          isDetected: _isFaceDetected,
                          progress: _currentStep / 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    _instructionText,
                    textAlign: TextAlign.center,
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
            ),
    );
  }
}

class FaceFramePainter extends CustomPainter {
  final bool isDetected;
  final double progress;

  FaceFramePainter({required this.isDetected, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width,
      height: size.height,
    );

    final basePaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawOval(rect, basePaint);

    final progressPaint = Paint()
      ..color = isDetected
          ? (progress >= 1 ? Colors.green : Colors.greenAccent)
          : Colors.grey
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.1415 * progress;
    canvas.drawArc(rect, -3.1415 / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(FaceFramePainter old) =>
      old.isDetected != isDetected || old.progress != progress;
}
