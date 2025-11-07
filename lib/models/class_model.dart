import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassModel implements HasId {
  final String _id;
  final String name; // "CNTT-01 K62"
  final String? departmentId; // "CNTT" - Khoa quản lý
  final String? headTeacherId; // ⭐ THÊM: GV chủ nhiệm lớp
  
  // ⭐ SỬA: XÓA courseId, lecturerId - thay bằng:
  final List<String>? courseIds; // Các môn lớp này học
  final List<String>? studentIds; // Danh sách sinh viên
  final List<String>? sessionIds; // Các buổi học của lớp
  
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  ClassModel({
    required String id,
    required this.name,
    this.departmentId,
    this.headTeacherId,
    this.courseIds,
    this.studentIds,
    this.sessionIds,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : _id = id;

  @override
  String get id => _id;

  factory ClassModel.fromMap(Map<String, dynamic> data, String id) {
    print("ClassModel.fromMap -> data: $data"); // ✅ Dòng này giúp bạn debug
    return ClassModel(
      id: id,
      name: _getString(data, 'name', 'Chưa đặt tên'),
      departmentId: data['department_id']?.toString(),
      headTeacherId: data['head_teacher_id']?.toString(),
      courseIds: (data['course_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      studentIds: (data['student_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      sessionIds: (data['session_ids'] as List?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: _getDateTime(data, 'created_at') ?? DateTime.now(),
      updatedAt: _getDateTime(data, 'updated_at'),
      isActive: data['is_active'] ?? true,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      if (departmentId != null) 'department_id': departmentId,
      if (headTeacherId != null) 'head_teacher_id': headTeacherId, // ⭐ SỬA
      if (courseIds != null) 'course_ids': courseIds, // ⭐ SỬA
      if (studentIds != null) 'student_ids': studentIds,
      if (sessionIds != null) 'session_ids': sessionIds,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  ClassModel copyWith({
    String? id,
    String? name,
    String? departmentId,
    String? headTeacherId, // ⭐ SỬA
    List<String>? courseIds, // ⭐ SỬA
    List<String>? studentIds,
    List<String>? sessionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      headTeacherId: headTeacherId ?? this.headTeacherId, // ⭐ SỬA
      courseIds: courseIds ?? this.courseIds, // ⭐ SỬA
      studentIds: studentIds ?? this.studentIds,
      sessionIds: sessionIds ?? this.sessionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

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

  static DateTime? _getDateTime(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }


  // === BUSINESS LOGIC METHODS ===
  
  bool containsStudent(String studentId) {
    return studentIds?.contains(studentId) ?? false;
  }

  ClassModel addStudent(String studentId) {
    final newStudentIds = List<String>.from(studentIds ?? []);
    if (!newStudentIds.contains(studentId)) {
      newStudentIds.add(studentId);
    }
    return copyWith(studentIds: newStudentIds);
  }

  ClassModel removeStudent(String studentId) {
    final newStudentIds = List<String>.from(studentIds ?? []);
    newStudentIds.remove(studentId);
    return copyWith(studentIds: newStudentIds);
  }

  // ⭐ THÊM: Quản lý môn học
  bool containsCourse(String courseId) {
    return courseIds?.contains(courseId) ?? false;
  }

  ClassModel addCourse(String courseId) {
    final newCourseIds = List<String>.from(courseIds ?? []);
    if (!newCourseIds.contains(courseId)) {
      newCourseIds.add(courseId);
    }
    return copyWith(courseIds: newCourseIds);
  }

  ClassModel removeCourse(String courseId) {
    final newCourseIds = List<String>.from(courseIds ?? []);
    newCourseIds.remove(courseId);
    return copyWith(courseIds: newCourseIds);
  }

  ClassModel addSession(String sessionId) {
    final newSessionIds = List<String>.from(sessionIds ?? []);
    if (!newSessionIds.contains(sessionId)) {
      newSessionIds.add(sessionId);
    }
    return copyWith(sessionIds: newSessionIds);
  }

  // ⭐ THÊM: Tính số lượng
  int get studentCount => studentIds?.length ?? 0;
  int get courseCount => courseIds?.length ?? 0;
  int get sessionCount => sessionIds?.length ?? 0;

  @override
  String toString() {
    return 'ClassModel(id: $id, name: $name, courses: $courseCount, students: $studentCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}