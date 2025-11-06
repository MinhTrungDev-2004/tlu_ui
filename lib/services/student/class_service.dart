import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/class_model.dart';
import '../../models/session_model.dart';
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
        field: 'departmentId',
        isEqualTo: departmentId,
      );
    } catch (e) {
      throw Exception('Lỗi khi lấy lớp học theo khoa: $e');
    }
  }

  /// 🔹 Lấy lớp học mà sinh viên đang tham gia (FIXED - DÙNG snake_case)
  Future<List<ClassModel>> getClassesByStudentId(String studentId) async {
    try {
      print('🔍 [DEBUG] Querying classes for student: $studentId');
      
      // THỬ CẢ 2 CÁCH
      // Cách 1: snake_case (khớp với ClassModel.toMap() hiện tại)
      final classesBySnakeCase = await _firestoreService.queryDocuments<ClassModel>(
        field: 'student_ids',  // ← snake_case
        arrayContains: studentId,
      );
      
      print('📚 [DEBUG] Found ${classesBySnakeCase.length} classes with snake_case');
      
      // Cách 2: camelCase (nếu bạn sửa ClassModel.toMap() sau này)
      final classesByCamelCase = await _firestoreService.queryDocuments<ClassModel>(
        field: 'studentIds',  // ← camelCase
        arrayContains: studentId,
      );
      
      print('📚 [DEBUG] Found ${classesByCamelCase.length} classes with camelCase');
      
      // Kết hợp kết quả
      final allClasses = [...classesBySnakeCase, ...classesByCamelCase];
      final uniqueClasses = allClasses.toSet().toList();
      
      print('🎯 [DEBUG] Total unique classes found: ${uniqueClasses.length}');
      return uniqueClasses;
      
    } catch (e) {
      print('❌ [DEBUG] Error in getClassesByStudentId: $e');
      throw Exception('Lỗi khi lấy lớp học của sinh viên: $e');
    }
  }

  /// 🔹 Lấy lớp học theo giảng viên (FIXED - DÙNG snake_case)
  Future<List<ClassModel>> getClassesByTeacher(String teacherId) async {
    try {
      return await _firestoreService.queryDocuments<ClassModel>(
        field: 'lecturer_id',  // ← snake_case
        isEqualTo: teacherId,
      );
    } catch (e) {
      throw Exception('Lỗi khi lấy lớp học theo giảng viên: $e');
    }
  }

  // ==================== QUẢN LÝ BUỔI HỌC ====================

  /// 🔹 Lấy tất cả buổi học của một lớp (FIXED - DÙNG snake_case)
  Future<List<SessionModel>> getSessionsByClass(String classId) async {
    try {
      final sessions = await _firestoreService.queryDocuments<SessionModel>(
        field: 'class_id',  // ← snake_case
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
      // Format date để query (chỉ lấy ngày, không giờ)
      final startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
      final endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

      final sessions = await _firestoreService.queryDocuments<SessionModel>(
        field: 'date',
        isGreaterThanOrEqualTo: startOfDay,
        isLessThanOrEqualTo: endOfDay,
      );
      
      print('📅 [DEBUG] Found ${sessions.length} sessions for date $date');
      return sessions;
    } catch (e) {
      throw Exception('Lỗi khi lấy buổi học theo ngày: $e');
    }
  }

  /// 🔹 Lấy buổi học của sinh viên theo ngày (FIXED VERSION)
  Future<List<SessionModel>> getStudentSessionsByDate({
    required String studentId,
    required DateTime date,
  }) async {
    try {
      print('🎯 [DEBUG] Getting sessions for student: $studentId on date: $date');

      // 1. Lấy các lớp mà sinh viên tham gia
      final studentClasses = await getClassesByStudentId(studentId);
      print('📚 [DEBUG] Student classes found: ${studentClasses.length}');
      
      for (final classItem in studentClasses) {
        print('   - Class: ${classItem.name} (${classItem.id}) - Students: ${classItem.studentIds?.length ?? 0}');
      }

      if (studentClasses.isEmpty) {
        print('❌ [DEBUG] Student is not enrolled in any classes');
        return [];
      }

      // 2. Lấy tất cả session của các lớp đó
      final allSessions = <SessionModel>[];
      for (final classItem in studentClasses) {
        final sessions = await getSessionsByClass(classItem.id);
        print('🕒 [DEBUG] Sessions for class ${classItem.id}: ${sessions.length}');
        
        for (final session in sessions) {
          final sessionDate = session.date.toDate();
          print('     - ${session.courseId} | ${sessionDate} | ${session.status.name}');
        }
        
        allSessions.addAll(sessions);
      }

      print('📦 [DEBUG] Total sessions before filtering: ${allSessions.length}');

      // 3. Lọc theo ngày
      final filteredSessions = allSessions.where((session) {
        final sessionDate = session.date.toDate();
        final isSameDate = sessionDate.year == date.year &&
            sessionDate.month == date.month &&
            sessionDate.day == date.day;
        
        print('   📅 Comparing: ${sessionDate} with $date → $isSameDate');
        return isSameDate;
      }).toList();

      print('🎉 [DEBUG] Final result: ${filteredSessions.length} sessions');
      for (final session in filteredSessions) {
        final start = session.startTime.toDate();
        final end = session.endTime.toDate();
        print('   ✅ ${session.courseId} | ${start.hour}:${start.minute}-${end.hour}:${end.minute} | ${session.status.name}');
      }
      
      return filteredSessions;
    } catch (e) {
      print('❌ [DEBUG] Error in getStudentSessionsByDate: $e');
      throw Exception('Lỗi khi lấy buổi học của sinh viên: $e');
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

  // ==================== DIRECT QUERY FOR DEBUG ====================

  /// 🔹 Query trực tiếp để debug (NEW)
  Future<void> debugDirectQuery(String studentId) async {
    print('\n🎯 [DIRECT DEBUG] Testing direct queries...');
    
    // 1. Kiểm tra user
    final userDoc = await _firestore.collection('users').doc(studentId).get();
    print('👤 User exists: ${userDoc.exists}');
    if (userDoc.exists) {
      print('   - classIds: ${userDoc.data()?['classIds']}');
      print('   - classId: ${userDoc.data()?['classId']}');
    }
    
    // 2. Query classes trực tiếp với snake_case
    final classesSnapshot = await _firestore.collection('classes')
        .where('student_ids', arrayContains: studentId)
        .get();
    print('🏫 Direct snake_case query: ${classesSnapshot.docs.length} classes');
    for (final doc in classesSnapshot.docs) {
      print('   - ${doc.id}: ${doc.data()['name']}');
      print('     student_ids: ${doc.data()['student_ids']}');
    }
    
    // 3. Query classes trực tiếp với camelCase
    final classesSnapshot2 = await _firestore.collection('classes')
        .where('studentIds', arrayContains: studentId)
        .get();
    print('🏫 Direct camelCase query: ${classesSnapshot2.docs.length} classes');
    
    // 4. Query sessions trực tiếp
    final sessionsSnapshot = await _firestore.collection('sessions')
        .where('class_id', isEqualTo: 'CSE123_02')
        .get();
    print('🕒 Direct sessions query: ${sessionsSnapshot.docs.length} sessions');
    for (final doc in sessionsSnapshot.docs) {
      final data = doc.data();
      print('   - ${doc.id}: ${data['course_id']} | ${data['date']?.toDate()}');
    }
  }

  // ==================== STREAM REAL-TIME ====================

  /// 🔹 Stream danh sách lớp học của sinh viên (FIXED)
  Stream<List<ClassModel>> watchStudentClasses(String studentId) {
    return _firestoreService.watchQueryDocuments<ClassModel>(
      field: 'student_ids',  // ← snake_case
      arrayContains: studentId,
    );
  }

  /// 🔹 Stream buổi học theo ngày
  Stream<List<SessionModel>> watchSessionsByDate(DateTime date) {
    final startOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day));
    final endOfDay = Timestamp.fromDate(DateTime(date.year, date.month, date.day, 23, 59, 59));

    return _firestoreService.watchQueryDocuments<SessionModel>(
      field: 'date',
      isGreaterThanOrEqualTo: startOfDay,
      isLessThanOrEqualTo: endOfDay,
    );
  }

  /// 🔹 Stream buổi học của sinh viên theo ngày (FIXED)
  Stream<List<SessionModel>> watchStudentSessionsByDate({
    required String studentId,
    required DateTime date,
  }) {
    return _firestoreService.watchCollection<SessionModel>().asyncMap((sessions) async {
      // Get student's classes first
      final studentClasses = await getClassesByStudentId(studentId);
      final classIds = studentClasses.map((c) => c.id).toList();
      
      return sessions.where((session) {
        final isStudentInClass = classIds.contains(session.classId);
        final sessionDate = session.date.toDate();
        final isSameDate = sessionDate.year == date.year &&
            sessionDate.month == date.month &&
            sessionDate.day == date.day;
        
        return isStudentInClass && isSameDate;
      }).toList();
    });
  }
    // ==================== GIẢNG VIÊN ====================

  /// 🔹 Lấy tên giảng viên theo ID
  Future<String> getLecturerNameById(String? lecturerId) async {
    if (lecturerId == null || lecturerId.isEmpty) {
      return 'Không rõ';
    }

    try {
      // 🔥 Truy vấn Firestore — đổi tên collection hoặc field tùy cấu trúc thật của bạn
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

}