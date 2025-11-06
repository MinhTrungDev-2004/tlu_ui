import '../../services/firestore_service.dart';

class ClassModel implements HasId {
  final String _id;
  final String name;
  final String courseId;
  final String lecturerId;
  
  // ===== bổ sung =====
  final String? departmentId;       // Khoa / bộ môn
  final List<String>? studentIds;   // danh sách UID sinh viên
  final List<String>? sessionIds;   // danh sách buổi học
  
  // === THÊM MỚI: Thông tin cho hiển thị lịch học ===
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  ClassModel({
    required String id,
    required this.name,
    required this.courseId,
    required this.lecturerId,
    this.departmentId,
    this.studentIds,
    this.sessionIds,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : _id = id;

  @override
  String get id => _id;

  factory ClassModel.fromMap(Map<String, dynamic> data, String id) {
    return ClassModel(
      id: id,
      name: _getString(data, 'name'),
      courseId: _getString(data, 'course_id'),
      lecturerId: _getString(data, 'lecturer_id'),
      departmentId: _getString(data, 'department_id'),
      studentIds: _getListString(data, 'student_ids'),
      sessionIds: _getListString(data, 'session_ids'),
      createdAt: _getDateTime(data, 'created_at'),
      updatedAt: _getDateTime(data, 'updated_at'),
      isActive: data['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course_id': courseId,
      'lecturer_id': lecturerId,
      if (departmentId != null) 'department_id': departmentId,
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
    String? courseId,
    String? lecturerId,
    String? departmentId,
    List<String>? studentIds,
    List<String>? sessionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      courseId: courseId ?? this.courseId,
      lecturerId: lecturerId ?? this.lecturerId,
      departmentId: departmentId ?? this.departmentId,
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
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // === THÊM MỚI: Utility methods cho business logic ===
  
  // Kiểm tra nếu class có sinh viên cụ thể
  bool containsStudent(String studentId) {
    return studentIds?.contains(studentId) ?? false;
  }

  // Thêm sinh viên vào class
  ClassModel addStudent(String studentId) {
    final newStudentIds = List<String>.from(studentIds ?? []);
    if (!newStudentIds.contains(studentId)) {
      newStudentIds.add(studentId);
    }
    return copyWith(studentIds: newStudentIds);
  }

  // Xóa sinh viên khỏi class
  ClassModel removeStudent(String studentId) {
    final newStudentIds = List<String>.from(studentIds ?? []);
    newStudentIds.remove(studentId);
    return copyWith(studentIds: newStudentIds);
  }

  // Thêm session vào class
  ClassModel addSession(String sessionId) {
    final newSessionIds = List<String>.from(sessionIds ?? []);
    if (!newSessionIds.contains(sessionId)) {
      newSessionIds.add(sessionId);
    }
    return copyWith(sessionIds: newSessionIds);
  }

  @override
  String toString() {
    return 'ClassModel(id: $id, name: $name, courseId: $courseId, lecturerId: $lecturerId, students: ${studentIds?.length ?? 0})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}