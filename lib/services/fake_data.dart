import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../models/face_data_model.dart';
import '../models/class_model.dart';
import '../models/session_model.dart';
import '../models/course_model.dart';
import '../models/attendance_model.dart';
import 'firestore_service.dart';

class MockDataGenerator {
  final FirestoreService _service = FirestoreService();

  // ==== TẠO DỮ LIỆU MÔ PHỎNG ====
  Future<void> seedData() async {
    print('🔄 Bắt đầu tạo dữ liệu mô phỏng đầy đủ...');

    // ==== 1️⃣ GIẢNG VIÊN ====
    final teachers = [
      // GIỮ NGUYÊN GIẢNG VIÊN CŨ
      UserModel(
        uid: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        name: 'Kiều Tuấn Dũng',
        email: 'kieutuandung@tlu.edu.vn',
        role: 'teacher',
        lecturerCode: 'GV001',
        academicTitle: 'Tiến sĩ',
        faculty: 'Công nghệ thông tin',
        isFaceRegistered: false,
        faceUrls: null,
        faceDataId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // THÊM GIẢNG VIÊN MỚI
      UserModel(
        uid: 'teacher_002',
        name: 'PGS.TS Trần Thị Minh',
        email: 'tranthiminh@tlu.edu.vn',
        role: 'teacher',
        lecturerCode: 'GV002',
        academicTitle: 'Phó Giáo sư - Tiến sĩ',
        faculty: 'Công nghệ thông tin',
        teachingClassIds: ['KTPM3', 'KHMT1'],
        isFaceRegistered: false,
        faceUrls: null,
        faceDataId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        uid: 'teacher_003',
        name: 'TS Phạm Văn Hùng',
        email: 'phamvanhung@tlu.edu.vn',
        role: 'teacher',
        lecturerCode: 'GV003',
        academicTitle: 'Tiến sĩ',
        faculty: 'Khoa học máy tính',
        teachingClassIds: ['KTPM3'],
        isFaceRegistered: false,
        faceUrls: null,
        faceDataId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final teacher in teachers) {
      await _service.addDocument<UserModel>(teacher);
    }
    print('✅ Đã tạo ${teachers.length} giảng viên');

    // ==== 2️⃣ SINH VIÊN ====
    final students = [
      // GIỮ NGUYÊN SINH VIÊN CŨ
      UserModel(
        uid: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        name: 'Lê Đức Chiến',
        email: 'leducchien@sv.tlu.edu.vn',
        role: 'student',
        studentCode: '2251172253',
        departmentId: 'CNTT',
        classId: 'KTPM3',
        classIds: ['KTPM3'],
        isFaceRegistered: false,
        faceUrls: [],
        faceDataId: 'face_DP1KnG7Tp4X5Due249TmStmCtwl1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // THÊM SINH VIÊN MỚI
      UserModel(
        uid: 'student_002',
        name: 'Nguyễn Thị Hương',
        email: 'nguyenthihuong@sv.tlu.edu.vn',
        role: 'student',
        studentCode: '2251172001',
        departmentId: 'CNTT',
        classId: 'KTPM3',
        classIds: ['KTPM3'],
        isFaceRegistered: false,
        faceUrls: [],
        faceDataId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        uid: 'student_003',
        name: 'Trần Văn Nam',
        email: 'tranvannam@sv.tlu.edu.vn',
        role: 'student',
        studentCode: '2251172002',
        departmentId: 'CNTT',
        classId: 'KTPM3',
        classIds: ['KTPM3'],
        isFaceRegistered: false,
        faceUrls: [],
        faceDataId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        uid: 'student_004',
        name: 'Phạm Thị Mai',
        email: 'phamthimai@sv.tlu.edu.vn',
        role: 'student',
        studentCode: '2251172003',
        departmentId: 'CNTT',
        classId: 'KHMT1',
        classIds: ['KHMT1'],
        isFaceRegistered: false,
        faceUrls: [],
        faceDataId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        uid: 'student_005',
        name: 'Hoàng Văn Đức',
        email: 'hoangvanduc@sv.tlu.edu.vn',
        role: 'student',
        studentCode: '2251172004',
        departmentId: 'CNTT',
        classId: 'KHMT1',
        classIds: ['KHMT1'],
        isFaceRegistered: false,
        faceUrls: [],
        faceDataId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final student in students) {
      await _service.addDocument<UserModel>(student);
    }
    print('✅ Đã tạo ${students.length} sinh viên');

    // ==== 3️⃣ FACE DATA ====
    // GIỮ NGUYÊN FACE DATA CŨ
    final faceData = FaceDataModel(
      id: 'face_DP1KnG7Tp4X5Due249TmStmCtwl1',
      userId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
      userEmail: 'leducchien@sv.tlu.edu.vn',
      userRole: 'student',
      poseImageUrls: {},
      poseEmbeddings: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      version: 0,
    );

    await _service.addDocument<FaceDataModel>(faceData);
    print('✅ Đã tạo face data cho sinh viên');

    // ==== 4️⃣ MÔN HỌC ====
    final courses = [
      // GIỮ NGUYÊN MÔN HỌC CŨ
      CourseModel(
        id: 'CSE123',
        name: 'Lập trình Flutter',
        departmentId: 'CNTT',
        lecturerIds: ['qEWuN8OEaEVdycX0Dhf1xzU6ijp1'],
        courseCode: 'CSE123',
        description: 'Lập trình di động với Flutter',
        credits: 3,
        semester: 'HK1-2024',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      // THÊM MÔN HỌC MỚI
      CourseModel(
        id: 'CSE101',
        name: 'Lập trình Cơ bản',
        departmentId: 'CNTT',
        lecturerIds: ['teacher_002'],
        courseCode: 'CSE101',
        description: 'Môn học cung cấp kiến thức nền tảng về lập trình',
        credits: 3,
        semester: 'HK1-2024',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      CourseModel(
        id: 'CSE201',
        name: 'Cấu trúc dữ liệu và Giải thuật',
        departmentId: 'CNTT',
        lecturerIds: ['teacher_003'],
        courseCode: 'CSE201',
        description: 'Môn học về các cấu trúc dữ liệu và thuật toán cơ bản',
        credits: 4,
        semester: 'HK1-2024',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      CourseModel(
        id: 'CSE301',
        name: 'Cơ sở dữ liệu',
        departmentId: 'CNTT',
        lecturerIds: ['teacher_002', 'teacher_003'],
        courseCode: 'CSE301',
        description: 'Môn học về thiết kế và quản trị cơ sở dữ liệu',
        credits: 3,
        semester: 'HK1-2024',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
    ];

    for (final course in courses) {
      await _service.addDocument<CourseModel>(course);
    }
    print('✅ Đã tạo ${courses.length} môn học');

    // ==== 5️⃣ LỚP HỌC ====
    final classes = [
      // GIỮ NGUYÊN LỚP HỌC CŨ
      ClassModel(
        id: 'KTPM3',
        name: '64KTPM3',
        departmentId: 'CNTT',
        headTeacherId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        courseIds: ['CSE123', 'CSE101', 'CSE201'],
        studentIds: ['DP1KnG7Tp4X5Due249TmStmCtwl1', 'student_002', 'student_003'],
        sessionIds: ['session_1', 'session_2', 'session_3'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      // THÊM LỚP HỌC MỚI
      ClassModel(
        id: 'KHMT1',
        name: '64KHMT1',
        departmentId: 'CNTT',
        headTeacherId: 'teacher_002',
        courseIds: ['CSE301', 'CSE101'],
        studentIds: ['student_004', 'student_005'],
        sessionIds: ['session_4', 'session_5'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
    ];

    for (final classModel in classes) {
      await _service.addDocument<ClassModel>(classModel);
    }
    print('✅ Đã tạo ${classes.length} lớp học');

    // ==== 6️⃣ BUỔI HỌC ====
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1)); // Thứ 2 đầu tuần
    
    final sessions = [
      // GIỮ NGUYÊN BUỔI HỌC CŨ
      SessionModel(
        id: 'session_1',
        courseId: 'CSE123',
        classId: 'KTPM3',
        date: now,
        startTime: '07:00',
        endTime: '09:30',
        room: 'P.301-A1',
        lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        attendanceIds: [],
        status: SessionStatus.done,
        qrCode: null,
        qrExpiry: null,
        isRecurring: false,
        repeatDays: [],
        repeatUntil: null,
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      // THÊM BUỔI HỌC MỚI
      SessionModel(
        id: 'session_2',
        courseId: 'CSE101',
        classId: 'KTPM3',
        date: currentWeekStart.add(const Duration(days: 1)), // Thứ 3
        startTime: '09:45',
        endTime: '12:15',
        room: 'P.302-A1',
        lecturerId: 'teacher_002',
        attendanceIds: [],
        status: SessionStatus.ongoing,
        qrCode: null,
        qrExpiry: null,
        isRecurring: false,
        repeatDays: [],
        repeatUntil: null,
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_3',
        courseId: 'CSE201',
        classId: 'KTPM3',
        date: currentWeekStart.add(const Duration(days: 2)), // Thứ 4
        startTime: '13:30',
        endTime: '16:00',
        room: 'P.303-A1',
        lecturerId: 'teacher_003',
        attendanceIds: [],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: false,
        repeatDays: [],
        repeatUntil: null,
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_4',
        courseId: 'CSE301',
        classId: 'KHMT1',
        date: currentWeekStart.add(const Duration(days: 3)), // Thứ 5
        startTime: '07:00',
        endTime: '09:30',
        room: 'P.304-A1',
        lecturerId: 'teacher_002',
        attendanceIds: [],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: false,
        repeatDays: [],
        repeatUntil: null,
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_5',
        courseId: 'CSE101',
        classId: 'KHMT1',
        date: currentWeekStart.add(const Duration(days: 4)), // Thứ 6
        startTime: '09:45',
        endTime: '12:15',
        room: 'P.305-A1',
        lecturerId: 'teacher_002',
        attendanceIds: [],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: false,
        repeatDays: [],
        repeatUntil: null,
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final session in sessions) {
      await _service.addDocument<SessionModel>(session);
    }
    print('✅ Đã tạo ${sessions.length} buổi học');

    print('🎉 ĐÃ TẠO DỮ LIỆU MÔ PHỎNG THÀNH CÔNG!');
    print('📊 Tổng quan dữ liệu:');
    print('   👨‍🏫 Giảng viên: ${teachers.length}');
    print('   👨‍🎓 Sinh viên: ${students.length}');
    print('   📚 Môn học: ${courses.length}');
    print('   🏫 Lớp học: ${classes.length}');
    print('   📅 Buổi học: ${sessions.length}');
    print('   🎭 Face data: 1');
  }

  // ==== XÓA DỮ LIỆU ====
  Future<void> clearMockData() async {
    print('🗑️ Đang xóa toàn bộ dữ liệu mô phỏng...');
    try {
      final collections = [
        'users',
        'face_data',
        'classes',
        'sessions',
        'courses',
        'attendances'
      ];

      for (final collection in collections) {
        final snapshot = await FirebaseFirestore.instance.collection(collection).get();

        if (snapshot.docs.isEmpty) {
          print('⚠️ Không có dữ liệu trong collection: $collection');
          continue;
        }

        final batch = FirebaseFirestore.instance.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        print('✅ Đã xóa collection: $collection');
      }

      print('🧹 Dữ liệu mô phỏng đã được xóa hoàn toàn!');
    } catch (e) {
      print('❌ Lỗi khi xóa dữ liệu: $e');
    }
  }

  // ==== XEM THỐNG KÊ DỮ LIỆU ====
  Future<void> showDataStats() async {
    print('📈 THỐNG KÊ DỮ LIỆU HIỆN CÓ:');
    
    final collections = ['users', 'classes', 'sessions', 'courses', 'face_data'];
    
    for (final collection in collections) {
      final snapshot = await FirebaseFirestore.instance.collection(collection).get();
      print('   $collection: ${snapshot.docs.length} bản ghi');
    }
  }
}