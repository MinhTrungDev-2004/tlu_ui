import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class FaceDataModel {
  final String id;
  final String userId;
  final List<String> imageUrls;
  final List<List<double>> embeddingsList;
  final Timestamp updatedAt;
  final int version;

  FaceDataModel({
    required this.id,
    required this.userId,
    required this.imageUrls,
    required this.embeddingsList,
    required this.updatedAt,
    this.version = 1,
  });

  /// Tạo object từ Firestore map
  factory FaceDataModel.fromMap(Map<String, dynamic> data, String id) {
    return FaceDataModel(
      id: id,
      userId: data['user_id'] ?? '',
      imageUrls: List<String>.from(data['image_urls'] ?? []),
      // Giải mã mỗi embeddings từ string JSON về List<double>
      embeddingsList: (data['embeddings_list'] as List<dynamic>? ?? [])
          .map((e) => List<double>.from(jsonDecode(e as String)))
          .toList(),
      updatedAt: data['updated_at'] ?? Timestamp.now(),
      version: data['version'] != null
          ? int.tryParse(data['version'].toString()) ?? 1
          : 1,
    );
  }

  /// Chuyển object thành map để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'image_urls': imageUrls,
      // Mỗi embeddings List<double> encode thành string
      'embeddings_list':
          embeddingsList.map((e) => jsonEncode(e)).toList(),
      'updated_at': updatedAt,
      'version': version,
    };
  }

  /// Tạo bản sao mới khi cần cập nhật
  FaceDataModel copyWith({
    String? id,
    String? userId,
    List<String>? imageUrls,
    List<List<double>>? embeddingsList,
    Timestamp? updatedAt,
    int? version,
  }) {
    return FaceDataModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrls: imageUrls ?? this.imageUrls,
      embeddingsList: embeddingsList ?? this.embeddingsList,
      updatedAt: updatedAt ?? this.updatedAt,
      version: version ?? this.version,
    );
  }
}
