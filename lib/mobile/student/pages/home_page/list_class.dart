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

  // 🎯 Hàm xác định trạng thái thời gian thực
  SessionStatus _calculateRealTimeStatus(SessionModel session) {
    final now = DateTime.now();
    final sessionStart = session.startDateTime;
    final sessionEnd = session.endDateTime;

    // Kiểm tra nếu thời gian không hợp lệ
    if (sessionStart.isAfter(sessionEnd)) {
      return SessionStatus.done;
    }

    // Tính toán trạng thái thực tế
    if (now.isBefore(sessionStart)) {
      return SessionStatus.scheduled;
    } else if (now.isAfter(sessionEnd)) {
      return SessionStatus.done;
    } else {
      return SessionStatus.ongoing;
    }
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
    // Sử dụng trạng thái tính toán thời gian thực
    final sessionsWithRealTimeStatus = sessionsWithCourse.map((sessionWithCourse) {
      final realTimeStatus = _calculateRealTimeStatus(sessionWithCourse.session);
      
      // Tạo session mới với trạng thái chính xác
      final updatedSession = sessionWithCourse.session.copyWith(status: realTimeStatus);
      
      return SessionWithCourse(
        session: updatedSession,
        course: sessionWithCourse.course,
      );
    }).toList();

    // Sắp xếp theo thứ tự ưu tiên màu
    final sortedSessions = List<SessionWithCourse>.from(sessionsWithRealTimeStatus)
      ..sort((a, b) {
        final statusOrder = {
          SessionStatus.ongoing: 1,
          SessionStatus.scheduled: 2,
          SessionStatus.done: 3,
        };
        
        final aOrder = statusOrder[a.session.status] ?? 4;
        final bOrder = statusOrder[b.session.status] ?? 4;
        
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

    // Tính toán trạng thái thực tế
    final realTimeStatus = _calculateRealTimeStatus(session);

    // 🎨 Xác định màu theo trạng thái THỰC TẾ
    Color statusColor;
    switch (realTimeStatus) {
      case SessionStatus.ongoing:
        statusColor = Colors.green;
        break;
      case SessionStatus.scheduled:
        statusColor = Colors.red;
        break;
      case SessionStatus.done:
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor, width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng đầu tiên - Tên môn học và trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên môn học
                Expanded(
                  child: _buildCourseNameSection(sessionWithCourse),
                ),
                const SizedBox(width: 12),
                // Trạng thái THỰC TẾ
                _buildSessionStatus(realTimeStatus, statusColor),
              ],
            ),
            const SizedBox(height: 8),

            // Dòng lớp học
            _buildInfoRow(
              icon: Icons.class_outlined,
              text: session.classId,
            ),
            const SizedBox(height: 4),

            // Phòng học và ngày học
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  text: session.room ?? 'Chưa có phòng',
                ),
                Text(
                  'Ngày ${session.dateDisplay}',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Giảng viên và thời gian
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
          ],
        ),
      ),
    );
  }

  // Widget trạng thái sử dụng trạng thái THỰC TẾ
  Widget _buildSessionStatus(SessionStatus realTimeStatus, Color statusColor) {
    String statusText;
    IconData statusIcon;

    switch (realTimeStatus) {
      case SessionStatus.ongoing:
        statusText = 'Đang diễn ra';
        statusIcon = Icons.play_arrow;
        break;
      case SessionStatus.scheduled:
        statusText = 'Sắp diễn ra';
        statusIcon = Icons.schedule;
        break;
      case SessionStatus.done:
        statusText = 'Đã kết thúc';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusText = 'Không xác định';
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 14, color: statusColor),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseNameSection(SessionWithCourse sessionWithCourse) {
    if (sessionWithCourse.course != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sessionWithCourse.courseName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
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
}

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