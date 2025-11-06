import '../models/user/user_model.dart';
import '../models/face_data_model.dart';
import '../models/class_model.dart';
import '../models/session_model.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockDataGenerator {
  final FirestoreService _service = FirestoreService();

  Future<void> seedData() async {
    print('🔄 Bắt đầu tạo dữ liệu mô phỏng...');

    // ==== 1️⃣ GIẢNG VIÊN ====
    final teacher = UserModel(
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
    );

    await _service.addDocument<UserModel>(teacher);
    print('✅ Đã tạo giảng viên: ${teacher.name}');

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
    print('✅ Đã tạo face data trống cho sinh viên');

    // ==== 4️⃣ LỚP HỌC (ĐÃ SỬA THEO MODEL MỚI) ====
    final classModel = ClassModel(
      id: 'CNTT-01-K62',
      name: 'Công nghệ thông tin 01 Khóa 62',
      departmentId: 'CNTT',
      headTeacherId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      courseIds: ['CT101', 'CT102', 'TO101'], // ⭐ SỬA: course_ids array
      studentIds: ['DP1KnG7Tp4X5Due249TmStmCtwl1'],
      sessionIds: ['session_1', 'session_2', 'session_3', 'session_4'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    await _service.addDocument<ClassModel>(classModel);
    print('✅ Đã tạo lớp học: ${classModel.name}');

    // ==== 5️⃣ BUỔI HỌC (ĐÃ SỬA THEO SESSION MODEL MỚI) ====
    final now = DateTime.now();
    
    // Buổi học ĐÃ KẾT THÚC (sáng nay)
    final pastSession = SessionModel(
      id: 'session_1',
      courseId: 'CT101',
      classId: 'CNTT-01-K62',
      date: DateTime(now.year, now.month, now.day), // ⭐ SỬA: DateTime
      startTime: '07:00', // ⭐ SỬA: String
      endTime: '08:30',   // ⭐ SỬA: String
      room: 'P.301-A1',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      attendanceIds: [],
      status: SessionStatus.done,
      qrCode: null,
      qrExpiry: null,
      isRecurring: true,
      repeatDays: [1, 3, 5], // Thứ 2,4,6
      repeatUntil: DateTime(2025, 2, 28),
      parentSessionId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Buổi học ĐANG DIỄN RA (hiện tại)
    final ongoingSession = SessionModel(
      id: 'session_2',
      courseId: 'CT101',
      classId: 'CNTT-01-K62',
      date: DateTime(now.year, now.month, now.day),
      startTime: '09:45',
      endTime: '11:15',
      room: 'P.301-A1',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      attendanceIds: [],
      status: SessionStatus.ongoing,
      qrCode: 'qr_ongoing_123',
      qrExpiry: DateTime.now().add(Duration(minutes: 15)),
      isRecurring: true,
      repeatDays: [1, 3, 5],
      repeatUntil: DateTime(2025, 2, 28),
      parentSessionId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Buổi học SẮP DIỄN RA (chiều nay)
    final upcomingSession = SessionModel(
      id: 'session_3',
      courseId: 'CT101',
      classId: 'CNTT-01-K62',
      date: DateTime(now.year, now.month, now.day),
      startTime: '12:55',
      endTime: '14:25',
      room: 'P.301-A1',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      attendanceIds: [],
      status: SessionStatus.scheduled,
      qrCode: null,
      qrExpiry: null,
      isRecurring: true,
      repeatDays: [1, 3, 5],
      repeatUntil: DateTime(2025, 2, 28),
      parentSessionId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Buổi học NGÀY MAI
    final tomorrowSession = SessionModel(
      id: 'session_4',
      courseId: 'CT101',
      classId: 'CNTT-01-K62',
      date: DateTime(now.year, now.month, now.day + 1),
      startTime: '08:45',
      endTime: '10:15',
      room: 'P.301-A1',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      attendanceIds: [],
      status: SessionStatus.scheduled,
      qrCode: null,
      qrExpiry: null,
      isRecurring: true,
      repeatDays: [1, 3, 5],
      repeatUntil: DateTime(2025, 2, 28),
      parentSessionId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _service.addDocument<SessionModel>(pastSession);
    await _service.addDocument<SessionModel>(ongoingSession);
    await _service.addDocument<SessionModel>(upcomingSession);
    await _service.addDocument<SessionModel>(tomorrowSession);

    print('✅ Đã tạo 4 buổi học:');
    print('   - Buổi 1: ĐÃ KẾT THÚC (07:00 - 08:30)');
    print('   - Buổi 2: ĐANG DIỄN RA (09:45 - 11:15) - CÓ QR');
    print('   - Buổi 3: SẮP DIỄN RA (12:55 - 14:25)');
    print('   - Buổi 4: NGÀY MAI (08:45 - 10:15)');

    // ==== 6️⃣ THÊM DỮ LIỆU MÔN HỌC (COURSE) ====
    final course = {
      'id': 'CT101',
      'name': 'Lập trình Flutter',
      'department_id': 'CNTT',
      'lecturer_ids': ['qEWuN8OEaEVdycX0Dhf1xzU6ijp1'],
      'course_code': 'CT101',
      'description': 'Môn học lập trình di động với Flutter và Dart',
      'credits': 3,
      'semester': 'HK1-2024',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_active': true,
    };

    await FirebaseFirestore.instance.collection('courses').doc('CT101').set(course);
    print('✅ Đã tạo môn học: Lập trình Flutter');

    print('🎉 HOÀN THÀNH TẠO DỮ LIỆU MÔ PHỎNG!');
    print('📊 Kết quả:');
    print('   👨‍🏫 Giảng viên: 1 (TS. Kiều Tuấn Dũng)');
    print('   👨‍🎓 Sinh viên: 1 (Lê Đức Chiến)');
    print('   🎭 Face Data: 1 (trống)');
    print('   🏫 Lớp học: 1 (CNTT-01-K62)');
    print('   🕒 Buổi học: 4 (đủ trạng thái)');
    print('   📚 Môn học: 1 (Lập trình Flutter)');
  }

  // ==== 7️⃣ PHƯƠNG THỨC XÓA DỮ LIỆU (ĐỂ TEST) ====
  Future<void> clearMockData() async {
    print('🗑️ Đang xóa dữ liệu mô phỏng...');
    
    try {
      // Xóa user
      await _service.deleteDocument<UserModel>('qEWuN8OEaEVdycX0Dhf1xzU6ijp1');
      await _service.deleteDocument<UserModel>('DP1KnG7Tp4X5Due249TmStmCtwl1');
      
      // Xóa face data
      await _service.deleteDocument<FaceDataModel>('face_DP1KnG7Tp4X5Due249TmStmCtwl1');
      
      // Xóa lớp học
      await _service.deleteDocument<ClassModel>('CNTT-01-K62');
      
      // Xóa sessions
      await _service.deleteDocument<SessionModel>('session_1');
      await _service.deleteDocument<SessionModel>('session_2');
      await _service.deleteDocument<SessionModel>('session_3');
      await _service.deleteDocument<SessionModel>('session_4');
      
      // Xóa course
      await FirebaseFirestore.instance.collection('courses').doc('CT101').delete();
      
      print('✅ Đã xóa toàn bộ dữ liệu mô phỏng');
    } catch (e) {
      print('❌ Lỗi khi xóa dữ liệu: $e');
    }
  }

  // ==== 8️⃣ PHƯƠNG THỨC KIỂM TRA DỮ LIỆU ====
  Future<void> checkMockData() async {
    print('🔍 Kiểm tra dữ liệu mô phỏng...');
    
    final users = await _service.getAllDocuments<UserModel>();
    final classes = await _service.getAllDocuments<ClassModel>();
    final sessions = await _service.getAllDocuments<SessionModel>();
    final faceData = await _service.getAllDocuments<FaceDataModel>();
    
    final courseDoc = await FirebaseFirestore.instance.collection('courses').doc('CT101').get();
    
    print('📊 Số lượng dữ liệu hiện tại:');
    print('   👥 Users: ${users.length}');
    print('   🏫 Classes: ${classes.length}');
    print('   🕒 Sessions: ${sessions.length}');
    print('   🎭 FaceData: ${faceData.length}');
    print('   📚 Courses: ${courseDoc.exists ? 1 : 0}');
    
    // Hiển thị chi tiết sessions
    for (final session in sessions) {
      print('   🕒 Session ${session.id}: ${session.courseId} | ${session.startTime}-${session.endTime} | ${session.status.name}');
    }
  }
}