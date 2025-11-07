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

    // ==== 3️⃣ FACE DATA ====
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
      
    ];

    for (final course in courses) {
      await _service.addDocument<CourseModel>(course);
    }
    print('✅ Đã tạo ${courses.length} môn học');

    // ==== 5️⃣ LỚP HỌC ====
    final classes = [
      ClassModel(
        id: 'KTPM3',
        name: '64KTPM3 ',
        departmentId: 'CNTT',
        headTeacherId: 'qEWuN8OEaEVdycX0Dhf1xzU6ijp1',
        courseIds: ['CSE123'],
        studentIds: ['DP1KnG7Tp4X5Due249TmStmCtwl1'],
        sessionIds: ['session_1'],
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
    final sessions = [
      SessionModel(
        id: 'session_1',
        courseId: 'CSE123',
        classId: 'KTPM3',
        date: now,
        startTime: '07:00',
        endTime: '23:00',
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
      
    ];

    for (final session in sessions) {
      await _service.addDocument<SessionModel>(session);
    }
    print('✅ Đã tạo ${sessions.length} buổi học');

    
  }

  // ==== 8️⃣ XÓA DỮ LIỆU ====
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
        final snapshot =
            await FirebaseFirestore.instance.collection(collection).get();

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
}
