import '../../models/attendance_model.dart' as attendance;
import '../../models/session_model.dart' as session;
import '../../models/course_model.dart';
import '../../services/firestore_service.dart';

class AttendanceHistory {
  final session.SessionModel sessionData;
  final attendance.AttendanceModel attendanceData;
  final CourseModel course;

  AttendanceHistory({
    required this.sessionData,
    required this.attendanceData,
    required this.course,
  });

  String get courseName => course.name;
  String get courseCode => course.courseCode ?? '';

  String get dateDisplay {
    final vietnameseDays = [
      'Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư',
      'Thứ năm', 'Thứ sáu', 'Thứ bảy'
    ];
    final dayOfWeek = vietnameseDays[sessionData.date.weekday % 7];
    return '$dayOfWeek, ${sessionData.date.day} tháng ${sessionData.date.month}, ${sessionData.date.year}';
  }

  String get timeDisplay => '${sessionData.startTime} - ${sessionData.endTime}';

  String get checkinTime {
    final time = attendanceData.timestamp.toDate();
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (attendanceData.status) {
      case attendance.AttendanceStatus.present:
        return 'Có mặt';
      case attendance.AttendanceStatus.late:
        return 'Muộn';
      case attendance.AttendanceStatus.absent:
        return 'Vắng';
    }
  }

  String get statusColor {
    switch (attendanceData.status) {
      case attendance.AttendanceStatus.present:
        return 'green';
      case attendance.AttendanceStatus.late:
        return 'orange';
      case attendance.AttendanceStatus.absent:
        return 'red';
    }
  }
}

class AttendanceHistoryService {
  final FirestoreService _firestore = FirestoreService();

  /// Lấy toàn bộ lịch sử điểm danh của sinh viên
  Future<List<AttendanceHistory>> getStudentAttendanceHistory(String studentId) async {
    try {
      final attendances = await _firestore.queryDocuments<attendance.AttendanceModel>(
        field: 'student_id',
        isEqualTo: studentId,
      );

      List<AttendanceHistory> history = [];

      for (final att in attendances) {
        try {
          final sess = await _firestore.getDocument<session.SessionModel>(att.sessionId);
          if (sess == null) continue;

          final courseData = await _firestore.getDocument<CourseModel>(sess.courseId);
          if (courseData == null) continue;

          history.add(AttendanceHistory(
            sessionData: sess,
            attendanceData: att,
            course: courseData,
          ));
        } catch (_) {
          continue;
        }
      }

      history.sort((a, b) => b.sessionData.date.compareTo(a.sessionData.date));
      return history;
    } catch (e) {
      print('Error in getStudentAttendanceHistory: $e');
      rethrow;
    }
  }

  /// Thống kê tổng hợp điểm danh
  Future<Map<String, dynamic>> getAttendanceStats(String studentId) async {
    final history = await getStudentAttendanceHistory(studentId);
    final total = history.length;
    final present = history.where((h) => h.attendanceData.status == attendance.AttendanceStatus.present).length;
    final late = history.where((h) => h.attendanceData.status == attendance.AttendanceStatus.late).length;
    final absent = history.where((h) => h.attendanceData.status == attendance.AttendanceStatus.absent).length;
    final attendanceRate = total > 0 ? ((present + late) / total * 100) : 0.0;

    return {
      'total': total,
      'present': present,
      'late': late,
      'absent': absent,
      'attendanceRate': attendanceRate,
    };
  }

  /// Lọc lịch sử theo trạng thái
  Future<List<AttendanceHistory>> getFilteredHistory(String studentId, String filter) async {
    final allHistory = await getStudentAttendanceHistory(studentId);
    switch (filter.toLowerCase()) {
      case 'có mặt':
        return allHistory.where((h) => h.attendanceData.status == attendance.AttendanceStatus.present).toList();
      case 'muộn':
        return allHistory.where((h) => h.attendanceData.status == attendance.AttendanceStatus.late).toList();
      case 'vắng':
        return allHistory.where((h) => h.attendanceData.status == attendance.AttendanceStatus.absent).toList();
      default:
        return allHistory;
    }
  }

  /// Lấy lịch sử theo khoảng thời gian
  Future<List<AttendanceHistory>> getHistoryByDateRange(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allHistory = await getStudentAttendanceHistory(studentId);

    return allHistory.where((h) {
      final sessionDate = h.sessionData.date;
      final afterStart = startDate == null || sessionDate.isAfter(startDate.subtract(const Duration(days: 1)));
      final beforeEnd = endDate == null || sessionDate.isBefore(endDate.add(const Duration(days: 1)));
      return afterStart && beforeEnd;
    }).toList();
  }

  /// Thống kê điểm danh theo từng môn học
  Future<Map<String, Map<String, dynamic>>> getStatsByCourse(String studentId) async {
    final history = await getStudentAttendanceHistory(studentId);
    final Map<String, List<AttendanceHistory>> courseGroups = {};

    for (final h in history) {
      courseGroups.putIfAbsent(h.course.id, () => []);
      courseGroups[h.course.id]!.add(h);
    }

    final Map<String, Map<String, dynamic>> courseStats = {};
    for (final entry in courseGroups.entries) {
      final courseHistory = entry.value;
      final total = courseHistory.length;
      final present = courseHistory.where((h) => h.attendanceData.status == attendance.AttendanceStatus.present).length;
      final late = courseHistory.where((h) => h.attendanceData.status == attendance.AttendanceStatus.late).length;
      final absent = courseHistory.where((h) => h.attendanceData.status == attendance.AttendanceStatus.absent).length;
      final rate = total > 0 ? ((present + late) / total * 100) : 0.0;

      courseStats[entry.key] = {
        'courseName': courseHistory.first.courseName,
        'total': total,
        'present': present,
        'late': late,
        'absent': absent,
        'attendanceRate': rate,
      };
    }

    return courseStats;
  }

  /// Stream real-time điểm danh
  Stream<List<AttendanceHistory>> watchStudentAttendanceHistory(String studentId) {
    return _firestore.watchQueryDocuments<attendance.AttendanceModel>(
      field: 'student_id',
      isEqualTo: studentId,
    ).asyncMap((attendances) async {
      List<AttendanceHistory> history = [];
      for (final att in attendances) {
        try {
          final sess = await _firestore.getDocument<session.SessionModel>(att.sessionId);
          final courseData = await _firestore.getDocument<CourseModel>(sess?.courseId ?? '');
          if (sess != null && courseData != null) {
            history.add(AttendanceHistory(
              sessionData: sess,
              attendanceData: att,
              course: courseData,
            ));
          }
        } catch (_) {}
      }
      history.sort((a, b) => b.sessionData.date.compareTo(a.sessionData.date));
      return history;
    });
  }

  /// Phân trang lịch sử điểm danh
  Future<List<AttendanceHistory>> getPaginatedHistory(
    String studentId, {
    int limit = 10,
    String? lastSessionId,
  }) async {
    final allHistory = await getStudentAttendanceHistory(studentId);

    if (lastSessionId == null) return allHistory.take(limit).toList();

    final startIndex = allHistory.indexWhere((h) => h.sessionData.id == lastSessionId) + 1;
    if (startIndex <= 0 || startIndex >= allHistory.length) return [];

    return allHistory.sublist(startIndex, (startIndex + limit).clamp(0, allHistory.length));
  }
}
