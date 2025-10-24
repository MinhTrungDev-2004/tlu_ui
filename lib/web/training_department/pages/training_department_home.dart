import 'package:flutter/material.dart';
import '../../../services/user_service.dart';


// Định nghĩa màu sắc theo giao diện
const Color kPrimaryBlue = Color(0xFF19325B); // Xanh đậm nền Sidebar & AppBar
const Color kCardBlue = Color(0xFF264D9D);    // Xanh đậm thẻ module
const Color kActiveBlueBackground = Color(0xFF142845); // Màu nền item đang chọn (Hơi tối hơn)
const Color kBorderActive = Colors.white; // Màu border item đang chọn

// --------------------------------------------------------------------------
// WIDGET CHÍNH: HOME DASHBOARD PAGE
// --------------------------------------------------------------------------

class TrainingDepartmentHome extends StatefulWidget {
  const TrainingDepartmentHome({super.key});

  @override
  State<TrainingDepartmentHome> createState() => _TrainingDepartmentHomeState();
}

class _TrainingDepartmentHomeState extends State<TrainingDepartmentHome> {
  // Danh sách các mục điều hướng Sidebar
  final List<Map<String, dynamic>> _sidebarItems = [
    {'title': 'Trang chủ', 'icon': Icons.home, 'index': 0},
    {'title': 'Quản lý khoa', 'icon': Icons.dashboard, 'index': 1},
    {'title': 'Quản lý ngành', 'icon': Icons.book, 'index': 2},
    {'title': 'Quản lý giảng viên', 'icon': Icons.people, 'index': 3},
    {'title': 'Quản lý lớp học', 'icon': Icons.class_, 'index': 4},
    {'title': 'Quản lý sinh viên', 'icon': Icons.group, 'index': 5},
    {'title': 'Quản lý môn học', 'icon': Icons.library_books, 'index': 6},
    {'title': 'Quản lý phòng học', 'icon': Icons.meeting_room, 'index': 7},
    {'title': 'Quản lý lịch giảng dạy', 'icon': Icons.calendar_today, 'index': 8},
    {'title': 'Quản lý điểm danh', 'icon': Icons.check_circle, 'index': 9},
  ];

  // Danh sách các Module chức năng trên Trang Chủ
  final List<String> _dashboardModules = [
    'Quản lý khoa',
    'Quản lý ngành',
    'Quản lý giảng viên',
    'Quản lý lớp học',
    'Quản lý sinh viên',
    'Quản lý môn học',
    'Quản lý phòng học',
    'Quản lý lịch giảng dạy',
    'Quản lý điểm danh',
  ];

  int _selectedIndex = 0; // Trang chủ là mục đầu tiên

  void _onSidebarItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getContentForIndex(int index) {
    switch (index) {
      case 0:
        return MainContent(modules: _dashboardModules);
      default:
        return Center(
          child: Text(
            'Nội dung ${_sidebarItems[index]['title']}',
            style: const TextStyle(fontSize: 24),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // 1. Sidebar (Thanh điều hướng dọc)
          Sidebar(
            items: _sidebarItems,
            selectedIndex: _selectedIndex,
            onItemSelected: _onSidebarItemSelected,
          ),

          // 2. Main Content Area (App Bar + Nội dung chính)
          Expanded(
            child: Column(
              children: <Widget>[
                // Thanh Header/App Bar
                const CustomAppBar(),
                // Nội dung chính
                Expanded(
                  child: _getContentForIndex(_selectedIndex),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// WIDGET 1: SIDEBAR (Thanh điều hướng dọc)
// --------------------------------------------------------------------------

class Sidebar extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250, // Chiều rộng cố định cho Sidebar
      color: kPrimaryBlue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Logo & Tiêu đề
          Container(
            height: 60,
            padding: const EdgeInsets.all(15.0),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              color: Color(0xFF142845), // Màu đậm hơn cho phần logo
            ),
            child: const Text(
              'TRƯỜNG ĐẠI HỌC THỦY LỢI HỆ THỐNG ĐIỂM DANH',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Danh sách các mục điều hướng
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final bool isActive = index == selectedIndex;

                return SidebarItem(
                  title: item['title'],
                  icon: item['icon'],
                  isActive: isActive,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Item trong Sidebar
class SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? kActiveBlueBackground : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isActive ? kBorderActive : Colors.transparent,
              width: 3.0,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: isActive ? kBorderActive : Colors.blue[100],
              size: 20,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: isActive ? kBorderActive : Colors.blue[100],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// WIDGET 2: CUSTOM APP BAR (Thanh tiêu đề ngang)
// --------------------------------------------------------------------------

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // Thông tin ngày tháng
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Tổng quan', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                'Thứ Năm, 31 tháng 3, 2025', // Thay bằng ngày tháng thực tế
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
              ),
            ],
          ),

          // Thông tin người dùng
          Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Ngô Minh Trang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Phòng đào tạo', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              const SizedBox(width: 10),
              // Avatar người dùng (Placeholder)
              const CircleAvatar(
                radius: 18,
                backgroundColor: kPrimaryBlue,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// WIDGET 3: MAIN CONTENT (Nội dung chính - Hiển thị các Module Card)
// --------------------------------------------------------------------------

class MainContent extends StatelessWidget {
  final List<String> modules;

  const MainContent({super.key, required this.modules});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Nền trắng
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Tiêu đề Trang Chủ
          const Text(
            'Trang Chủ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Theo dõi và quản lý hoạt động điểm danh tại Trường Đại học Thủy Lợi',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),

          // Lưới các Module Chức Năng
          Expanded(
            child: GridView.count(
              crossAxisCount: 4, // Số cột trên desktop
              childAspectRatio: 1.2, // Tỷ lệ chiều rộng/chiều cao của thẻ
              crossAxisSpacing: 25.0,
              mainAxisSpacing: 25.0,
              children: modules.map((title) {
                return ModuleCard(title: title);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Thẻ Module Chức Năng
class ModuleCard extends StatelessWidget {
  final String title;

  const ModuleCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Xử lý khi nhấn vào module - hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tính năng $title sẽ được phát triển')),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: kCardBlue,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.menu_book, // Icon mặc định cho các module
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
