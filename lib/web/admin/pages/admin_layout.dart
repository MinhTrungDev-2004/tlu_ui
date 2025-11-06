import 'package:flutter/material.dart';
import 'sidebar_page.dart';
import 'home_page.dart';
import 'users_page.dart';
import 'config_page.dart';
import 'permissions_page.dart';
import 'statistics_page.dart';
import 'backup_config_page.dart';

class AdminLayout extends StatefulWidget {
  const AdminLayout({Key? key}) : super(key: key);

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    // UsersPage(),
    ConfigPage(), // Cấu hình
    PermissionsPage(),
    StatisticsPage(),
    BackupConfigPage(), // Backup & Logs
  ];

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(onItemSelected: onItemSelected),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: pages[selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
