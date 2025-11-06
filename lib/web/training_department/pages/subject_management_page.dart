import 'package:flutter/material.dart';


// Bạn có thể import file hằng số màu của bạn
const Color kPrimaryBlue = Color(0xFF19325B);

// 1. Data Model cho Môn học
class Subject {
  final String id;
  final String name;
  final int credits;
  final String department; // Khoa quản lý

  Subject({
    required this.id,
    required this.name,
    required this.credits,
    required this.department,
  });
}

// 2. Widget chính của trang
class SubjectManagementPage extends StatefulWidget {
  const SubjectManagementPage({super.key});

  @override
  State<SubjectManagementPage> createState() => _SubjectManagementPageState();
}

class _SubjectManagementPageState extends State<SubjectManagementPage> {
  // 3. Dữ liệu mẫu (mock data)
  late List<Subject> _subjects;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu mẫu
    _subjects = [
      Subject(
          id: 'IT1110',
          name: 'Tin học đại cương',
          credits: 3,
          department: 'CNTT'),
      Subject(
          id: 'IT3160',
          name: 'Công nghệ phần mềm',
          credits: 3,
          department: 'CNTT'),
      Subject(
          id: 'CE1111',
          name: 'Cơ sở dữ liệu',
          credits: 3,
          department: 'CNTT'),
      Subject(
          id: 'MA1101',
          name: 'Giải tích I',
          credits: 4,
          department: 'Toán ứng dụng'),
      Subject(
          id: 'PE1102',
          name: 'Triết học Mác-Lênin',
          credits: 3,
          department: 'Lý luận chính trị'),
    ];
  }

  // 4. Hàm xử lý các hành động
  void _addSubject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm môn học...')),
    );
  }

  void _editSubject(Subject subject) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng sửa môn ${subject.name}...')),
    );
  }

  void _deleteSubject(Subject subject) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng xóa môn ${subject.name}...')),
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
                'Quản lý môn học',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue, // Dùng màu xanh chủ đạo
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _addSubject,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm môn học',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue, // Dùng màu xanh chủ đạo
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
                        label: Text('Mã môn học',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Tên môn học',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Số tín chỉ',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Khoa quản lý',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Hành động',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _subjects.map((subject) {
                    return DataRow(
                      cells: [
                        DataCell(Text(subject.id)),
                        DataCell(Text(subject.name)),
                        DataCell(Text(subject.credits.toString())),
                        DataCell(Text(subject.department)),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editSubject(subject),
                              tooltip: 'Sửa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSubject(subject),
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