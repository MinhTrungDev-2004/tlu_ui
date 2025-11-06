import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/user_model.dart';

class UserService {
  final CollectionReference _usersCollection =
  FirebaseFirestore.instance.collection('users');
  Stream<UserModel> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw Exception("Không tìm thấy người dùng với UID: $uid");
      }

      // Sử dụng factory 'fromMap' của bạn để chuyển đổi
      final data = snapshot.data() as Map<String, dynamic>;
      return UserModel.fromMap(data, snapshot.id);
    });
  }

  /// Lấy dữ liệu người dùng (chỉ một lần) bằng Future
  Future<UserModel> getUser(String uid) async {
    final snapshot = await _usersCollection.doc(uid).get();

    if (!snapshot.exists) {
      throw Exception("Không tìm thấy người dùng với UID: $uid");
    }

    final data = snapshot.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, snapshot.id);
  }

  /// Cập nhật dữ liệu người dùng
  Future<void> updateUser(String uid, Map<String, dynamic> data) {
    // Bạn có thể dùng `toUpdateMap()` từ model của bạn ở đây
    return _usersCollection.doc(uid).update(data);
  }
}