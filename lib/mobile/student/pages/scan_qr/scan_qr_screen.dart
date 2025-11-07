import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'widgets/class_info_screen.dart';
import '../register_face/widgets/main_appbar.dart';
import '../../../../services/session_service.dart'; // Import SessionService

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  MobileScannerController? controller;
  bool _isScanning = true;
  bool _navigated = false;
  final SessionService _sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRDetected(BarcodeCapture capture) async {
    if (!_navigated && capture.barcodes.isNotEmpty) {
      final String? qrData = capture.barcodes.first.rawValue;
      
      if (qrData != null) {
        setState(() {
          _navigated = true;
          _isScanning = false;
        });

        // Hiển thị loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          // Lấy thông tin session từ QR data
          final session = await _sessionService.getSessionFromQR(qrData);
          
          Navigator.pop(context); // Đóng loading dialog

          if (session != null) {
            // Kiểm tra tính hợp lệ của session
            final validationError = _sessionService.validateSessionForAttendance(session);
            
            if (validationError == null) {
              // Chuyển đến trang thông tin buổi học với session data
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassInfoScreen(
                    session: session,
                  ),
                ),
              );
            } else {
              _showErrorDialog(validationError);
              _resetScanner();
            }
          } else {
            _showErrorDialog('Mã QR không hợp lệ hoặc không tìm thấy buổi học');
            _resetScanner();
          }
        } catch (e) {
          Navigator.pop(context);
          _showErrorDialog('Lỗi khi xử lý mã QR: $e');
          _resetScanner();
        }
      }
    }
  }

  void _resetScanner() {
    setState(() {
      _navigated = false;
      _isScanning = true;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(''),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cutOut = screenSize.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildMainAppBar(
        context: context,
        title: 'Quét QR Code',
        showBack: true,
      ),
      body: Stack(
        children: [
          // Camera scanner - chỉ hiển thị khi đang quét
          if (_isScanning)
            MobileScanner(
              controller: controller,
              onDetect: _onQRDetected,
              fit: BoxFit.cover,
            ),

          // Overlay khung quét
          _buildQROverlay(cutOut),

          // Hướng dẫn
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _isScanning 
                  ? 'Đặt mã QR trong khung để quét'
                  : 'Đang xử lý...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Nút hủy
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
                label: const Text(
                  'Hủy',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Overlay khung QR
  Widget _buildQROverlay(double cutOut) {
    final screenSize = MediaQuery.of(context).size;
    final overlayHeight = screenSize.height - 200;

    return IgnorePointer(
      child: SizedBox(
        width: screenSize.width,
        height: overlayHeight,
        child: Stack(
          children: [
            // Làm tối background xung quanh khung quét
            Container(color: Colors.black54),
            
            // Khung quét chính giữa
            Center(
              child: Container(
                width: cutOut,
                height: cutOut,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isScanning ? Colors.green : Colors.grey,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomPaint(
                  painter: _CornerPainter(
                    color: _isScanning ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ),

            // Hiệu ứng quét - chỉ hiển thị khi đang quét
            if (_isScanning)
              Positioned(
                top: (overlayHeight - cutOut) / 2,
                left: (screenSize.width - cutOut) / 2,
                child: Container(
                  width: cutOut,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.withOpacity(0.1),
                        Colors.green,
                        Colors.green.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const SizedBox(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Painter vẽ 4 góc khung QR
class _CornerPainter extends CustomPainter {
  final Color color;

  const _CornerPainter({this.color = Colors.green});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    const cornerSize = 30.0;

    // Góc trên bên trái
    canvas.drawLine(Offset(0, 0), Offset(cornerSize, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerSize), paint);

    // Góc trên bên phải
    canvas.drawLine(Offset(size.width - cornerSize, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize), paint);

    // Góc dưới bên trái
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerSize), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize, size.height), paint);

    // Góc dưới bên phải
    canvas.drawLine(Offset(size.width, size.height - cornerSize), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width - cornerSize, size.height), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}