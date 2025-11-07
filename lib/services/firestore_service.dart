import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../models/attendance_model.dart';
import '../models/class_model.dart';
import '../models/course_model.dart';
import '../models/face_data_model.dart';
import '../models/session_model.dart';
import '../models/majors_model.dart';
import '../models/department_model.dart';
import '../models/room_model.dart';

/// Interface chuẩn cho các model có id
abstract class HasId {
  String get id;
  Map<String, dynamic> toMap();
}

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _getCollectionName<T>() {
    if (T == UserModel) return 'users';
    if (T == AttendanceModel) return 'attendance_records'; // 🚨 SỬA: 'attendances' → 'attendance_records'
    if (T == ClassModel) return 'classes';
    if (T == CourseModel) return 'courses';
    if (T == FaceDataModel) return 'face_data';
    if (T == SessionModel) return 'sessions';
    
    throw Exception('Unknown model type: $T');
  }

  /// 🔹 Generic method để convert Map → Model
  T _convertToModel<T extends HasId>(Map<String, dynamic> data, String id) {
    if (T == UserModel) {
      return UserModel.fromMap(data, id) as T;
    } else if (T == AttendanceModel) {
      return AttendanceModel.fromMap(data, id) as T;
    } else if (T == ClassModel) {
      return ClassModel.fromMap(data, id) as T;
    } else if (T == CourseModel) {
      return CourseModel.fromMap(data, id) as T;
    } else if (T == FaceDataModel) {
      return FaceDataModel.fromMap(data, id) as T;
    } else if (T == SessionModel) {
      return SessionModel.fromMap(data, id) as T;
    }
    
    throw Exception('Unknown model type for conversion: $T');
  }

  /// 🔹 Helper method để extract data từ DocumentSnapshot an toàn
  Map<String, dynamic> _extractDataFromDocument(DocumentSnapshot<Object?> doc) {
    final rawData = doc.data();
    final result = <String, dynamic>{'id': doc.id};
    
    if (rawData == null) return result;
    
    if (rawData is Map<String, dynamic>) {
      result.addAll(rawData);
    } else if (rawData is Map<dynamic, dynamic>) {
      // Convert Map<dynamic, dynamic> → Map<String, dynamic>
      rawData.forEach((key, value) {
        result[key.toString()] = value;
      });
    }
    
    return result;
  }

  /// 🔹 Helper method cho QueryDocumentSnapshot
  Map<String, dynamic> _extractDataFromQueryDoc(QueryDocumentSnapshot<Object?> doc) {
    final rawData = doc.data();
    final result = <String, dynamic>{'id': doc.id};
    
    if (rawData == null) return result;
    
    if (rawData is Map<String, dynamic>) {
      result.addAll(rawData);
    } else if (rawData is Map<dynamic, dynamic>) {
      rawData.forEach((key, value) {
        result[key.toString()] = value;
      });
    }
    
    return result;
  }

  /// 🆕 THÊM: Method với custom collection name
  Future<void> createDocument<T extends HasId>({
    required String collection,
    required Map<String, dynamic> data,
    required String id,
  }) async {
    try {
      await _db.collection(collection).doc(id).set(data);
      print('✅ [FirestoreService] Đã tạo document: $collection/$id');
    } catch (e) {
      print('❌ [FirestoreService] Lỗi tạo document: $e');
      rethrow;
    }
  }

  /// Thêm document vào Firestore
  Future<void> addDocument<T extends HasId>(T model, {String? customCollection}) async {
    try {
      final collectionName = customCollection ?? _getCollectionName<T>();
      await _db.collection(collectionName).doc(model.id).set(model.toMap());
      print('✅ [FirestoreService] Đã thêm document: $collectionName/${model.id}');
    } catch (e) {
      print('❌ [FirestoreService] Lỗi thêm document: $e');
      rethrow;
    }
  }

  /// Lấy document theo id và trả về Model
  Future<T?> getDocument<T extends HasId>(String id) async {
    try {
      final collectionName = _getCollectionName<T>();
      final doc = await _db.collection(collectionName).doc(id).get();
      
      if (!doc.exists) {
        print('ℹ️ [FirestoreService] Document không tồn tại: $collectionName/$id');
        return null;
      }
      
      final Map<String, dynamic> data = _extractDataFromDocument(doc);
      final result = _convertToModel<T>(data, id);
      print('✅ [FirestoreService] Đã lấy document: $collectionName/$id');
      return result;
    } catch (e) {
      print('❌ [FirestoreService] Lỗi lấy document: $e');
      rethrow;
    }
  }

  /// 🆕 THÊM: Lấy document từ collection cụ thể
  Future<T?> getDocumentFromCollection<T extends HasId>({
    required String collection,
    required String id,
  }) async {
    try {
      final doc = await _db.collection(collection).doc(id).get();
      
      if (!doc.exists) {
        print('ℹ️ [FirestoreService] Document không tồn tại: $collection/$id');
        return null;
      }
      
      final Map<String, dynamic> data = _extractDataFromDocument(doc);
      final result = _convertToModel<T>(data, id);
      print('✅ [FirestoreService] Đã lấy document: $collection/$id');
      return result;
    } catch (e) {
      print('❌ [FirestoreService] Lỗi lấy document từ collection: $e');
      rethrow;
    }
  }

  /// Lấy tất cả documents và trả về List<Model>
  Future<List<T>> getAllDocuments<T extends HasId>([String? collection]) async {
    try {
      final collectionName = collection ?? _getCollectionName<T>();
      final snapshot = await _db.collection(collectionName).get();
      
      final result = snapshot.docs.map((doc) {
        final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
        return _convertToModel<T>(data, doc.id);
      }).toList();
      
      print('✅ [FirestoreService] Đã lấy ${result.length} documents từ $collectionName');
      return result;
    } catch (e) {
      print('❌ [FirestoreService] Lỗi lấy all documents: $e');
      rethrow;
    }
  }

  /// Lấy documents với query
  Future<List<T>> queryDocuments<T extends HasId>({
    String? collection,
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
      final collectionName = collection ?? _getCollectionName<T>();
      Query query = _db.collection(collectionName);

      if (field != null) {
        if (isEqualTo != null) {
          query = query.where(field, isEqualTo: isEqualTo);
        }
        if (isNotEqualTo != null) {
          query = query.where(field, isNotEqualTo: isNotEqualTo);
        }
        if (isLessThan != null) {
          query = query.where(field, isLessThan: isLessThan);
        }
        if (isLessThanOrEqualTo != null) {
          query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
        }
        if (isGreaterThan != null) {
          query = query.where(field, isGreaterThan: isGreaterThan);
        }
        if (isGreaterThanOrEqualTo != null) {
          query = query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
        }
        if (arrayContains != null) {
          query = query.where(field, arrayContains: arrayContains);
        }
        if (arrayContainsAny != null) {
          query = query.where(field, arrayContainsAny: arrayContainsAny);
        }
        if (whereIn != null) {
          query = query.where(field, whereIn: whereIn);
        }
        if (whereNotIn != null) {
          query = query.where(field, whereNotIn: whereNotIn);
        }
        if (isNull == true) {
          query = query.where(field, isNull: true);
        }
      }

      final snapshot = await query.get();
      final result = snapshot.docs.map((doc) {
        final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
        return _convertToModel<T>(data, doc.id);
      }).toList();
      
      print('✅ [FirestoreService] Query $collectionName: ${result.length} documents');
      return result;
    } catch (e) {
      print('❌ [FirestoreService] Lỗi query documents: $e');
      rethrow;
    }
  }

  /// Cập nhật document
  Future<void> updateDocument<T extends HasId>(String id, Map<String, dynamic> updates) async {
    try {
      final collectionName = _getCollectionName<T>();
      await _db.collection(collectionName).doc(id).update(updates);
      print('✅ [FirestoreService] Đã cập nhật document: $collectionName/$id');
    } catch (e) {
      print('❌ [FirestoreService] Lỗi cập nhật document: $e');
      rethrow;
    }
  }

  /// Xóa document
  Future<void> deleteDocument<T extends HasId>(String id) async {
    try {
      final collectionName = _getCollectionName<T>();
      await _db.collection(collectionName).doc(id).delete();
      print('✅ [FirestoreService] Đã xóa document: $collectionName/$id');
    } catch (e) {
      print('❌ [FirestoreService] Lỗi xóa document: $e');
      rethrow;
    }
  }

  /// Stream real-time changes cho collection
  Stream<List<T>> watchCollection<T extends HasId>() {
    final collectionName = _getCollectionName<T>();
    return _db.collection(collectionName).snapshots().map((snapshot) {
      final result = snapshot.docs.map((doc) {
        final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
        return _convertToModel<T>(data, doc.id);
      }).toList();
      print('📡 [FirestoreService] Stream update: ${result.length} documents từ $collectionName');
      return result;
    });
  }

  /// Stream real-time changes cho single document
  Stream<T?> watchDocument<T extends HasId>(String id) {
    final collectionName = _getCollectionName<T>();
    return _db.collection(collectionName).doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        print('📡 [FirestoreService] Stream: Document $collectionName/$id không tồn tại');
        return null;
      }
      final Map<String, dynamic> data = _extractDataFromDocument(doc);
      final result = _convertToModel<T>(data, doc.id);
      print('📡 [FirestoreService] Stream update: $collectionName/$id');
      return result;
    });
  }

  /// 🔹 Stream query documents với điều kiện
  Stream<List<T>> watchQueryDocuments<T extends HasId>({
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
  }) {
    try {
      final collectionName = _getCollectionName<T>();
      Query query = _db.collection(collectionName);

      if (field != null) {
        if (isEqualTo != null) {
          query = query.where(field, isEqualTo: isEqualTo);
        }
        if (isNotEqualTo != null) {
          query = query.where(field, isNotEqualTo: isNotEqualTo);
        }
        if (isLessThan != null) {
          query = query.where(field, isLessThan: isLessThan);
        }
        if (isLessThanOrEqualTo != null) {
          query = query.where(field, isLessThanOrEqualTo: isLessThanOrEqualTo);
        }
        if (isGreaterThan != null) {
          query = query.where(field, isGreaterThan: isGreaterThan);
        }
        if (isGreaterThanOrEqualTo != null) {
          query = query.where(field, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo);
        }
        if (arrayContains != null) {
          query = query.where(field, arrayContains: arrayContains);
        }
        if (arrayContainsAny != null) {
          query = query.where(field, arrayContainsAny: arrayContainsAny);
        }
        if (whereIn != null) {
          query = query.where(field, whereIn: whereIn);
        }
        if (whereNotIn != null) {
          query = query.where(field, whereNotIn: whereNotIn);
        }
        if (isNull == true) {
          query = query.where(field, isNull: true);
        }
      }

      return query.snapshots().map((snapshot) {
        final result = snapshot.docs.map((doc) {
          final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
          return _convertToModel<T>(data, doc.id);
        }).toList();
        print('📡 [FirestoreService] Stream query: ${result.length} documents từ $collectionName');
        return result;
      });
    } catch (e) {
      throw Exception('Error streaming query documents: $e');
    }
  }

  /// Kiểm tra document tồn tại
  Future<bool> documentExists<T extends HasId>(String id) async {
    final collectionName = _getCollectionName<T>();
    final doc = await _db.collection(collectionName).doc(id).get();
    final exists = doc.exists;
    print('ℹ️ [FirestoreService] Document $collectionName/$id ${exists ? 'tồn tại' : 'không tồn tại'}');
    return exists;
  }

  /// 🆕 THÊM: Kiểm tra document tồn tại trong collection cụ thể
  Future<bool> documentExistsInCollection(String collection, String id) async {
    final doc = await _db.collection(collection).doc(id).get();
    final exists = doc.exists;
    print('ℹ️ [FirestoreService] Document $collection/$id ${exists ? 'tồn tại' : 'không tồn tại'}');
    return exists;
  }

  /// Batch write - thêm/update nhiều documents cùng lúc
  Future<void> batchWrite<T extends HasId>(List<T> documents) async {
    final batch = _db.batch();
    
    for (final doc in documents) {
      final collectionName = _getCollectionName<T>();
      final docRef = _db.collection(collectionName).doc(doc.id);
      batch.set(docRef, doc.toMap());
    }
    
    await batch.commit();
    print('✅ [FirestoreService] Đã batch write ${documents.length} documents');
  }

  /// 🔹 Lấy documents với sắp xếp
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
      final result = snapshot.docs.map((doc) {
        final Map<String, dynamic> data = _extractDataFromQueryDoc(doc);
        return _convertToModel<T>(data, doc.id);
      }).toList();
      
      print('✅ [FirestoreService] Đã lấy ${result.length} documents với order từ $collectionName');
      return result;
    } catch (e) {
      print('❌ [FirestoreService] Lỗi lấy documents với order: $e');
      rethrow;
    }
  }

  /// 🔹 Xóa nhiều documents theo điều kiện
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
      print('✅ [FirestoreService] Đã xóa ${snapshot.docs.length} documents từ $collectionName');
    } catch (e) {
      print('❌ [FirestoreService] Lỗi xóa documents where: $e');
      rethrow;
    }
  }

  /// 🆕 THÊM: Debug method để kiểm tra collection names
  void debugCollectionNames() {
    print('🔍 [FirestoreService] Debug Collection Names:');
    print('   - UserModel: ${_getCollectionName<UserModel>()}');
    print('   - AttendanceModel: ${_getCollectionName<AttendanceModel>()}');
    print('   - ClassModel: ${_getCollectionName<ClassModel>()}');
    print('   - CourseModel: ${_getCollectionName<CourseModel>()}');
    print('   - FaceDataModel: ${_getCollectionName<FaceDataModel>()}');
    print('   - SessionModel: ${_getCollectionName<SessionModel>()}');
  }
  
  
}