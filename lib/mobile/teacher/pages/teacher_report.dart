import 'package:flutter/material.dart';

class TeacherReport extends StatefulWidget {
  const TeacherReport({super.key});

  @override
  // Sửa lại tên State cho nhất quán
  State<TeacherReport> createState() => _TeacherReportState();
}

// Sửa lại tên State cho nhất quán
class _TeacherReportState extends State<TeacherReport> {
  // Biến để lưu giá trị dropdown đang chọn
  String? _selectedCourse = 'Lập trình ứng dụng di động - 64KTPM3';

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
      automaticallyImplyLeading: false,
      title: const Text(
        'Báo cáo và thống kê',
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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Phần nội dung (Dropdown và danh sách)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Dropdown chọn lớp
                  _buildCourseSelector(),
                  const SizedBox(height: 24),
                  // 2. Danh sách buổi điểm danh
                  _buildAttendanceList(),
                ],
              ),
            ),
          ),
          // 3. Nút "Xuất báo cáo" (Luôn ở dưới cùng)
          const SizedBox(height: 16),
          _buildExportButton(),
        ],
      ),
    );
  }

  /// 2a. Widget cho Dropdown chọn lớp
  Widget _buildCourseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn lớp học phần',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        // Bọc Dropdown trong Card để có nền trắng và bo góc
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            // Dùng DropdownButtonFormField để có style chuẩn
            child: DropdownButtonFormField<String>(
              initialValue: _selectedCourse,
              decoration: const InputDecoration(
                border: InputBorder.none, // Ẩn đường viền bên trong
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCourse = newValue;
                });
              },
              items: <String>[
                'Lập trình ứng dụng di động - 64KTPM3',
                'Cơ sở dữ liệu - 64KTPM1',
                'Mạng máy tính - 64KTPM2'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// 2b. Widget cho danh sách các buổi điểm danh
  Widget _buildAttendanceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi tiết các buổi điểm danh',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        // Danh sách các buổi
        _buildSessionCard('Buổi 1 - 29/9/2025', 'Có mặt: 60, Vắng: 4'),
        const SizedBox(height: 12),
        _buildSessionCard('Buổi 2 - 30/9/2025', 'Có mặt: 60, Vắng: 4'),
        const SizedBox(height: 12),
        _buildSessionCard('Buổi 3 - 1/10/2025', 'Có mặt: 60, Vắng: 4'),
      ],
    );
  }

  /// 2c. Widget con cho từng Card buổi học
  Widget _buildSessionCard(String title, String subtitle) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () {
          // Thêm logic khi nhấn vào xem chi tiết 1 buổi
        },
      ),
    );
  }

  /// 2d. Widget cho nút "Xuất báo cáo"
  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Xuất báo cáo'),
      ),
    );
  }
}