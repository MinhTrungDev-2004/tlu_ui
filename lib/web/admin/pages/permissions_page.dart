import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({Key? key}) : super(key: key);

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  String? selectedUser;
  String? selectedRole;
  bool isLoading = true;

  List<Map<String, dynamic>> users = [];
  List<String> roles = [];
  Map<String, List<String>> rolePermissions = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadDataFromFirebase();
  }

  Future<void> _loadDataFromFirebase() async {
    try {
      // Lấy danh sách users từ Firebase
      final usersSnapshot = await _firestore.collection('users').get();
      final List<Map<String, dynamic>> loadedUsers = [];
      
      for (var doc in usersSnapshot.docs) {
        final userData = doc.data();
        loadedUsers.add({
          'id': doc.id,
          'name': userData['name'] ?? 'Chưa có tên',
          'email': userData['email'] ?? '',
          'currentRole': userData['role'] ?? 'Chưa có vai trò',
        });
      }

      // Lấy danh sách roles và permissions từ Firebase
      final rolesSnapshot = await _firestore.collection('roles').get();
      final List<String> loadedRoles = [];
      final Map<String, List<String>> loadedPermissions = {};
      
      for (var doc in rolesSnapshot.docs) {
        final roleData = doc.data();
        final roleName = roleData['name'] ?? doc.id;
        loadedRoles.add(roleName);
        
        // Lấy permissions cho role này
        final permissions = roleData['permissions'] as List<dynamic>?;
        if (permissions != null) {
          loadedPermissions[roleName] = permissions.cast<String>();
        } else {
          loadedPermissions[roleName] = [];
        }
      }

      setState(() {
        users = loadedUsers;
        roles = loadedRoles;
        rolePermissions = loadedPermissions;
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu từ Firebase: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải dữ liệu từ Firebase...'),
            ],
          ),
        ),
      );
    }

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
                    const Text('Thay đổi quyền cho người dùng',
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
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Chọn quyền cụ thể (tùy chọn)',
                              border: OutlineInputBorder(),
                            ),
                            value: null,
                            items: selectedRole != null && rolePermissions[selectedRole] != null
                                ? rolePermissions[selectedRole]!.map((permission) {
                                    return DropdownMenuItem<String>(
                                      value: permission,
                                      child: Text(permission),
                                    );
                                  }).toList()
                                : [],
                            onChanged: (value) {
                              // Có thể mở rộng để thêm/xóa quyền riêng lẻ
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã chọn quyền: $value')),
                              );
                            },
                            hint: const Text('Chọn quyền cụ thể'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: selectedUser != null && selectedRole != null
                              ? _savePermission
                              : null,
                          icon: const Icon(Icons.save),
                          label: const Text('Lưu thay đổi'),
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

          

            // Hiển thị bảng phân quyền
            Expanded(
              child: _buildUserTableView(),
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
                              height: 120,
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: permissions.map((permission) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: true, // Mặc định checked vì đang có quyền
                                            onChanged: (bool? value) {
                                              // TODO: Có thể mở rộng để cho phép bỏ quyền riêng lẻ
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Chức năng bỏ quyền riêng lẻ đang được phát triển'),
                                                ),
                                              );
                                            },
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(child: Text(permission)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
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

  Future<void> _savePermission() async {
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
              onPressed: () async {
                try {
                  // Cập nhật role trong Firebase
                  await _firestore.collection('users').doc(selectedUser).update({
                    'role': selectedRole,
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  // Cập nhật local state
                  setState(() {
                    user['currentRole'] = selectedRole;
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã cập nhật vai trò cho ${user['name']} thành $selectedRole')),
                  );
                  
                  // Reset selection
                  selectedUser = null;
                  selectedRole = null;
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi khi cập nhật vai trò: $e')),
                  );
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );
    }
  }
}
