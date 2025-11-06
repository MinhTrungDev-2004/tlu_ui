import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_menu.dart';
import '../scan_qr/scan_qr_screen.dart';
import '../user_information/user_screen.dart';
import '../register_face/widgets/main_appbar.dart';
import 'list_class.dart';
import '../../../../services/student/class_service.dart';
import '../../../../models/session_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final DateTime _selectedDate = DateTime.now();
  final ClassService _classService = ClassService();
  
  String? _studentId; // Thay vì cứng studentId
  List<SessionModel> _todaySessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUserAndLoadSessions();
  }

  Future<void> _getCurrentUserAndLoadSessions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy user hiện tại từ Firebase Auth
      final User? user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        _studentId = user.uid; // Sử dụng UID thực tế
        print('👤 User UID: $_studentId');
        
        await _loadTodaySessions();
      } else {
        print('❌ Không có user đăng nhập');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Lỗi khi lấy user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTodaySessions() async {
    if (_studentId == null) {
      print('❌ StudentId null, không thể load sessions');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print('🔄 Đang load sessions cho student: $_studentId');
      
      final sessions = await _classService.getStudentSessionsByDate(
        studentId: _studentId!,
        date: _selectedDate,
      );
      
      print('✅ Load được ${sessions.length} sessions');
      
      setState(() {
        _todaySessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading sessions: $e');
      setState(() {
        _isLoading = false;
        _todaySessions = [];
      });
    }
  }

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

  Future<void> _refreshSessions() async {
    await _loadTodaySessions();
  }

  // Xóa didChangeDependencies và build pages trong build method
  List<Widget> get _pages {
    return [
      _buildHomeContent(),
      const SizedBox(),
      const PersonalPage(),
    ];
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_todaySessions.isEmpty) {
      return const Center(
        child: Text(
          'Hôm nay bạn không có lịch học nào.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }
    
    return ListClassScreen(
      sessions: _todaySessions,
      selectedDate: _selectedDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const HomeMenu(),

      appBar: buildMainAppBar(
        context: context,
        title: _selectedIndex == 0
            ? 'Lớp học'
            : _selectedIndex == 2
                ? 'Cá nhân'
                : '',
        showBack: false,
      ),

      body: _selectedIndex == 0
          ? RefreshIndicator(
              onRefresh: _refreshSessions,
              child: _buildHomeContent(),
            )
          : _pages[_selectedIndex],

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
                label: 'Lớp học',
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