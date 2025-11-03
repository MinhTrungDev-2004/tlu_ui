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

    // ==== 1️⃣ Giảng viên ====
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
        isFaceRegistered: true,
        faceUrl: 'https://example.com/face_gv001.jpg',
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
        isFaceRegistered: true,
        faceUrl: 'https://example.com/face_gv002.jpg',
      ),
    ];
    for (var gv in teachers) await _service.addDocument<UserModel>(gv);

    // ==== 2️⃣ Sinh viên ====
    final students = [
      UserModel(
        uid: 'SV001',
        name: 'Nguyễn Văn A',
        email: 'sv001@tlu.edu.vn',
        role: 'student',
        studentCode: 'SV001',
        classId: 'CNTT01',
        departmentId: 'CNTT',
        classIds: ['CNTT01'],
        isFaceRegistered: true,
        faceUrl: 'https://example.com/face_sv001.jpg',
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
      ),
      UserModel(
        uid: 'SV005',
        name: 'Hoàng Văn E',
        email: 'sv005@tlu.edu.vn',
        role: 'student',
        studentCode: 'SV005',
        classId: 'CNTT01',
        departmentId: 'CNTT',
        classIds: ['CNTT01'],
      ),
    ];
    for (var sv in students) await _service.addDocument<UserModel>(sv);

    // ==== 3️⃣ Môn học ====
    final courses = [
      CourseModel(
        id: 'CS101',
        name: 'Lập trình Flutter',
        teacherId: teachers[0].uid,
        departmentId: 'CNTT',
        classIds: ['CNTT01'],
        description: 'Khóa học Flutter cơ bản',
        credits: 3,
        semester: 'HK1',
      ),
      CourseModel(
        id: 'CS102',
        name: 'Cấu trúc dữ liệu',
        teacherId: teachers[1].uid,
        departmentId: 'CNTT',
        classIds: ['CNTT02'],
        description: 'Cấu trúc dữ liệu cơ bản',
        credits: 3,
        semester: 'HK1',
      ),
    ];
    for (var course in courses) await _service.addDocument<CourseModel>(course);

    // ==== 4️⃣ Lớp học ====
    final classes = [
      ClassModel(
        id: 'CNTT01',
        name: 'CNTT 01',
        courseId: 'CS101',
        teacherId: teachers[0].uid,
        departmentId: 'CNTT',
        studentIds: ['SV001', 'SV002', 'SV005'],
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

    // ==== 5️⃣ Buổi học ====
    final sessions = [
      SessionModel(
        id: 'S001',
        courseId: 'CS101',
        classId: 'CNTT01',
        date: now,
        startTime: Timestamp.fromDate(
          DateTime(now.toDate().year, now.toDate().month, now.toDate().day, 8, 0),
        ),
        endTime: Timestamp.fromDate(
          DateTime(now.toDate().year, now.toDate().month, now.toDate().day, 10, 0),
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
          DateTime(now.toDate().year, now.toDate().month, now.toDate().day, 10, 0),
        ),
        endTime: Timestamp.fromDate(
          DateTime(now.toDate().year, now.toDate().month, now.toDate().day, 12, 0),
        ),
        lecturerId: teachers[1].uid,
        room: 'P102',
      ),
    ];
    for (var s in sessions) await _service.addDocument<SessionModel>(s);

    // ==== 6️⃣ Face data ====
    final faceDataList = [
      FaceDataModel(
        id: 'F001',
        userId: 'SV001',
        embeddings: [0.12, 0.34, 0.56],
        updatedAt: now,
        version: 1,
      ),
      FaceDataModel(
        id: 'F002',
        userId: 'GV001',
        embeddings: [0.78, 0.90, 0.11],
        updatedAt: now,
        version: 1,
      ),
    ];
    for (var fd in faceDataList) await _service.addDocument<FaceDataModel>(fd);

    // ==== 7️⃣ Điểm danh ====
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
        sessionId: 'S001',
        studentId: 'SV005',
        classId: 'CNTT01',
        timestamp: now,
        status: AttendanceStatus.present,
        
      ),
      AttendanceModel(
        id: 'A004',
        sessionId: 'S002',
        studentId: 'SV003',
        classId: 'CNTT02',
        timestamp: now,
        status: AttendanceStatus.present,
        
      ),
      AttendanceModel(
        id: 'A005',
        sessionId: 'S002',
        studentId: 'SV004',
        classId: 'CNTT02',
        timestamp: now,
        status: AttendanceStatus.late,
        
      ),
    ];
    for (var att in attendanceList) await _service.addDocument<AttendanceModel>(att);
  }
}
