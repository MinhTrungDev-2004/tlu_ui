
import '../../models/attendance_model.dart';
import '../../models/session_model.dart';
import '../../models/course_model.dart';
import '../../services/firestore_service.dart';

class AttendanceHistory {
  final SessionModel session;
  final AttendanceModel attendance;
  final CourseModel course;

  AttendanceHistory({
    required this.session,
    required this.attendance,
    required this.course,
  });

  String get courseName => course.name;
  String get courseCode => course.courseCode ?? '';

  String get dateDisplay {
    final vietnameseDays = ['Chủ nhật', 'Thứ hai', 'Thứ ba', 'Thứ tư', 'Thứ năm', 'Thứ sáu', 'Thứ bảy'];
    final dayOfWeek = vietnameseDays[session.date.weekday % 7];
    return '$dayOfWeek, ${session.date.day} tháng ${session.date.month}, ${session.date.year}';
  }

  String get timeDisplay => '${session.startTime} - ${session.endTime}';

  String get checkinTime {
    final time = attendance.timestamp.toDate();
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get statusText {
    switch (attendance.status) {
      case AttendanceStatus.present:
        return 'Có mặt';
      case AttendanceStatus.late:
        return 'Muộn';
      case AttendanceStatus.absent:
        return 'Vắng';
    }
  }

  // Thêm color cho UI
  String get statusColor {
    switch (attendance.status) {
      case AttendanceStatus.present:
        return 'green';
      case AttendanceStatus.late:
        return 'orange';
      case AttendanceStatus.absent:
        return 'red';
    }
  }
}

class AttendanceHistoryService {
  final FirestoreService _firestore = FirestoreService();

  /// 📊 Lấy toàn bộ lịch sử điểm danh của sinh viên - ĐÃ SỬA
  Future<List<AttendanceHistory>> getStudentAttendanceHistory(String studentId) async {
    try {
      print('🔄 Loading attendance history for student: $studentId');

      // 1. Lấy tất cả attendance records của student - SỬA: dùng queryDocuments
      final attendances = await _firestore.queryDocuments<AttendanceModel>(
        field: 'student_id',
        isEqualTo: studentId,
      );

      print('📝 Found ${attendances.length} attendance records');

      List<AttendanceHistory> history = [];

      for (final attendance in attendances) {
        try {
          // 2. Lấy thông tin session - SỬA: dùng getDocument
          final session = await _firestore.getDocument<SessionModel>(attendance.sessionId);
          if (session == null) {
            print('⚠️ Session not found: ${attendance.sessionId}');
            continue;
          }

          // 3. Lấy thông tin course - SỬA: dùng getDocument
          final course = await _firestore.getDocument<CourseModel>(session.courseId);
          if (course == null) {
            print('⚠️ Course not found: ${session.courseId}');
            continue;
          }

          history.add(AttendanceHistory(
            session: session,
            attendance: attendance,
            course: course,
          ));

          print('✅ Added history for session: ${session.id}');

        } catch (e) {
          print('❌ Error processing attendance record: $e');
          continue;
        }
      }

      // Sắp xếp theo thời gian giảm dần (mới nhất đầu tiên)
      history.sort((a, b) => b.session.date.compareTo(a.session.date));

      print('🎉 Loaded ${history.length} history items');
      return history;

    } catch (e) {
      print('💥 Error in getStudentAttendanceHistory: $e');
      rethrow;
    }
  }

  /// 📈 Thống kê chuyên cần - ĐÃ SỬA
  Future<Map<String, dynamic>> getAttendanceStats(String studentId) async {
    try {
      final history = await getStudentAttendanceHistory(studentId);
      
      if (history.isEmpty) {
        return {
          'total': 0,
          'present': 0,
          'absent': 0,
          'late': 0,
          'attendanceRate': 0.0,
        };
      }

      final total = history.length;
      final present = history.where((h) => h.attendance.status == AttendanceStatus.present).length;
      final late = history.where((h) => h.attendance.status == AttendanceStatus.late).length;
      final absent = history.where((h) => h.attendance.status == AttendanceStatus.absent).length;
      
      // Tính tỷ lệ có mặt (present + late đều tính là đi học)
      final attendanceRate = total > 0 ? ((present + late) / total * 100) : 0.0;

      return {
        'total': total,
        'present': present,
        'absent': absent,
        'late': late,
        'attendanceRate': attendanceRate,
      };
    } catch (e) {
      print('💥 Error in getAttendanceStats: $e');
      rethrow;
    }
  }

