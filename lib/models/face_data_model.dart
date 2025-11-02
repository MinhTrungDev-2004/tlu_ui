import 'package:cloud_firestore/cloud_firestore.dart';

class FaceDataModel {
  final String userId;
  final List<double> embeddings; // vector đặc trưng
  final DateTime updatedAt;

  FaceDataModel({
    required this.userId,
    required this.embeddings,
    required this.updatedAt,
  });

  factory FaceDataModel.fromMap(Map<String, dynamic> data, String id) {
    return FaceDataModel(
      userId: id,
      embeddings: (data['embeddings'] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'embeddings': embeddings,
    'updated_at': Timestamp.fromDate(updatedAt),
  };
}
