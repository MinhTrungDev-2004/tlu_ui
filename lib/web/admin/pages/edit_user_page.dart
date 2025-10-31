import 'package:flutter/material.dart';

class EditUserPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onUpdate;

  const EditUserPage({
    super.key,
    required this.userData,
    required this.onUpdate,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _teacherIdController;
  late TextEditingController _facultyController;
  late TextEditingController _departmentController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(text: widget.userData['name'] ?? '');
    _emailController = TextEditingController(text: widget.userData['email'] ?? '');
    _teacherIdController = TextEditingController(text: widget.userData['teacherId'] ?? widget.userData['id'] ?? '');
    _facultyController = TextEditingController(text: '');
    _departmentController = TextEditingController(text: '');
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _selectedStatus = widget.userData['status'] ?? 'Hoạt động';
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      // Kiểm tra mật khẩu nếu có nhập
      if (_passwordController.text.isNotEmpty &&
          _passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu không khớp!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final updatedUser = {
        'id': _teacherIdController.text,
        'teacherId': _teacherIdController.text,
        'name': _fullNameController.text,
        'email': _emailController.text,
        'status': _selectedStatus,
        'updatedAt': DateTime.now().toString(),
        // Chỉ cập nhật mật khẩu nếu có nhập
        if (_passwordController.text.isNotEmpty)
          'password': _passwordController.text,
      };

      widget.onUpdate(updatedUser);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chỉnh sửa thông tin người dùng',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Thông tin cơ bản
                const Text('Thông tin cơ bản', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _fullNameController,
                  label: 'Họ và tên',
                  errorMessage: 'Vui lòng nhập họ tên',
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  errorMessage: 'Vui lòng nhập email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),

                // Thông tin chuyên môn
                const Text('Thông tin chuyên môn', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _teacherIdController,
                  label: 'Mã người dùng',
                  errorMessage: 'Vui lòng nhập mã người dùng',
                ),
                const SizedBox(height: 24),

                // Thông tin tài khoản (tùy chọn - chỉ thay đổi khi cần)
                const Text('Thông tin tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Để trống nếu không muốn thay đổi mật khẩu',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Mật khẩu mới',
                  errorMessage: 'Vui lòng nhập mật khẩu',
                  obscureText: true,
                  isRequired: false,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu mới',
                  errorMessage: 'Vui lòng xác nhận mật khẩu',
                  obscureText: true,
                  isRequired: false,
                ),
                const SizedBox(height: 24),

                // Trạng thái tài khoản
                const Text('Trạng thái tài khoản', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildStatusDropdown(),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _handleUpdate,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                      child: const Text(
                        'Cập nhật',
                        style: TextStyle(color: Colors.white70),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String errorMessage,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: isRequired
          ? (value) => (value == null || value.isEmpty) ? errorMessage : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Trạng thái',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      ),
      items: const [
        DropdownMenuItem(value: 'Hoạt động', child: Text('Hoạt động')),
        DropdownMenuItem(value: 'Tạm khóa', child: Text('Tạm khóa')),
        DropdownMenuItem(value: 'Đã nghỉ', child: Text('Đã nghỉ')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value!;
        });
      },
      validator: (value) => value == null ? 'Vui lòng chọn trạng thái' : null,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _teacherIdController.dispose();
    _facultyController.dispose();
    _departmentController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}