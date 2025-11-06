import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel implements HasId {
  final String _id;
  final String name;
  final String departmentId;   // Khoa / bộ môn quản lý
  final String? description;    // Mô tả khóa học
  final int credits;           // Số tín chỉ
  final String? semester;       // Học kỳ (nếu cố định)
  
  // ⭐ SỬA: XÓA lecturerId, classIds - thay bằng:
  final List<String>? lecturerIds; // ⭐ THÊM: Danh sách GV có thể dạy môn này
  final String? courseCode;     // ⭐ THÊM: Mã môn học (ví dụ: "CT101")
  
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  CourseModel({
    required String id,
    required this.name,
    required this.departmentId,
    this.lecturerIds,
    this.courseCode,
    this.description,
    this.credits = 3,
    this.semester,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : _id = id;

  @override
  String get id => _id;

  factory CourseModel.fromMap(Map<String, dynamic> data, String id) {
    return CourseModel(
      id: id,
      name: _getString(data, 'name'),
      departmentId: _getString(data, 'department_id'),
      lecturerIds: _getListString(data, 'lecturer_ids'), // ⭐ SỬA
      courseCode: _getString(data, 'course_code'), // ⭐ THÊM
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
      'department_id': departmentId,
      if (lecturerIds != null) 'lecturer_ids': lecturerIds, // ⭐ SỬA
      if (courseCode != null) 'course_code': courseCode, // ⭐ THÊM
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
    String? departmentId,
    List<String>? lecturerIds, // ⭐ SỬA
    String? courseCode, // ⭐ THÊM
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
      departmentId: departmentId ?? this.departmentId,
      lecturerIds: lecturerIds ?? this.lecturerIds, // ⭐ SỬA
      courseCode: courseCode ?? this.courseCode, // ⭐ THÊM
      description: description ?? this.description,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // ===== Business Logic Methods =====
  
  /// ⭐ SỬA: Quản lý giảng viên (thay vì lớp học)
  bool canTeach(String lecturerId) {
    return lecturerIds?.contains(lecturerId) ?? false;
  }

  /// ⭐ THÊM: Thêm giảng viên có thể dạy môn này
  CourseModel addLecturer(String lecturerId) {
    final newLecturerIds = List<String>.from(lecturerIds ?? []);
    if (!newLecturerIds.contains(lecturerId)) {
      newLecturerIds.add(lecturerId);
    }
    return copyWith(lecturerIds: newLecturerIds);
  }

  /// ⭐ THÊM: Xóa giảng viên khỏi danh sách
  CourseModel removeLecturer(String lecturerId) {
    final newLecturerIds = List<String>.from(lecturerIds ?? []);
    newLecturerIds.remove(lecturerId);
    return copyWith(lecturerIds: newLecturerIds);
  }

  /// Kiểm tra khóa học có đang hoạt động không
  bool get isActiveCourse => isActive;

  /// ⭐ THÊM: Lấy số lượng giảng viên có thể dạy
  int get lecturerCount => lecturerIds?.length ?? 0;

  /// ⭐ THÊM: Kiểm tra có mã môn học không
  bool get hasCourseCode => courseCode != null && courseCode!.isNotEmpty;

  // ===== Helper functions =====
  static String _getString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  static List<String>? _getListString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return null;
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
    return 'CourseModel(id: $id, name: $name, code: $courseCode, lecturers: $lecturerCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CourseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}