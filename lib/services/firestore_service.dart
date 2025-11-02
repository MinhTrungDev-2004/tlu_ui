import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../models/attendance_model.dart';
import '../models/class_model.dart';
import '../models/course_model.dart';
import '../models/face_data_model.dart';
import '../models/session_model.dart';
// xử lí các thao tác với Firestore

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==== Map giữa model và tên collection ====
  String _getCollectionName(Type type) {
    switch (type) {
      case UserModel:
        return 'users';
      case AttendanceModel:
        return 'attendance';
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

  // ==== ADD (Create) ====
  Future<void> addDocument<T>(T model) async {
    final collectionName = _getCollectionName(T);
    final ref = _db.collection(collectionName);

    if (model is UserModel) {
      await ref.doc(model.uid).set(model.toMap());
    } else if (model is AttendanceModel) {
      await ref.doc(model.id).set(model.toMap());
    } else if (model is ClassModel) {
      await ref.doc(model.id).set(model.toMap());
    } else if (model is CourseModel) {
      await ref.doc(model.id).set(model.toMap());
    } else if (model is FaceDataModel) {
      await ref.doc(model.userId).set(model.toMap());
    } else if (model is SessionModel) {
      await ref.doc(model.id).set(model.toMap());
    } else {
      throw Exception('Unsupported model type for addDocument');
    }
  }

  // ==== GET ONE ====
  Future<Map<String, dynamic>?> getDocument<T>(String id) async {
    final collectionName = _getCollectionName(T);
    final doc = await _db.collection(collectionName).doc(id).get();
    return doc.data();
  }

  // ==== GET ALL ====
  Future<List<Map<String, dynamic>>> getAllDocuments<T>() async {
    final collectionName = _getCollectionName(T);
    final snapshot = await _db.collection(collectionName).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ==== UPDATE ====
  Future<void> updateDocument<T>(String id, Map<String, dynamic> data) async {
    final collectionName = _getCollectionName(T);
    await _db.collection(collectionName).doc(id).update(data);
  }

  // ==== DELETE ====
  Future<void> deleteDocument<T>(String id) async {
    final collectionName = _getCollectionName(T);
    await _db.collection(collectionName).doc(id).delete();
  }
}
