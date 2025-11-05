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

  String _getCollectionName<T>() {
    switch (T) {
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
        throw Exception('Unknown model type: $T');
    }
  }

  /// 🔹 SỬA: Generic method để convert Map → Model
  T _convertToModel<T>(Map<String, dynamic> data) {
    final id = data['id']?.toString() ?? '';
    
    switch (T) {
      case UserModel:
        return UserModel.fromMap(data, id) as T;
      case AttendanceModel:
        return AttendanceModel.fromMap(data, id) as T;
      case ClassModel:
        return ClassModel.fromMap(data, id) as T;
      case CourseModel:
        return CourseModel.fromMap(data, id) as T;
      case FaceDataModel:
        return FaceDataModel.fromMap(data, id) as T;
      case SessionModel:
        return SessionModel.fromMap(data, id) as T;
      default:
        throw Exception('Unknown model type for conversion: $T');
    }
  }

  /// 🔹 SỬA: Helper method để extract data từ DocumentSnapshot an toàn
  Map<String, dynamic> _extractDataFromDocument(DocumentSnapshot<Object?> doc) {
    final rawData = doc.data();
    if (rawData == null) return {'id': doc.id};
    
    if (rawData is Map<String, dynamic>) {
      return Map<String, dynamic>.from(rawData)..['id'] = doc.id;
    } else if (rawData is Map<dynamic, dynamic>) {
      // Convert Map<dynamic, dynamic> → Map<String, dynamic>
      final Map<String, dynamic> convertedData = {};
      rawData.forEach((key, value) {
        convertedData[key.toString()] = value;
      });
      return convertedData..['id'] = doc.id;
    } else {
      throw Exception('Unexpected document data type: ${rawData.runtimeType}');
    }
  }

  /// 🔹 SỬA: Helper method cho QueryDocumentSnapshot
  Map<String, dynamic> _extractDataFromQueryDoc(QueryDocumentSnapshot<Object?> doc) {
    final rawData = doc.data();
    if (rawData == null) return {'id': doc.id};
    
    if (rawData is Map<String, dynamic>) {
      return Map<String, dynamic>.from(rawData)..['id'] = doc.id;
    } else if (rawData is Map<dynamic, dynamic>) {
      final Map<String, dynamic> convertedData = {};
      rawData.forEach((key, value) {
        convertedData[key.toString()] = value;
      });
      return convertedData..['id'] = doc.id;
    } else {
      throw Exception('Unexpected document data type: ${rawData.runtimeType}');
    }
  }

  /// Thêm document vào Firestore
  Future<void> addDocument<T extends HasId>(T model, {String? customCollection}) async {
    try {
      final collectionName = customCollection ?? _getCollectionName<T>();
      await _db.collection(collectionName).doc(model.id).set(model.toMap());
    } catch (e) {
      throw Exception('Error adding document: $e');
    }
  }

  /// Lấy document theo id và trả về Model
  Future<T?> getDocument<T extends HasId>(String id) async {
    try {
      final collectionName = _getCollectionName<T>();
      final doc = await _db.collection(collectionName).doc(id).get();
      
      if (!doc.exists) return null;
      
      final Map<String, dynamic> data = _extractDataFromDocument(doc);
      return _convertToModel<T>(data);
    } catch (e) {
      throw Exception('Error getting document: $e');
    }
  }

  /// Lấy tất cả documents và trả về List<Model>
  Future<List<T>> getAllDocuments<T extends HasId>() async {
    try {
      final collectionName = _getCollectionName<T>();
      final snapshot = await _db.collection(collectionName).get();
      
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
        return _convertToModel<T>(data);
      }).toList();
    } catch (e) {
      throw Exception('Error getting all documents: $e');
    }
  }

  /// Lấy documents với query
  Future<List<T>> queryDocuments<T extends HasId>({
    String? field,
    dynamic isEqualTo,
    dynamic isNotEqualTo,
    dynamic isLessThan,
    dynamic isLessThanOrEqualTo,
    dynamic isGreaterThan,
    dynamic isGreaterThanOrEqualTo,
    dynamic arrayContains,
    List<dynamic>? arrayContainsAny,
    List<dynamic>? whereIn,
    List<dynamic>? whereNotIn,
    bool? isNull,
  }) async {
    try {
      final collectionName = _getCollectionName<T>();
      Query query = _db.collection(collectionName);

      if (field != null && isEqualTo != null) {
        query = query.where(field, isEqualTo: isEqualTo);
      }
      if (field != null && isNotEqualTo != null) {
        query = query.where(field, isNotEqualTo: isNotEqualTo);
      }
      if (field != null && isLessThan != null) {
        query = query.where(field, isLessThan: isLessThan);
      }
      if (field != null && isLessThanOrEqualTo != null) {
        query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
      }
      if (field != null && isGreaterThan != null) {
        query = query.where(field, isGreaterThan: isGreaterThan);
      }
      if (field != null && isGreaterThanOrEqualTo != null) {
        query = query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
      }
      if (field != null && arrayContains != null) {
        query = query.where(field, arrayContains: arrayContains);
      }
      if (field != null && arrayContainsAny != null) {
        query = query.where(field, arrayContainsAny: arrayContainsAny);
      }
      if (field != null && whereIn != null) {
        query = query.where(field, whereIn: whereIn);
      }
      if (field != null && whereNotIn != null) {
        query = query.where(field, whereNotIn: whereNotIn);
      }
      if (field != null && isNull == true) {
        query = query.where(field, isNull: true);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
        return _convertToModel<T>(data);
      }).toList();
    } catch (e) {
      throw Exception('Error querying documents: $e');
    }
  }

  /// Cập nhật document
  Future<void> updateDocument<T extends HasId>(String id, Map<String, dynamic> updates) async {
    try {
      final collectionName = _getCollectionName<T>();
      await _db.collection(collectionName).doc(id).update(updates);
    } catch (e) {
      throw Exception('Error updating document: $e');
    }
  }

  /// Xóa document
  Future<void> deleteDocument<T extends HasId>(String id) async {
    try {
      final collectionName = _getCollectionName<T>();
      await _db.collection(collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting document: $e');
    }
  }

  /// Stream real-time changes cho collection
  Stream<List<T>> watchCollection<T extends HasId>() {
    final collectionName = _getCollectionName<T>();
    return _db.collection(collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
        return _convertToModel<T>(data);
      }).toList();
    });
  }

  /// Stream real-time changes cho single document
  Stream<T?> watchDocument<T extends HasId>(String id) {
    final collectionName = _getCollectionName<T>();
    return _db.collection(collectionName).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      final Map<String, dynamic> data = _extractDataFromDocument(doc);
      return _convertToModel<T>(data);
    });
  }

  /// Kiểm tra document tồn tại
  Future<bool> documentExists<T extends HasId>(String id) async {
    final collectionName = _getCollectionName<T>();
    final doc = await _db.collection(collectionName).doc(id).get();
    return doc.exists;
  }

  /// Batch write - thêm/update nhiều documents cùng lúc
  Future<void> batchWrite<T extends HasId>(List<T> documents) async {
    final collectionName = _getCollectionName<T>();
    final batch = _db.batch();
    
    for (final doc in documents) {
      final docRef = _db.collection(collectionName).doc(doc.id);
      batch.set(docRef, doc.toMap());
    }
    
    await batch.commit();
  }

  /// 🔹 THÊM: Lấy documents với sắp xếp
  Future<List<T>> getDocumentsWithOrder<T extends HasId>({
    String? orderByField,
    bool descending = false,
    int? limit,
  }) async {
    try {
      final collectionName = _getCollectionName<T>();
      Query query = _db.collection(collectionName);

      if (orderByField != null) {
        query = query.orderBy(orderByField, descending: descending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
        return _convertToModel<T>(data);
      }).toList();
    } catch (e) {
      throw Exception('Error getting documents with order: $e');
    }
  }

  /// 🔹 THÊM: Xóa nhiều documents theo điều kiện
  Future<void> deleteDocumentsWhere<T extends HasId>({
    required String field,
    required dynamic value,
  }) async {
    try {
      final collectionName = _getCollectionName<T>();
      final snapshot = await _db.collection(collectionName)
          .where(field, isEqualTo: value)
          .get();

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error deleting documents where: $e');
    }
  }
}