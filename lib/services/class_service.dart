import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';

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

  Future<String> createClass(ClassModel klass) async {
    try {
      final toSave = klass.copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final doc = await _classesRef.add(toSave);
      return doc.id;
    } catch (e) {
      print('[ClassService] createClass error: $e');
      rethrow;
    }
  }

  // =========================
  // READ
  // =========================

  Future<ClassModel?> getClassById(String id) async {
    try {
      final doc = await _classesRef.doc(id).get();
      return doc.data();
    } catch (e) {
      print('[ClassService] getClassById($id) error: $e');
      return null;
    }
  }

  /// Stream tất cả lớp (có thể filter isActive)
  Stream<List<ClassModel>> streamClasses({bool? isActive}) {
    Query<ClassModel> q = _classesRef;
    if (isActive != null) {
      q = q.where('is_active', isEqualTo: isActive);
    }
    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Stream lớp theo khoa (departmentId)
  Stream<List<ClassModel>> streamClassesByDepartment(String departmentId,
      {bool? isActive}) {
    Query<ClassModel> q =
    _classesRef.where('department_id', isEqualTo: departmentId);
    if (isActive != null) {
      q = q.where('is_active', isEqualTo: isActive);
    }
    // ❌ Bỏ orderBy('name') để không cần index
    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Tìm lớp theo tên đơn giản (không cần index)
  Future<List<ClassModel>> searchByNamePrefix(String prefix,
      {int limit = 20}) async {
    if (prefix.isEmpty) return [];
    try {
      final snap = await _classesRef.get();
      final all = snap.docs.map((d) => d.data()).toList();
      return all
          .where((c) =>
          c.name.toLowerCase().startsWith(prefix.toLowerCase()))
          .take(limit)
          .toList();
    } catch (e) {
      print('[ClassService] searchByNamePrefix("$prefix") error: $e');
      return [];
    }
  }

  // =========================
  // UPDATE
  // =========================

  Future<void> updateClassData(String classId, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _classesRef.doc(classId).update(data);
    } catch (e) {
      print('[ClassService] updateClassData($classId) error: $e');
      rethrow;
    }
  }

  Future<void> renameClass(String classId, String newName) {
    return updateClassData(classId, {'name': newName});
  }

  Future<void> setHeadTeacher(String classId, String? headTeacherId) {
    return updateClassData(classId, {'head_teacher_id': headTeacherId});
  }

  Future<void> setActive(String classId, bool isActive) {
    return updateClassData(classId, {'is_active': isActive});
  }

  // ---------- STUDENT ----------

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

  Future<void> addStudents(String classId, List<String> studentIds) async {
    if (studentIds.isEmpty) return;
    await updateClassData(classId, {
      'student_ids': FieldValue.arrayUnion(studentIds),
    });
  }

  Future<void> removeStudents(String classId, List<String> studentIds) async {
    if (studentIds.isEmpty) return;
    await updateClassData(classId, {
      'student_ids': FieldValue.arrayRemove(studentIds),
    });
  }

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

  // ---------- COURSE ----------

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

  // ---------- SESSION ----------

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

  // =========================
  // DELETE
  // =========================

  Future<void> deleteClass(String classId) async {
    try {
      await _classesRef.doc(classId).delete();
    } catch (e) {
      print('[ClassService] deleteClass($classId) error: $e');
      rethrow;
    }
  }
}
