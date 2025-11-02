import 'package:flutter/material.dart';
import 'cammera_attendance_screen.dart'; // import trang điểm danh khuôn mặt

class ClassInfoScreen extends StatelessWidget {
  const ClassInfoScreen({super.key});

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
                  'Thông tin buổi học',
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thông tin lớp học
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Môn học: Android 9-2025   CSE441',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person, size: 20, color: Colors.black54),
                        SizedBox(width: 6),
                        Text('Kiều Tuấn Dũng'),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                        SizedBox(width: 6),
                        Text('Thứ ba, 15 tháng 9, 2025'),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 20, color: Colors.black54),
                        SizedBox(width: 6),
                        Text('07:10 - 09:40'),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text('Số buổi: 5'),
                    SizedBox(height: 8),
                    Text(
                      'Ghi chú: Mã QR có hiệu lực trong 15 phút',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Nút Điểm danh
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FaceAttendanceScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Điểm danh'),
            ),
            const SizedBox(height: 10),

            // Nút Quét lại QR
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Quét lại QR'),
            ),
          ],
        ),
      ),
    );
  }
}
