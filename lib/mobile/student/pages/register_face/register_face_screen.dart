import 'package:flutter/material.dart';
import 'widgets/face_card.dart';
import 'widgets/notice_box.dart';
import 'widgets/main_appbar.dart'; // ✅ import AppBar dùng chung

class RegisterFaceScreen extends StatelessWidget {
  final String? userId;

  const RegisterFaceScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final double horizontalPadding = screenWidth * 0.05;
    final double verticalPadding = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // ✅ Dùng AppBar chung
      appBar: buildMainAppBar(
        context: context,
        title: 'Đăng ký khuôn mặt',
        showBack: true,
      ),

      // --- Nội dung thân trang ---
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            children: [
              // Thẻ hiển thị khuôn mặt
              SizedBox(
                width: screenWidth,
                child: FaceCard(userId: userId),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Hộp thông báo
              SizedBox(
                width: screenWidth,
                child: NoticeBox(),
              ),

              // Khoảng trống phía cuối
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
