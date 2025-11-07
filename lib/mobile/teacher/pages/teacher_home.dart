import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../../../services/teacher/teacher_service.dart';
import '../../../models/user/user_model.dart';
import '../../../models/session_model.dart';
import '../../../services/session_service.dart';
import '../../../models/course_model.dart';
import '../../../services/course_service.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';
class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Services & cache
  final SessionService _sessionService = SessionService();
  final CourseService _courseService = CourseService();
  final ClassService _classService = ClassService();
  final Map<String, CourseModel?> _courseCache = {};
  final Map<String, ClassModel?> _classCache = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: currentUserId == null
          ? const Center(child: Text('Lỗi: Người dùng chưa đăng nhập.'))
          : FutureBuilder<UserModel?>(
              future: TeacherService.getTeacherById(currentUserId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('Không tìm thấy người dùng.'));
                }
                final user = snapshot.data!;
                return _buildBody(user);
              },
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            hintText: 'Tìm kiếm lớp học phần...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 10.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildWelcomeCard(user),
          const SizedBox(height: 20),
          _buildNotificationCard(),
          const SizedBox(height: 20),
          _buildScheduleCard(user), // ⭐ vẫn giữ UI như cũ nhưng đổ dữ liệu thật
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel user) {
    final String today = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, ${user.name}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Chúc bạn ngày làm việc hiệu quả',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            'Hôm nay\n$today',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.notifications_outlined, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(
                    'Thông báo mới',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông báo thay đổi lịch học',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Lớp lập trình web ngày 25/01 chuyển từ phòng TC-201 sang TC-202',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ⭐ Card lịch hôm nay (đổ dữ liệu nhưng GIỮ NGUYÊN UI)
  Widget _buildScheduleCard(UserModel user) {
    // Nếu sessions.lecturer_id lưu UID Firebase → dùng currentUserId
    final String lecturerKey = currentUserId ?? user.id;

    return StreamBuilder<List<SessionModel>>(
      stream: _sessionService.streamSessionsForLecturerOnDate(
        lecturerKey,
        DateTime.now(),
      ),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final sessions = (snapshot.data ?? [])..sort(
          (a, b) => a.startDateTime.compareTo(b.startDateTime),
        );

        // chọn 1 buổi để hiển thị: đang diễn ra ưu tiên, nếu không có thì buổi sắp tới
        final now = DateTime.now();
        SessionModel? display;
        if (sessions.isNotEmpty) {
          display = sessions.firstWhereOrNull((s) => s.isHappeningNow);
          display ??= sessions.firstWhereOrNull((s) => s.startDateTime.isAfter(now));
        }

        // đếm số buổi còn lại sau buổi được hiển thị (để giữ dòng "Còn X lớp học nữa")
        int remainingCount = 0;
        if (display != null) {
          final idx = sessions.indexOf(display);
          if (idx >= 0) remainingCount = sessions.length - (idx + 1);
        }
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_month_outlined, color: Colors.blue),
                      SizedBox(width: 10),
                      Text(
                        'Lịch giảng dạy hôm nay',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (hasError)
                Text('Lỗi tải lịch học: ${snapshot.error}')
              else if (display == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Không có buổi học nào sắp diễn ra.',
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                )
              else
                _buildScheduleItem(user, display),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (display == null || display.isHappeningNow)
                      ? null
                      : () {
                          // TODO: generate QR cho display
                          // _sessionService.generateAndSaveQr(display.id, Duration(minutes: 5));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    (display?.isHappeningNow ?? false)
                        ? 'Lớp đang diễn ra'
                        : 'Tạo QR Điểm Danh',
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {}, // TODO: chuyển tới danh sách chi tiết
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Còn ${remainingCount > 0 ? remainingCount : 0} lớp học nữa',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey[700]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// GIỮ NGUYÊN LAYOUT ITEM như ảnh: Tên môn (đậm), thời gian + phòng, giảng viên, dòng “chủ đề” (mình thay = tên lớp để có dữ liệu thật)
  Widget _buildScheduleItem(UserModel user, SessionModel session) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.menu_book_outlined, color: Colors.grey[600], size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseName(session.courseId), // (đậm)
              const SizedBox(height: 5),
              _buildInfoRow(
                Icons.access_time_outlined,
                '${session.timeDisplay}'
                '${session.room != null && session.room!.isNotEmpty ? "   ${session.room}" : ""}',
              ),
              const SizedBox(height: 5),
              _buildInfoRow(Icons.person_outline, 'Giảng viên: ${user.name}'),
              const SizedBox(height: 5),
              // Ảnh UI có “Chủ đề: …” – model chưa có field topic,
              // tạm hiển thị tên LỚP để giữ bố cục & có dữ liệu thật.
              FutureBuilder<ClassModel?>(
                future: _getClass(session.classId),
                builder: (context, snap) {
                  final classText = (snap.connectionState == ConnectionState.done)
                      ? (snap.data != null ? snap.data!.name : 'Không tìm thấy lớp')
                      : 'Đang tải lớp...';
                  return _buildInfoRow(
                    Icons.label_outline,
                    'Lớp: $classText',
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===== Helpers: tên môn / tên lớp có cache để tránh N+1 =====

  Widget _buildCourseName(String courseId) {
    final cached = _courseCache[courseId];
    if (cached != null) {
      return Text(
        cached.name,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return FutureBuilder<CourseModel?>(
      future: _courseService.getCourseById(courseId),
      builder: (context, snapshot) {
        String courseName = 'Đang tải tên môn học...';
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            _courseCache[courseId] = snapshot.data; // cache
            courseName = snapshot.data!.name;
          } else {
            courseName = 'Không tìm thấy môn học';
          }
        }
        return Text(
          courseName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Future<ClassModel?> _getClass(String classId) async {
    if (_classCache.containsKey(classId)) return _classCache[classId];
    final data = await _classService.getClassById(classId);
    _classCache[classId] = data;
    return data;
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
