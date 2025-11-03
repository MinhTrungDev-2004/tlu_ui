import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_menu.dart';
import '../scan_qr/scan_qr_screen.dart';
import '../user_information/user_screen.dart';
import '../register_face/widgets/main_appbar.dart'; //  Dùng AppBar chung

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _HomeContent(),
    SizedBox(),
    PersonalPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRScanScreen()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const HomeMenu(),

      // ✅ Dùng AppBar thống nhất
      appBar: buildMainAppBar(
        context: context,
        title: _selectedIndex == 0
            ? 'Trang chủ'
            : _selectedIndex == 2
                ? 'Cá nhân'
                : '',
        showBack: false, //  Trang chủ không có nút back
       
      ),

      // === Nội dung chính ===
      body: _pages[_selectedIndex],

      // === Thanh điều hướng dưới cùng ===
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1, color: Colors.grey, thickness: 0.8),
          BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF1470E2),
            unselectedItemColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.qr_code_scanner_outlined),
                label: 'Quét QR',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Cá nhân',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// === Nội dung trang "Trang chủ" ===
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Hôm nay bạn không có lịch học nào.',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}
