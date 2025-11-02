class ClassModel {
  final String id;
  final String courseId;
  final String lecturerId;
  final String semester;
  final List<Map<String, dynamic>> schedule; // [{day:2,time:'07:30-09:30',room:'A101'}]
  final List<String> studentIds;

  ClassModel({
    required this.id,
    required this.courseId,
    required this.lecturerId,
    required this.semester,
    required this.schedule,
    required this.studentIds,
  });

  factory ClassModel.fromMap(Map<String, dynamic> data, String id) {
    return ClassModel(
      id: id,
      courseId: data['course_id'],
      lecturerId: data['lecturer_id'],
      semester: data['semester'],
      schedule: List<Map<String, dynamic>>.from(data['schedule'] ?? []),
      studentIds: List<String>.from(data['student_ids'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'course_id': courseId,
    'lecturer_id': lecturerId,
    'semester': semester,
    'schedule': schedule,
    'student_ids': studentIds,
  };

  ClassModel copyWith({
    String? courseId,
    String? lecturerId,
    String? semester,
    List<Map<String, dynamic>>? schedule,
    List<String>? studentIds,
  }) {
    return ClassModel(
      id: id,
      courseId: courseId ?? this.courseId,
      lecturerId: lecturerId ?? this.lecturerId,
      semester: semester ?? this.semester,
      schedule: schedule ?? this.schedule,
      studentIds: studentIds ?? this.studentIds,
    );
  }
}
