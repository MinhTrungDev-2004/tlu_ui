import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../mobile/navigation/app_router.dart';

// Định nghĩa màu sắc theo giao diện mẫu
const Color kPrimaryBlue = Color(0xFF19325B); 
const Color kButtonBlue = Color(0xFF264D9D); 
const Color kLightGrey = Color(0xFFF5F5F5); 

class LoginPageWeb extends StatefulWidget {
  const LoginPageWeb({super.key});

  @override
  State<LoginPageWeb> createState() => _LoginPageWebState();
}

class _LoginPageWebState extends State<LoginPageWeb> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    // Kiểm tra validation trước
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Lấy thông tin đăng nhập
    final email = _accountController.text.trim();
    final password = _passwordController.text.trim();

    // Kiểm tra thông tin đăng nhập
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ email và mật khẩu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Đăng nhập với Firebase Authentication
      final userCredential = await AuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential?.user != null) {
        final userRole = await UserService.initializeUser();
        if (userRole == null) {
          throw Exception('Không thể xác định role của user');
        }
        setState(() {
          _isLoading = false;
        });

        // Hiển thị thông báo đăng nhập thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập thành công! Chào mừng ${UserService.displayName}'),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Điều hướng dựa trên role
        if (mounted) {
          if (userRole == UserRole.teacher) {
            Navigator.pushReplacementNamed(context, AppRouter.teacherRoute);
          } else if (userRole == UserRole.trainingDepartment) {
            Navigator.pushReplacementNamed(context, AppRouter.trainingDepartmentRoute);
          } else if (userRole == UserRole.admin) {
            Navigator.pushReplacementNamed(context, AppRouter.adminRoute);
          } else if (userRole == UserRole.student) {
            Navigator.pushReplacementNamed(context, AppRouter.studentRoute);
          } else if (userRole == UserRole.supervisor) {
            Navigator.pushReplacementNamed(context, AppRouter.supervisorRoute);
          } else {
            // Role không hợp lệ
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tài khoản hoặc mật khẩu không hợp lệ'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đăng nhập: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // Scaffold chứa giao diện 2 cột cố định (phù hợp cho web/desktop)
    return Scaffold(
      body: Row(
        children: <Widget>[
          // 1. Phần Nhập liệu (Trắng) - Chiếm 40% (Thay thế placeholder)
          Expanded(
            flex: 4,
            child: LoginInputSection(
              formKey: _formKey,
              accountController: _accountController,
              passwordController: _passwordController,
              obscurePassword: _obscurePassword,
              rememberMe: _rememberMe,
              isLoading: _isLoading,
              onObscurePasswordChanged: (val) {
                setState(() {
                  _obscurePassword = val;
                });
              },
              onRememberMeChanged: (val) {
                setState(() {
                  _rememberMe = val;
                });
              },
              onLoginPressed: _handleLogin,
            ),
          ),

          // 2. Phần Thông tin (Xanh đậm) - Chiếm 60% (Thay thế placeholder)
          const Expanded(
            flex: 6,
            child: InfoSection(),
          ),
        ],
      ),
    );
  }
}


class LoginInputSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController accountController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final Function(bool) onObscurePasswordChanged;
  final Function(bool) onRememberMeChanged;
  final VoidCallback onLoginPressed;

  const LoginInputSection({
    super.key,
    required this.formKey,
    required this.accountController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.onObscurePasswordChanged,
    required this.onRememberMeChanged,
    required this.onLoginPressed,
  });

  Widget _buildInputField(String hint, {
    bool obscureText = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: kLightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50.0),
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 380, // Giới hạn chiều rộng của form để trông đẹp hơn trên màn hình lớn
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Tiêu đề: Đăng nhập
                const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 50),

                // Email
                const Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildInputField(
                  'Nhập email của bạn',
                  controller: accountController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!value.contains('@')) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Mật khẩu
                const Text('Mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildInputField(
                  'Nhập mật khẩu của bạn',
                  obscureText: obscurePassword,
                  controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      onObscurePasswordChanged(!obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Ghi nhớ và Quên mật khẩu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Ghi nhớ tôi (Checkbox)
                    Row(
                      children: [
                        Theme(
                          data: ThemeData(unselectedWidgetColor: Colors.grey),
                          child: Checkbox(
                            value: rememberMe,
                            onChanged: (val) {
                              onRememberMeChanged(val ?? false);
                            },
                            activeColor: kPrimaryBlue,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const Text('Ghi nhớ tôi'),
                      ],
                    ),

                    // Quên mật khẩu (TextButton)
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tính năng quên mật khẩu sẽ được phát triển'),
                          ),
                        );
                      },
                      child: const Text(
                        'Quên mật khẩu?',
                        style: TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Nút Đăng nhập
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kButtonBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 5,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Đăng nhập',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// PHẦN 2: INFO SECTION (Xanh đậm)
// --------------------------------------------------------------------------

class InfoSection extends StatelessWidget {
  const InfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryBlue,
      padding: const EdgeInsets.all(50.0),
      child: Center(
        child: SizedBox(
          width: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Logo TLU (Đã thay bằng Image.asset)
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  // Thêm box shadow nhẹ để giống logo thật hơn
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withValues(alpha: 0.1),
                       blurRadius: 10,
                       offset: const Offset(0, 5),
                     ),
                   ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SỬ DỤNG IMAGE.ASSET TẠI ĐÂY
                      Image.asset(
                        'assets/Logo.png', // Đường dẫn đến ảnh của bạn
                        width: 110, // Kích thước ảnh bên trong container
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                      // Thêm chữ "1959" nếu nó không nằm trong ảnh logo
                      const Text('1959', style: TextStyle(color: kPrimaryBlue, fontSize: 12)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Tiêu đề lớn
              const Text(
                'Quản lý hệ thống điểm danh thông minh',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Mô tả
              const Text(
                'Dành riêng cho phòng đào tạo và giảng viên tại trường đại học Thủy Lợi để quản lý điểm danh sinh viên một cách hiệu quả và thông minh.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}