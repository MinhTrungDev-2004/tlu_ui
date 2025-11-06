import 'package:flutter/material.dart';


// Import hằng số màu của bạn
const Color kPrimaryBlue = Color(0xFF19325B);

// 1. Data Model cho Ngành học
class Major {
  final String id; // Mã ngành (ví dụ: 7480201)
  final String name; // Tên ngành
  final String department; // Khoa quản lý
  final double duration; // Thời gian đào tạo (ví dụ: 4.5 năm)

  Major({
    required this.id,
    required this.name,
    required this.department,
    required this.duration,
  });
}

// 2. Widget chính của trang
class MajorManagementPage extends StatefulWidget {
  const MajorManagementPage({super.key});

  @override
  State<MajorManagementPage> createState() => _MajorManagementPageState();
}

class _MajorManagementPageState extends State<MajorManagementPage> {
  // 3. Dữ liệu mẫu (mock data)
  late List<Major> _majors;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu mẫu
    _majors = [
      Major(
        id: '7480201',
        name: 'Công nghệ thông tin',
        department: 'Khoa CNTT',
        duration: 4.5,
      ),
      Major(
        id: '7580201',
        name: 'Kỹ thuật Xây dựng',
        department: 'Khoa CT Xây dựng',
        duration: 4.5,
      ),
      Major(
        id: '7520114',
        name: 'Kỹ thuật Cơ khí',
        department: 'Khoa Cơ khí',
        duration: 4.0,
      ),
      Major(
        id: '7510602',
        name: 'Quản lý tài nguyên nước',
        department: 'Khoa Tài nguyên nước',
        duration: 4.0,
      ),
    ];
  }

  // 4. Hàm xử lý các hành động
  void _addMajor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm ngành học...')),
    );
  }

  void _editMajor(Major major) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng sửa ngành ${major.name}...')),
    );
  }

  void _deleteMajor(Major major) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng xóa ngành ${major.name}...')),
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
                'Quản lý ngành học',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _addMajor,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm ngành học',
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
                        label: Text('Mã ngành',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Tên ngành',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Khoa quản lý',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Thời gian ĐT (năm)',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Hành động',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _majors.map((major) {
                    return DataRow(
                      cells: [
                        DataCell(Text(major.id)),
                        DataCell(Text(major.name)),
                        DataCell(Text(major.department)),
                        DataCell(Text(major.duration.toString())),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editMajor(major),
                              tooltip: 'Sửa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMajor(major),
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