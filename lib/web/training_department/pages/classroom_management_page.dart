import 'package:flutter/material.dart';

// Định nghĩa các màu sắc chủ đạo để file này có thể chạy độc lập
// Hoặc bạn có thể import file chứa hằng số màu của bạn
const Color kPrimaryBlue = Color(0xFF19325B);

// 1. Data Model cho Phòng học
class Classroom {
  final String id;
  final String name;
  final String building;
  final int capacity;
  final String type;

  Classroom({
    required this.id,
    required this.name,
    required this.building,
    required this.capacity,
    required this.type,
  });
}

// 2. Widget chính của trang
class ClassroomManagementPage extends StatefulWidget {
  const ClassroomManagementPage({super.key});

  @override
  State<ClassroomManagementPage> createState() =>
      _ClassroomManagementPageState();
}

class _ClassroomManagementPageState extends State<ClassroomManagementPage> {
  // 3. Dữ liệu mẫu (mock data)
  late List<Classroom> _classrooms;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu mẫu
    _classrooms = [
      Classroom(
          id: 'P001',
          name: 'Phòng 101-A1',
          building: 'Nhà A1',
          capacity: 100,
          type: 'Lý thuyết'),
      Classroom(
          id: 'P002',
          name: 'Phòng 203-A1',
          building: 'Nhà A1',
          capacity: 80,
          type: 'Lý thuyết'),
      Classroom(
          id: 'P003',
          name: 'Phòng 305-C2',
          building: 'Nhà C2',
          capacity: 60,
          type: 'Thực hành'),
      Classroom(
          id: 'P004',
          name: 'Phòng 401-A4',
          building: 'Nhà A4',
          capacity: 120,
          type: 'Hội trường'),
      Classroom(
          id: 'P005',
          name: 'Phòng 202-C1',
          building: 'Nhà C1',
          capacity: 50,
          type: 'Thực hành'),
    ];
  }

  // 4. Hàm xử lý các hành động (Tạm thời chỉ hiển thị SnackBar)
  void _addClassroom() {
    // Tại đây, bạn có thể hiển thị một Dialog để thêm phòng học mới
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm phòng học...')),
    );
  }

  void _editClassroom(Classroom classroom) {
    // Hiển thị Dialog với dữ liệu của 'classroom' để chỉnh sửa
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng sửa phòng ${classroom.name}...')),
    );
  }

  void _deleteClassroom(Classroom classroom) {
    // Hiển thị Dialog xác nhận trước khi xóa
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng xóa phòng ${classroom.name}...')),
    );
  }

  // 5. Giao diện (Build method)
  @override
  Widget build(BuildContext context) {
    return Container(
      // Dùng màu nền trắng giống MainContent
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
                'Quản lý phòng học',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue, // Dùng màu xanh chủ đạo
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _addClassroom,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm phòng học',
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
              // Bắt buộc phải có SingleChildScrollView cho DataTable
              child: SizedBox(
                width: double.infinity, // Đảm bảo DataTable chiếm hết chiều rộng
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(kPrimaryBlue.withOpacity(0.1)),
                  columns: const [
                    DataColumn(
                        label: Text('Mã phòng',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Tên phòng',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Tòa nhà',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Sức chứa',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Loại phòng',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Hành động',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _classrooms.map((classroom) {
                    // Biến mỗi đối tượng Classroom thành một DataRow
                    return DataRow(
                      cells: [
                        DataCell(Text(classroom.id)),
                        DataCell(Text(classroom.name)),
                        DataCell(Text(classroom.building)),
                        DataCell(Text(classroom.capacity.toString())),
                        DataCell(
                          Chip(
                            label: Text(
                              classroom.type,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: classroom.type == 'Thực hành'
                                ? Colors.orange[100]
                                : Colors.blue[100],
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
                              onPressed: () => _editClassroom(classroom),
                              tooltip: 'Sửa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteClassroom(classroom),
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