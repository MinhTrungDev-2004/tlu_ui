import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'teacher_home.dart';
import 'teacher_schedule.dart';
import 'teacher_report.dart';
import 'teacher_profile.dart';
import 'nav_teacher.dart';

class QRAttendanceNavigation extends StatefulWidget {
  const QRAttendanceNavigation({super.key});

  @override
  State<QRAttendanceNavigation> createState() => _QRAttendanceNavigationState();
}

class _QRAttendanceNavigationState extends State<QRAttendanceNavigation> {
  int _selectedIndex = 2; // Mặc định chọn tab "Điểm danh"

  static const List<Widget> _pages = <Widget>[
    TeacherHome(),
    TeacherSchedule(),
    QRAttendanceContent(), // Nội dung QR điểm danh
    TeacherReport(),
    TeacherProfile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
      ),
    );
  }
}

// Nội dung trang QR điểm danh
class QRAttendanceContent extends StatefulWidget {
  final VoidCallback? onHideQR;
  
  const QRAttendanceContent({super.key, this.onHideQR});

  @override
  State<QRAttendanceContent> createState() => _QRAttendanceContentState();
}

class _QRAttendanceContentState extends State<QRAttendanceContent> {
  bool _isAttendanceActive = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Danh sách sinh viên demo
  final List<Student> _students = [
    Student(name: 'Ngô Minh Trung', msv: '01', isPresent: false),
    Student(name: 'Lê Đức Chiến', msv: '02', isPresent: false),
    Student(name: 'Nguyễn Ngọc Phước', msv: '03', isPresent: false),
    Student(name: 'Trần Văn An', msv: '04', isPresent: false),
    Student(name: 'Lê Thị Bình', msv: '05', isPresent: false),
  ];

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students.where((student) =>
        student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        student.msv.contains(_searchQuery)).toList();
  }

  void _toggleAttendance() {
    setState(() {
      _isAttendanceActive = !_isAttendanceActive;
    });
  }

  void _markAttendance(int index) {
    setState(() {
      _students[index].isPresent = !_students[index].isPresent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header xanh
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.onHideQR != null) {
                        widget.onHideQR!();
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Text(
                    'Điểm danh sinh viên',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48), // Để cân bằng với nút back
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Nút trạng thái điểm danh
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: _isAttendanceActive ? const Color(0xFFE3F2FD) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isAttendanceActive ? const Color(0xFF2196F3) : Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isAttendanceActive ? 'Điểm danh đang diễn ra...' : 'Điểm danh đã kết thúc',
                            style: TextStyle(
                              color: _isAttendanceActive ? const Color(0xFF2196F3) : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Switch(
                            value: _isAttendanceActive,
                            onChanged: (value) => _toggleAttendance(),
                            activeThumbColor: const Color(0xFF2196F3),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Thời gian
                    const Text(
                      '15:00',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // QR Code
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: 'ATTENDANCE_${DateTime.now().millisecondsSinceEpoch}',
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'QR ĐIỂM DANH',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sinh viên quét QR này để điểm danh',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Danh sách sinh viên
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Danh sách sinh viên',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Thanh tìm kiếm
                          TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm sinh viên',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Danh sách sinh viên
                          ..._filteredStudents.asMap().entries.map((entry) {
                            int index = entry.key;
                            Student student = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: student.isPresent ? const Color(0xFFE8F5E8) : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: student.isPresent ? const Color(0xFF4CAF50) : Colors.grey[300]!,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                      Text(
                                        'MSV: ${student.msv}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: _isAttendanceActive ? () => _markAttendance(index) : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: student.isPresent 
                                          ? const Color(0xFF4CAF50) 
                                          : const Color(0xFF2196F3),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      student.isPresent ? 'Đã điểm danh' : 'Điểm danh',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Student {
  final String name;
  final String msv;
  bool isPresent;

  Student({
    required this.name,
    required this.msv,
    this.isPresent = false,
  });
}
