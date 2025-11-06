import 'package:flutter/material.dart';


// Import hằng số màu của bạn
const Color kPrimaryBlue = Color(0xFF19325B);

// 1. Data Model cho Sinh viên
class Student {
  final String id;
  final String name;
  final String className; // Lớp (ví dụ: CNTT-01 K62)
  final String major; // Ngành (ví dụ: Công nghệ thông tin)
  final String email;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.major,
    required this.email,
  });
}

// 2. Widget chính của trang
class StudentManagementPage extends StatefulWidget {
  const StudentManagementPage({super.key});

  @override
  State<StudentManagementPage> createState() => _StudentManagementPageState();
}

class _StudentManagementPageState extends State<StudentManagementPage> {
  // 3. Dữ liệu mẫu (mock data)
  late List<Student> _students;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu mẫu
    _students = [
      Student(
        id: '20010001',
        name: 'Nguyễn Văn An',
        className: 'CNTT-01 K62',
        major: 'Công nghệ thông tin',
        email: 'annv_20010001@thuyloi.edu.vn',
      ),
      Student(
        id: '20020015',
        name: 'Trần Thị Bình',
        className: 'KT-02 K62',
        major: 'Kỹ thuật cơ khí',
        email: 'binhtt_20020015@thuyloi.edu.vn',
      ),
      Student(
        id: '21010030',
        name: 'Lê Văn Cường',
        className: 'XD-01 K63',
        major: 'Kỹ thuật xây dựng',
        email: 'cuonglv_21010030@thuyloi.edu.vn',
      ),
      Student(
        id: '21030005',
        name: 'Phạm Thị Dung',
        className: 'TNN-03 K63',
        major: 'Kỹ thuật tài nguyên nước',
        email: 'dungpt_21030005@thuyloi.edu.vn',
      ),
    ];
  }

  // 4. Hàm xử lý các hành động
  void _addStudent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm sinh viên...')),
    );
  }

  void _editStudent(Student student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng sửa sinh viên ${student.name}...')),
    );
  }

  void _deleteStudent(Student student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng xóa sinh viên ${student.name}...')),
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
                'Quản lý sinh viên',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _addStudent,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm sinh viên',
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
                        label: Text('Mã sinh viên',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Họ và tên',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Lớp',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Ngành',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Email',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Hành động',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _students.map((student) {
                    return DataRow(
                      cells: [
                        DataCell(Text(student.id)),
                        DataCell(Text(student.name)),
                        DataCell(Text(student.className)),
                        DataCell(Text(student.major)),
                        DataCell(Text(student.email)),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editStudent(student),
                              tooltip: 'Sửa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStudent(student),
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