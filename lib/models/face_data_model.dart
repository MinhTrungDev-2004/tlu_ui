import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user/user_model.dart';
import '../../services/firestore_service.dart'; // 🔹 THÊM IMPORT

class FaceDataModel implements HasId { // 🔹 THÊM: implements HasId
  final String _id;
  final String userId;
  final String userEmail;
  final String userRole;
  
  final Map<String, String> poseImageUrls;
  final Map<String, List<double>> poseEmbeddings;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final int version;

  FaceDataModel({
    required String id,
    required this.userId,
    required this.userEmail,
    required this.userRole,
    required this.poseImageUrls,
    required this.poseEmbeddings,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.version = 1,
  }):_id = id;

  // 🔹 THÊM: Implement HasId interface
  @override
  String get id => _id;

  @override
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userRole': userRole,
      'poseImageUrls': poseImageUrls,
      'poseEmbeddings': _encodePoseEmbeddings(poseEmbeddings),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
      'version': version,
    };
  }

  /// ✅ Tạo từ Firestore
  factory FaceDataModel.fromMap(Map<String, dynamic> data, String id) {
    return FaceDataModel(
      id: id,
      userId: data['userId']?.toString() ?? '',
      userEmail: data['userEmail']?.toString() ?? '',
      userRole: data['userRole']?.toString() ?? 'student',
      poseImageUrls: Map<String, String>.from(data['poseImageUrls'] ?? {}),
      poseEmbeddings: _parsePoseEmbeddings(data['poseEmbeddings'] ?? {}),
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
      isActive: data['isActive'] ?? true,
      version: (data['version'] as num?)?.toInt() ?? 1,
    );
  }

  /// ✅ SỬA: Helper parse timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is Timestamp) return timestamp.toDate();
    return DateTime.now();
  }

  /// ✅ Parse embeddings từ Firestore
  static Map<String, List<double>> _parsePoseEmbeddings(Map<dynamic, dynamic> data) {
    Map<String, List<double>> result = {};
    data.forEach((key, value) {
      if (value is String) {
        try {
          result[key.toString()] = List<double>.from(jsonDecode(value));
        } catch (e) {
          print('Error parsing embedding for pose $key: $e');
        }
      }
    });
    return result;
  }

  /// ✅ Encode embeddings để lưu Firestore
  static Map<String, String> _encodePoseEmbeddings(Map<String, List<double>> embeddings) {
    Map<String, String> result = {};
    embeddings.forEach((pose, embedding) {
      result[pose] = jsonEncode(embedding);
    });
    return result;
  }

  /// ✅ CopyWith
  FaceDataModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userRole,
    Map<String, String>? poseImageUrls,
    Map<String, List<double>>? poseEmbeddings,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? version,
  }) {
    return FaceDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userRole: userRole ?? this.userRole,
      poseImageUrls: poseImageUrls ?? this.poseImageUrls,
      poseEmbeddings: poseEmbeddings ?? this.poseEmbeddings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
    );
  }

  /// ✅ Getter tiện ích
  bool get hasCompleteData => poseImageUrls.length >= 3 && poseEmbeddings.length >= 3;
  List<String> get availablePoses => poseImageUrls.keys.toList();
  
  /// ✅ Tạo mới từ UserModel
  factory FaceDataModel.fromUser({
    required UserModel user,
    required Map<String, String> poseImageUrls,
    required Map<String, List<double>> poseEmbeddings,
  }) {
    final now = DateTime.now();
    return FaceDataModel(
      id: 'face_${user.uid}',
      userId: user.uid,
      userEmail: user.email,
      userRole: user.role,
      poseImageUrls: poseImageUrls,
      poseEmbeddings: poseEmbeddings,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// ✅ THÊM: Factory để tạo face data trống
  factory FaceDataModel.empty({required UserModel user}) {
    final now = DateTime.now();
    return FaceDataModel(
      id: 'face_${user.uid}',
      userId: user.uid,
      userEmail: user.email,
      userRole: user.role,
      poseImageUrls: {},
      poseEmbeddings: {},
      createdAt: now,
      updatedAt: now,
      isActive: true,
      version: 0,
    );
  }

  /// ✅ THÊM: Convert to JSON
  Map<String, dynamic> toJson() => toMap();

  /// ✅ THÊM: Debug string
  @override
  String toString() {
    return 'FaceDataModel(id: $id, userId: $userId, poses: ${poseImageUrls.keys.toList()}, hasEmbeddings: ${poseEmbeddings.isNotEmpty})';
  }
}