import 'package:flutter/material.dart';

// Import hằng số màu của bạn
const Color kPrimaryBlue = Color(0xFF19325B);

// 1. Data Model cho Khoa
class Department {
  final String id; // Mã khoa, ví dụ: CNTT
  final String name; // Tên khoa
  final String dean; // Trưởng khoa
  final String office; // Văn phòng khoa

  Department({
    required this.id,
    required this.name,
    required this.dean,
    required this.office,
  });
}

// 2. Widget chính của trang
class DepartmentManagementPage extends StatefulWidget {
  const DepartmentManagementPage({super.key});

  @override
  State<DepartmentManagementPage> createState() =>
      _DepartmentManagementPageState();
}

class _DepartmentManagementPageState extends State<DepartmentManagementPage> {
  // 3. Dữ liệu mẫu (mock data)
  late List<Department> _departments;

  @override
  void initState() {
    super.initState();
    // Khởi tạo dữ liệu mẫu
    _departments = [
      Department(
        id: 'CNTT',
        name: 'Khoa Công nghệ thông tin',
        dean: 'GS. TSKH. ABC',
        office: 'P.201 - Nhà C1',
      ),
      Department(
        id: 'XD',
        name: 'Khoa Kỹ thuật Xây dựng',
        dean: 'PGS. TS. XYZ',
        office: 'P.101 - Nhà A1',
      ),
      Department(
        id: 'CK',
        name: 'Khoa Cơ khí',
        dean: 'TS. Nguyễn Văn B',
        office: 'P.305 - Nhà C2',
      ),
      Department(
        id: 'TNN',
        name: 'Khoa Tài nguyên nước',
        dean: 'PGS. TS. Trần Thị D',
        office: 'P.105 - Nhà A4',
      ),
    ];
  }

  // 4. Hàm xử lý các hành động
  void _addDepartment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thêm khoa...')),
    );
  }

  void _editDepartment(Department department) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng sửa khoa ${department.name}...')),
    );
  }

  void _deleteDepartment(Department department) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chức năng xóa khoa ${department.name}...')),
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
                'Quản lý khoa',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _addDepartment,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm khoa',
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
                        label: Text('Mã khoa',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Tên khoa',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Trưởng khoa',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Văn phòng',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Hành động',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _departments.map((dept) {
                    return DataRow(
                      cells: [
                        DataCell(Text(dept.id)),
                        DataCell(Text(dept.name)),
                        DataCell(Text(dept.dean)),
                        DataCell(Text(dept.office)),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editDepartment(dept),
                              tooltip: 'Sửa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDepartment(dept),
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