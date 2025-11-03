import '../../services/firestore_service.dart';

class CourseModel implements HasId {
  final String _id;
  final String name;
  final String teacherId;      // Giảng viên phụ trách khóa học
  final String departmentId;   // Khoa / bộ môn
  final List<String>? classIds; // Lớp học thuộc khóa học
  final String? description;    // Mô tả khóa học
  final int? credits;           // Số tín chỉ
  final String? semester;       // Học kỳ

  CourseModel({
    required String id,
    required this.name,
    required this.teacherId,
    required this.departmentId,
    this.classIds,
    this.description,
    this.credits,
    this.semester,
  }) : _id = id;

  @override
  String get id => _id;

  factory CourseModel.fromMap(Map<String, dynamic> data, String id) {
    return CourseModel(
      id: id,
      name: _getString(data, 'name'),
      teacherId: _getString(data, 'teacher_id'),
      departmentId: _getString(data, 'department_id'),
      classIds: _getListString(data, 'class_ids'),
      description: _getString(data, 'description'),
      credits: data['credits'] != null ? int.tryParse(data['credits'].toString()) : null,
      semester: _getString(data, 'semester'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'teacher_id': teacherId,
      'department_id': departmentId,
      if (classIds != null) 'class_ids': classIds,
      if (description != null) 'description': description,
      if (credits != null) 'credits': credits,
      if (semester != null) 'semester': semester,
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
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      departmentId: departmentId ?? this.departmentId,
      classIds: classIds ?? this.classIds,
      description: description ?? this.description,
      credits: credits ?? this.credits,
      semester: semester ?? this.semester,
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
