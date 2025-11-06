
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

    // ==== 1️⃣ GIẢNG VIÊN (KHÔNG có khuôn mặt) ====
    final teacher = UserModel(
      uid: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      name: 'Kiều Tuấn Dũng',
      email: 'kieutuandung@tlu.edu.vn',
      role: 'teacher',
      lecturerCode: 'GV001',
      academicTitle: 'Tiến sĩ',
      faculty: 'Công nghệ thông tin',
      teachingClassIds: ['CSE123_02'],
      isFaceRegistered: false, // 🔹 Giảng viên không cần đăng ký khuôn mặt
      faceUrls: null, // 🔹 Không có ảnh khuôn mặt
      faceDataId: null, // 🔹 Không có face data
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _service.addDocument<UserModel>(teacher);
    print('✅ Đã tạo giảng viên: ${teacher.name}');

    // ==== 2️⃣ SINH VIÊN (CÓ khuôn mặt) ====
    final student = UserModel(
      uid: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
      name: 'Lê Đức Chiến',
      email: 'sinhvien@gmail.com',
      role: 'student',
      studentCode: '2251172253',
      classId: 'KTPM3',
      departmentId: 'CNTT',
      classIds: ['CSE123_02'],
      isFaceRegistered: false, // 🔹 Chưa đăng ký khuôn mặt (sẽ đăng ký sau)
      faceUrls: [], // 🔹 Chưa có ảnh
      faceDataId: 'face_DP1KnG7Tp4X5Due249TmStmCtwl1', // 🔹 Reference đến face_data
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _service.addDocument<UserModel>(student);
    print('✅ Đã tạo sinh viên: ${student.name}');

    // ==== 3️⃣ FACE DATA CHO SINH VIÊN (TRỐNG - chờ đăng ký) ====
    final faceData = FaceDataModel(
      id: 'face_DP1KnG7Tp4X5Due249TmStmCtwl1',
      userId: 'DP1KnG7Tp4X5Due249TmStmCtwl1',
      userEmail: 'sinhvien1@sv.tlu.edu.vn',
      userRole: 'student',
      poseImageUrls: {}, // 🔹 Map rỗng - chưa có ảnh
      poseEmbeddings: {}, // 🔹 Map rỗng - chưa có embeddings
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      version: 0,
    );

    await _service.addDocument<FaceDataModel>(faceData);
    print('✅ Đã tạo face data trống cho sinh viên');

    print('🎉 HOÀN THÀNH TẠO DỮ LIỆU MÔ PHỎNG!');
    print('📊 Kết quả:');
    print('   👨‍🏫 Giảng viên: 1 (TS. Trần Văn Giảng) - KHÔNG có khuôn mặt');
    print('   👨‍🎓 Sinh viên: 1 (Nguyễn Văn A) - CÓ face data (chờ đăng ký)');
    print('   🎭 Face Data: 1 (trống)');
    //==== 3️⃣ LỚP HỌC ====
    final classModel = ClassModel(
      id: 'CSE123_02',
      name: 'Lập trình C++',
      courseId: 'CSE123',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      departmentId: 'CNTT',
      studentIds: ['DP1KnG7Tp4X5Due249TmStmCtwl1'],
      sessionIds: ['session_1', 'session_2', 'session_3'],
    );

    await _service.addDocument<ClassModel>(classModel);
    print('✅ Đã tạo lớp học: ${classModel.name}');

    // ==== 4️⃣ BUỔI HỌC (SESSIONS) ====
    final now = DateTime.now();
    
    // Buổi học ĐÃ KẾT THÚC (sáng nay)
    final pastSession = SessionModel(
      id: 'session_1',
      courseId: 'CSE123',
      classId: 'CSE123_02',
      date: Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      startTime: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 7, 0)),
      endTime: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 8, 30)),
      room: '207-B5',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      attendanceIds: [],
      status: SessionStatus.done,
      qrCode: null,
      qrExpiry: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    // Buổi học ĐANG DIỄN RA (hiện tại)
    final ongoingSession = SessionModel(
      id: 'session_2',
      courseId: 'CSE123',
      classId: 'CSE123_02',
      date: Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      startTime: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 9, 45)),
      endTime: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 11, 15)),
      room: '207-B5',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      attendanceIds: [],
      status: SessionStatus.ongoing,
      qrCode: null,
      qrExpiry: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    // Buổi học SẮP DIỄN RA (chiều nay)
    final upcomingSession = SessionModel(
      id: 'session_3',
      courseId: 'CSE123',
      classId: 'CSE123_02',
      date: Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      startTime: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 12, 55)),
      endTime: Timestamp.fromDate(DateTime(now.year, now.month, now.day, 14, 25)),
      room: '207-B5',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      attendanceIds: [],
      status: SessionStatus.scheduled,
      qrCode: null,
      qrExpiry: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    // Buổi học NGÀY MAI
    final tomorrowSession = SessionModel(
      id: 'session_4',
      courseId: 'CSE123',
      classId: 'CSE123_02',
      date: Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1)),
      startTime: Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1, 8, 45)),
      endTime: Timestamp.fromDate(DateTime(now.year, now.month, now.day + 1, 10, 15)),
      room: '207-B5',
      lecturerId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
      attendanceIds: [],
      status: SessionStatus.scheduled,
      qrCode: null,
      qrExpiry: null,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    await _service.addDocument<SessionModel>(pastSession);
    await _service.addDocument<SessionModel>(ongoingSession);
    await _service.addDocument<SessionModel>(upcomingSession);
    await _service.addDocument<SessionModel>(tomorrowSession);

    print('✅ Đã tạo 4 buổi học:');
    print('   - Buổi 1: ĐÃ KẾT THÚC (07:00 - 08:30)');
    print('   - Buổi 2: ĐANG DIỄN RA (09:45 - 11:15)');
    print('   - Buổi 3: SẮP DIỄN RA (12:55 - 14:25)');
    print('   - Buổi 4: NGÀY MAI (08:45 - 10:15)');


  }

  
}