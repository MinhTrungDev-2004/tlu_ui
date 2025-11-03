import 'package:cloud_firestore/cloud_firestore.dart';

class FaceDataModel {
  final String id;                  // document ID
  final String userId;
  final List<double> embeddings;
  final Timestamp updatedAt;
  final int version;                // số lần cập nhật
  final String? method;             // "camera", "upload", "import"

  FaceDataModel({
    required this.id,
    required this.userId,
    required this.embeddings,
    required this.updatedAt,
    this.version = 1,
    this.method,
  });

  factory FaceDataModel.fromMap(Map<String, dynamic> data, String id) {
    return FaceDataModel(
      id: id,
      userId: data['user_id'] as String,
      embeddings: List<double>.from((data['embeddings'] as List<dynamic>).map((e) => e.toDouble())),
      updatedAt: data['updated_at'] as Timestamp,
      version: data['version'] != null ? int.tryParse(data['version'].toString()) ?? 1 : 1,
      method: data['method'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'embeddings': embeddings,
      'updated_at': updatedAt,
      'version': version,
      if (method != null) 'method': method,
    };
  }

  FaceDataModel copyWith({
    String? id,
    String? userId,
    List<double>? embeddings,
    Timestamp? updatedAt,
    int? version,
    String? method,
  }) {
    return FaceDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      embeddings: embeddings ?? this.embeddings,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
      method: method ?? this.method,
    );
  }
}
