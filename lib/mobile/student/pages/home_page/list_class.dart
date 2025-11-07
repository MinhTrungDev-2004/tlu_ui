import 'package:flutter/material.dart';
import '../../../../models/session_model.dart';
import '../../../../models/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListClassScreen extends StatelessWidget {
  final List<SessionWithCourse> sessionsWithCourse;
  final DateTime selectedDate;

  const ListClassScreen({
    super.key,
    required this.sessionsWithCourse,
    required this.selectedDate,
  });

  factory ListClassScreen.fromSessions({
    required List<SessionModel> sessions,
    required DateTime selectedDate,
  }) {
    final sessionsWithCourse = sessions.map((session) => SessionWithCourse(
      session: session,
      course: null,
    )).toList();

    return ListClassScreen(
      sessionsWithCourse: sessionsWithCourse,
      selectedDate: selectedDate,
    );
  }

  Future<String> _getLecturerName(String? lecturerId) async {
    if (lecturerId == null || lecturerId.isEmpty) return 'Chưa có giảng viên';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(lecturerId).get();
      if (!doc.exists) return 'Không tìm thấy';
      final data = doc.data();
      return data?['name'] ?? data?['fullName'] ?? data?['displayName'] ?? 'Không rõ';
    } catch (e) {
      return 'Lỗi';
    }
  }

  Future<String> _getCourseName(String courseId) async {
    if (courseId.isEmpty) return 'Không xác định';
    try {
      final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();
      if (!doc.exists) return 'Môn học không tồn tại';
      final data = doc.data();
      return data?['name'] ?? data?['course_name'] ?? courseId;
    } catch (e) {
      return courseId;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 SỬA: Sắp xếp theo thứ tự ưu tiên màu
    final sortedSessions = List<SessionWithCourse>.from(sessionsWithCourse)
      ..sort((a, b) {
        // Ưu tiên theo trạng thái: Đang diễn ra → Sắp diễn ra → Đã kết thúc
        final statusOrder = {
          SessionStatus.ongoing: 1,    // Xanh lá - cao nhất
          SessionStatus.scheduled: 2,  // Đỏ - giữa
          SessionStatus.done: 3,       // Xanh nước biển - thấp nhất
        };
        
        final aOrder = statusOrder[a.session.status] ?? 4;
        final bOrder = statusOrder[b.session.status] ?? 4;
        
        // Nếu cùng trạng thái, sắp xếp theo thời gian
        if (aOrder == bOrder) {
          return a.session.startDateTime.compareTo(b.session.startDateTime);
        }
        
        return aOrder.compareTo(bOrder);
      });

    if (sortedSessions.isEmpty) {
      return const Center(
        child: Text(
          'Hôm nay bạn không có lịch học nào.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(sortedSessions[index]);
      },
    );
  }

  Widget _buildSessionCard(SessionWithCourse sessionWithCourse) {
    final session = sessionWithCourse.session;

    // 🎨 Xác định màu theo trạng thái
    Color borderColor;
    switch (session.status) {
      case SessionStatus.ongoing:
        borderColor = Colors.green;      // Xanh lá - Đang diễn ra
        break;
      case SessionStatus.scheduled:
        borderColor = Colors.red;        // Đỏ - Sắp diễn ra
        break;
      case SessionStatus.done:
        borderColor = Colors.blue;       // Xanh nước biển - Đã kết thúc
        break;
      default:
        borderColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseNameSection(sessionWithCourse, borderColor),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(icon: Icons.class_outlined, text: session.classId),
                Text(
                  'Ngày ${session.dateDisplay}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              text: session.room ?? 'Chưa có phòng',
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Giảng viên',
                        style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 2),
                    FutureBuilder<String>(
                      future: _getLecturerName(session.lecturerId),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.data ?? 'Đang tải...',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Thời gian',
                        style: TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 2),
                    Text(
                      session.timeDisplay,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildSessionStatus(session),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseNameSection(SessionWithCourse sessionWithCourse, Color borderColor) {
    if (sessionWithCourse.course != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sessionWithCourse.courseName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: borderColor,
            ),
          ),
          if (sessionWithCourse.courseCode.isNotEmpty && 
              sessionWithCourse.courseCode != sessionWithCourse.session.courseId) ...[
            const SizedBox(height: 2),
            Text(
              'Mã môn: ${sessionWithCourse.courseCode}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      );
    }

    return FutureBuilder<String>(
      future: _getCourseName(sessionWithCourse.session.courseId),
      builder: (context, snapshot) {
        final courseName = snapshot.data ?? sessionWithCourse.session.courseId;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: borderColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Mã môn: ${sessionWithCourse.session.courseId}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSessionStatus(SessionModel session) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (session.status) {
      case SessionStatus.ongoing:
        statusColor = Colors.green;
        statusText = 'Đang diễn ra';
        statusIcon = Icons.play_arrow;
        break;
      case SessionStatus.scheduled:
        statusColor = Colors.red;
        statusText = 'Sắp diễn ra';
        statusIcon = Icons.schedule;
        break;
      case SessionStatus.done:
        statusColor = Colors.blue;
        statusText = 'Đã kết thúc';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Không xác định';
        statusIcon = Icons.help_outline;
    }

    // 🔥 THÊM: Highlight đặc biệt cho buổi học đang diễn ra
    if (session.isHappeningNow) {
      statusColor = Colors.orange;
      statusText = 'ĐANG DIỄN RA NGAY BÂY GIỜ';
      statusIcon = Icons.notifications_active;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Model kết hợp Session + Course
class SessionWithCourse {
  final SessionModel session;
  final CourseModel? course;

  SessionWithCourse({
    required this.session,
    required this.course,
  });

  String get courseName => course?.name ?? 'Đang tải...';
  String get courseCode => course?.courseCode ?? session.courseId;
  String get room => session.room ?? 'Chưa có phòng';
}