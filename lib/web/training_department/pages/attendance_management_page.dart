import 'package:flutter/material.dart';

// Import hằng số màu của bạn
const Color kPrimaryBlue = Color(0xFF19325B);

// 1. Data Model cho một Lớp học đã diễn ra
class ClassSessionSummary {
  final String subjectName;
  final String className;
  final String lecturerName;
  final String department; // Khoa
  final String major; // Ngành
  final DateTime date;
  final int totalStudents;
  final int presentCount;

  ClassSessionSummary({
    required this.subjectName,
    required this.className,
    required this.lecturerName,
    required this.department,
    required this.major,
    required this.date,
    required this.totalStudents,
    required this.presentCount,
  });

  int get absentCount => totalStudents - presentCount;
  double get attendanceRate => presentCount / totalStudents;
}

// 2. Widget chính của trang
class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({super.key});

  @override
  State<AttendanceManagementPage> createState() =>
      _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  // 3. Dữ liệu mẫu (mock data)
  final List<ClassSessionSummary> _allSessions = [
    ClassSessionSummary(
      subjectName: 'Công nghệ phần mềm',
      className: 'CNTT-01 K62',
      lecturerName: 'TS. Trần Thị B',
      department: 'Công nghệ thông tin',
      major: 'Công nghệ thông tin',
      date: DateTime(2025, 10, 28, 7, 30),
      totalStudents: 52,
      presentCount: 50,
    ),
    ClassSessionSummary(
      subjectName: 'Cơ sở dữ liệu',
      className: 'CNTT-02 K62',
      lecturerName: 'ThS. Nguyễn Văn A',
      department: 'Công nghệ thông tin',
      major: 'Công nghệ thông tin',
      date: DateTime(2025, 10, 28, 9, 30),
      totalStudents: 55,
      presentCount: 48,
    ),
    ClassSessionSummary(
      subjectName: 'Kết cấu thép',
      className: 'XD-01 K61',
      lecturerName: 'PGS. TS. XYZ',
      department: 'Kỹ thuật Xây dựng',
      major: 'Kỹ thuật Xây dựng',
      date: DateTime(2025, 10, 27, 13, 30),
      totalStudents: 48,
      presentCount: 48,
    ),
    ClassSessionSummary(
      subjectName: 'Cơ lý thuyết',
      className: 'KT-01 K63',
      lecturerName: 'ThS. Lê Văn D',
      department: 'Cơ khí',
      major: 'Kỹ thuật Cơ khí',
      date: DateTime(2025, 10, 27, 15, 30),
      totalStudents: 60,
      presentCount: 51,
    ),
  ];

  // Biến cho các bộ lọc
  String? _selectedDepartment; // Lọc theo Khoa
  String? _selectedClass; // Lọc theo Lớp
  DateTime? _selectedDate;

  // 4. Hàm xử lý các hành động
  void _viewDetails(ClassSessionSummary session) {
    // Trong ứng dụng thật, bạn sẽ mở một Dialog hoặc trang mới
    // để hiển thị danh sách sinh viên của buổi học này.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Xem chi tiết điểm danh lớp ${session.className} - Môn ${session.subjectName}')),
    );
  }

  void _filterResults() {
    // Logic lọc... (hiện tại chỉ hiển thị thông báo)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đang lọc kết quả...')),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 5. Giao diện (Build method)
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- Hàng Tiêu đề ---
          Text(
            'Quản lý điểm danh',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kPrimaryBlue,
                ),
          ),
          const SizedBox(height: 20),

          // --- Khu vực Bộ lọc ---
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Lọc theo Khoa
                _buildFilterDropdown(
                  hint: 'Chọn khoa',
                  value: _selectedDepartment,
                  items: ['Công nghệ thông tin', 'Kỹ thuật Xây dựng', 'Cơ khí'],
                  onChanged: (val) {
                    setState(() => _selectedDepartment = val);
                  },
                ),
                const SizedBox(width: 20),
                // Lọc theo Lớp
                _buildFilterDropdown(
                  hint: 'Chọn lớp',
                  value: _selectedClass,
                  items: ['CNTT-01 K62', 'XD-01 K61', 'KT-01 K63'],
                  onChanged: (val) {
                    setState(() => _selectedClass = val);
                  },
                ),
                const SizedBox(width: 20),
                // Lọc theo Ngày
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chọn ngày',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _pickDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_selectedDate == null
                          ? 'Chọn ngày'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        foregroundColor: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Nút Lọc
                ElevatedButton.icon(
                  onPressed: _filterResults,
                  icon: const Icon(Icons.filter_alt, color: Colors.white),
                  label: const Text('Lọc kết quả',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // --- Bảng Dữ liệu Kết quả ---
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(kPrimaryBlue.withOpacity(0.1)),
                  columns: const [
                    DataColumn(
                        label: Text('Môn học',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Lớp',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Giảng viên',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Khoa',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Ngành',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Tỉ lệ chuyên cần',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Chi tiết',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _allSessions.map((session) {
                    return DataRow(
                      cells: [
                        DataCell(Text(session.subjectName)),
                        DataCell(Text(session.className)),
                        DataCell(Text(session.lecturerName)),
                        DataCell(Text(session.department)),
                        DataCell(Text(session.major)),
                        DataCell(
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${session.presentCount}/${session.totalStudents} (${(session.attendanceRate * 100).toStringAsFixed(0)}%)'),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: session.attendanceRate,
                                backgroundColor: Colors.red[100],
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.green),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ],
                          ),
                        ),
                        DataCell(IconButton(
                          icon: const Icon(Icons.arrow_forward_ios,
                              size: 16, color: kPrimaryBlue),
                          onPressed: () => _viewDetails(session),
                          tooltip: 'Xem chi tiết',
                        )),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget con cho Dropdown
  Widget _buildFilterDropdown({
    required String hint,
    String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hint,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: const TextStyle(color: Colors.grey)),
              isExpanded: false,
              items: items.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}