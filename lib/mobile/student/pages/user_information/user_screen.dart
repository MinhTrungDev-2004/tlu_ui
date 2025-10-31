import 'package:flutter/material.dart';
import '../register_face/register_face_screen.dart';
import 'widgets/history_attendance.dart';

class PersonalPage extends StatelessWidget {
  const PersonalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            // Avatar và tên người dùng
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Lê Đức Chiến',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 25),

            // Menu chức năng
            _buildMenuItem(
              context,
              Icons.face_retouching_natural,
              'Cập nhật khuôn mặt',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterFaceScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.person_outline,
              'Thông tin cá nhân',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang được phát triển')),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.history,
              'Lịch sử điểm danh',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AttendanceHistoryScreen()),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.settings_outlined,
              'Cài đặt',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang được phát triển')),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.help_outline,
              'Trợ giúp',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang được phát triển')),
                );
              },
            ),
            _buildMenuItem(
              context,
              Icons.feedback_outlined,
              'Phản hồi / Góp ý',
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đang được phát triển')),
                );
              },
            ),

            const SizedBox(height: 16),

            // Nút đăng xuất
            _buildMenuItem(
              context,
              Icons.logout,
              'Đăng xuất',
              () => _showLogoutDialog(context),
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.black),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: color ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã đăng xuất thành công')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
