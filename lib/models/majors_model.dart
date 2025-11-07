import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class MajorModel implements HasId {
  final String id;
  final String code; // "7480201", "7580201", "7520114", "7510602"
  final String name; // "Công nghệ thông tin", "Kỹ thuật Xây dựng"
  final String departmentId; // ID khoa quản lý (liên kết departments)
  final String? departmentName; // "Khoa CNTT" (lưu trực tiếp để hiển thị nhanh)
  final double duration; // 4.5, 4.0 (năm)
  final String? description;
  final int totalCredits; // Tổng số tín chỉ
  final String degreeType; // "Cử nhân", "Kỹ sư"
  final List<String>? curriculumIds; // Chương trình đào tạo
  final List<String>? classIds; // Các lớp thuộc ngành
  final List<String>? studentIds; // Sinh viên thuộc ngành
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MajorModel({
    required this.id,
    required this.code,
    required this.name,
    required this.departmentId,
    this.departmentName,
    required this.duration,
    this.description,
    this.totalCredits = 150,
    this.degreeType = 'Cử nhân',
    this.curriculumIds,
    this.classIds,
    this.studentIds,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory MajorModel.fromMap(Map<String, dynamic> data, String id) {
    return MajorModel(
      id: id,
      code: data['code']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      departmentId: data['departmentId']?.toString() ?? '',
      departmentName: data['departmentName']?.toString(),
      duration: (data['duration'] as num?)?.toDouble() ?? 4.0,
      description: data['description']?.toString(),
      totalCredits: (data['totalCredits'] as int?) ?? 150,
      degreeType: data['degreeType']?.toString() ?? 'Cử nhân',
      curriculumIds: _parseStringList(data['curriculumIds']),
      classIds: _parseStringList(data['classIds']),
      studentIds: _parseStringList(data['studentIds']),
      isActive: data['isActive'] ?? true,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'departmentId': departmentId,
      if (departmentName != null) 'departmentName': departmentName,
      'duration': duration,
      if (description != null) 'description': description,
      'totalCredits': totalCredits,
      'degreeType': degreeType,
      if (curriculumIds != null) 'curriculumIds': curriculumIds,
      if (classIds != null) 'classIds': classIds,
      if (studentIds != null) 'studentIds': studentIds,
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

  MajorModel copyWith({
    String? id,
    String? code,
    String? name,
    String? departmentId,
    String? departmentName,
    double? duration,
    String? description,
    int? totalCredits,
    String? degreeType,
    List<String>? curriculumIds,
    List<String>? classIds,
    List<String>? studentIds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MajorModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      totalCredits: totalCredits ?? this.totalCredits,
      degreeType: degreeType ?? this.degreeType,
      curriculumIds: curriculumIds ?? this.curriculumIds,
      classIds: classIds ?? this.classIds,
      studentIds: studentIds ?? this.studentIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Business logic methods
  bool get isEngineeringDegree => degreeType.contains('Kỹ sư');
  
  String get displayName => '$code - $name';
  
  String get durationDisplay => '${duration.toStringAsFixed(1)} năm';
  
  int get estimatedSemesters => (duration * 2).round();
  
  @override
  String toString() {
    return 'MajorModel(id: $id, code: $code, name: $name, duration: $duration)';
  }
}