import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../models/attendance_model.dart';
import '../models/class_model.dart';
import '../models/course_model.dart';
import '../models/face_data_model.dart';
import '../models/session_model.dart';
import 'firestore_service.dart';

class MockDataGenerator {
  final FirestoreService _service = FirestoreService();

  Future<void> seedData() async {
    final now = Timestamp.now();

    // ==== 1️⃣ GIẢNG VIÊN (Không có ảnh khuôn mặt) ====
    final teachers = [
      UserModel(
        uid: 'GV001',
        name: 'Trần Văn Giảng',
        email: 'gv001@tlu.edu.vn',
        role: 'lecturer',
        lecturerCode: 'GV001',
        hocHamHocVi: 'TS',
        khoa: 'CNTT',
        teachingClassIds: ['CNTT01'],
        isFaceRegistered: false,
      ),
      UserModel(
        uid: 'GV002',
        name: 'Nguyễn Thị Lan',
        email: 'gv002@tlu.edu.vn',
        role: 'lecturer',
        lecturerCode: 'GV002',
        hocHamHocVi: 'ThS',
        khoa: 'CNTT',
        teachingClassIds: ['CNTT02'],
        isFaceRegistered: false,
      ),
    ];
    for (var gv in teachers) await _service.addDocument<UserModel>(gv);

    // ==== 2️⃣ SINH VIÊN (Có ảnh khuôn mặt) ====
    final students = [
      UserModel(
        uid: 'TyocMfOS3dSayWrdW9aDMVGK7n83',
        name: 'Nguyễn Văn A',
        email: 'sinhvien1@gmail.com',
        role: 'student',
        studentCode: 'SV001',
        classId: 'CNTT01',
        departmentId: 'CNTT',
        classIds: ['CNTT01'],
        isFaceRegistered: false,
        faceUrls: [
        ],
      ),
      UserModel(
        uid: 'SV002',
        name: 'Trần Thị B',
        email: 'sv002@tlu.edu.vn',
        role: 'student',
        studentCode: 'SV002',
        classId: 'CNTT01',
        departmentId: 'CNTT',
        classIds: ['CNTT01'],
        isFaceRegistered: true,
        faceUrls: [
          'https://example.com/faces/sv002.jpg',
        ],
      ),
      UserModel(
        uid: 'SV003',
        name: 'Lê Văn C',
        email: 'sv003@tlu.edu.vn',
        role: 'student',
        studentCode: 'SV003',
        classId: 'CNTT02',
        departmentId: 'CNTT',
        classIds: ['CNTT02'],
        isFaceRegistered: true,
        faceUrls: [
          'https://example.com/faces/sv003.jpg',
        ],
      ),
      UserModel(
        uid: 'SV004',
        name: 'Phạm Thị D',
        email: 'sv004@tlu.edu.vn',
        role: 'student',
        studentCode: 'SV004',
        classId: 'CNTT02',
        departmentId: 'CNTT',
        classIds: ['CNTT02'],
        isFaceRegistered: true,
        faceUrls: [
          'https://example.com/faces/sv004.jpg',
        ],
      ),
    ];
    for (var sv in students) await _service.addDocument<UserModel>(sv);

    // ==== 3️⃣ MÔN HỌC ====
    final courses = [
      CourseModel(
        id: 'CS101',
        name: 'Lập trình Flutter',
        teacherId: teachers[0].uid,
        departmentId: 'CNTT',
        classIds: ['CNTT01'],
        description: 'Khóa học Flutter cơ bản cho sinh viên CNTT',
        credits: 3,
        semester: 'HK1',
      ),
      CourseModel(
        id: 'CS102',
        name: 'Cấu trúc dữ liệu',
        teacherId: teachers[1].uid,
        departmentId: 'CNTT',
        classIds: ['CNTT02'],
        description: 'Học về danh sách, cây, đồ thị và thuật toán cơ bản',
        credits: 3,
        semester: 'HK1',
      ),
    ];
    for (var course in courses) await _service.addDocument<CourseModel>(course);

    // ==== 4️⃣ LỚP HỌC ====
    final classes = [
      ClassModel(
        id: 'CNTT01',
        name: 'CNTT 01',
        courseId: 'CS101',
        teacherId: teachers[0].uid,
        departmentId: 'CNTT',
        studentIds: ['SV001', 'SV002'],
      ),
      ClassModel(
        id: 'CNTT02',
        name: 'CNTT 02',
        courseId: 'CS102',
        teacherId: teachers[1].uid,
        departmentId: 'CNTT',
        studentIds: ['SV003', 'SV004'],
      ),
    ];
    for (var cls in classes) await _service.addDocument<ClassModel>(cls);

    // ==== 5️⃣ BUỔI HỌC ====
    final sessions = [
      SessionModel(
        id: 'S001',
        courseId: 'CS101',
        classId: 'CNTT01',
        date: now,
        startTime: Timestamp.fromDate(
          DateTime.now().copyWith(hour: 8, minute: 0),
        ),
        endTime: Timestamp.fromDate(
          DateTime.now().copyWith(hour: 10, minute: 0),
        ),
        lecturerId: teachers[0].uid,
        room: 'P101',
      ),
      SessionModel(
        id: 'S002',
        courseId: 'CS102',
        classId: 'CNTT02',
        date: now,
        startTime: Timestamp.fromDate(
          DateTime.now().copyWith(hour: 10, minute: 30),
        ),
        endTime: Timestamp.fromDate(
          DateTime.now().copyWith(hour: 12, minute: 0),
        ),
        lecturerId: teachers[1].uid,
        room: 'P102',
      ),
    ];
    for (var s in sessions) await _service.addDocument<SessionModel>(s);

    // ==== 6️⃣ DỮ LIỆU KHUÔN MẶT (CHỈ SINH VIÊN) ====
    final faceDataList = [
      FaceDataModel(
        id: 'F001',
        userId: 'SV001',
        imageUrls: [
        ],
        embeddingsList: [
          
        ],
        updatedAt: now,
        version: 0,
      ),
      FaceDataModel(
        id: 'F002',
        userId: 'SV002',
        imageUrls: [
          'https://example.com/faces/sv002.jpg',
        ],
        embeddingsList: [
          [0.22, 0.51, 0.66, 0.41],
        ],
        updatedAt: now,
        version: 1,
      ),
      FaceDataModel(
        id: 'F003',
        userId: 'SV003',
        imageUrls: [
          'https://example.com/faces/sv003.jpg',
        ],
        embeddingsList: [
          [0.19, 0.33, 0.71, 0.52],
        ],
        updatedAt: now,
        version: 1,
      ),
    ];
    for (var fd in faceDataList) await _service.addDocument<FaceDataModel>(fd);

    // ==== 7️⃣ ĐIỂM DANH ====
    final attendanceList = [
      AttendanceModel(
        id: 'A001',
        sessionId: 'S001',
        studentId: 'SV001',
        classId: 'CNTT01',
        timestamp: now,
        status: AttendanceStatus.present,
      ),
      AttendanceModel(
        id: 'A002',
        sessionId: 'S001',
        studentId: 'SV002',
        classId: 'CNTT01',
        timestamp: now,
        status: AttendanceStatus.absent,
      ),
      AttendanceModel(
        id: 'A003',
        sessionId: 'S002',
        studentId: 'SV003',
        classId: 'CNTT02',
        timestamp: now,
        status: AttendanceStatus.present,
      ),
      AttendanceModel(
        id: 'A004',
        sessionId: 'S002',
        studentId: 'SV004',
        classId: 'CNTT02',
        timestamp: now,
        status: AttendanceStatus.late,
      ),
    ];
    for (var att in attendanceList) await _service.addDocument<AttendanceModel>(att);

    print('✅ Dữ liệu mô phỏng đã được thêm thành công!');
  }
}
