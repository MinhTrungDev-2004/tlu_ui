import '../../services/firestore_service.dart';

class UserModel implements HasId {
  final String uid;
  final String name;
  final String email;
  final String role; // student | lecturer | pdt | admin

  // ==== Giảng viên ====
  final String? lecturerCode;  // Mã giảng viên
  final String? hocHamHocVi;   // Học hàm học vị
  final String? khoa;          // Khoa (tên khoa)
  final List<String>? teachingClassIds; // Lớp giảng viên dạy

  // ==== Sinh viên ====
  final String? studentCode;   // Mã sinh viên
  final String? classId;       // Lớp hành chính
  final String? departmentId;  // Khoa (ID khoa)
  final List<String>? classIds; // Danh sách lớp sinh viên tham gia

  // ==== Nhận diện khuôn mặt ====
  final String? faceUrl;
  final bool isFaceRegistered;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.lecturerCode,
    this.hocHamHocVi,
    this.khoa,
    this.teachingClassIds,
    this.studentCode,
    this.classId,
    this.departmentId,
    this.classIds,
    this.faceUrl,
    this.isFaceRegistered = false,
  });

  @override
  String get id => uid;

  /// ✅ Từ Firestore Map → UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: _getString(data, 'name', ''),
      email: _getString(data, 'email', ''),
      role: _getString(data, 'role', 'student'),
      lecturerCode: _getString(data, 'lecturerCode'),
      hocHamHocVi: _getString(data, 'hocHamHocVi'),
      khoa: _getString(data, 'khoa'),
      teachingClassIds: _getListString(data, 'teachingClassIds'),
      studentCode: _getString(data, 'studentCode'),
      classId: _getString(data, 'classId'),
      departmentId: _getString(data, 'departmentId'),
      classIds: _getListString(data, 'classIds'),
      faceUrl: _getString(data, 'faceUrl'),
      isFaceRegistered: _getBool(data, 'isFaceRegistered', false),
    );
  }

  /// ✅ Từ UserModel → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (lecturerCode != null) 'lecturerCode': lecturerCode,
      if (hocHamHocVi != null) 'hocHamHocVi': hocHamHocVi,
      if (khoa != null) 'khoa': khoa,
      if (teachingClassIds != null) 'teachingClassIds': teachingClassIds,
      if (studentCode != null) 'studentCode': studentCode,
      if (classId != null) 'classId': classId,
      if (departmentId != null) 'departmentId': departmentId,
      if (classIds != null) 'classIds': classIds,
      if (faceUrl != null) 'faceUrl': faceUrl,
      'isFaceRegistered': isFaceRegistered,
    };
  }

  /// ✅ Helper functions
  static String _getString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  static bool _getBool(Map<String, dynamic> data, String key, [bool defaultValue = false]) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value is bool ? value : value.toString().toLowerCase() == 'true';
  }

  static List<String>? _getListString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    return null;
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? lecturerCode,
    String? hocHamHocVi,
    String? khoa,
    List<String>? teachingClassIds,
    String? studentCode,
    String? classId,
    String? departmentId,
    List<String>? classIds,
    String? faceUrl,
    bool? isFaceRegistered,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      lecturerCode: lecturerCode ?? this.lecturerCode,
      hocHamHocVi: hocHamHocVi ?? this.hocHamHocVi,
      khoa: khoa ?? this.khoa,
      teachingClassIds: teachingClassIds ?? this.teachingClassIds,
      studentCode: studentCode ?? this.studentCode,
      classId: classId ?? this.classId,
      departmentId: departmentId ?? this.departmentId,
      classIds: classIds ?? this.classIds,
      faceUrl: faceUrl ?? this.faceUrl,
      isFaceRegistered: isFaceRegistered ?? this.isFaceRegistered,
    );
  }

  /// ✅ Getter tiện ích
  bool get isStudent => role == 'student';
  bool get isLecturer => role == 'lecturer';
  bool get isPDT => role == 'pdt';
  bool get isAdmin => role == 'admin';

  String get displayName {
    if (isStudent && studentCode != null) {
      return '$studentCode - $name';
    }
    if (isLecturer && lecturerCode != null) {
      return '$lecturerCode - $name';
    }
    return name;
  }
}
