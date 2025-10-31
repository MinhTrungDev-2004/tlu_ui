import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF0D47A1);

class Sidebar extends StatelessWidget {
  final Function(int) onItemSelected;

  const Sidebar({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: primaryColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRƯỜNG ĐẠI HỌC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'THỦY LỢI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Danh sách menu
          SidebarItem(
            title: "Trang chủ",
            icon: Icons.home,
            onTap: () => onItemSelected(0),
          ),
          SidebarItem(
            title: "Người dùng",
            icon: Icons.people,
            onTap: () => onItemSelected(1),
          ),
          SidebarItem(
            title: "Cấu hình",
            icon: Icons.settings,
            onTap: () => onItemSelected(2),
          ),
          SidebarItem(
            title: "Phân quyền",
            icon: Icons.admin_panel_settings,
            onTap: () => onItemSelected(3),
          ),
          SidebarItem(
            title: "Thống kê hệ thống",
            icon: Icons.bar_chart,
            onTap: () => onItemSelected(4),
          ),
          SidebarItem(
            title: "Nhật kí và hỗ trợ",
            icon: Icons.backup,
            onTap: () => onItemSelected(5),
          ),
          const Spacer(),

          // 🔻 Footer
          const Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text(
              '© 2025 Đại học Thủy Lợi',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const SidebarItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 16),
      ),
      onTap: onTap,
    );
  }
}
