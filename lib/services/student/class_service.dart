import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/class_model.dart';
import '../../models/session_model.dart';
import '../../models/course_model.dart';
import '../firestore_service.dart';

class ClassService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== QUẢN LÝ LỚP HỌC ====================

  /// 🔹 Lấy thông tin lớp học theo ID
  Future<ClassModel?> getClassById(String classId) async {
    try {
      return await _firestoreService.getDocument<ClassModel>(classId);
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin lớp học: $e');
    }
  }

  /// 🔹 Lấy tất cả lớp học
  Future<List<ClassModel>> getAllClasses() async {
    try {
      return await _firestoreService.getAllDocuments<ClassModel>();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách lớp học: $e');
    }
  }

  /// 🔹 Lấy lớp học theo khoa/bộ môn
  Future<List<ClassModel>> getClassesByDepartment(String departmentId) async {
    try {
      return await _firestoreService.queryDocuments<ClassModel>(
        field: 'department_id',
        isEqualTo: departmentId,
      );
    } catch (e) {
      throw Exception('Lỗi khi lấy lớp học theo khoa: $e');
    }
  }

  /// 🔹 Lấy lớp học mà sinh viên đang tham gia
  Future<List<ClassModel>> getClassesByStudentId(String studentId) async {
    try {
      print('🔍 [DEBUG] Querying classes for student: $studentId');
      
      final classes = await _firestoreService.queryDocuments<ClassModel>(
        field: 'student_ids',
        arrayContains: studentId,
      );
      
      print('📚 [DEBUG] Found ${classes.length} classes for student $studentId');
      return classes;
    } catch (e) {
      print('❌ [DEBUG] Error in getClassesByStudentId: $e');
      throw Exception('Lỗi khi lấy lớp học của sinh viên: $e');
    }
  }

  // ==================== QUẢN LÝ BUỔI HỌC ====================

  /// 🔹 Lấy tất cả buổi học của một lớp
  Future<List<SessionModel>> getSessionsByClass(String classId) async {
    try {
      final sessions = await _firestoreService.queryDocuments<SessionModel>(
        field: 'class_id',
        isEqualTo: classId,
      );
      print('🕒 [DEBUG] Found ${sessions.length} sessions for class $classId');
      return sessions;
    } catch (e) {
      throw Exception('Lỗi khi lấy buổi học theo lớp: $e');
    }
  }

  /// 🔹 Lấy buổi học theo ngày
  Future<List<SessionModel>> getSessionsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final sessions = await _firestoreService.queryDocuments<SessionModel>(
        field: 'date',
        isGreaterThanOrEqualTo: startOfDay.toIso8601String(),
        isLessThanOrEqualTo: endOfDay.toIso8601String(),
      );
      
      print('📅 [DEBUG] Found ${sessions.length} sessions for date $date');
      return sessions;
    } catch (e) {
      throw Exception('Lỗi khi lấy buổi học theo ngày: $e');
    }
  }

  /// 🔹 Lấy buổi học của sinh viên theo ngày
  Future<List<SessionModel>> getStudentSessionsByDate({
    required String studentId,
    required DateTime date,
  }) async {
    try {
      print('🎯 [DEBUG] Getting sessions for student: $studentId on date: $date');

      // 1. Lấy các lớp mà sinh viên tham gia
      final studentClasses = await getClassesByStudentId(studentId);
      print('📚 [DEBUG] Student classes found: ${studentClasses.length}');
      
      if (studentClasses.isEmpty) {
        print('❌ [DEBUG] Student is not enrolled in any classes');
        return [];
      }

      // 2. Lấy tất cả session của các lớp đó
      final allSessions = <SessionModel>[];
      for (final classItem in studentClasses) {
        final sessions = await getSessionsByClass(classItem.id);
        print('🕒 [DEBUG] Sessions for class ${classItem.id}: ${sessions.length}');
        allSessions.addAll(sessions);
      }

      print('📦 [DEBUG] Total sessions before filtering: ${allSessions.length}');

      // 3. Lọc theo ngày
      final filteredSessions = allSessions.where((session) {
        final sessionDate = session.date;
        final isSameDate = sessionDate.year == date.year &&
            sessionDate.month == date.month &&
            sessionDate.day == date.day;
        
        print('   📅 Comparing: ${sessionDate} with $date → $isSameDate');
        return isSameDate;
      }).toList();

      print('🎉 [DEBUG] Final result: ${filteredSessions.length} sessions');
      return filteredSessions;
    } catch (e) {
      print('❌ [DEBUG] Error in getStudentSessionsByDate: $e');
      throw Exception('Lỗi khi lấy buổi học của sinh viên: $e');
    }
  }

  // 🔥 MỚI: Lấy buổi học với thông tin môn học đầy đủ
  Future<List<SessionWithCourse>> getStudentSessionsWithCourseInfo({
    required String studentId,
    required DateTime date,
  }) async {
    try {
      print('🎯 [DEBUG] Getting sessions with course info for student: $studentId');

      // 1. Lấy sessions cơ bản
      final sessions = await getStudentSessionsByDate(
        studentId: studentId,
        date: date,
      );

      print('📚 [DEBUG] Loading course info for ${sessions.length} sessions');

      // 2. Lấy thông tin course cho mỗi session
      final List<SessionWithCourse> result = [];

      for (final session in sessions) {
        try {
          final course = await _firestoreService.getDocument<CourseModel>(session.courseId);
          
          result.add(SessionWithCourse(
            session: session,
            course: course,
          ));

          print('✅ [DEBUG] Added session with course: ${course?.name ?? "Unknown"}');
        } catch (e) {
          print('❌ [DEBUG] Error loading course for session ${session.id}: $e');
          // Vẫn thêm session nhưng course = null
          result.add(SessionWithCourse(
            session: session,
            course: null,
          ));
        }
      }

      print('🎉 [DEBUG] Final result with course info: ${result.length} sessions');
      return result;
    } catch (e) {
      print('❌ [DEBUG] Error in getStudentSessionsWithCourseInfo: $e');
      throw Exception('Lỗi khi lấy buổi học với thông tin môn học: $e');
    }
  }

  // 🔥 MỚI: Lấy tên môn học từ courseId
  Future<String> getCourseName(String courseId) async {
    if (courseId.isEmpty) return 'Không xác định';
    
    try {
      final course = await _firestoreService.getDocument<CourseModel>(courseId);
      return course?.name ?? 'Môn học không tồn tại';
    } catch (e) {
      print('❌ [DEBUG] Error getting course name for $courseId: $e');
      return courseId; // Fallback về ID nếu lỗi
    }
  }

  // 🔥 MỚI: Lấy thông tin course theo ID
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      return await _firestoreService.getDocument<CourseModel>(courseId);
    } catch (e) {
      print('❌ [DEBUG] Error getting course by ID $courseId: $e');
      return null;
    }
  }

  /// 🔹 Lấy buổi học đang diễn ra của sinh viên
  Future<List<SessionModel>> getOngoingStudentSessions(String studentId) async {
    try {
      final now = DateTime.now();
      final todaySessions = await getStudentSessionsByDate(
        studentId: studentId,
        date: now,
      );

      return todaySessions.where((session) {
        return session.isHappeningNow && session.status == SessionStatus.ongoing;
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy buổi học đang diễn ra: $e');
    }
  }

  /// 🔹 Lấy buổi học sắp diễn ra của sinh viên
  Future<List<SessionModel>> getUpcomingStudentSessions(String studentId) async {
    try {
      final now = DateTime.now();
      final todaySessions = await getStudentSessionsByDate(
        studentId: studentId,
        date: now,
      );

      return todaySessions.where((session) {
        return session.status == SessionStatus.scheduled &&
            session.startDateTime.isAfter(now);
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy buổi học sắp diễn ra: $e');
    }
  }

  // ==================== TẠO VÀ CẬP NHẬT ====================

  /// 🔹 Tạo lớp học mới
  Future<void> createClass(ClassModel classModel) async {
    try {
      await _firestoreService.addDocument<ClassModel>(classModel);
      print('✅ Đã tạo lớp học: ${classModel.name}');
    } catch (e) {
      throw Exception('Lỗi khi tạo lớp học: $e');
    }
  }

  /// 🔹 Cập nhật lớp học
  Future<void> updateClass(String classId, ClassModel classModel) async {
    try {
      await _firestoreService.updateDocument<ClassModel>(classId, classModel.toMap());
      print('✅ Đã cập nhật lớp học: $classId');
    } catch (e) {
      throw Exception('Lỗi khi cập nhật lớp học: $e');
    }
  }

  /// 🔹 Thêm sinh viên vào lớp
  Future<void> addStudentToClass(String classId, String studentId) async {
    try {
      final classModel = await getClassById(classId);
      if (classModel != null) {
        final updatedClass = classModel.addStudent(studentId);
        await updateClass(classId, updatedClass);
        print('✅ Đã thêm sinh viên $studentId vào lớp $classId');
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm sinh viên vào lớp: $e');
    }
  }

  /// 🔹 Xóa sinh viên khỏi lớp
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    try {
      final classModel = await getClassById(classId);
      if (classModel != null) {
        final updatedClass = classModel.removeStudent(studentId);
        await updateClass(classId, updatedClass);
        print('✅ Đã xóa sinh viên $studentId khỏi lớp $classId');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa sinh viên khỏi lớp: $e');
    }
  }

  // ==================== STREAM REAL-TIME ====================

  /// 🔹 Stream danh sách lớp học của sinh viên
  Stream<List<ClassModel>> watchStudentClasses(String studentId) {
    return _firestoreService.watchQueryDocuments<ClassModel>(
      field: 'student_ids',
      arrayContains: studentId,
    );
  }

  /// 🔹 Stream buổi học theo lớp
  Stream<List<SessionModel>> watchSessionsByClass(String classId) {
    return _firestoreService.watchQueryDocuments<SessionModel>(
      field: 'class_id',
      isEqualTo: classId,
    );
  }

  // 🔥 MỚI: Stream buổi học với course info
  Stream<List<SessionWithCourse>> watchStudentSessionsWithCourseInfo({
    required String studentId,
    required DateTime date,
  }) {
    return _firestoreService.watchCollection<SessionModel>().asyncMap((sessions) async {
      // Lọc sessions theo student và date
      final studentClasses = await getClassesByStudentId(studentId);
      final classIds = studentClasses.map((c) => c.id).toList();
      
      final filteredSessions = sessions.where((session) {
        final isStudentInClass = classIds.contains(session.classId);
        final sessionDate = session.date;
        final isSameDate = sessionDate.year == date.year &&
            sessionDate.month == date.month &&
            sessionDate.day == date.day;
        
        return isStudentInClass && isSameDate;
      }).toList();

      // Lấy course info cho mỗi session
      final List<SessionWithCourse> result = [];
      for (final session in filteredSessions) {
        final course = await getCourseById(session.courseId);
        result.add(SessionWithCourse(
          session: session,
          course: course,
        ));
      }

      return result;
    });
  }

  // ==================== TIỆN ÍCH ====================

  /// 🔹 Lấy tên giảng viên theo ID
  Future<String> getLecturerNameById(String? lecturerId) async {
    if (lecturerId == null || lecturerId.isEmpty) {
      return 'Không rõ';
    }

    try {
      final doc = await _firestore.collection('users').doc(lecturerId).get();

      if (!doc.exists) {
        print('⚠️ [DEBUG] Không tìm thấy giảng viên có ID: $lecturerId');
        return 'Không tìm thấy';
      }

      final data = doc.data();
      final name = data?['name'] ?? data?['fullName'] ?? data?['displayName'];

      if (name == null || name.toString().trim().isEmpty) {
        print('⚠️ [DEBUG] Giảng viên $lecturerId không có trường name');
        return 'Không rõ';
      }

      print('👨‍🏫 [DEBUG] Lecturer $lecturerId → $name');
      return name;
    } catch (e) {
      print('❌ [DEBUG] Lỗi khi lấy tên giảng viên $lecturerId: $e');
      return 'Lỗi';
    }
  }

  /// 🔹 Kiểm tra sinh viên có trong lớp không
  Future<bool> isStudentInClass(String studentId, String classId) async {
    try {
      final classModel = await getClassById(classId);
      return classModel?.containsStudent(studentId) ?? false;
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra sinh viên trong lớp: $e');
    }
  }

  /// 🔹 Đếm số sinh viên trong lớp
  Future<int> getStudentCount(String classId) async {
    try {
      final classModel = await getClassById(classId);
      return classModel?.studentCount ?? 0;
    } catch (e) {
      throw Exception('Lỗi khi đếm số sinh viên: $e');
    }
  }
}

// 🔥 THÊM: Model kết hợp Session + Course
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
  
  // Các getter tiện ích khác
  String get displayInfo => '$courseName • $room';
  bool get hasCourseInfo => course != null;
  
  // Delegate các phương thức từ SessionModel
  DateTime get date => session.date;
  String get timeDisplay => session.timeDisplay;
  String get dateDisplay => session.dateDisplay;
  bool get isHappeningNow => session.isHappeningNow;
  SessionStatus get status => session.status;
}