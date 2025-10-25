import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'login_page_web.dart';
import 'login_page_mobile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Dùng Future.delayed thay vì Timer (cách hiện đại hơn)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => kIsWeb 
              ? const LoginPageWeb() 
              : const LoginPageMobile(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F0FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo.png',
              height: 120,
            ),
            const SizedBox(height: 24),
            const Text(
              'TLU Smart Attendance',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF005CFF),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Hệ Thống Điểm Danh Thông Minh',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
            ),

            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005CFF)),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}