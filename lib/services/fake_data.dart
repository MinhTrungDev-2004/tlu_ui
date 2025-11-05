
import '../models/user/user_model.dart';
import '../models/face_data_model.dart';
import 'firestore_service.dart';

class MockDataGenerator {
  final FirestoreService _service = FirestoreService();

  Future<void> seedData() async {
    print('🔄 Bắt đầu tạo dữ liệu mô phỏng...');

    // ==== 1️⃣ GIẢNG VIÊN (KHÔNG có khuôn mặt) ====
    final teacher = UserModel(
      uid: 'GV001',
      name: 'Kiều Tuấn Dũng',
      email: 'kieutuandung@tlu.edu.vn',
      role: 'lecturer',
      lecturerCode: 'GV001',
      academicTitle: 'Tiến sĩ',
      faculty: 'Công nghệ thông tin',
      teachingClassIds: ['CNTT01'],
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
      classIds: ['KTPM3'],
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
  }

  
}