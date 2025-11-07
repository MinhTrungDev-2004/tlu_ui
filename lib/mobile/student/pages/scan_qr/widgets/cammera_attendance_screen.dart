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
  bool _isCapturing = false;
  bool _isSuccess = false;
  bool _isVerifying = false;
  bool _hasError = false;
  int _faceStableCount = 0;
  final int _requiredStableFrames = 5;

  String _instructionText = "Đưa khuôn mặt bạn vào khung tròn";
  String _statusText = "Đang chờ khuôn mặt...";
  UserModel? _matchedStudent;
  Timer? _autoNavigateTimer;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableTracking: true,
        enableContours: true,
        minFaceSize: 0.15,
      ),
    );
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) {
          _showErrorSnackBar('Cần quyền Camera để điểm danh');
          _navigateBack();
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showErrorSnackBar('Không tìm thấy camera nào');
        _navigateBack();
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
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      
      await _controller!.initialize();

      if (!mounted) return;
      
      setState(() => _isCameraInitialized = true);
      await _controller!.startImageStream(_processCameraImage);
      
    } catch (e) {
      debugPrint("Lỗi khởi tạo camera: $e");
      if (mounted) {
        _showErrorSnackBar('Lỗi khởi tạo camera: $e');
        _navigateBack();
      }
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isDetecting || _isCapturing || _isSuccess || _isVerifying || _hasError) return;
    
    _isDetecting = true;
    try {
      final rotation = InputImageRotationValue.fromRawValue(
        _controller!.description.sensorOrientation,
      ) ?? InputImageRotation.rotation0deg;

      // SỬA: Sử dụng cách đơn giản để convert CameraImage
      final inputImage = _getInputImageFromCameraImage(image, rotation);
      final faces = await _faceDetector.processImage(inputImage);
      
      if (!mounted) return;

      if (faces.isNotEmpty) {
        final face = faces.first;
        final angleY = face.headEulerAngleY ?? 0;
        final angleX = face.headEulerAngleX ?? 0;

        // Kiểm tra góc nghiêng và ngẩng
        if (angleY.abs() < 15 && angleX.abs() < 15) {
          _faceStableCount++;
          setState(() {
            _instructionText = "Giữ yên... ($_faceStableCount/$_requiredStableFrames)";
          });
          
          if (_faceStableCount >= _requiredStableFrames) {
            await _captureAndVerifyFace();
            _faceStableCount = 0;
          }
        } else {
          setState(() {
            if (angleY.abs() >= 15) {
              _instructionText = "Vui lòng nhìn thẳng vào camera";
            } else {
              _instructionText = "Điều chỉnh góc nhìn";
            }
          });
          _faceStableCount = 0;
        }
      } else {
        setState(() {
          _instructionText = "Đưa khuôn mặt vào khung tròn";
        });
        _faceStableCount = 0;
      }
    } catch (e) {
      debugPrint("Lỗi nhận diện khuôn mặt: $e");
    } finally {
      _isDetecting = false;
    }
  }

  // SỬA: Method mới đơn giản hơn không dùng WriteBuffer
  InputImage _getInputImageFromCameraImage(CameraImage image, InputImageRotation rotation) {
    try {
      // Đối với format YUV420 (Android)
      if (image.format.group == ImageFormatGroup.yuv420) {
        final plane = image.planes.first;
        
        // Sử dụng Uint8List.fromList thay vì WriteBuffer
        final bytes = Uint8List.fromList(plane.bytes);
        
        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      } 
      // Đối với format BGRA8888 (iOS)
      else if (image.format.group == ImageFormatGroup.bgra8888) {
        final plane = image.planes.first;
        final bytes = Uint8List.fromList(plane.bytes);
        
        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.bgra8888,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      }
      // Format khác - sử dụng mặc định
      else {
        final plane = image.planes.first;
        final bytes = Uint8List.fromList(plane.bytes);
        
        return InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation,
            format: InputImageFormat.nv21,
            bytesPerRow: plane.bytesPerRow,
          ),
        );
      }
    } catch (e) {
      debugPrint("Lỗi convert CameraImage: $e");
      // Fallback: sử dụng plane đầu tiên
      final plane = image.planes.first;
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    }
  }

  Future<void> _captureAndVerifyFace() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) return;

    setState(() {
      _isCapturing = true;
      _isVerifying = true;
      _statusText = "Đang xác thực khuôn mặt...";
    });

    try {
      await _controller!.stopImageStream();
      
      final XFile file = await _controller!.takePicture();
      final File imageFile = File(file.path);
      
      // Kiểm tra kích thước file
      final fileSize = await imageFile.length();
      if (fileSize == 0) {
        throw Exception("Ảnh chụp bị lỗi (kích thước 0 bytes)");
      }

      debugPrint("📸 Đã chụp ảnh: ${file.path} (${fileSize} bytes)");

      // Gọi service điểm danh với khuôn mặt
      final result = await _studentService.markAttendanceWithFace(imageFile);
      
      if (!mounted) return;

      if (result['success'] == true) {
        // ✅ Điểm danh thành công
        final student = await _studentService.getStudentById(widget.studentId);
        
        setState(() {
          _isSuccess = true;
          _matchedStudent = student;
          _statusText = "Điểm danh thành công!";
        });

        debugPrint("✅ Điểm danh thành công với similarity: ${result['similarity']}");

        // Ghi nhận điểm danh vào session
        await _sessionService.markAttendance(
          sessionId: widget.session.id,
          studentId: widget.studentId,
          faceImageUrl: file.path,
          similarity: result['similarity'] ?? 0.0,
        );

        _startAutoNavigateTimer();
      } else {
        // ❌ Điểm danh thất bại
        setState(() {
          _hasError = true;
          _statusText = result['message'] ?? "Xác thực thất bại";
        });
        
        debugPrint("❌ Điểm danh thất bại: ${result['message']}");
        await _restartCameraAfterDelay();
      }
    } catch (e) {
      debugPrint("Lỗi xác thực khuôn mặt: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _statusText = "Lỗi hệ thống: ${e.toString()}";
        });
        await _restartCameraAfterDelay();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _restartCameraAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted && !_isSuccess) {
      await _restartCamera();
    }
  }

  Future<void> _restartCamera() async {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        await _controller!.startImageStream(_processCameraImage);
        setState(() {
          _hasError = false;
          _instructionText = "Đưa khuôn mặt bạn vào khung tròn";
          _statusText = "Đang chờ khuôn mặt...";
        });
        debugPrint("🔄 Đã khởi động lại camera");
      }
    } catch (e) {
      debugPrint("Lỗi khởi động lại camera: $e");
      if (mounted) {
        _showErrorSnackBar('Lỗi camera: $e');
      }
    }
  }

  void _startAutoNavigateTimer() {
    _autoNavigateTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  void _navigateBack() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _manualRetry() {
    if (_hasError) {
      _restartCamera();
    }
  }

  @override
  void dispose() {
    _autoNavigateTimer?.cancel();
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang khởi tạo camera...'),
                ],
              ),
            )
          : Column(
              children: [
                const SizedBox(height: 30),
                
                // Camera Preview
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera preview với overlay
                      Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getBorderColor(),
                            width: 4,
                          ),
                        ),
                        child: ClipOval(
                          child: CameraPreview(_controller!),
                        ),
                      ),
                      
                      // Overlay khi đang xử lý
                      if (_isVerifying && !_isSuccess)
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 16),
                                Text(
                                  'Đang xác thực...',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // Icon thành công
                      if (_isSuccess)
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(0.3),
                            border: Border.all(color: Colors.green, width: 4),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 80,
                          ),
                        ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Thông tin sinh viên khi thành công
                if (_isSuccess && _matchedStudent != null)
                  Column(
                    children: [
                      Text(
                        _matchedStudent!.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _matchedStudent!.email ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      if (_matchedStudent!.studentCode != null)
                        Text(
                          'Mã SV: ${_matchedStudent!.studentCode!}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                
                // Hướng dẫn và trạng thái
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    children: [
                      if (!_isSuccess)
                        Text(
                          _instructionText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        _statusText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _getStatusColor(),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Nút thử lại khi có lỗi
                if (_hasError && !_isSuccess)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: _manualRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ),
                
                const Spacer(),
                
                // Footer hướng dẫn
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Column(
                    children: [
                      Text(
                        '💡 Hướng dẫn:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Đảm bảo khuôn mặt được chiếu sáng rõ\n• Nhìn thẳng vào camera\n• Giữ yên trong vài giây',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Color _getBorderColor() {
    if (_isSuccess) return Colors.green;
    if (_hasError) return Colors.red;
    if (_isVerifying) return Colors.orange;
    if (_faceStableCount > 0) return Colors.blue;
    return Colors.grey;
  }

  Color _getStatusColor() {
    if (_isSuccess) return Colors.green;
    if (_hasError) return Colors.red;
    if (_isVerifying) return Colors.orange;
    return Colors.grey;
  }
}