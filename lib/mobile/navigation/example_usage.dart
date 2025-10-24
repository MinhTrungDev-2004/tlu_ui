import 'package:flutter/material.dart';
import 'navigation_service.dart';
import 'role_manager.dart';

// Ví dụ sử dụng Navigation Service
class ExampleLoginPage extends StatelessWidget {
  const ExampleLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Đăng nhập với vai trò Giáo viên:'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Đăng nhập với vai trò giáo viên
                NavigationService.navigateToRole(UserRole.teacher);
              },
              child: const Text('Đăng nhập với vai trò Giáo viên'),
            ),
          ],
        ),
      ),
    );
  }
}

// Teacher Profile để đăng xuất
class ExampleLogoutButton extends StatelessWidget {
  const ExampleLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Đăng xuất và quay về trang login
        RoleManager.setRole(UserRole.guest);
        NavigationService.navigateToRole(UserRole.guest);
      },
      child: const Text('Đăng xuất'),
    );
  }
}
