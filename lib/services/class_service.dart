import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

/// Service làm việc với collection `classes`
/// - Dùng withConverter để map <-> ClassModel
/// - Tự động set updated_at = serverTimestamp() khi update
class ClassService {
  static const String _collectionName = 'classes';

  final CollectionReference<ClassModel> _classesRef;

  ClassService()
      : _classesRef = FirebaseFirestore.instance
            .collection(_collectionName)
            .withConverter<ClassModel>(
              fromFirestore: (snap, _) =>
                  ClassModel.fromMap(snap.data() ?? {}, snap.id),
              toFirestore: (model, _) => model.toMap(),
            );

  // =========================
  // CREATE
  // =========================

  /// Tạo một lớp mới. Trả về id document vừa tạo.
  Future<String> createClass(ClassModel klass) async {
    try {
      final toSave = klass.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final doc = await _classesRef.add(toSave);
      return doc.id;
    } catch (e) {
      // ignore: avoid_print
      print('[ClassService] createClass error: $e');
      rethrow;
    }
  }

  // =========================
  // READ
  // =========================

  /// Lấy một lớp theo id. Trả về null nếu không tồn tại.
  Future<ClassModel?> getClassById(String id) async {
    try {
      final doc = await _classesRef.doc(id).get();
      return doc.data();
    } catch (e) {
      print('[ClassService] getClassById($id) error: $e');
      return null;
    }
  }

