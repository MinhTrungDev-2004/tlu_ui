import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../navigation/navigation_service.dart';
import '../../navigation/role_manager.dart';
import '../../../services/teacher/teacher_service.dart';
import '../../../models/user/user_model.dart';

class TeacherProfile extends StatelessWidget {
  const TeacherProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
      backgroundColor: const Color(0xFFF4F6F8), // Màu nền xám nhạt
      // KHÔNG có bottomNavigationBar
    );
  }

  /// 1) AppBar: giữ nguyên UI
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

  /// 2) Body: giữ bố cục cũ, chỉ thay header thành dữ liệu thật
  Widget _buildBody(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text('Lỗi: Người dùng chưa đăng nhập.'),
        ),
      );
    }

    return FutureBuilder<UserModel?>(
      future: TeacherService.getTeacherById(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
            ),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Không tìm thấy thông tin giảng viên.'),
            ),
          );
        }

        return SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa
              children: [
                _buildProfileHeader(user), // ⭐ header dữ liệu thật
                const SizedBox(height: 32),
                _buildActionList(context),  // danh sách chức năng
              ],
            ),
          ),
        );
      },
    );
  }

  /// Header: avatar + tên + MGV (giữ nguyên UI)
  Widget _buildProfileHeader(UserModel user) {
    final initials =
        (user.name.isNotEmpty ? user.name.trim()[0] : '?').toUpperCase();

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          // Nếu có ảnh đại diện: dùng backgroundImage: NetworkImage(url)
          child: Text(
            initials,
            style: TextStyle(
              fontSize: 48,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          // Nếu có field riêng (maGV/teacherCode), thay user.id bằng field đó
          'MGV: ${user.lecturerCode}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  /// Danh sách chức năng (giữ nguyên UI)
  Widget _buildActionList(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      clipBehavior: Clip.antiAlias, // Bo góc các ListTile bên trong
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
            onTap: () async {
              // (tuỳ chọn) sign out Firebase
              try {
                await FirebaseAuth.instance.signOut();
              } catch (_) {}

              // Giữ nguyên điều hướng theo role như bạn đang dùng
              RoleManager.setRole(UserRole.guest);
              NavigationService.navigateToRole(UserRole.guest);
            },
          ),
        ],
      ),
    );
  }

  /// Item trong danh sách (giữ nguyên UI)
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
