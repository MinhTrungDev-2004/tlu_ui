import 'package:flutter/material.dart';

class TeacherSchedule extends StatefulWidget {
  const TeacherSchedule({super.key});

  @override
  State<TeacherSchedule> createState() => _TeacherScheduleState();
}

class _TeacherScheduleState extends State<TeacherSchedule> {

  @override
  Widget build(BuildContext context) {
    // DefaultTabController bao bọc Scaffold để quản lý TabBar
    return DefaultTabController(
      length: 3, // Có 3 tab
      child: Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody()
      ),
    );
  }

  /// 1. Widget cho AppBar (Header xanh và TabBar)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      // Tự động ẩn nút "Back" nếu màn hình này là màn hình chính
      automaticallyImplyLeading: false,
      bottom: TabBar(
        indicatorColor: Colors.yellow, // Màu của vạch chân
        indicatorWeight: 3.0,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white.withValues(alpha: 0.8),
        tabs: const [
          Tab(text: 'Hôm nay'),
          Tab(text: 'Lịch dạy'),
          Tab(text: 'Tải lịch'),
        ],
      ),
    );
  }

  /// 2. Widget cho Thân (Body) - Chứa nội dung của 3 Tab
  Widget _buildBody() {
    return TabBarView(
      children: [
        // Nội dung cho Tab "Hôm nay"
        _buildTodayTab(),
        // Nội dung placeholder cho 2 tab còn lại
        const Center(child: Text('Nội dung Lịch Dạy')),
        const Center(child: Text('Nội dung Tải Lịch')),
      ],
    );
  }

  /// 2a. Nội dung cho Tab "Hôm nay"
  Widget _buildTodayTab() {
    return Container(
      color: const Color(0xFFF4F6F8), // Màu nền xám nhạt
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            // Ngày tháng
            Text(
              'Thứ 6, Ngày 26/9/2025',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            // Card lớp học 1
            _buildClassCard(
              title: 'Lập trình ứng dụng di động',
              className: '64KTPM3',
              time: '07:00 - 09:00',
              room: '207-B5',
              statusLines: ['Trạng thái: Đã đóng', 'Chưa điểm danh'],
              barColor: Colors.green, // Màu thanh bên trái
            ),
            const SizedBox(height: 16),
            // Card lớp học 2
            _buildClassCard(
              title: 'Lập trình ứng dụng di động',
              className: '64KTPM3',
              time: '07:00 - 09:00',
              room: '207-B5',
              statusLines: ['Trạng thái: Đã đóng', 'Chưa điểm danh'],
              barColor: Colors.blue, // Màu thanh bên trái
            ),
          ],
        ),
      ),
    );
  }

  /// 2b. Widget tái sử dụng cho Card Lớp học
  Widget _buildClassCard({
    required String title,
    required String className,
    required String time,
    required String room,
    required List<String> statusLines,
    required Color barColor,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge, // Để bo góc thanh màu
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh màu bên trái
            Container(width: 8, color: barColor),
            // Nội dung bên phải
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng 1: Tiêu đề và Giờ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildIconTextRow(
                          Icons.access_time_outlined,
                          time,
                          Colors.grey.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Dòng 2: Lớp
                    Text(
                      'Lớp: $className',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Dòng 3: Phòng
                    _buildIconTextRow(
                      Icons.location_on_outlined,
                      room,
                      Colors.grey.shade600,
                    ),
                    const SizedBox(height: 12),
                    // Dòng 4: Trạng thái và Nút
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Cột trạng thái
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: statusLines
                              .map((line) => Text(
                            line,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ))
                              .toList(),
                        ),
                        // Nút Tạo QR
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Tạo QR'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget con cho (Icon + Text)
  Widget _buildIconTextRow(IconData icon, String text, Color? color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }


}