  /// 🔍 Lọc lịch sử theo trạng thái - ĐÃ SỬA
  Future<List<AttendanceHistory>> getFilteredHistory(
    String studentId, 
    String filter
  ) async {
    final allHistory = await getStudentAttendanceHistory(studentId);
    
    switch (filter.toLowerCase()) {
      case 'có mặt':
        return allHistory.where((h) => h.attendance.status == AttendanceStatus.present).toList();
      case 'muộn':
        return allHistory.where((h) => h.attendance.status == AttendanceStatus.late).toList();
      case 'vắng':
        return allHistory.where((h) => h.attendance.status == AttendanceStatus.absent).toList();
      default:
        return allHistory;
    }
  }

  /// 📅 Lấy lịch sử theo khoảng thời gian - ĐÃ SỬA
  Future<List<AttendanceHistory>> getHistoryByDateRange(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allHistory = await getStudentAttendanceHistory(studentId);
    
    if (startDate == null && endDate == null) {
      return allHistory;
    }

    return allHistory.where((history) {
      final sessionDate = history.session.date;
      final afterStart = startDate == null || sessionDate.isAfter(startDate.subtract(const Duration(days: 1)));
      final beforeEnd = endDate == null || sessionDate.isBefore(endDate.add(const Duration(days: 1)));
      return afterStart && beforeEnd;
    }).toList();
  }

  /// 🎯 Lấy thống kê theo môn học - ĐÃ SỬA
  Future<Map<String, Map<String, dynamic>>> getStatsByCourse(String studentId) async {
    final history = await getStudentAttendanceHistory(studentId);
    final Map<String, List<AttendanceHistory>> courseGroups = {};

    // Nhóm theo course
    for (final item in history) {
      final courseId = item.course.id;
      if (!courseGroups.containsKey(courseId)) {
        courseGroups[courseId] = [];
      }
      courseGroups[courseId]!.add(item);
    }

    // Tính thống kê cho từng course
    final Map<String, Map<String, dynamic>> courseStats = {};
    
    for (final entry in courseGroups.entries) {
      final courseId = entry.key;
      final courseHistory = entry.value;
      final courseName = courseHistory.first.courseName;

      final total = courseHistory.length;
      final present = courseHistory.where((h) => h.attendance.status == AttendanceStatus.present).length;
      final late = courseHistory.where((h) => h.attendance.status == AttendanceStatus.late).length;
      final absent = courseHistory.where((h) => h.attendance.status == AttendanceStatus.absent).length;
      final rate = total > 0 ? ((present + late) / total * 100) : 0.0;

      courseStats[courseId] = {
        'courseName': courseName,
        'total': total,
        'present': present,
        'late': late,
        'absent': absent,
        'attendanceRate': rate,
      };
    }

    return courseStats;
  }

  /// 🔥 Stream real-time cho lịch sử điểm danh - MỚI THÊM
  Stream<List<AttendanceHistory>> watchStudentAttendanceHistory(String studentId) {
    return _firestore.watchQueryDocuments<AttendanceModel>(
      field: 'student_id',
      isEqualTo: studentId,
    ).asyncMap((attendances) async {
      List<AttendanceHistory> history = [];

      for (final attendance in attendances) {
        try {
          final session = await _firestore.getDocument<SessionModel>(attendance.sessionId);
          final course = await _firestore.getDocument<CourseModel>(session?.courseId ?? '');
          
          if (session != null && course != null) {
            history.add(AttendanceHistory(
              session: session,
              attendance: attendance,
              course: course,
            ));
          }
        } catch (e) {
          print('❌ Error in stream: $e');
        }
      }

      history.sort((a, b) => b.session.date.compareTo(a.session.date));
      return history;
    });
  }

  /// 📊 Lấy lịch sử với phân trang - MỚI THÊM
  Future<List<AttendanceHistory>> getPaginatedHistory(
    String studentId, {
    int limit = 10,
    String? lastSessionId,
  }) async {
    try {
      // Lấy tất cả rồi phân trang (có thể optimize sau)
      final allHistory = await getStudentAttendanceHistory(studentId);
      
      if (lastSessionId == null) {
        return allHistory.take(limit).toList();
      }

      // Tìm vị trí bắt đầu
      final startIndex = allHistory.indexWhere((h) => h.session.id == lastSessionId) + 1;
      if (startIndex <= 0 || startIndex >= allHistory.length) {
        return [];
      }

      return allHistory.sublist(startIndex, startIndex + limit);
    } catch (e) {
      print('💥 Error in getPaginatedHistory: $e');
      return [];
    }
  }
}