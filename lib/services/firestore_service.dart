import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../models/attendance_model.dart';
import '../models/class_model.dart';
import '../models/course_model.dart';
import '../models/face_data_model.dart';
import '../models/session_model.dart';

/// Interface chuẩn cho các model có id
abstract class HasId {
  String get id;
   Map<String, dynamic> toMap();
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _getCollectionName(Type type) {
    switch (type) {
      case UserModel:
        return 'users';
      case AttendanceModel:
        return 'attendances';
      case ClassModel:
        return 'classes';
      case CourseModel:
        return 'courses';
      case FaceDataModel:
        return 'face_data';
      case SessionModel:
        return 'sessions';
      default:
        throw Exception('Unknown model type: $type');
    }
  }

  /// Thêm document vào Firestore
  Future<void> addDocument<T>(T model, {String? collection}) async {
    final collectionName = collection ?? _getCollectionName(T);
    final ref = _db.collection(collectionName);

    if (model is FaceDataModel) {
      await ref.add(model.toMap()); // auto-id
    } else if (model is HasId) {
      await ref.doc(model.id).set(model.toMap());
    } else {
      throw Exception('Unsupported model type for addDocument');
    }
  }

  /// Lấy document theo id
  Future<Map<String, dynamic>?> getDocument<T>(String id) async {
    final collectionName = _getCollectionName(T);
    final doc = await _db.collection(collectionName).doc(id).get();
    if (!doc.exists) return null;
    return {...doc.data()!, 'id': doc.id};
  }

  /// Lấy tất cả document
  Future<List<Map<String, dynamic>>> getAllDocuments<T>() async {
    final collectionName = _getCollectionName(T);
    final snapshot = await _db.collection(collectionName).get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  /// Cập nhật document
  Future<void> updateDocument<T>(String id, Map<String, dynamic> data) async {
    final collectionName = _getCollectionName(T);
    await _db.collection(collectionName).doc(id).set(data, SetOptions(merge: true));
  }

  /// Xóa document
  Future<void> deleteDocument<T>(String id) async {
    final collectionName = _getCollectionName(T);
    await _db.collection(collectionName).doc(id).delete();
  }
}
