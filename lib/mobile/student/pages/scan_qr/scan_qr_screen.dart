import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'widgets/class_info_screen.dart';

class QRScanScreen extends StatefulWidget {
  const QRScanScreen({super.key});

  @override
  State<QRScanScreen> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  MobileScannerController? controller;
  bool _isScanning = true;
  bool _navigated = false;
  String? _scannedData;
  bool _flashOn = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRDetected(BarcodeCapture capture) {
    if (!_navigated && capture.barcodes.isNotEmpty) {
      final String? code = capture.barcodes.first.rawValue;
      setState(() {
        _scannedData = code;
        _navigated = true;
        _isScanning = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ClassInfoScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final appBarHeight = isTablet ? 120.0 : 100.0;
    final cutOut = screenSize.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, appBarHeight),
        child: Container(
          height: appBarHeight,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1470E2), Color(0xFF0D5BB8)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quét QR Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Camera scanner
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
              child: const Text(
                'Đặt mã QR trong khung để quét',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // ✅ Nút hủy duy nhất, căn giữa
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
      child: Container(
        width: screenSize.width,
        height: overlayHeight,
        child: Stack(
          children: [
            Container(color: Colors.black54),
            Center(
              child: Container(
                width: cutOut,
                height: cutOut,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomPaint(
                  painter: _CornerPainter(),
                ),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    const cornerSize = 30.0;

    // 4 góc
    canvas.drawLine(Offset(0, 0), Offset(cornerSize, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerSize), paint);

    canvas.drawLine(Offset(size.width - cornerSize, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize), paint);

    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerSize), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize, size.height), paint);

    canvas.drawLine(Offset(size.width, size.height - cornerSize), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width - cornerSize, size.height), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