  /// Stream tất cả lớp (có thể filter isActive).
  Stream<List<ClassModel>> streamClasses({bool? isActive}) {
    Query<ClassModel> q = _classesRef.orderBy('name');
    if (isActive != null) {
      q = q.where('is_active', isEqualTo: isActive);
    }
    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Stream lớp theo khoa (departmentId).
  Stream<List<ClassModel>> streamClassesByDepartment(String departmentId,
      {bool? isActive}) {
    Query<ClassModel> q =
        _classesRef.where('department_id', isEqualTo: departmentId);
    if (isActive != null) {
      q = q.where('is_active', isEqualTo: isActive);
    }
    q = q.orderBy('name');
    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Tìm lớp theo tiền tố tên (prefix) – phục vụ search box.
  /// Lưu ý: cần index nếu kết hợp thêm where khác.
  Future<List<ClassModel>> searchByNamePrefix(String prefix,
      {int limit = 20}) async {
    if (prefix.isEmpty) return [];
    final end = '${prefix}\uf8ff';
    try {
      final snap = await _classesRef
          .orderBy('name')
          .startAt([prefix])
          .endAt([end])
          .limit(limit)
          .get();
      return snap.docs.map((d) => d.data()).toList();
    } catch (e) {
      print('[ClassService] searchByNamePrefix("$prefix") error: $e');
      return [];
    }
  }

  /// Phân trang: lấy danh sách lớp theo tên với limit; truyền `lastDoc` để trang tiếp theo.
  Future<QuerySnapshot<ClassModel>> pageByName({int limit = 20, DocumentSnapshot<ClassModel>? lastDoc}) {
    Query<ClassModel> q = _classesRef.orderBy('name').limit(limit);
    if (lastDoc != null) q = q.startAfterDocument(lastDoc);
    return q.get();
  }

  // =========================
  // UPDATE (cập nhật dạng Map hoặc helpers cụ thể)
  // =========================

  /// Cập nhật linh hoạt bằng Map (tự động set `updated_at` = serverTimestamp).
  Future<void> updateClassData(String classId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _classesRef.doc(classId).update(data);
    } catch (e) {
      print('[ClassService] updateClassData($classId) error: $e');
      rethrow;
    }
  }

  /// Đổi tên lớp.
  Future<void> renameClass(String classId, String newName) {
    return updateClassData(classId, {'name': newName});
  }

  /// Set/đổi GVCN (head teacher)
  Future<void> setHeadTeacher(String classId, String? headTeacherId) {
    return updateClassData(classId, {'head_teacher_id': headTeacherId});
  }

  /// Kích hoạt / vô hiệu hóa lớp.
  Future<void> setActive(String classId, bool isActive) {
    return updateClassData(classId, {'is_active': isActive});
  }

  // ---------- Quản lý STUDENT ----------

  Future<void> addStudent(String classId, String studentId) async {
    await updateClassData(classId, {
      'student_ids': FieldValue.arrayUnion([studentId]),
    });
  }

  Future<void> removeStudent(String classId, String studentId) async {
    await updateClassData(classId, {
      'student_ids': FieldValue.arrayRemove([studentId]),
    });
  }

  /// Thêm nhiều sinh viên một lúc.
  Future<void> addStudents(String classId, List<String> studentIds) async {
    if (studentIds.isEmpty) return;
    await updateClassData(classId, {
      'student_ids': FieldValue.arrayUnion(studentIds),
    });
  }

  /// Xoá nhiều sinh viên một lúc.
  Future<void> removeStudents(String classId, List<String> studentIds) async {
    if (studentIds.isEmpty) return;
    await updateClassData(classId, {
      'student_ids': FieldValue.arrayRemove(studentIds),
    });
  }

  /// Di chuyển một sinh viên sang lớp khác (transaction an toàn).
  Future<void> moveStudent({
    required String fromClassId,
    required String toClassId,
    required String studentId,
  }) async {
    final db = FirebaseFirestore.instance;
    await db.runTransaction((txn) async {
      final fromRef = _classesRef.doc(fromClassId);
      final toRef = _classesRef.doc(toClassId);

      txn.update(fromRef, {
        'student_ids': FieldValue.arrayRemove([studentId]),
        'updated_at': FieldValue.serverTimestamp(),
      });
      txn.update(toRef, {
        'student_ids': FieldValue.arrayUnion([studentId]),
        'updated_at': FieldValue.serverTimestamp(),
      });
    });
  }

  // ---------- Quản lý COURSE ----------

  Future<void> addCourse(String classId, String courseId) async {
    await updateClassData(classId, {
      'course_ids': FieldValue.arrayUnion([courseId]),
    });
  }

  Future<void> removeCourse(String classId, String courseId) async {
    await updateClassData(classId, {
      'course_ids': FieldValue.arrayRemove([courseId]),
    });
  }

  Future<void> addCourses(String classId, List<String> courseIds) async {
    if (courseIds.isEmpty) return;
    await updateClassData(classId, {
      'course_ids': FieldValue.arrayUnion(courseIds),
    });
  }

  Future<void> removeCourses(String classId, List<String> courseIds) async {
    if (courseIds.isEmpty) return;
    await updateClassData(classId, {
      'course_ids': FieldValue.arrayRemove(courseIds),
    });
  }

  // ---------- Quản lý SESSION ----------

  Future<void> addSession(String classId, String sessionId) async {
    await updateClassData(classId, {
      'session_ids': FieldValue.arrayUnion([sessionId]),
    });
  }

  Future<void> removeSession(String classId, String sessionId) async {
    await updateClassData(classId, {
      'session_ids': FieldValue.arrayRemove([sessionId]),
    });
  }

  Future<void> addSessions(String classId, List<String> sessionIds) async {
    if (sessionIds.isEmpty) return;
    await updateClassData(classId, {
      'session_ids': FieldValue.arrayUnion(sessionIds),
    });
  }

  Future<void> removeSessions(String classId, List<String> sessionIds) async {
    if (sessionIds.isEmpty) return;
    await updateClassData(classId, {
      'session_ids': FieldValue.arrayRemove(sessionIds),
    });
  }

  // =========================
  // DELETE
  // =========================

  /// Xoá hẳn document lớp (không thể hoàn tác). Thực tế nên set is_active=false.
  Future<void> deleteClass(String classId) async {
    try {
      await _classesRef.doc(classId).delete();
    } catch (e) {
      print('[ClassService] deleteClass($classId) error: $e');
      rethrow;
    }
  }
}
