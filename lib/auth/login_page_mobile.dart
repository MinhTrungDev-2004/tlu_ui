import 'package:flutter/material.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/user_service.dart';
import '../services/student/student_service.dart'; // 🔹 THÊM IMPORT
import '../mobile/navigation/app_router.dart';

class LoginPageMobile extends StatefulWidget {
  const LoginPageMobile({super.key});

  @override
  State<LoginPageMobile> createState() => _LoginPageMobileState();
}

class _LoginPageMobileState extends State<LoginPageMobile> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _accountController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ email và mật khẩu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Đăng nhập bằng Firebase Authentication
      final userCredential = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential?.user != null) {
        // Lấy role người dùng sau khi đăng nhập
        final userRole = await UserService.initializeUser();
        if (userRole == null) throw Exception('Không thể xác định role của người dùng');

        if (!mounted) return;

        // 🔹 KIỂM TRA NẾU LÀ STUDENT VÀ CHƯA ĐĂNG KÝ KHUÔN MẶT
        if (userRole == UserRole.student) {
          final studentId = userCredential!.user!.uid;
          final hasRegisteredFace = await StudentService().hasRegisteredFace(studentId);
          
          if (!hasRegisteredFace) {
            // 🔹 CHƯA ĐĂNG KÝ KHUÔN MẶT - ĐIỀU HƯỚNG ĐẾN TRANG ĐĂNG KÝ
            Navigator.pushReplacementNamed(
              context, 
              AppRouter.faceRegistrationRoute,
              arguments: studentId, // Truyền studentId để đăng ký
            );
            return;
          }
        }

        // 🔹 ĐÃ ĐĂNG KÝ KHUÔN MẶT HOẶC KHÔNG PHẢI STUDENT - ĐIỀU HƯỚNG VỀ TRANG CHỦ
        _navigateToHomePage(userRole);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng nhập: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔹 HÀM ĐIỀU HƯỚNG VỀ TRANG CHỦ THEO ROLE
  void _navigateToHomePage(UserRole userRole) {
    switch (userRole) {
      case UserRole.admin:
        Navigator.pushReplacementNamed(context, AppRouter.adminRoute);
        break;
      case UserRole.trainingDepartment:
        Navigator.pushReplacementNamed(context, AppRouter.trainingDepartmentRoute);
        break;
      case UserRole.teacher:
        Navigator.pushReplacementNamed(context, AppRouter.teacherRoute);
        break;
      case UserRole.student:
        Navigator.pushReplacementNamed(context, AppRouter.studentRoute);
        break;
      case UserRole.supervisor:
        Navigator.pushReplacementNamed(context, AppRouter.supervisorRoute);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản không hợp lệ.'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                // Biểu tượng logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1470E2),
                    borderRadius: BorderRadius.circular(45),
                  ),
                  child: const Icon(Icons.school, color: Colors.white, size: 48),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),

                const SizedBox(height: 48),

                // Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _accountController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Nhập email của bạn',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1470E2)),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1470E2), width: 1.5),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1470E2), width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập email';
                        if (!value.contains('@')) return 'Email không hợp lệ';
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Password
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mật khẩu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: 'Nhập mật khẩu',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1470E2)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey[600],
                          ),
                          onPressed: () => setState(() {
                            _obscurePassword = !_obscurePassword;
                          }),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1470E2), width: 1.5),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1470E2), width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                        if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                        return null;
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng quên mật khẩu đang được phát triển.'),
                        ),
                      );
                    },
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(
                        color: Color(0xFF1470E2),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Nút đăng nhập
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1470E2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Đăng nhập',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 24),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}