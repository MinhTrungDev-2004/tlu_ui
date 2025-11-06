import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/session_model.dart';
import '../../../services/session_service.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';

class TeacherSchedule extends StatefulWidget {
  const TeacherSchedule({super.key});

  @override
  State<TeacherSchedule> createState() => _TeacherScheduleState();
}

class _TeacherScheduleState extends State<TeacherSchedule> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  final SessionService _sessionService = SessionService();
  final CourseService _courseService = CourseService();
  final ClassService _classService = ClassService();

  // simple caches để tránh N+1
  final Map<String, CourseModel?> _courseCache = {};
  final Map<String, ClassModel?> _classCache = {};

  @override
  Widget build(BuildContext context) {
    // DefaultTabController bao bọc Scaffold để quản lý TabBar
    return DefaultTabController(
      length: 3, // Có 3 tab
      child: Scaffold(appBar: _buildAppBar(), body: _buildBody()),
    );
  }

  /// 1. Widget cho AppBar (Header xanh và TabBar)
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      // Tự động ẩn nút "Back" nếu màn hình này là màn hình chính
      automaticallyImplyLeading: false,
      bottom: TabBar(
        indicatorColor: Colors.yellow, // Màu của vạch chân
        indicatorWeight: 3.0,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelColor: Colors.white.withValues(alpha: 0.8),
        tabs: const [
          Tab(text: 'Hôm nay'),
          Tab(text: 'Lịch dạy'),
          Tab(text: 'Tải lịch'),
        ],
      ),
    );
  }

  /// 2. Widget cho Thân (Body) - Chứa nội dung của 3 Tab
  Widget _buildBody() {
    return TabBarView(
      children: [
        // Nội dung cho Tab "Hôm nay"
        _buildTodayTab(),
        // Nội dung placeholder cho 2 tab còn lại
        const Center(child: Text('Nội dung Lịch Dạy')),
        const Center(child: Text('Nội dung Tải Lịch')),
      ],
    );
  }

  /// 2a. Nội dung cho Tab "Hôm nay" — ĐỔ DỮ LIỆU THẬT
  Widget _buildTodayTab() {
    if (_uid == null) {
      return const Center(child: Text('Lỗi: Chưa đăng nhập.'));
    }

    final today = DateTime.now();
    final dow = _weekdayVi(today.weekday);
    final dateStr =
        'Thứ $dow, Ngày ${today.day}/${today.month}/${today.year}'; // giữ format tương tự bạn

    return Container(
      color: const Color(0xFFF4F6F8), // Màu nền xám nhạt
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            // Ngày tháng (giữ kiểu hiển thị như UI mẫu)
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),

            // ⭐ Stream các buổi học của giảng viên trong NGÀY HÔM NAY
            StreamBuilder<List<SessionModel>>(
              stream: _sessionService.streamSessionsForLecturerOnDate(
                _uid!,
                today,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                  );
                }
                final sessions = (snapshot.data ?? [])
                  ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

                if (sessions.isEmpty) {
                  return const Text(
                    'Không có buổi học nào hôm nay.',
                    style: TextStyle(color: Colors.grey),
                  );
                }

                // Render danh sách card theo đúng UI của bạn
                return Column(
                  children: [
                    for (final s in sessions) ...[
                      FutureBuilder<_CardData>(
                        future: _composeCardData(s),
                        builder: (context, snap) {
                          // Trong lúc chờ tên lớp/môn → vẫn render card với text tạm
                          final cd = snap.data ??
                              _CardData(
                                title: 'Đang tải...',
                                className: 'Đang tải...',
                                time: s.timeDisplay,
                                room: s.room ?? '---',
                                statusLines: _statusLinesOf(s),
                                barColor: _barColorOf(s),
                              );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildClassCard(
                              title: cd.title,
                              className: cd.className,
                              time: cd.time,
                              room: cd.room,
                              statusLines: cd.statusLines,
                              barColor: cd.barColor,
                              onTapQR: () {
                                // Giữ UI: nút luôn khả dụng (như file mẫu).
                                // Nếu muốn chặn khi đang diễn ra, thêm điều kiện tại đây.
                                // _sessionService.generateAndSaveQr(s.id, const Duration(minutes: 5));
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper: ghép dữ liệu hiển thị 1 card
  Future<_CardData> _composeCardData(SessionModel s) async {
    final course = await _getCourse(s.courseId);
    final klass = await _getClass(s.classId);

    return _CardData(
      title: course?.name ?? 'Không tìm thấy môn',
      className: klass?.name ?? 'Không tìm thấy lớp',
      time: s.timeDisplay,
      room: s.room ?? '---',
      statusLines: _statusLinesOf(s),
      barColor: _barColorOf(s),
    );
  }

  // Hai dòng trạng thái dưới nút: “Trạng thái: …” & “… sinh viên đã điểm danh”
  List<String> _statusLinesOf(SessionModel s) {
    final String statusText = () {
      if (s.isCancelled) return 'Đã hủy';
      if (s.isHappeningNow) return 'Đang diễn ra';
      final now = DateTime.now();
      if (now.isBefore(s.startDateTime)) return 'Chưa bắt đầu';
      if (now.isAfter(s.endDateTime)) return 'Đã kết thúc';
      return s.status.name;
    }();

    final int count = s.attendanceIds?.length ?? 0;
    final String attendanceText =
    count == 0 ? 'Chưa điểm danh' : '$count sinh viên đã điểm danh';

    return ['Trạng thái: $statusText', attendanceText];
  }

  // Màu thanh trái theo trạng thái (giữ style gần với mẫu của bạn)
  Color _barColorOf(SessionModel s) {
    if (s.isCancelled) return Colors.red;
    if (s.isHappeningNow) return Colors.green;
    final now = DateTime.now();
    if (now.isBefore(s.startDateTime)) return Colors.blue;
    return Colors.grey;
  }

  String _weekdayVi(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '2';
      case DateTime.tuesday:
        return '3';
      case DateTime.wednesday:
        return '4';
      case DateTime.thursday:
        return '5';
      case DateTime.friday:
        return '6';
      case DateTime.saturday:
        return '7';
      case DateTime.sunday:
      default:
        return 'Chủ nhật';
    }
  }

  // ====== Reusable widgets: giữ NGUYÊN giao diện của bạn ======

  /// 2b. Widget tái sử dụng cho Card Lớp học
  Widget _buildClassCard({
    required String title,
    required String className,
    required String time,
    required String room,
    required List<String> statusLines,
    required Color barColor,
    required VoidCallback onTapQR,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge, // Để bo góc thanh màu
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh màu bên trái
            Container(width: 8, color: barColor),
            // Nội dung bên phải
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng 1: Tiêu đề và Giờ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildIconTextRow(
                          Icons.access_time_outlined,
                          time,
                          Colors.grey.shade600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Dòng 2: Lớp
                    Text(
                      'Lớp: $className',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Dòng 3: Phòng
                    _buildIconTextRow(
                      Icons.location_on_outlined,
                      room,
                      Colors.grey.shade600,
                    ),
                    const SizedBox(height: 12),
                    // Dòng 4: Trạng thái và Nút
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Cột trạng thái
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: statusLines
                              .map(
                                (line) => Text(
                              line,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          )
                              .toList(),
                        ),
                        // Nút Tạo QR
                        ElevatedButton(
                          onPressed: onTapQR,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Tạo QR'),
                        ),
                      ],
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

  /// Widget con cho (Icon + Text)
  Widget _buildIconTextRow(IconData icon, String text, Color? color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 14, color: color),
        ),
      ],
    );
  }

  // ===== cache helpers =====
  Future<CourseModel?> _getCourse(String courseId) async {
    if (_courseCache.containsKey(courseId)) return _courseCache[courseId];
    final data = await _courseService.getCourseById(courseId);
    _courseCache[courseId] = data;
    return data;
  }

  Future<ClassModel?> _getClass(String classId) async {
    if (_classCache.containsKey(classId)) return _classCache[classId];
    final data = await _classService.getClassById(classId);
    _classCache[classId] = data;
    return data;
  }
}

// struct nhỏ để gom dữ liệu hiển thị card
class _CardData {
  final String title;
  final String className;
  final String time;
  final String room;
  final List<String> statusLines;
  final Color barColor;

  _CardData({
    required this.title,
    required this.className,
    required this.time,
    required this.room,
    required this.statusLines,
    required this.barColor,
  });
}
