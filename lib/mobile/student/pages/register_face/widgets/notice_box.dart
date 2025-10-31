import 'package:flutter/material.dart';

class NoticeBox extends StatelessWidget {
  const NoticeBox({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Tối ưu kích thước cho Samsung Galaxy Note 5
    final double cardPadding = screenWidth * 0.05; // 5% chiều rộng màn hình
    final double iconSize = screenWidth * 0.06; // 6% chiều rộng màn hình
    final double fontSize = screenWidth * 0.035; // 3.5% chiều rộng màn hình
    final double titleFontSize = screenWidth * 0.04; // 4% chiều rộng màn hình
    final double spacing = screenHeight * 0.01; // 1% chiều cao màn hình

    return Card(
      color: Colors.orange.shade50,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded, 
                  color: Colors.orange.shade700,
                  size: iconSize,
                ),
                SizedBox(width: screenWidth * 0.02),
                Text(
                  "Lưu ý",
                  style: TextStyle(
                    fontSize: titleFontSize, 
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),
            _buildNoticeItem("Đảm bảo môi trường có ánh sáng tốt.", fontSize),
            _buildNoticeItem("Nhìn thẳng vào camera trong suốt quá trình.", fontSize),
            _buildNoticeItem("Không đeo kính râm, khẩu trang hoặc mũ.", fontSize),
            _buildNoticeItem("Giữ khuôn mặt trong khung hình.", fontSize),
            _buildNoticeItem("Quá trình sẽ mất khoảng 10 đến 15 giây.", fontSize),
          ],
        ),
      ),
    );
  }

  Widget _buildNoticeItem(String text, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.orange.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.grey.shade700,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
