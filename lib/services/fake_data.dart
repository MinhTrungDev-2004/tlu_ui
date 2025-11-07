import '../models/user/user_model.dart';
import '../models/face_data_model.dart';
import '../models/class_model.dart';
import '../models/session_model.dart';
import '../models/course_model.dart';
import '../models/attendance_model.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockDataGenerator {
  final FirestoreService _service = FirestoreService();

  Future<void> seedData() async {
    print('🔄 Bắt đầu tạo dữ liệu mô phỏng đầy đủ...');

    // ==== 1️⃣ GIẢNG VIÊN ====
    final teachers = [
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
      UserModel(
        uid: 'teacher_2',
        name: 'Nguyễn Thị Hương',
        email: 'nguyenthihuong@tlu.edu.vn',
        role: 'teacher',
        lecturerCode: 'GV002',
        academicTitle: 'Thạc sĩ',
        faculty: 'Công nghệ thông tin',
        isFaceRegistered: false,
        faceUrls: null,
        faceDataId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      UserModel(
        uid: 'teacher_3',
        name: 'Trần Văn Minh',
        email: 'tranvanminh@tlu.edu.vn',
        role: 'teacher',
        lecturerCode: 'GV003',
        academicTitle: 'Tiến sĩ',
        faculty: 'Toán học',
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
    final student = UserModel(
      uid: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
      name: 'Lê Đức Chiến',
      email: 'leducchien@sv.tlu.edu.vn',
      role: 'student',
      studentCode: '2251172253',
      departmentId: 'CNTT',
      isFaceRegistered: false,
      faceUrls: [],
      faceDataId: 'face_DP1KnG7Tp4X5Due249TmStmCtwl1',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _service.addDocument<UserModel>(student);
    print('✅ Đã tạo sinh viên: ${student.name}');

    // ==== 3️⃣ FACE DATA CHO SINH VIÊN ====
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

    // ==== 4️⃣ MÔN HỌC (COURSES) - ĐA DẠNG ====
    final courses = [
      CourseModel(
        id: 'CT101',
        name: 'Lập trình Flutter',
        departmentId: 'CNTT',
        lecturerIds: ['qEWuN8OEaEVdycX0Dhf1xzU6ijp1'],
        courseCode: 'CT101',
        description: 'Môn học lập trình di động với Flutter và Dart',
        credits: 3,
        semester: 'HK1-2024',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      CourseModel(
        id: 'CT102',
        name: 'Cấu trúc dữ liệu và giải thuật',
        departmentId: 'CNTT',
        lecturerIds: ['teacher_2'],
        courseCode: 'CT102',
        description: 'Môn học về cấu trúc dữ liệu và thuật toán cơ bản',
        credits: 4,
        semester: 'HK1-2024',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      CourseModel(
        id: 'TO101',
        name: 'Toán cao cấp',
        departmentId: 'TOAN',
        lecturerIds: ['teacher_3'],
        courseCode: 'TO101',
        description: 'Môn toán cao cấp cho kỹ sư',
        credits: 3,
        semester: 'HK1-2024',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      CourseModel(
        id: 'CT201',
        name: 'Cơ sở dữ liệu',
        departmentId: 'CNTT',
        lecturerIds: ['qEWuN8OEaEVdycX0Dhf1xzU6ijp1'],
        courseCode: 'CT201',
        description: 'Môn học về hệ quản trị cơ sở dữ liệu',
        credits: 3,
        semester: 'HK1-2024',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      CourseModel(
        id: 'CT301',
        name: 'Trí tuệ nhân tạo',
        departmentId: 'CNTT',
        lecturerIds: ['teacher_2'],
        courseCode: 'CT301',
        description: 'Môn học về AI và Machine Learning',
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

    // ==== 5️⃣ LỚP HỌC - SINH VIÊN THAM GIA NHIỀU LỚP ====
    final classes = [
      ClassModel(
        id: 'CNTT-01-K62',
        name: 'Công nghệ thông tin 01 Khóa 62',
        departmentId: 'CNTT',
        headTeacherId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        courseIds: ['CT101', 'CT102'],
        studentIds: ['DP1KnG7Tp4X5Due249TmStmCtwl1'],
        sessionIds: ['session_1', 'session_2', 'session_3', 'session_4', 'session_5', 'session_6'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      ClassModel(
        id: 'CNTT-02-K62',
        name: 'Công nghệ thông tin 02 Khóa 62',
        departmentId: 'CNTT',
        headTeacherId: 'teacher_2',
        courseIds: ['CT201', 'CT301'],
        studentIds: ['DP1KnG7Tp4X5Due249TmStmCtwl1'],
        sessionIds: ['session_7', 'session_8', 'session_9', 'session_10'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
      ClassModel(
        id: 'TOAN-01-K62',
        name: 'Toán ứng dụng 01 Khóa 62',
        departmentId: 'TOAN',
        headTeacherId: 'teacher_3',
        courseIds: ['TO101'],
        studentIds: ['DP1KnG7Tp4X5Due249TmStmCtwl1'],
        sessionIds: ['session_11', 'session_12'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      ),
    ];

    for (final classModel in classes) {
      await _service.addDocument<ClassModel>(classModel);
    }
    print('✅ Đã tạo ${classes.length} lớp học cho sinh viên');

    // ==== 6️⃣ BUỔI HỌC - ĐA DẠNG TRONG CÙNG NGÀY ====
    final now = DateTime.now();
    final sessions = [
      // === BUỔI SÁNG (07:00 - 11:30) ===
      SessionModel(
        id: 'session_1',
        courseId: 'CT101',
        classId: 'CNTT-01-K62',
        date: DateTime(now.year, now.month, now.day),
        startTime: '07:00',
        endTime: '08:30',
        room: 'P.301-A1',
        lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        attendanceIds: ['attendance_1'],
        status: SessionStatus.done,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_2',
        courseId: 'CT102',
        classId: 'CNTT-01-K62',
        date: DateTime(now.year, now.month, now.day),
        startTime: '08:45',
        endTime: '10:15',
        room: 'P.302-A1',
        lecturerId: 'teacher_2',
        attendanceIds: ['attendance_2'],
        status: SessionStatus.ongoing,
        qrCode: 'qr_active_123',
        qrExpiry: DateTime.now().add(const Duration(minutes: 30)),
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_3',
        courseId: 'TO101',
        classId: 'TOAN-01-K62',
        date: DateTime(now.year, now.month, now.day),
        startTime: '10:30',
        endTime: '11:30',
        room: 'P.201-B1',
        lecturerId: 'teacher_3',
        attendanceIds: ['attendance_3'],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // === BUỔI CHIỀU (13:00 - 17:30) ===
      SessionModel(
        id: 'session_4',
        courseId: 'CT201',
        classId: 'CNTT-02-K62',
        date: DateTime(now.year, now.month, now.day),
        startTime: '13:00',
        endTime: '14:30',
        room: 'P.401-A2',
        lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        attendanceIds: ['attendance_4'],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_5',
        courseId: 'CT301',
        classId: 'CNTT-02-K62',
        date: DateTime(now.year, now.month, now.day),
        startTime: '14:45',
        endTime: '16:15',
        room: 'Lab.101-C1',
        lecturerId: 'teacher_2',
        attendanceIds: ['attendance_5'],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_6',
        courseId: 'CT101',
        classId: 'CNTT-01-K62',
        date: DateTime(now.year, now.month, now.day),
        startTime: '16:30',
        endTime: '17:30',
        room: 'Lab.201-C1',
        lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        attendanceIds: ['attendance_6'],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // === BUỔI TỐI (18:00 - 21:00) ===
      SessionModel(
        id: 'session_7',
        courseId: 'CT201',
        classId: 'CNTT-02-K62',
        date: DateTime(now.year, now.month, now.day),
        startTime: '18:00',
        endTime: '19:30',
        room: 'P.301-A1',
        lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        attendanceIds: ['attendance_7'],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_8',
        courseId: 'TO101',
        classId: 'TOAN-01-K62',
        date: DateTime(now.year, now.month, now.day),
        startTime: '19:45',
        endTime: '21:00',
        room: 'P.202-B1',
        lecturerId: 'teacher_3',
        attendanceIds: ['attendance_8'],
        status: SessionStatus.scheduled,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // === BUỔI HỌC TRONG QUÁ KHỨ (ĐỂ TEST LỊCH SỬ) ===
      SessionModel(
        id: 'session_9',
        courseId: 'CT101',
        classId: 'CNTT-01-K62',
        date: DateTime(now.year, now.month, now.day - 1), // Hôm qua
        startTime: '07:00',
        endTime: '08:30',
        room: 'P.301-A1',
        lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        attendanceIds: ['attendance_9'],
        status: SessionStatus.done,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_10',
        courseId: 'CT102',
        classId: 'CNTT-01-K62',
        date: DateTime(now.year, now.month, now.day - 2), // 2 ngày trước
        startTime: '08:45',
        endTime: '10:15',
        room: 'P.302-A1',
        lecturerId: 'teacher_2',
        attendanceIds: ['attendance_10'],
        status: SessionStatus.done,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_11',
        courseId: 'TO101',
        classId: 'TOAN-01-K62',
        date: DateTime(now.year, now.month, now.day - 3), // 3 ngày trước
        startTime: '10:30',
        endTime: '11:30',
        room: 'P.201-B1',
        lecturerId: 'teacher_3',
        attendanceIds: ['attendance_11'],
        status: SessionStatus.done,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      SessionModel(
        id: 'session_12',
        courseId: 'CT201',
        classId: 'CNTT-02-K62',
        date: DateTime(now.year, now.month, now.day - 4), // 4 ngày trước
        startTime: '13:00',
        endTime: '14:30',
        room: 'P.401-A2',
        lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        attendanceIds: ['attendance_12'],
        status: SessionStatus.done,
        qrCode: null,
        qrExpiry: null,
        isRecurring: true,
        repeatDays: [1, 3, 5],
        repeatUntil: DateTime(2025, 2, 28),
        parentSessionId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final session in sessions) {
      await _service.addDocument<SessionModel>(session);
    }
    print('✅ Đã tạo ${sessions.length} buổi học');

    // ==== 7️⃣ DỮ LIỆU ĐIỂM DANH - ĐẦY ĐỦ TRẠNG THÁI ====
    final attendances = [
      // === HÔM NAY ===
      // Buổi sáng - CÓ MẶT đúng giờ
      AttendanceModel(
        id: 'attendance_1',
        sessionId: 'session_1',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-01-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 7, 5)),
        status: AttendanceStatus.present,
      ),
      // Buổi sáng - ĐI MUỘN
      AttendanceModel(
        id: 'attendance_2',
        sessionId: 'session_2',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-01-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 9, 0)), // Muộn 15 phút
        status: AttendanceStatus.late,
      ),
      // Buổi sáng - VẮNG
      AttendanceModel(
        id: 'attendance_3',
        sessionId: 'session_3',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'TOAN-01-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 10, 30)),
        status: AttendanceStatus.absent,
      ),
      // Buổi chiều - CÓ MẶT
      AttendanceModel(
        id: 'attendance_4',
        sessionId: 'session_4',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-02-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 13, 2)),
        status: AttendanceStatus.present,
      ),
      // Buổi chiều - ĐI MUỘN
      AttendanceModel(
        id: 'attendance_5',
        sessionId: 'session_5',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-02-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 15, 0)), // Muộn 15 phút
        status: AttendanceStatus.late,
      ),
      // Buổi chiều - CÓ MẶT
      AttendanceModel(
        id: 'attendance_6',
        sessionId: 'session_6',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-01-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 16, 28)),
        status: AttendanceStatus.present,
      ),
      // Buổi tối - VẮNG
      AttendanceModel(
        id: 'attendance_7',
        sessionId: 'session_7',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-02-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 18, 0)),
        status: AttendanceStatus.absent,
      ),
      // Buổi tối - CÓ MẶT
      AttendanceModel(
        id: 'attendance_8',
        sessionId: 'session_8',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'TOAN-01-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 19, 40)),
        status: AttendanceStatus.present,
      ),

      // === QUÁ KHỨ - ĐỂ TEST LỊCH SỬ ===
      // Hôm qua - CÓ MẶT
      AttendanceModel(
        id: 'attendance_9',
        sessionId: 'session_9',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-01-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day - 1, 7, 3)),
        status: AttendanceStatus.present,
      ),
      // 2 ngày trước - VẮNG
      AttendanceModel(
        id: 'attendance_10',
        sessionId: 'session_10',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-01-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day - 2, 8, 45)),
        status: AttendanceStatus.absent,
      ),
      // 3 ngày trước - ĐI MUỘN
      AttendanceModel(
        id: 'attendance_11',
        sessionId: 'session_11',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'TOAN-01-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day - 3, 10, 45)), // Muộn 15 phút
        status: AttendanceStatus.late,
      ),
      // 4 ngày trước - CÓ MẶT
      AttendanceModel(
        id: 'attendance_12',
        sessionId: 'session_12',
        studentId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
        classId: 'CNTT-02-K62',
        timestamp: Timestamp.fromDate(DateTime(now.year, now.month, now.day - 4, 13, 1)),
        status: AttendanceStatus.present,
      ),
    ];

    for (final attendance in attendances) {
      await _service.addDocument<AttendanceModel>(attendance);
    }
    print('✅ Đã tạo ${attendances.length} bản ghi điểm danh');

    print('🎉 HOÀN THÀNH TẠO DỮ LIỆU MÔ PHỎNG ĐẦY ĐỦ!');
    print('📊 TỔNG KẾT:');
    print('   👨‍🏫 Giảng viên: ${teachers.length}');
    print('   👨‍🎓 Sinh viên: 1 (Lê Đức Chiến)');
    print('   🎭 Face Data: 1');
    print('   📚 Môn học: ${courses.length} môn');
    print('   🏫 Lớp học: ${classes.length} lớp');
    print('   🕒 Buổi học: ${sessions.length} buổi');
    print('   ✅ Điểm danh: ${attendances.length} bản ghi');
    print('');
    print('📈 THỐNG KÊ ĐIỂM DANH SINH VIÊN:');
    print('   🟢 Có mặt: ${attendances.where((a) => a.status == AttendanceStatus.present).length} buổi');
    print('   🟡 Đi muộn: ${attendances.where((a) => a.status == AttendanceStatus.late).length} buổi');
    print('   🔴 Vắng: ${attendances.where((a) => a.status == AttendanceStatus.absent).length} buổi');
    print('   📊 Tỷ lệ chuyên cần: ${((attendances.where((a) => a.status == AttendanceStatus.present).length + attendances.where((a) => a.status == AttendanceStatus.late).length) / attendances.length * 100).toStringAsFixed(1)}%');
  }

  // ==== 8️⃣ PHƯƠNG THỨC XÓA DỮ LIỆU ====
  Future<void> clearMockData() async {
    print('🗑️ Đang xóa toàn bộ dữ liệu mô phỏng...');
    
    try {
      final collections = ['users', 'face_data', 'classes', 'sessions', 'courses', 'attendances'];
      
      for (final collection in collections) {
        final snapshot = await FirebaseFirestore.instance.collection(collection).get();
        final batch = FirebaseFirestore.instance.batch();
        
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        
        await batch.commit();
        print('✅ Đã xóa collection: $collection');
      }
      
      print('🎯 Đã xóa toàn bộ dữ liệu mô phỏng');
    } catch (e) {
      print('❌ Lỗi khi xóa dữ liệu: $e');
    }
  }

  // ==== 9️⃣ PHƯƠNG THỨC KIỂM TRA DỮ LIỆU ====
  Future<void> checkMockData() async {
    print('🔍 Kiểm tra dữ liệu mô phỏng...');
    
    final collections = ['users', 'face_data', 'classes', 'sessions', 'courses', 'attendances'];
    
    for (final collection in collections) {
      final snapshot = await FirebaseFirestore.instance.collection(collection).get();
      print('   📁 $collection: ${snapshot.docs.length} documents');
      
      if (collection == 'attendances') {
        final presentCount = snapshot.docs.where((doc) => doc.data()['status'] == 'present').length;
        final lateCount = snapshot.docs.where((doc) => doc.data()['status'] == 'late').length;
        final absentCount = snapshot.docs.where((doc) => doc.data()['status'] == 'absent').length;
        
        print('      🟢 Có mặt: $presentCount');
        print('      🟡 Muộn: $lateCount');
        print('      🔴 Vắng: $absentCount');
      }
    }
  }
}