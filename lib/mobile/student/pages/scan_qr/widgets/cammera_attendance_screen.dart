import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../services/session_service.dart';
import '../../../../../services/student/student_service.dart';
import '../../../../../models/session_model.dart';
import '../../../../../models/user/user_model.dart';
import '../../register_face/widgets/main_appbar.dart';
import '../../home_page/home_screen.dart';

class FaceAttendanceScreen extends StatefulWidget {
  final SessionModel session;
  final String studentId;

  const FaceAttendanceScreen({
    super.key,
    required this.session,
    required this.studentId,
  });

  @override
  State<FaceAttendanceScreen> createState() => _FaceAttendanceScreenState();
}

class _FaceAttendanceScreenState extends State<FaceAttendanceScreen> {
  CameraController? _controller;
  late final FaceDetector _faceDetector;
  final SessionService _sessionService = SessionService();
  final StudentService _studentService = StudentService();

  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  bool _isFaceDetected = false;
  bool _isCapturing = false;
  bool _isSuccess = false;
  bool _isVerifying = false;
  int _faceStableCount = 0;
  final int _requiredStableFrames = 5;

  String _instructionText = "Đưa khuôn mặt bạn vào khung tròn";
  String _processText = "Đang chờ nhận diện khuôn mặt...";
  UserModel? _matchedStudent;

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
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cần quyền Camera để điểm danh')),
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
    if (_isDetecting || _isCapturing || _isSuccess || _isVerifying) return;
    _isDetecting = true;
    try {
      final rotation = InputImageRotationValue.fromRawValue(
        _controller!.description.sensorOrientation,
      ) ?? InputImageRotation.rotation0deg;

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
        setState(() {
          _isFaceDetected = true;
        });

        final face = faces.first;
        final angleY = face.headEulerAngleY ?? 0;

        if (angleY.abs() < 15) {
          _faceStableCount++;
          if (_faceStableCount >= _requiredStableFrames) {
            await _captureAndVerifyFace();
            _faceStableCount = 0;
          }
        } else {
          _instructionText = "Vui lòng nhìn thẳng vào camera";
          _faceStableCount = 0;
        }
      } else {
        _isFaceDetected = false;
        _instructionText = "Đưa khuôn mặt vào khung tròn";
        _faceStableCount = 0;
      }
    } catch (e) {
      debugPrint("Lỗi nhận diện: $e");
    } finally {
      _isDetecting = false;
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> _captureAndVerifyFace() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;
    setState(() {
      _isCapturing = true;
      _isVerifying = true;
    });
    try {
      await _controller!.stopImageStream();
      final XFile file = await _controller!.takePicture();
      final dir = await getTemporaryDirectory();
      final savedPath = '${dir.path}/attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(file.path).copy(savedPath);

      final result = await _studentService.markAttendanceWithFace(savedFile);

      if (result['success'] == true) {
        final matched = result['student'];
        setState(() {
          _isSuccess = true;
          _matchedStudent = UserModel(
            uid: matched['studentId'],
            name: matched['name'],
            email: matched['email'],
            role: 'student',
          );
        });

        await _sessionService.markAttendance(
          sessionId: widget.session.id,
          studentId: matched['studentId'],
          faceImageUrl: savedFile.path,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Điểm danh thành công!"),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _isSuccess = false;
          _instructionText = "Không tìm thấy sinh viên phù hợp";
        });
        await _controller!.startImageStream(_processCameraImage);
      }
    } catch (e) {
      debugPrint("Lỗi xác thực khuôn mặt: $e");
      await _controller!.startImageStream(_processCameraImage);
    } finally {
      setState(() {
        _isCapturing = false;
        _isVerifying = false;
      });
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
    return Scaffold(
      appBar: buildMainAppBar(
        context: context,
        title: "Điểm danh khuôn mặt",
        showBack: true,
      ),
      backgroundColor: Colors.white,
      body: !_isCameraInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 280,
                          height: 280,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                      if (_isVerifying && !_isSuccess)
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
                      if (_isSuccess)
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 5),
                          ),
                          child: const Icon(Icons.check_circle,
                              color: Colors.green, size: 100),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // ✅ Khi xác thực chưa thành công thì hiển thị hướng dẫn
                if (!_isSuccess) ...[
                  Text(
                    _instructionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _isVerifying ? Colors.blue : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isVerifying) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    const Text('Đang xác thực...', style: TextStyle(color: Colors.grey)),
                  ],
                ],

                // ✅ Khi xác thực thành công, chỉ hiển thị thông tin sinh viên
                if (_isSuccess && _matchedStudent != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          " Xác thực thành công",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _matchedStudent!.name,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _matchedStudent!.uid,
                          style: const TextStyle(color: Colors.black54, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
