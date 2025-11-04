import 'package:flutter/material.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({Key? key}) : super(key: key);

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  String? selectedUser;
  String? selectedRole;
  bool showTreeView = false;

  final List<Map<String, dynamic>> users = [
    {'id': 1, 'name': 'Nguyễn Văn A', 'email': 'nguyenvana@tlu.edu.vn', 'currentRole': 'Admin'},
    {'id': 2, 'name': 'Trần Thị B', 'email': 'tranthib@tlu.edu.vn', 'currentRole': 'Giảng viên'},
    {'id': 3, 'name': 'Lê Văn C', 'email': 'levanc@tlu.edu.vn', 'currentRole': 'Phòng đào tạo'},
    {'id': 4, 'name': 'Phạm Thị D', 'email': 'phamthid@tlu.edu.vn', 'currentRole': 'Giảng viên'},
    {'id': 5, 'name': 'Hoàng Văn E', 'email': 'hoangvane@tlu.edu.vn', 'currentRole': 'Giám sát'},
  ];

  final List<String> roles = [
    'Admin',
    'Giảng viên',
    'Phòng đào tạo',
    'Quản lý khoa',
    'Giám sát',
  ];

  final Map<String, List<String>> rolePermissions = {
    'Admin': [
      'Quản lý người dùng',
      'Phân quyền hệ thống',
      'Cấu hình hệ thống',
      'Xem thống kê',
      'Backup dữ liệu',
      'Quản lý log',
    ],
    'Giảng viên': [
      'Xem danh sách sinh viên',
      'Điểm danh',
      'Xem báo cáo lớp',
      'Cập nhật thông tin cá nhân',
    ],
    'Phòng đào tạo': [
      'Quản lý chương trình đào tạo',
      'Xem và phê duyệt lịch học',
      'Quản lý điểm và kết quả học tập',
      'Thống kê và báo cáo toàn trường',
    ],
    'Quản lý khoa': [
      'Quản lý giảng viên khoa',
      'Xem thống kê khoa',
      'Quản lý lớp học',
      'Phê duyệt đơn từ',
    ],
    'Giám sát': [
      'Theo dõi hoạt động giảng dạy',
      'Giám sát điểm danh',
      'Đánh giá chất lượng lớp học',
      'Báo cáo vi phạm hoặc sự cố',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân quyền người dùng',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Khu vực chọn người dùng và vai trò
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cấu hình quyền cho người dùng',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Chọn người dùng',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedUser,
                            items: users.map((user) {
                              return DropdownMenuItem<String>(
                                value: user['id'].toString(),
                                child: Text('${user['name']} (${user['currentRole']})'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedUser = value;
                                selectedRole = null;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Chọn vai trò mới',
                              border: OutlineInputBorder(),
                            ),
                            value: selectedRole,
                            items: roles.map((role) {
                              return DropdownMenuItem<String>(
                                value: role,
                                child: Text(role),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: selectedUser != null && selectedRole != null
                              ? _savePermission
                              : null,
                          icon: const Icon(Icons.save),
                          label: const Text('Lưu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chọn chế độ xem
            Row(
              children: [
                const Text('Xem quyền theo:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('Bảng'),
                  selected: !showTreeView,
                  onSelected: (selected) => setState(() => showTreeView = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Sơ đồ cây'),
                  selected: showTreeView,
                  onSelected: (selected) => setState(() => showTreeView = true),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hiển thị bảng hoặc cây
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    return _buildTreeView();
                  } else {
                    return showTreeView ? _buildTreeView() : _buildUserTableView();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 BẢNG PHÂN QUYỀN THEO NGƯỜI DÙNG
  Widget _buildUserTableView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Danh sách người dùng và quyền',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: 30,
                    headingRowHeight: 56,
                    dataRowHeight: 72,
                    columns: const [
                      DataColumn(label: Text('Họ tên', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Vai trò', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Quyền', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: users.map((user) {
                      final role = user['currentRole'];
                      final permissions = rolePermissions[role] ?? ['(Chưa có quyền)'];
                      return DataRow(
                        cells: [
                          DataCell(Text(user['name'])),
                          DataCell(Text(user['email'])),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getRoleColor(role).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getRoleColor(role)),
                              ),
                              child: Text(role, style: TextStyle(color: _getRoleColor(role))),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              height: 80, // 👈 cố định chiều cao
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: permissions.map((p) => Text("• $p")).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Sơ đồ cây quyền
  Widget _buildTreeView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sơ đồ phân quyền dạng cây', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: rolePermissions.entries.map((entry) {
                    return _buildRoleTree(entry.key, entry.value);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTree(String role, List<String> permissions) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(Icons.admin_panel_settings, color: _getRoleColor(role)),
        title: Text(role,
            style: TextStyle(fontWeight: FontWeight.bold, color: _getRoleColor(role), fontSize: 16)),
        children: permissions
            .map((permission) => ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
          title: Text(permission),
          dense: true,
        ))
            .toList(),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.purple;
      case 'Giảng viên':
        return Colors.blue;
      case 'Phòng đào tạo':
        return Colors.green;
      case 'Quản lý khoa':
        return Colors.orange;
      case 'Giám sát':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _savePermission() {
    if (selectedUser != null && selectedRole != null) {
      final user = users.firstWhere((u) => u['id'].toString() == selectedUser);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận thay đổi quyền'),
          content: Text(
            'Bạn có chắc chắn muốn thay đổi vai trò của ${user['name']} từ ${user['currentRole']} thành $selectedRole?',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  user['currentRole'] = selectedRole;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã cập nhật vai trò cho ${user['name']} thành $selectedRole')),
                );
                selectedUser = null;
                selectedRole = null;
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
    }
  }
}
