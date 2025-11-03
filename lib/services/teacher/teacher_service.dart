import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/user_model.dart';

/// Service quản lý GIẢNG VIÊN dựa trên collection `users` (role = 'lecturer')
class TeacherService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';
  static const String _teacherRole = 'teacher';

  /// Thêm giảng viên
  static Future<String> addTeacher(UserModel user) async {
    try {
      final data = user.copyWith(role: _teacherRole).toMap();
      final docRef = await _firestore.collection(_collectionName).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi khi thêm giảng viên: $e');
    }
  }

  /// Lấy tất cả giảng viên
  static Future<List<UserModel>> getAllTeachers() async {
    try {
      final qs = await _firestore
          .collection(_collectionName)
          .where('role', isEqualTo: _teacherRole)
          .orderBy('name')
          .get();

      return qs.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách giảng viên: $e');
    }
  }

  /// Stream realtime danh sách giảng viên
  static Stream<List<UserModel>> getTeachersStream() {
    return _firestore
        .collection(_collectionName)
        .where('role', isEqualTo: _teacherRole)
        .orderBy('name')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  /// Lấy giảng viên theo document id
  static Future<UserModel?> getTeacherById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin giảng viên: $e');
    }
  }

  /// Tìm kiếm giảng viên (lọc client-side sau khi query role=lecturer)
  static Future<List<UserModel>> searchTeachers(String searchQuery) async {
    try {
      final q = searchQuery.trim().toLowerCase();
      final qs = await _firestore
          .collection(_collectionName)
          .where('role', isEqualTo: _teacherRole)
          .get();

      return qs.docs
          .map((d) => UserModel.fromMap(d.data(), d.id))
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              (u.maGV ?? '').toLowerCase().contains(q))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm giảng viên: $e');
    }
  }

  /// Cập nhật giảng viên
  static Future<void> updateTeacher(String id, UserModel user) async {
    try {
      final data = user.copyWith(role: _teacherRole).toMap();
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Lỗi khi cập nhật giảng viên: $e');
    }
  }

  /// Xóa giảng viên
  static Future<void> deleteTeacher(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa giảng viên: $e');
    }
  }

  /// Kiểm tra mã GV đã tồn tại chưa (trên collection `users` role=lecturer)
  static Future<bool> checkMaGVExists(String maGV, {String? excludeId}) async {
    try {
      final qs = await _firestore
          .collection(_collectionName)
          .where('role', isEqualTo: _teacherRole)
          .where('maGV', isEqualTo: maGV)
          .get();

      if (excludeId != null) {
        return qs.docs.any((d) => d.id != excludeId);
      }
      return qs.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra mã GV: $e');
    }
  }
}
