import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/user_model.dart';

/// Service quản lý GIẢNG VIÊN (role = 'lecturer') trong collection `users`
/// DỮ LIỆU: dùng `lecturerCode` làm mã GV
class TeacherService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'users';
  static const String _teacherRole = 'lecturer';

  // ==================== LẤY DANH SÁCH ====================
  static Future<List<UserModel>> getAllTeachers() async {
    try {
      final query = _firestore
          .collection(_collectionName)
          .where('role', isEqualTo: _teacherRole)
          .orderBy('name'); // CẦN INDEX: role + name

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        throw Exception(
          'Firestore cần index!\n'
          '→ Click link trong console để tạo:\n'
          'Collection: users\n'
          'Fields: role (Ascending), name (Ascending)',
        );
      }
      rethrow;
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách giảng viên: $e');
    }
  }

  // ==================== STREAM REALTIME ====================
  static Stream<List<UserModel>> getTeachersStream() {
    return _firestore
        .collection(_collectionName)
        .where('role', isEqualTo: _teacherRole)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ==================== LẤY THEO ID ====================
  static Future<UserModel?> getTeacherById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin giảng viên: $e');
    }
  }

  // ==================== TÌM KIẾM (DỰA TRÊN lecturerCode) ====================
  static Future<List<UserModel>> searchTeachers(String searchQuery) async {
    if (searchQuery.trim().isEmpty) return getAllTeachers();

    final q = searchQuery.trim().toLowerCase();
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('role', isEqualTo: _teacherRole)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .where((user) =>
              user.name.toLowerCase().contains(q) ||
              user.email.toLowerCase().contains(q) ||
              (user.lecturerCode ?? '').toLowerCase().contains(q))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm giảng viên: $e');
    }
  }

  // ==================== CẬP NHẬT ====================
  static Future<void> updateTeacher(String id, UserModel user) async {
    try {
      final data = user.copyWith(role: _teacherRole).toMap();
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Lỗi cập nhật giảng viên: $e');
    }
  }

  // ==================== XÓA ====================
  static Future<void> deleteTeacher(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Lỗi xóa giảng viên: $e');
    }
  }

  // ==================== KIỂM TRA MÃ GV TRÙNG (DỰA TRÊN lecturerCode) ====================
  static Future<bool> checkLecturerCodeExists(String code, {String? excludeId}) async {
    if (code.trim().isEmpty) return false;

    try {
      final query = _firestore
          .collection(_collectionName)
          .where('role', isEqualTo: _teacherRole)
          .where('lecturerCode', isEqualTo: code.trim()); // CẦN INDEX

      final snapshot = await query.get();

      if (excludeId != null) {
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }
      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (e) {
      if (e.code == 'failed-precondition') {
        throw Exception(
          'Cần tạo index cho: role + lecturerCode\n'
          '→ Vào Firebase Console → Indexes → Tạo composite index',
        );
      }
      rethrow;
    } catch (e) {
      throw Exception('Lỗi kiểm tra mã giảng viên: $e');
    }
  }
}