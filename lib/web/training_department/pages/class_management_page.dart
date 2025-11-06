import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF19325B);

// 1. Data Model cho Lớp học (Lớp sinh hoạt)
class StudentClass {
  final String id; // Mã lớp, ví dụ: CNTT-01 K62
  final String major; // Ngành học
  final String headTeacher; // Giảng viên chủ nhiệm
  final int studentCount; // Sĩ số
  final String cohort; // Khóa (ví dụ: K62)

  StudentClass({
    required this.id,
    required this.major,
    required this.headTeacher,
    required this.studentCount,
    required this.cohort,
  });
}

// 2. Widget chính của trang
class ClassManagementPage extends StatefulWidget {
  const ClassManagementPage({super.key});

  @override
  State<ClassManagementPage> createState() => _ClassManagementPageState();
}

class _ClassManagementPageState extends State<ClassManagementPage> {
  // 3. Dữ liệu mẫu (mock data)
  late List<StudentClass> _classes;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu mẫu
    _classes = [
      StudentClass(
        id: 'CNTT-01 K62',
        major: 'Công nghệ thông tin',
        headTeacher: 'ThS. Nguyễn Văn A',
        studentCount: 55,
        cohort: 'K62',
      ),
      StudentClass(
        id: 'CNTT-02 K62',
        major: 'Công nghệ thông tin',
        headTeacher: 'TS. Trần Thị B',
        studentCount: 52,
        cohort: 'K62',
      ),
      StudentClass(
        id: 'KT-01 K63',
        major: 'Kỹ thuật cơ khí',
        headTeacher: 'ThS. Lê Văn D',
        studentCount: 60,
        cohort: 'K63',
      ),
      StudentClass(
        id: 'XD-01 K61',
        major: 'Kỹ thuật xây dựng',
        headTeacher: 'TS. Phạm Thị E',
        studentCount: 48,
        cohort: 'K61',
      ),
    ];
  }

  // 4. Hàm xử lý các hành động
  void _addClass() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm lớp học...')),
    );
  }

  void _editClass(StudentClass studentClass) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng sửa lớp ${studentClass.id}...')),
    );
  }

  void _deleteClass(StudentClass studentClass) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng xóa lớp ${studentClass.id}...')),
    );
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
          // --- Hàng Tiêu đề và Nút "Thêm mới" ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý lớp học',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _addClass,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm lớp học',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Bảng Dữ liệu (DataTable) ---
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(kPrimaryBlue.withOpacity(0.1)),
                  columns: const [
                    DataColumn(
                        label: Text('Mã lớp',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Ngành',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('GVCN',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Sĩ số',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Khóa',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Hành động',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _classes.map((cls) {
                    return DataRow(
                      cells: [
                        DataCell(Text(cls.id)),
                        DataCell(Text(cls.major)),
                        DataCell(Text(cls.headTeacher)),
                        DataCell(Text(cls.studentCount.toString())),
                        DataCell(
                          Chip(
                            label: Text(
                              cls.cohort,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                          ),
                        ),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editClass(cls),
                              tooltip: 'Sửa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteClass(cls),
                              tooltip: 'Xóa',
                            ),
                          ],
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
}