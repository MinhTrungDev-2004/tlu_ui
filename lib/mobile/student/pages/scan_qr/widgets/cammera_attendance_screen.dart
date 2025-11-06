import 'dart:async';
import 'package:flutter/material.dart';
import '../../home_page/home_screen.dart';


class FaceAttendanceScreen extends StatefulWidget {
  const FaceAttendanceScreen({super.key});

  @override
  State<FaceAttendanceScreen> createState() => _FaceAttendanceScreenState();
}

class _FaceAttendanceScreenState extends State<FaceAttendanceScreen> {
  int _state = 0; // 0: chờ, 1: không xác định, 2: nhận diện đúng
  String _processText = 'Đang tiến hành nhận diện 2s . . .';

  @override
  void initState() {
    super.initState();
    _simulateRecognition();
  }

  void _simulateRecognition() {
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _state = 2;
      });

      if (_state == 2) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted){
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = 100;
    final double appBarWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: Size(appBarWidth, appBarHeight),
        child: Container(
          height: appBarHeight,
          decoration: const BoxDecoration(
            color: Color(0xFF1470E2),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Điểm danh',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // --- Nội dung chính ---
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 👉 canh giữa dọc
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Điểm danh bằng khuôn mặt',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // --- Khung camera ---x
              Container(
                width: 309,
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 245,
                      height: 340,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _state == 0
                              ? const Color.fromARGB(255, 85, 247, 169)
                              : _state == 1
                                  ? Colors.redAccent
                                  : const Color.fromARGB(255, 85, 247, 169),
                          width: 2,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(120, 160),
                        ),
                      ),
                    ),
                    if (_state == 0)
                      const Text(
                        'Đưa mặt vào khung camera',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      )
                    else if (_state == 1)
                      const Text(
                        'Khuôn mặt không xác định\nVui lòng thử lại',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.redAccent, fontSize: 14),
                      )
                    else if (_state == 2)
                      ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(110, 150),
                        ),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=800&auto=format&fit=crop&q=60',
                          width: 220,
                          height: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Thông tin sinh viên ---
              Column(
                children: const [
                  Text(
                    'Thông tin sinh viên',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('Họ tên: Lê Đức Chiến'),
                  Text('Lớp: 64KTPM3'),
                  Text('MSV: 2251172253'),
                ],
              ),

              const SizedBox(height: 18),

              // --- Dòng trạng thái ---
              Text(
                _processText,
                style: const TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
