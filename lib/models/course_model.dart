class CourseModel {
  final String id;
  final String name;
  final String code;
  final int credits;
  final String? departmentId;

  CourseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.credits,
    this.departmentId,
  });

  factory CourseModel.fromMap(Map<String, dynamic> data, String id) {
    return CourseModel(
      id: id,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      credits: (data['credits'] ?? 0) as int,
      departmentId: data['department_id'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'code': code,
    'credits': credits,
    'department_id': departmentId,
  };
}
