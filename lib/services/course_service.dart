import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course_model.dart'; // Import CourseModel của bạn
import 'dart:async';

class CourseService {
  final CollectionReference<CourseModel> _coursesRef;

  CourseService()
      : _coursesRef = FirebaseFirestore.instance
      .collection('courses') // Tên collection của bạn
      .withConverter<CourseModel>(

    // Chuyển đổi từ Firestore (Map) sang CourseModel
    fromFirestore: (snapshot, _) =>
        CourseModel.fromMap(snapshot.data()!, snapshot.id),

    // Chuyển đổi từ CourseModel sang Firestore (Map)
    toFirestore: (course, _) => course.toMap(),
  );

  // --- 1. CREATE (Tạo) ---

  /// Tạo một môn học mới
  Future<String> createCourse(CourseModel course) async {
    try {
      // Thêm 'created_at' và 'updated_at' khi tạo mới
      final courseWithTimestamps = course.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef = await _coursesRef.add(courseWithTimestamps);
      return docRef.id;
    } catch (e) {
      print("Lỗi khi tạo môn học: $e");
      rethrow;
    }
  }

  // --- 2. READ (Đọc) ---

  /// Lấy một môn học cụ thể bằng ID
  Future<CourseModel?> getCourseById(String id) async {
    try {
      final doc = await _coursesRef.doc(id).get();
      return doc.data(); // Trả về CourseModel hoặc null
    } catch (e) {
      print("Lỗi khi lấy môn học: $e");
      return null;
    }
  }

  /// Lấy (stream) toàn bộ danh sách môn học
  /// Sắp xếp theo tên (name)
  Stream<List<CourseModel>> streamCourses() {
    final query = _coursesRef.orderBy('name');

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Lấy (stream) các môn học theo một khoa (departmentId)
  Stream<List<CourseModel>> streamCoursesByDepartment(String departmentId) {
    final query = _coursesRef
        .where('department_id', isEqualTo: departmentId)
        .orderBy('name');

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Lấy (stream) các môn học mà một giảng viên có thể dạy (lecturerId)
  Stream<List<CourseModel>> streamCoursesForLecturer(String lecturerId) {
    // Sử dụng 'array-contains' để tìm trong mảng 'lecturer_ids'
    final query = _coursesRef
        .where('lecturer_ids', arrayContains: lecturerId)
        .orderBy('name');

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  // --- 3. UPDATE (Cập nhật) ---

  /// Cập nhật dữ liệu cơ bản cho môn học
  /// (Dùng Map để cập nhật linh hoạt)
  Future<void> updateCourseData(String courseId, Map<String, dynamic> data) async {
    try {
      // Tự động thêm 'updated_at' khi cập nhật
      data['updated_at'] = FieldValue.serverTimestamp();
      await _coursesRef.doc(courseId).update(data);
    } catch (e) {
      print("Lỗi khi cập nhật môn học: $e");
      rethrow;
    }
  }

  /// Thêm một giảng viên vào danh sách có thể dạy
  Future<void> addLecturerToCourse(String courseId, String lecturerId) async {
    try {
      await _coursesRef.doc(courseId).update({
        'lecturer_ids': FieldValue.arrayUnion([lecturerId]),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi khi thêm giảng viên: $e");
      rethrow;
    }
  }

  /// Xóa một giảng viên khỏi danh sách có thể dạy
  Future<void> removeLecturerFromCourse(String courseId, String lecturerId) async {
    try {
      await _coursesRef.doc(courseId).update({
        'lecturer_ids': FieldValue.arrayRemove([lecturerId]),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi khi xóa giảng viên: $e");
      rethrow;
    }
  }

  /// Kích hoạt hoặc vô hiệu hóa môn học
  Future<void> setCourseActive(String courseId, bool isActive) async {
    await updateCourseData(courseId, {'is_active': isActive});
  }

  // --- 4. DELETE (Xóa) ---

  /// Xóa một môn học khỏi Firestore
  /// CẢNH BÁO: Thao tác này không thể hoàn tác.
  /// Trong thực tế, bạn nên dùng 'is_active = false' thay vì xóa hẳn.
  Future<void> deleteCourse(String courseId) async {
    try {
      await _coursesRef.doc(courseId).delete();
    } catch (e) {
      print("Lỗi khi xóa môn học: $e");
      rethrow;
    }
  }
}