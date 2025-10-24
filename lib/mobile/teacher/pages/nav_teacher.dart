import 'package:flutter/material.dart';
import 'teacher_home.dart';
import 'teacher_schedule.dart';
import 'teacher_attendance.dart';
import 'teacher_report.dart';
import 'teacher_profile.dart';
import 'qr_attendance_nav.dart';

class TeacherNavigation extends StatefulWidget {
  const TeacherNavigation({super.key});

  @override
  State<TeacherNavigation> createState() => _TeacherNavigationState();
}

class _TeacherNavigationState extends State<TeacherNavigation> {
  int _selectedIndex = 0;
  bool _showQRAttendance = false;

  List<Widget> get _pages => <Widget>[
    TeacherHome(),
    TeacherSchedule(),
    _showQRAttendance ? QRAttendanceContent(onHideQR: _hideQR) : TeacherAttendance(onShowQR: _showQR),
    TeacherReport(),
    TeacherProfile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Reset QR view when switching tabs
      if (index != 2) {
        _showQRAttendance = false;
      }
    });
  }

  void _showQR() {
    setState(() {
      _showQRAttendance = true;
    });
  }

  void _hideQR() {
    setState(() {
      _showQRAttendance = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavTeacherUi(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        onShowQR: _showQR,
        onHideQR: _hideQR,
        showQRAttendance: _showQRAttendance,
      ),
    );
  }
}

class NavTeacherUi extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final VoidCallback? onShowQR;
  final VoidCallback? onHideQR;
  final bool showQRAttendance;

  const NavTeacherUi({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onShowQR,
    this.onHideQR,
    this.showQRAttendance = false,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Lịch dạy',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle_outline),
          label: 'Điểm danh',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          label: 'Báo cáo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Cá nhân',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      elevation: 5,
    );
  }
}