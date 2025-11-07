import 'package:flutter/material.dart';
import '../scan_qr/scan_qr_screen.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 255,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo + tên app
              Row(
                children: const [
                  Icon(Icons.school, color: Color(0xFF1470E2), size: 36),
                  SizedBox(width: 8),
                  Text(
                    'TLU Attendance',
                    style: TextStyle(
                      color: Color(0xFF1470E2),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- Danh mục menu có thể ấn được ---
              _menuItem(
                icon: Icons.qr_code_scanner_outlined,
                title: 'Quét QR',
                onTap: () {
                  Navigator.pop(context); // Đóng menu
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QRScanScreen()),
                  );
                },
              ),
              _menuItem(
                icon: Icons.notifications_outlined,
                title: 'Thông báo',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chuyển đến trang Thông báo')),
                  );
                },
              ),
              _menuItem(
                icon: Icons.settings_outlined,
                title: 'Cài đặt',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chuyển đến trang Cài đặt')),
                  );
                },
              ),
              _menuItem(
                icon: Icons.help_outline,
                title: 'Trợ giúp',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chuyển đến trang Trợ giúp')),
                  );
                },
              ),

              const SizedBox(height: 28),

              const Text(
                'Lớp diễn ra hôm nay',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // 🟢 Lúc đầu chưa có lớp nào
              const Text(
                'Chưa có lớp học nào hôm nay.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm tạo menu item có thể ấn được
  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      splashColor: const Color(0xFF1470E2).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.black87, size: 22),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}