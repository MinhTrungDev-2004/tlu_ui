import 'package:flutter/material.dart';
import '../../navigation/app_router.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar với thanh tìm kiếm
      appBar: _buildAppBar(),

      // 2. Thân (body) của ứng dụng
      body: _buildBody(),

    );
  }

  /// 1. Widget cho AppBar (Thanh tìm kiếm)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0, // Bỏ bóng mờ
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            hintText: 'Tìm kiếm lớp học phần...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none, // Bỏ đường viền
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          ),
        ),
      ),
    );
  }

  /// 2. Widget cho Thân (Body)
  Widget _buildBody() {
    // SingleChildScrollView cho phép cuộn khi nội dung quá dài
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Thêm padding xung quanh
      child: Column(
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildNotificationCard(),
          const SizedBox(height: 20),
          _buildScheduleCard(),
        ],
      ),
    );
  }

  /// 2a. Card Chào mừng (Xin chào, Nguyễn Văn A!)
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue, // Màu nền xanh
        borderRadius: BorderRadius.circular(15.0), // Bo góc
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Xin chào, Nguyễn Văn A!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Chúc bạn ngày làm việc hiệu quả',
                style: TextStyle(
                  color: Colors.white70, // Màu trắng mờ
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Text(
            'Hôm nay\n30/07/2025',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 2b. Card Thông báo mới
  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [ // Thêm bóng mờ nhẹ
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tiêu đề card (Thông báo mới - Xem tất cả)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.notifications_outlined, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'Thông báo mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Nội dung thông báo
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[100], // Nền màu xám nhạt
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông báo thay đổi lịch học',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Lớp lập trình web ngày 25/01 chuyển từ phòng TC-201 sang phòng TC-202',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2c. Card Lịch giảng dạy
  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tiêu đề card (Lịch giảng dạy - Xem tất cả)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_month_outlined, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'Lịch giảng dạy hôm nay',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Chi tiết lớp học
          _buildScheduleItem(),
          const SizedBox(height: 15),
          // Nút "Tạo QR Điểm Danh"
          SizedBox(
            width: double.infinity, // Nút rộng tối đa
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.qrAttendanceRoute);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Nền màu xanh
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Tạo QR Điểm Danh',
                style:
                TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Nút "Còn 5 lớp học nữa"
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],

                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Còn 5 lớp học nữa',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[700]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget con cho chi tiết một lớp học
  Widget _buildScheduleItem() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.menu_book_outlined, color: Colors.grey[600], size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cơ sở dữ liệu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              _buildInfoRow(Icons.access_time_outlined, '07:00 - 09:30   TC-201'),
              const SizedBox(height: 5),
              _buildInfoRow(Icons.person_outline, 'Giảng viên: TS. Nguyễn Văn A'),
              const SizedBox(height: 5),
              _buildInfoRow(Icons.label_outline, 'Chủ đề: Chương 3: Thiết kế CSDL quan hệ'),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget con tái sử dụng cho các dòng thông tin (icon + text)
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

/// 3. Widget cho Bottom Navigation Bar

}