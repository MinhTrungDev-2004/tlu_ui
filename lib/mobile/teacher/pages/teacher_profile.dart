import 'package:flutter/material.dart';
import '../../navigation/navigation_service.dart';
import '../../navigation/role_manager.dart';

class TeacherProfile extends StatelessWidget {
  const TeacherProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
      backgroundColor: const Color(0xFFF4F6F8), // Màu nền xám nhạt
      // Chú ý: KHÔNG có bottomNavigationBar ở đây
    );
  }

  /// 1. Widget cho AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Thông tin cá nhân',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 2. Widget cho Thân (Body)
  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa
          children: [
            // 1. Phần thông tin (Avatar, Tên, MGV)
            _buildProfileHeader(),
            const SizedBox(height: 32),
            // 2. Phần danh sách chức năng (bọc trong Card)
            _buildActionList(context),
          ],
        ),
      ),
    );
  }

  /// 2a. Widget cho Header (Avatar, Tên)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50, // Kích thước avatar
          backgroundColor: Colors.grey.shade300,
          // Bạn có thể thay bằng NetworkImage nếu có link ảnh
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Ngô Minh Trung',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MGV: 2251172533',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  /// 2b. Widget cho danh sách các chức năng
  Widget _buildActionList(BuildContext context) {
    // Dùng Card để có nền trắng và bo góc
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      clipBehavior: Clip.antiAlias, // Để bo góc các ListTile bên trong
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            title: 'Thông tin cá nhân',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: 'Trợ giúp',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Phản hồi / Góp ý',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Đăng xuất',
            onTap: () {
              // Đăng xuất và quay về trang login
              RoleManager.setRole(UserRole.guest);
              NavigationService.navigateToRole(UserRole.guest);
            },
          ),
        ],
      ),
    );
  }

  /// 2c. Widget con (tái sử dụng) cho mỗi mục trong danh sách
  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 18,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}