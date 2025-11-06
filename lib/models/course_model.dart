import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel implements HasId {
  final String _id;
  final String name;
  final String lecturerId;      // Giảng viên phụ trách khóa học
  final String departmentId;   // Khoa / bộ môn
  final List<String> classIds; // Lớp học thuộc khóa học
  final String? description;    // Mô tả khóa học
  final int credits;           // Số tín chỉ
  final String? semester;       // Học kỳ
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  CourseModel({
    required String id,
    required this.name,
    required this.lecturerId,
    required this.departmentId,
    List<String>? classIds,
    this.description,
    this.credits = 3, // Giá trị mặc định
    this.semester,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  })  : _id = id,
        classIds = classIds ?? [];

  @override
  String get id => _id;

  factory CourseModel.fromMap(Map<String, dynamic> data, String id) {
    return CourseModel(
      id: id,
      name: _getString(data, 'name'),
      lecturerId: _getString(data, 'lecturer_id'),
      departmentId: _getString(data, 'department_id'),
      classIds: _getListString(data, 'class_ids'),
      description: _getString(data, 'description'),
      credits: _getInt(data, 'credits', 3),
      semester: _getString(data, 'semester'),
      createdAt: _getDateTime(data, 'created_at'),
      updatedAt: _getDateTime(data, 'updated_at'),
      isActive: data['is_active'] ?? true,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'lecturer_id': lecturerId,
      'department_id': departmentId,
      'class_ids': classIds,
      if (description != null && description!.isNotEmpty) 'description': description,
      'credits': credits,
      if (semester != null && semester!.isNotEmpty) 'semester': semester,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  CourseModel copyWith({
    String? id,
    String? name,
    String? teacherId,
    String? departmentId,
    List<String>? classIds,
    String? description,
    int? credits,
    String? semester,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lecturerId: lecturerId ?? this.lecturerId,
      departmentId: departmentId ?? this.departmentId,
      classIds: classIds ?? this.classIds,
      description: description ?? this.description,
      credits: credits ?? this.credits, 
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // ===== Business Logic Methods =====
  
  /// Kiểm tra khóa học có lớp học cụ thể không
  bool containsClass(String classId) {
    return classIds.contains(classId);
  }

  /// Thêm lớp học vào khóa học
  CourseModel addClass(String classId) {
    final newClassIds = List<String>.from(classIds);
    if (!newClassIds.contains(classId)) {
      newClassIds.add(classId);
    }
    return copyWith(classIds: newClassIds);
  }

  /// Xóa lớp học khỏi khóa học
  CourseModel removeClass(String classId) {
    final newClassIds = List<String>.from(classIds);
    newClassIds.remove(classId);
    return copyWith(classIds: newClassIds);
  }

  /// Kiểm tra khóa học có đang hoạt động không
  bool get isActiveCourse => isActive;

  /// Lấy số lượng lớp học
  int get classCount => classIds.length;

  // ===== Helper functions =====
  static String _getString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  static List<String> _getListString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  static int _getInt(Map<String, dynamic> data, String key, [int defaultValue = 0]) {
    final value = data[key];
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static DateTime? _getDateTime(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }

  @override
  String toString() {
    return 'CourseModel(id: $id, name: $name, lecturerId: $lecturerId, classes: $classCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}