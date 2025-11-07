
import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel implements HasId {
  final String id;
  final String code; // "CNTT", "XD", "CK", "TNN"
  final String name; // "Khoa Công nghệ thông tin"
  final String? headOfDepartmentId; // ID trưởng khoa (liên kết users)
  final String? headOfDepartmentName; // "GS. TSKH. ABC" (lưu trực tiếp để hiển thị nhanh)
  final String office; // "P201 - Nhà C1"
  final String? description;
  final List<String>? lecturerIds; // Danh sách giảng viên thuộc khoa
  final List<String>? majorIds; // Các ngành đào tạo thuộc khoa
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DepartmentModel({
    required this.id,
    required this.code,
    required this.name,
    this.headOfDepartmentId,
    this.headOfDepartmentName,
    required this.office,
    this.description,
    this.lecturerIds,
    this.majorIds,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory DepartmentModel.fromMap(Map<String, dynamic> data, String id) {
    return DepartmentModel(
      id: id,
      code: data['code']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      headOfDepartmentId: data['headOfDepartmentId']?.toString(),
      headOfDepartmentName: data['headOfDepartmentName']?.toString(),
      office: data['office']?.toString() ?? '',
      description: data['description']?.toString(),
      lecturerIds: _parseStringList(data['lecturerIds']),
      majorIds: _parseStringList(data['majorIds']),
      isActive: data['isActive'] ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      if (headOfDepartmentId != null) 'headOfDepartmentId': headOfDepartmentId,
      if (headOfDepartmentName != null) 'headOfDepartmentName': headOfDepartmentName,
      'office': office,
      if (description != null) 'description': description,
      if (lecturerIds != null) 'lecturerIds': lecturerIds,
      if (majorIds != null) 'majorIds': majorIds,
      'isActive': isActive,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  // Helper methods
  static List<String>? _parseStringList(dynamic data) {
    if (data == null) return null;
    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }
    return null;
  }

  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is DateTime) return timestamp;
    if (timestamp is Timestamp) return timestamp.toDate();
    return null;
  }

  DepartmentModel copyWith({
    String? id,
    String? code,
    String? name,
    String? headOfDepartmentId,
    String? headOfDepartmentName,
    String? office,
    String? description,
    List<String>? lecturerIds,
    List<String>? majorIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      headOfDepartmentId: headOfDepartmentId ?? this.headOfDepartmentId,
      headOfDepartmentName: headOfDepartmentName ?? this.headOfDepartmentName,
      office: office ?? this.office,
      description: description ?? this.description,
      lecturerIds: lecturerIds ?? this.lecturerIds,
      majorIds: majorIds ?? this.majorIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Business logic methods
  bool get hasHeadOfDepartment => headOfDepartmentId != null;
  
  String get displayName => '$code - $name';
  
  @override
  String toString() {
    return 'DepartmentModel(id: $id, code: $code, name: $name)';
  }
}