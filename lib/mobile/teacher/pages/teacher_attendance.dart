import 'package:flutter/material.dart';

class TeacherAttendance extends StatelessWidget {
  final VoidCallback? onShowQR;
  
  const TeacherAttendance({super.key, this.onShowQR});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      // Chú ý: KHÔNG có bottomNavigationBar ở đây
    );
  }

  /// 1. Widget cho AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      // Ẩn nút "Back" vì đây là 1 tab chính
      automaticallyImplyLeading: false,
      title: const Text(
        'Chọn lớp điểm danh',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 2. Widget cho Thân (Body)
  Widget _buildBody() {
    return Container(
      color: const Color(0xFFF4F6F8), // Màu nền xám nhạt
      child: SingleChildScrollView(
        // Thêm padding cho toàn bộ body
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            // Bộ chọn ngày (Hôm nay, Thứ 6...)
            _buildDatePicker(),
            const SizedBox(height: 20),

            // Card lớp học (Tái sử dụng)
            _buildClassCard(
              title: 'Lập trình ứng dụng di động',
              className: '64KTPM3',
              time: '07:00 - 09:00',
              room: '207-B5',
              statusLines: ['Trạng thái: Đã đóng', 'Chưa điểm danh'],
              barColor: Colors.blue, // Màu thanh bên trái
            ),
            // Bạn có thể thêm các card khác ở đây
          ],
        ),
      ),
    );
  }

  /// 3. Widget cho Bộ chọn ngày
  Widget _buildDatePicker() {
    return Card(
      elevation: 1, // Bóng mờ nhẹ
      shadowColor: Colors.grey.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Nút lùi ngày
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () { /* Thêm logic lùi ngày */ },
            ),
            // Cụm văn bản
            Column(
              children: [
                const Text(
                  'Hôm nay',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Thứ 6, 26/09/2025',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            // Nút tiến ngày
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              onPressed: () { /* Thêm logic tiến ngày */ },
            ),
          ],
        ),
      ),
    );
  }

  /* * PHẦN TÁI SỬ DỤNG
   * Mình copy code từ file teacher_schedule.dart
   * * LƯU Ý: Cách tốt nhất là bạn nên tách 2 hàm
   * (_buildClassCard và _buildIconTextRow)
   * ra một file widget dùng chung (ví dụ: class_card.dart)
   * rồi import vào cả 2 màn hình.
  */

  /// 4. Widget tái sử dụng cho Card Lớp học
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
                         Builder(
                           builder: (context) => ElevatedButton(
                             onPressed: onShowQR,
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

  /// 5. Widget con cho (Icon + Text)
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