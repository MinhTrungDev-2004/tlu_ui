import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_uesr_page.dart';
import 'edit_user_page.dart';
import 'dart:html' as html;

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String searchQuery = '';
  String selectedRole = 'Tất cả';

  // Hàm import CSV chỉ cho Firebase Auth
  Future<void> _importUsersFromCsv() async {
    final uploadInput = html.FileUploadInputElement()..accept = '.csv';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) return;

      final file = files.first;
      final reader = html.FileReader();
      reader.readAsText(file);

      await reader.onLoad.first;
      final content = reader.result as String;
      final lines = content.split(RegExp(r'\r?\n')).where((l) => l.trim().isNotEmpty).toList();

      if (lines.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File CSV trống')),
          );
        }
        return;
      }

      final header = lines.first.split(',').map((s) => s.trim().toLowerCase()).toList();
      if (header.length < 3 || header[0] != 'email' || header[1] != 'password' || header[2] != 'name') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Định dạng CSV: email,password,name')),
          );
        }
        return;
      }

      int success = 0;
      int failed = 0;
      List<String> errorMessages = [];

      // Hiển thị loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                SizedBox(width: 16),
                Text('Đang xử lý CSV...'),
              ],
            ),
            duration: Duration(minutes: 5),
          ),
        );
      }

      for (var i = 1; i < lines.length; i++) {
        final cols = lines[i].split(',').map((s) => s.trim()).toList();
        if (cols.length < 3) {
          failed++;
          errorMessages.add('Dòng ${i + 1}: Thiếu thông tin');
          continue;
        }

        final email = cols[0];
        final password = cols[1];
        final name = cols[2];

        try {
          // Chỉ tạo user trong Firebase Authentication
          await _auth.createUserWithEmailAndPassword(
              email: email,
              password: password
          );
          success++;

          print('✅ Đã tạo tài khoản: $email');

        } on FirebaseAuthException catch (e) {
          failed++;
          String errorMsg = 'Dòng ${i + 1} ($email): ';

          switch (e.code) {
            case 'email-already-in-use':
              errorMsg += 'Email đã được sử dụng';
              break;
            case 'invalid-email':
              errorMsg += 'Email không hợp lệ';
              break;
            case 'weak-password':
              errorMsg += 'Mật khẩu quá yếu';
              break;
            case 'operation-not-allowed':
              errorMsg += 'Phương thức đăng ký không được cho phép';
              break;
            default:
              errorMsg += 'Lỗi: ${e.message}';
          }

          errorMessages.add(errorMsg);
          print('❌ Lỗi tạo user $email: ${e.code}');
        } catch (e) {
          failed++;
          errorMessages.add('Dòng ${i + 1} ($email): Lỗi không xác định: $e');
          print('❌ Lỗi không xác định với user $email: $e');
        }
      }

      // Ẩn snackbar loading và hiển thị kết quả
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Thành công: $success | ❌ Thất bại: $failed'),
            backgroundColor: failed == 0 ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );

        // Hiển thị chi tiết lỗi nếu có
        if (errorMessages.isNotEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Chi tiết lỗi'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: errorMessages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.error, color: Colors.red, size: 16),
                      title: Text(
                        errorMessages[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth < 600 ? 16 : 24,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quản lý người dùng',
                  style: TextStyle(
                    fontSize: screenWidth < 600 ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    // Nút Nhập CSV - SỬA THÀNH _importUsersFromCsv
                    ElevatedButton.icon(
                      onPressed: _importUsersFromCsv,
                      icon: const Icon(Icons.file_upload),
                      label: Text(
                        'Nhập CSV',
                        style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 600 ? 16 : 20,
                          vertical: screenWidth < 600 ? 10 : 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Nút Thêm người dùng
                    ElevatedButton.icon(
                      onPressed: _showAddUserPopup,
                      icon: const Icon(Icons.add),
                      label: Text(
                        'Thêm người dùng',
                        style: TextStyle(fontSize: screenWidth < 600 ? 14 : 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 600 ? 16 : 20,
                          vertical: screenWidth < 600 ? 10 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search and Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildSearchFilter(screenWidth),
              ),
            ),
            const SizedBox(height: 16),

            // Users Table from Firestore
            Expanded(
              child: Card(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Danh sách người dùng',
                        style: TextStyle(
                          fontSize: screenWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('users').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Lỗi: ${snapshot.error}'));
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                  SizedBox(height: 16),
                                  Text('Chưa có người dùng nào', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                ],
                              ),
                            );
                          }

                          final users = snapshot.data!.docs;

                          final filteredUsers = users.where((doc) {
                            final user = doc.data() as Map<String, dynamic>;
                            final matchesSearch = user['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                                user['email'].toString().toLowerCase().contains(searchQuery.toLowerCase());
                            final matchesRole = selectedRole == 'Tất cả' || user['role'] == selectedRole;
                            return matchesSearch && matchesRole;
                          }).toList();

                          if (filteredUsers.isEmpty) {
                            return const Center(
                              child: Text('Không tìm thấy người dùng phù hợp', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            );
                          }
                          return _buildResponsiveTable(filteredUsers, screenWidth);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Các hàm khác giữ nguyên...
  Widget _buildSearchFilter(double screenWidth) {
    if (screenWidth > 800) {
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm theo tên hoặc email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Vai trò',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả vai trò')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'Giảng viên', child: Text('Giảng viên')),
                DropdownMenuItem(value: 'Quản lý Khoa', child: Text('Quản lý Khoa')),
                DropdownMenuItem(value: 'Phòng đào tạo', child: Text('Phòng đào tạo')),
                DropdownMenuItem(value: 'Giám sát', child: Text('Giám sát')),
                DropdownMenuItem(value: 'Sinh viên', child: Text('Sinh viên')),
              ],
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
          ),
        ],
      );
    } else if (screenWidth > 600) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Vai trò',
                border: OutlineInputBorder(),
              ),
              value: selectedRole,
              items: const [
                DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả vai trò')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'Giảng viên', child: Text('Giảng viên')),
                DropdownMenuItem(value: 'Quản lý Khoa', child: Text('Quản lý Khoa')),
                DropdownMenuItem(value: 'Phòng đào tạo', child: Text('Phòng đào tạo')),
                DropdownMenuItem(value: 'Giám sát', child: Text('Giám sát')),
                DropdownMenuItem(value: 'Sinh viên', child: Text('Sinh viên')),
              ],
              onChanged: (value) => setState(() => selectedRole = value!),
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm theo tên hoặc email...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => searchQuery = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Vai trò',
              border: OutlineInputBorder(),
            ),
            value: selectedRole,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'Tất cả', child: Text('Tất cả vai trò')),
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              DropdownMenuItem(value: 'Giảng viên', child: Text('Giảng viên')),
              DropdownMenuItem(value: 'Quản lý Khoa', child: Text('Quản lý Khoa')),
              DropdownMenuItem(value: 'Phòng đào tạo', child: Text('Phòng đào tạo')),
              DropdownMenuItem(value: 'Giám sát', child: Text('Giám sát')),
              DropdownMenuItem(value: 'Sinh viên', child: Text('Sinh viên')),
            ],
            onChanged: (value) => setState(() => selectedRole = value!),
          ),
        ],
      );
    }
  }

  Widget _buildResponsiveTable(List<QueryDocumentSnapshot> users, double screenWidth) {
    if (screenWidth < 1000) {
      return _buildTabletView(users);
    } else {
      return _buildDesktopView(users);
    }
  }

  Widget _buildDesktopView(List<QueryDocumentSnapshot> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DataTable(
          columnSpacing: 24,
          horizontalMargin: 0,
          headingRowHeight: 60,
          dataRowHeight: 56,
          columns: const [
            DataColumn(
              label: Expanded(
                child: Text(
                  'Họ tên',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Vai trò',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Trạng thái',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Lần đăng nhập cuối',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
            DataColumn(
              label: Expanded(
                child: Text(
                  'Hành động',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
          rows: users.map((doc) {
            final user = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      user['name'] ?? 'Chưa có tên',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      user['email'] ?? 'Chưa có email',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 120,
                    child: _buildRoleChip(user['role'] ?? 'Chưa có vai trò'),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 100,
                    child: _buildStatusChip(user['status'] ?? 'Hoạt động'),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      _formatLastLogin(user['lastLogin']),
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 160,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue, size: 20),
                          onPressed: () => _showUserDetailsDialog(user),
                          tooltip: 'Xem chi tiết',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange, size: 20),
                          onPressed: () => _showEditUserDialog(docId, user),
                          tooltip: 'Chỉnh sửa',
                        ),
                        IconButton(
                          icon: Icon(
                            (user['status'] ?? 'Hoạt động') == 'Hoạt động' ? Icons.lock : Icons.lock_open,
                            color: (user['status'] ?? 'Hoạt động') == 'Hoạt động' ? Colors.red : Colors.green,
                            size: 20,
                          ),
                          onPressed: () => _toggleUserStatus(docId, user),
                          tooltip: (user['status'] ?? 'Hoạt động') == 'Hoạt động' ? 'Khóa tài khoản' : 'Mở khóa tài khoản',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () => _showDeleteUserDialog(docId, user),
                          tooltip: 'Xóa người dùng',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabletView(List<QueryDocumentSnapshot> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DataTable(
          columnSpacing: 16,
          horizontalMargin: 0,
          headingRowHeight: 56,
          dataRowHeight: 52,
          columns: const [
            DataColumn(label: Text('Họ tên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(label: Text('Vai trò', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
            DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
          ],
          rows: users.map((doc) {
            final user = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Text(
                      user['name'] ?? 'Chưa có tên',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      user['email'] ?? 'Chưa có email',
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 100,
                    child: _buildRoleChip(user['role'] ?? 'Chưa có vai trò'),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 80,
                    child: _buildStatusChip(user['status'] ?? 'Hoạt động'),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 120,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue, size: 18),
                          onPressed: () => _showUserDetailsDialog(user),
                          tooltip: 'Xem chi tiết',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange, size: 18),
                          onPressed: () => _showEditUserDialog(docId, user),
                          tooltip: 'Chỉnh sửa',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                          onPressed: () => _showDeleteUserDialog(docId, user),
                          tooltip: 'Xóa người dùng',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getRoleColor(role)),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: _getRoleColor(role),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status == 'Hoạt động'
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == 'Hoạt động'
              ? Colors.green
              : Colors.red,
        ),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: status == 'Hoạt động'
              ? Colors.green
              : Colors.red,
          fontWeight: FontWeight.w500,
          fontSize: 12,
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
      case 'Sinh viên':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatLastLogin(dynamic lastLogin) {
    if (lastLogin == null) return 'Chưa đăng nhập';
    if (lastLogin is Timestamp) {
      return '${lastLogin.toDate().day}/${lastLogin.toDate().month}/${lastLogin.toDate().year} ${lastLogin.toDate().hour}:${lastLogin.toDate().minute}';
    }
    return lastLogin.toString();
  }

  void _showAddUserPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AddUserPageDialog(
        onUserAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm người dùng thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showEditUserDialog(String docId, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => EditUserPage(
        userData: user,
        onUpdate: (updatedUser) async {
          try {
            await _firestore.collection('users').doc(docId).update({
              ...updatedUser,
              'updatedAt': FieldValue.serverTimestamp(),
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã cập nhật thông tin người dùng!'),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi cập nhật: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }

  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Chi tiết: ${user['name']}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Họ và tên', user['name'] ?? 'Chưa có'),
              _buildDetailItem('Email', user['email'] ?? 'Chưa có'),
              _buildDetailItem('Mã người dùng', user['teacherId'] ?? user['id'] ?? 'Chưa có'),
              _buildDetailItem('Vai trò', user['role'] ?? 'Chưa có'),
              _buildDetailItem('Trạng thái', user['status'] ?? 'Hoạt động'),
              _buildDetailItem('Lần đăng nhập cuối', _formatLastLogin(user['lastLogin'])),
              if (user['createdAt'] != null)
                _buildDetailItem('Ngày tạo', _formatLastLogin(user['createdAt'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(String docId, Map<String, dynamic> user) async {
    final newStatus = (user['status'] ?? 'Hoạt động') == 'Hoạt động' ? 'Tạm khóa' : 'Hoạt động';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thay đổi trạng thái'),
        content: Text('Bạn có chắc chắn muốn ${newStatus == 'Tạm khóa' ? 'khóa' : 'mở khóa'} tài khoản ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('users').doc(docId).update({
                  'status': newStatus,
                  'updatedAt': FieldValue.serverTimestamp(),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã ${newStatus == 'Tạm khóa' ? 'khóa' : 'mở khóa'} tài khoản ${user['name']}'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi thay đổi trạng thái: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(newStatus == 'Tạm khóa' ? 'Khóa' : 'Mở khóa'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(String docId, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa người dùng'),
        content: Text('Bạn có chắc chắn muốn xóa người dùng ${user['name']}? \n\nThông tin sẽ bị xóa khỏi Firestore nhưng tài khoản Authentication vẫn tồn tại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('users').doc(docId).delete();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa thông tin người dùng ${user['name']} khỏi hệ thống'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi khi xóa người dùng: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa khỏi hệ thống'),
          ),
        ],
      ),
    );
  }
}