import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../services/student/student_service.dart';
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
  final StudentService _studentService = StudentService();
  
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  bool _isFaceDetected = false;
  bool _isCapturing = false;

  int _currentStep = 0;
  int _faceStableCount = 0;
  final int _requiredStableFrames = 5; // 🔹 GIẢM XUỐNG 5 FRAME ĐỂ TEST NHANH
  
  final Map<String, File> _capturedImages = {
    'frontal': File(''),
    'left': File(''),
    'right': File(''),
  };

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

    _controller = CameraController(
      frontCamera, 
      ResolutionPreset.medium, 
      enableAudio: false,
    );
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
        _isFaceDetected = true;
        final face = faces.first;
        final angleY = face.headEulerAngleY ?? 0;

        // 🔹 DEBUG: IN GÓC ĐỂ KIỂM TRA (có thể comment lại sau khi test xong)
        debugPrint("🐛 DEBUG: Step $_currentStep, AngleY: $angleY");

        bool isCorrectPose = false;
        String currentPose = '';
        
        // 🔹 ĐIỀU KIỆN GÓC CHO CAMERA TRƯỚC SAMSUNG
        if (_currentStep == 0 && angleY.abs() < 15) {
          // BƯỚC 1: NHÌN THẲNG - góc nằm trong khoảng -15 đến +15 độ
          _instructionText = "Nhìn thẳng và giữ ổn định";
          currentPose = 'frontal';
          isCorrectPose = true;
        } else if (_currentStep == 1 && angleY > 10) {
          // 🔹 BƯỚC 2: NHÌN SANG TRÁI - góc DƯƠNG (do camera trước Samsung đảo ngược)
          _instructionText = "Nhìn sang trái";
          currentPose = 'left';
          isCorrectPose = true;
        } else if (_currentStep == 2 && angleY < -10) {
          // 🔹 BƯỚC 3: NHÌN SANG PHẢI - góc ÂM (do camera trước Samsung đảo ngược)
          _instructionText = "Nhìn sang phải";
          currentPose = 'right';
          isCorrectPose = true;
        } else {
          // HƯỚNG DẪN CHUNG KHI CHƯA ĐÚNG GÓC
          _instructionText = "Đưa khuôn mặt đúng hướng";
        }

        if (isCorrectPose) {
          _faceStableCount++;
          if (_faceStableCount >= _requiredStableFrames) {
            await _captureAndSaveImage(currentPose);
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

  Future<void> _captureAndSaveImage(String pose) async {
    if (_controller == null || 
        !_controller!.value.isInitialized || 
        _isCapturing) return;
    if (_currentStep >= 3) return;

    setState(() => _isCapturing = true);

    try {
      // 🔹 TẠM DỪNG STREAM ĐỂ CHỤP ẢNH RÕ NÉT
      await _controller!.stopImageStream();
      final XFile file = await _controller!.takePicture();

      // 🔹 LƯU ẢNH VÀO BỘ NHỚ TẠM
      final dir = await getTemporaryDirectory();
      final savedPath = '${dir.path}/${pose}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedFile = await File(file.path).copy(savedPath);
      
      _capturedImages[pose] = savedFile;
      _currentStep++;

      // 🔹 TIẾP TỤC QUY TRÌNH HOẶC KẾT THÚC
      if (_currentStep < 3) {
        await _controller!.startImageStream(_processCameraImage);
      } else {
        await _registerFaceWithStudentService();
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Lỗi chụp ảnh: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chụp ảnh: $e')),
        );
      }
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _registerFaceWithStudentService() async {
    if (widget.userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Không có user ID')),
        );
      }
      return;
    }

    try {
      // 🔹 KIỂM TRA ĐÃ CHỤP ĐỦ 3 ẢNH
      if (_capturedImages['frontal'] == null || 
          _capturedImages['left'] == null || 
          _capturedImages['right'] == null) {
        throw Exception('Thiếu ảnh để đăng ký');
      }

      // 🔹 HIỆN LOADING KHI UPLOAD
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang upload ảnh lên server...'),
              ],
            ),
          ),
        );
      }

      // 🔹 GỌI SERVICE ĐĂNG KÝ KHUÔN MẶT
      await _studentService.registerFaceImagesOnly(
        studentId: widget.userId!,
        frontalImage: _capturedImages['frontal']!,
        leftImage: _capturedImages['left']!,
        rightImage: _capturedImages['right']!,
      );

      // 🔹 ĐÓNG LOADING VÀ CHUYỂN MÀN HÌNH
      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FaceRegisterSuccessScreen()),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      
      debugPrint("Lỗi đăng ký khuôn mặt: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng ký: $e')),
        );
        _showRetryDialog();
      }
    }
  }

  void _showRetryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi Đăng Ký'),
        content: const Text('Có lỗi xảy ra khi đăng ký khuôn mặt. Bạn có muốn thử lại?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCamera();
            },
            child: const Text('Thử Lại'),
          ),
        ],
      ),
    );
  }

  void _resetCamera() {
    setState(() {
      _currentStep = 0;
      _faceStableCount = 0;
      _capturedImages.clear();
      _instructionText = "Đưa khuôn mặt vào khung hình";
    });
    
    if (_controller != null && _controller!.value.isInitialized) {
      _controller!.startImageStream(_processCameraImage);
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
      backgroundColor: Colors.white,
      appBar: buildMainAppBar(
        context: context,
        title: "Đăng ký khuôn mặt",
        showBack: true,
      ),
      body: !_isCameraInitialized
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔹 CAMERA PREVIEW VỚI KHUNG NHẬN DIỆN
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
                  
                  // 🔹 CHỈ HIỆN TEXT HƯỚNG DẪN DUY NHẤT
                  Text(
                    _instructionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
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

  const FaceFramePainter({
    required this.isDetected,
    required this.progress,
  });

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