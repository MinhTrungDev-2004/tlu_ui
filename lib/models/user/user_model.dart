import '../../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class UserModel implements HasId {
  final String uid;
  final String name;
  final String email;
  final String role; // student | lecturer | pdt | admin

  // ==== Giảng viên ====
  final String? lecturerCode;
  final String? academicTitle;
  final String? faculty;
  final List<String>? teachingClassIds;

  // ==== Sinh viên ====
  final String? studentCode;
  final String? classId;
  final String? departmentId;
  final List<String>? classIds;

  // ==== Nhận diện khuôn mặt ====
  final List<String>? faceUrls;
  final bool isFaceRegistered;
  final String? faceDataId;

  // Timestamps để tracking
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.lecturerCode,
    this.academicTitle,
    this.faculty,
    this.teachingClassIds,
    this.studentCode,
    this.classId,
    this.departmentId,
    this.classIds,
    this.faceUrls,
    this.isFaceRegistered = false,
    this.faceDataId,
    this.createdAt,
    this.updatedAt,
  });

  @override
  String get id => uid;

  /// ✅ Từ Firestore Map → UserModel
  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'student',
      lecturerCode: data['lecturerCode']?.toString(),
      academicTitle: data['academicTitle']?.toString(),
      faculty: data['faculty']?.toString(),
      teachingClassIds: _parseStringList(data['teachingClassIds']),
      studentCode: data['studentCode']?.toString(),
      classId: data['classId']?.toString(),
      departmentId: data['departmentId']?.toString(),
      classIds: _parseStringList(data['classIds']),
      faceUrls: _parseStringList(data['faceUrls']),
      isFaceRegistered: data['isFaceRegistered'] == true,
      faceDataId: data['faceDataId']?.toString(),
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  /// ✅ SỬA: Từ UserModel → Firestore Map (FIX FieldValue)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      if (lecturerCode != null) 'lecturerCode': lecturerCode,
      if (academicTitle != null) 'academicTitle': academicTitle,
      if (faculty != null) 'faculty': faculty,
      if (teachingClassIds != null) 'teachingClassIds': teachingClassIds,
      if (studentCode != null) 'studentCode': studentCode,
      if (classId != null) 'classId': classId,
      if (departmentId != null) 'departmentId': departmentId,
      if (classIds != null) 'classIds': classIds,
      if (faceUrls != null) 'faceUrls': faceUrls,
      'isFaceRegistered': isFaceRegistered,
      if (faceDataId != null) 'faceDataId': faceDataId,
      // 🔹 SỬA: Không dùng FieldValue trong toMap(), chỉ dùng khi update trực tiếp
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };
  }

  /// ✅ SỬA: Method riêng cho update (có thể dùng FieldValue)
  Map<String, dynamic> toUpdateMap() {
    return {
      if (name.isNotEmpty) 'name': name,
      if (email.isNotEmpty) 'email': email,
      if (role.isNotEmpty) 'role': role,
      if (lecturerCode != null) 'lecturerCode': lecturerCode,
      if (academicTitle != null) 'academicTitle': academicTitle,
      if (faculty != null) 'faculty': faculty,
      if (teachingClassIds != null) 'teachingClassIds': teachingClassIds,
      if (studentCode != null) 'studentCode': studentCode,
      if (classId != null) 'classId': classId,
      if (departmentId != null) 'departmentId': departmentId,
      if (classIds != null) 'classIds': classIds,
      if (faceUrls != null) 'faceUrls': faceUrls,
      'isFaceRegistered': isFaceRegistered,
      if (faceDataId != null) 'faceDataId': faceDataId,
      'updatedAt': FieldValue.serverTimestamp(), // ✅ CÓ THỂ dùng FieldValue ở đây
    };
  }

  /// ✅ Helper functions
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

  /// ✅ CopyWith với đầy đủ fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? lecturerCode,
    String? academicTitle,
    String? faculty,
    List<String>? teachingClassIds,
    String? studentCode,
    String? classId,
    String? departmentId,
    List<String>? classIds,
    List<String>? faceUrls,
    bool? isFaceRegistered,
    String? faceDataId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      lecturerCode: lecturerCode ?? this.lecturerCode,
      academicTitle: academicTitle ?? this.academicTitle,
      faculty: faculty ?? this.faculty,
      teachingClassIds: teachingClassIds ?? this.teachingClassIds,
      studentCode: studentCode ?? this.studentCode,
      classId: classId ?? this.classId,
      departmentId: departmentId ?? this.departmentId,
      classIds: classIds ?? this.classIds,
      faceUrls: faceUrls ?? this.faceUrls,
      isFaceRegistered: isFaceRegistered ?? this.isFaceRegistered,
      faceDataId: faceDataId ?? this.faceDataId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ✅ Getter tiện ích
  bool get isStudent => role == 'student';
  bool get isLecturer => role == 'teacher';
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

  /// ✅ Check xem đã đăng ký khuôn mặt đầy đủ chưa
  bool get hasCompleteFaceRegistration {
    return isFaceRegistered && 
           faceUrls != null && 
           faceUrls!.length >= 3 &&
           faceDataId != null;
  }

  /// ✅ Helper để update face registration
  UserModel withFaceRegistration({
    required List<String> newFaceUrls,
    required String newFaceDataId,
  }) {
    return copyWith(
      faceUrls: newFaceUrls,
      isFaceRegistered: true,
      faceDataId: newFaceDataId,
      updatedAt: DateTime.now(),
    );
  }

  /// ✅ THÊM: Factory method để tạo user mới
  factory UserModel.createNew({
    required String uid,
    required String name,
    required String email,
    required String role,
    String? lecturerCode,
    String? academicTitle,
    String? faculty,
    String? studentCode,
    String? classId,
    String? departmentId,
  }) {
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      role: role,
      lecturerCode: lecturerCode,
      academicTitle: academicTitle,
      faculty: faculty,
      studentCode: studentCode,
      classId: classId,
      departmentId: departmentId,
      isFaceRegistered: false,
      faceUrls: null,
      faceDataId: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// ✅ THÊM: Convert to JSON (cho API calls nếu cần)
  Map<String, dynamic> toJson() => toMap();

  /// ✅ THÊM: Debug string
  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, role: $role, email: $email, isFaceRegistered: $isFaceRegistered)';
  }
}