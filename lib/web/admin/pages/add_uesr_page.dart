import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddUserPageDialog extends StatefulWidget {
  final Function()? onUserAdded;

  const AddUserPageDialog({super.key, this.onUserAdded});

  @override
  State<AddUserPageDialog> createState() => _AddUserPageDialogState();
}

class _AddUserPageDialogState extends State<AddUserPageDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _customIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // Map role với các trường profile mặc định
  final Map<String, Map<String, dynamic>> roleProfiles = {
    'student': {
      'displayName': 'Sinh viên',
      'profileFields': {
        'phone': '',
        'address': '',
        'birthday': '',
        'gender': '',
        'avatar': '',
        'studentClass': '',
        'course': '',
        'year': '',
        'major': '',
      }
    },
    'lecturer': {
      'displayName': 'Giảng viên',
      'profileFields': {
        'phone': '',
        'address': '',
        'birthday': '',
        'gender': '',
        'avatar': '',
        'faculty': '',
        'department': '',
        'degree': '',
        'specialization': '',
      }
    },
    'faculty_manager': {
      'displayName': 'Quản lý khoa',
      'profileFields': {
        'phone': '',
        'address': '',
        'birthday': '',
        'gender': '',
        'avatar': '',
        'faculty': '',
        'managementLevel': '',
        'responsibility': '',
      }
    },
    'academic_affairs': {
      'displayName': 'Phòng đào tạo',
      'profileFields': {
        'phone': '',
        'address': '',
        'birthday': '',
        'gender': '',
        'avatar': '',
        'trainingDepartment': '',
        'position': '',
      }
    },
    'supervisor': {
      'displayName': 'Giám sát',
      'profileFields': {
        'phone': '',
        'address': '',
        'birthday': '',
        'gender': '',
        'avatar': '',
        'supervisionArea': '',
        'position': '',
      }
    },
    'admin': {
      'displayName': 'Admin',
      'profileFields': {
        'phone': '',
        'address': '',
        'birthday': '',
        'gender': '',
        'avatar': '',
      }
    },
  };

  String _selectedRoleKey = 'student'; // Mặc định là Sinh viên

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _customIdController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Hàm tạo profile mặc định theo role
  Map<String, dynamic> _getDefaultProfile(String role) {
    return roleProfiles[role]?['profileFields'] ?? {};
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final customId = _customIdController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Kiểm tra xem 'id' (mã người dùng) đã tồn tại chưa
      final existingQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: customId)
          .limit(1)
          .get();

      if (existingQuery.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mã người dùng đã tồn tại trong hệ thống!'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 1️⃣ Tạo user trong Firebase Authentication
      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2️⃣ Tạo profile mặc định theo role
      final defaultProfile = _getDefaultProfile(_selectedRoleKey);

      // 3️⃣ Chuẩn bị dữ liệu để lưu vào Firestore
      final userData = {
        // Thông tin cơ bản (Admin tạo)
        'uid': userCred.user!.uid,
        'id': customId,
        'name': fullName,
        'email': email,
        'role': _selectedRoleKey,
        'status': 'Hoạt động',
        'profileCompleted': false, // ⭐ QUAN TRỌNG: chưa hoàn thiện profile
        'createdBy': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),

        // Profile động theo role (để trống - user tự cập nhật)
        'profile': defaultProfile,
        'profileUpdatedAt': null,
      };

      // 4️⃣ Lưu thông tin vào Firestore với UID làm DOCUMENT ID
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .set(userData);

      // Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Đã tạo tài khoản ${roleProfiles[_selectedRoleKey]?['displayName']} thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Gọi callback để refresh danh sách
      widget.onUserAdded?.call();

      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      String message = 'Đã xảy ra lỗi khi tạo tài khoản';
      if (e.code == 'email-already-in-use') {
        message = 'Email này đã được sử dụng!';
      } else if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu!';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ!';
      } else {
        message = e.message ?? message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ $message'), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi không xác định: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Thêm tài khoản người dùng',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Thông tin cơ bản
                const Text('Thông tin cơ bản',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTextField(_fullNameController, 'Họ và tên',
                    'Vui lòng nhập họ tên'),
                const SizedBox(height: 12),
                _buildTextField(
                  _emailController,
                  'Email',
                  'Vui lòng nhập email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildRoleDropdown(),
                const SizedBox(height: 24),

                // Thông tin định danh
                const Text('Thông tin định danh',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTextField(_customIdController, 'Mã người dùng (Mã GV, SV...)',
                    'Vui lòng nhập mã người dùng'),

                // Hiển thị gợi ý về mã người dùng
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _getIdHintText(),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // Thông tin tài khoản
                const Text('Thông tin tài khoản',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTextField(_passwordController, 'Mật khẩu',
                    'Vui lòng nhập mật khẩu',
                    obscureText: true),
                const SizedBox(height: 12),
                _buildTextField(_confirmPasswordController, 'Xác nhận mật khẩu',
                    'Vui lòng xác nhận mật khẩu',
                    obscureText: true),

                // Thông báo về việc hoàn thiện profile
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Người dùng sẽ cần hoàn thiện thông tin cá nhân khi đăng nhập lần đầu',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Tạo tài khoản',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String errorMessage, {
        bool obscureText = false,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) =>
      (value == null || value.trim().isEmpty) ? errorMessage : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRoleKey,
      decoration: const InputDecoration(
        labelText: 'Vai trò',
        border: OutlineInputBorder(),
      ),
      items: roleProfiles.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value['displayName']),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedRoleKey = value;
          });
        }
      },
      validator: (value) => value == null ? 'Vui lòng chọn vai trò' : null,
    );
  }

  // Hàm trả về gợi ý mã người dùng theo role
  String _getIdHintText() {
    switch (_selectedRoleKey) {
      case 'student':
        return 'Ví dụ: SV001, SV2024001...';
      case 'lecturer':
        return 'Ví dụ: GV001, GVCNTT...';
      case 'faculty_manager':
        return 'Ví dụ: QLK001, QL_KHOA_CNTT...';
      case 'academic_affairs':
        return 'Ví dụ: PDT001, PDT_DAOTAO...';
      case 'supervisor':
        return 'Ví dụ: GS001, GIAMSAT...';
      case 'admin':
        return 'Ví dụ: AD001, ADMIN...';
      default:
        return 'Nhập mã định danh cho người dùng';
    }
  }
}