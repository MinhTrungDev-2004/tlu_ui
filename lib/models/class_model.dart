import '../../services/firestore_service.dart';

class ClassModel implements HasId {
  final String _id;
  final String name;
  final String courseId;
  final String teacherId;
  
  // ===== bổ sung =====
  final String? departmentId;       // Khoa / bộ môn
  final List<String>? studentIds;   // danh sách UID sinh viên
  final List<String>? sessionIds;   // danh sách buổi học

  ClassModel({
    required String id,
    required this.name,
    required this.courseId,
    required this.teacherId,
    this.departmentId,
    this.studentIds,
    this.sessionIds,
  }) : _id = id;

  @override
  String get id => _id;

  factory ClassModel.fromMap(Map<String, dynamic> data, String id) {
    return ClassModel(
      id: id,
      name: _getString(data, 'name'),
      courseId: _getString(data, 'course_id'),
      teacherId: _getString(data, 'teacher_id'),
      departmentId: _getString(data, 'department_id'),
      studentIds: _getListString(data, 'student_ids'),
      sessionIds: _getListString(data, 'session_ids'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course_id': courseId,
      'teacher_id': teacherId,
      if (departmentId != null) 'department_id': departmentId,
      if (studentIds != null) 'student_ids': studentIds,
      if (sessionIds != null) 'session_ids': sessionIds,
    };
  }

  ClassModel copyWith({
    String? id,
    String? name,
    String? courseId,
    String? teacherId,
    String? departmentId,
    List<String>? studentIds,
    List<String>? sessionIds,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      courseId: courseId ?? this.courseId,
      teacherId: teacherId ?? this.teacherId,
      departmentId: departmentId ?? this.departmentId,
      studentIds: studentIds ?? this.studentIds,
      sessionIds: sessionIds ?? this.sessionIds,
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
    if (value is List) return value.map((e) => e.toString()).toList();
    return null;
  }
}
