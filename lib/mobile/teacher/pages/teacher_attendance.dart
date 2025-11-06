import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/session_model.dart';
import '../../../services/session_service.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';

class TeacherAttendance extends StatefulWidget {
  final VoidCallback? onShowQR;

  const TeacherAttendance({super.key, this.onShowQR});

  @override
  State<TeacherAttendance> createState() => _TeacherAttendanceState();
}

class _TeacherAttendanceState extends State<TeacherAttendance> {
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  final SessionService _sessionService = SessionService();
  final CourseService _courseService = CourseService();
  final ClassService _classService = ClassService();

  // simple caches để tránh N+1
  final Map<String, CourseModel?> _courseCache = {};
  final Map<String, ClassModel?> _classCache = {};

  DateTime _selectedDate = _dateOnly(DateTime.now());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // 1. AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text(
        'Chọn lớp điểm danh',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 2. Body
  Widget _buildBody() {
    if (_uid == null) {
      return const Center(child: Text('Lỗi: Chưa đăng nhập.'));
    }

    return Container(
      color: const Color(0xFFF4F6F8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            _buildDatePicker(),
            const SizedBox(height: 20),

            // ⭐ Stream tất cả buổi học của giảng viên trong ngày đã chọn
            StreamBuilder<List<SessionModel>>(
              stream: _sessionService.streamSessionsForLecturerOnDate(
                _uid!,
                _selectedDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40.0),
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
                  return const Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text(
                      'Không có buổi học nào trong ngày này.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (final s in sessions) ...[
                      FutureBuilder<_CardData>(
                        future: _composeCardData(s),
                        builder: (context, snap) {
                          // Hiển thị card ngay cả khi đang tải tên lớp/môn
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
                              onPressedQR: () {
                                // Nếu muốn ràng buộc logic: đang diễn ra thì không tạo QR
                                if (s.isHappeningNow) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Lớp đang diễn ra – không thể tạo QR mới.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                // Gọi callback bên ngoài (nếu có)
                                widget.onShowQR?.call();
                                // TODO: hoặc gọi trực tiếp service tạo QR:
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

  // Gom dữ liệu hiển thị 1 card (tên môn + tên lớp + …)
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

  // Tạo 2 dòng trạng thái dưới nút
  List<String> _statusLinesOf(SessionModel s) {
    final String statusText = () {
      if (s.isCancelled) return 'Đã hủy';
      if (s.isHappeningNow) return 'Đang diễn ra';
      final now = DateTime.now();
      if (now.isBefore(s.startDateTime)) return 'Chưa bắt đầu';
      if (now.isAfter(s.endDateTime)) return 'Đã kết thúc';
      return s.status.name; // fallback
    }();

    final String attendanceText = (() {
      final count = s.attendanceIds?.length ?? 0;
      if (count == 0) return 'Chưa điểm danh';
      return '$count sinh viên đã điểm danh';
    })();

    return ['Trạng thái: $statusText', attendanceText];
  }

  // Màu thanh dọc theo trạng thái
  Color _barColorOf(SessionModel s) {
    if (s.isCancelled) return Colors.red;
    if (s.isHappeningNow) return Colors.green;
    final now = DateTime.now();
    if (now.isBefore(s.startDateTime)) return Colors.blue;
    return Colors.grey;
  }

  // 3. DatePicker (UI giữ nguyên, nhưng có logic đổi ngày)
  Widget _buildDatePicker() {
    final isToday = _dateOnly(DateTime.now()) == _selectedDate;
    final dow = _weekdayVi(_selectedDate.weekday);
    final dateStr =
        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}';

    return Card(
      elevation: 1,
      shadowColor: Colors.grey.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                });
              },
            ),
            Column(
              children: [
                Text(
                  isToday ? 'Hôm nay' : 'Chọn ngày',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dow, $dateStr',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayVi(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ 2';
      case DateTime.tuesday:
        return 'Thứ 3';
      case DateTime.wednesday:
        return 'Thứ 4';
      case DateTime.thursday:
        return 'Thứ 5';
      case DateTime.friday:
        return 'Thứ 6';
      case DateTime.saturday:
        return 'Thứ 7';
      case DateTime.sunday:
      default:
        return 'Chủ nhật';
    }
  }

  // ====== Reusable parts (giữ UI như bạn gửi) ======

  /// 4. Card lớp học (giữ nguyên bố cục + thêm param onPressedQR)
  Widget _buildClassCard({
    required String title,
    required String className,
    required String time,
    required String room,
    required List<String> statusLines,
    required Color barColor,
    required VoidCallback onPressedQR,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.hardEdge,
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
                    // Tiêu đề + giờ
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
                    // Lớp
                    Text(
                      'Lớp: $className',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Phòng
                    _buildIconTextRow(
                      Icons.location_on_outlined,
                      room,
                      Colors.grey.shade600,
                    ),
                    const SizedBox(height: 12),
                    // Trạng thái + Nút QR
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
                          onPressed: onPressedQR,
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

  /// 5. (Icon + Text)
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

  // ====== cache helpers ======
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

// Struct nhỏ để gom dữ liệu hiển thị card
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
