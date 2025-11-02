class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // student | lecturer | pdt | admin

  // ==== Giảng viên ====
  final String? maGV;         // Mã giảng viên
  final String? hocHamHocVi;  // Học hàm học vị
  final String? khoa;         // Khoa (tên khoa)

  // ==== Sinh viên ====
  final String? classId;      // Lớp hành chính
  final String? departmentId; // Khoa (ID khoa)

  // ==== Nhận diện khuôn mặt ====
  final String? faceUrl;
  final bool isFaceRegistered;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.maGV,
    this.hocHamHocVi,
    this.khoa,
    this.classId,
    this.departmentId,
    this.faceUrl,
    this.isFaceRegistered = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      role: (data['role'] ?? '') as String,

      maGV: data['maGV'] as String?,
      hocHamHocVi: data['hocHamHocVi'] as String?,
      khoa: data['khoa'] as String?,

      classId: data['class_id'] as String?,
      departmentId: data['department_id'] as String?,

      faceUrl: data['face_url'] as String?,
      isFaceRegistered: (data['is_face_registered'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'role': role,

      if (maGV != null) 'maGV': maGV,
      if (hocHamHocVi != null) 'hocHamHocVi': hocHamHocVi,
      if (khoa != null) 'khoa': khoa,

      if (classId != null) 'class_id': classId,
      if (departmentId != null) 'department_id': departmentId,

      'face_url': faceUrl,
      'is_face_registered': isFaceRegistered,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? maGV,
    String? hocHamHocVi,
    String? khoa,
    String? classId,
    String? departmentId,
    String? faceUrl,
    bool? isFaceRegistered,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      maGV: maGV ?? this.maGV,
      hocHamHocVi: hocHamHocVi ?? this.hocHamHocVi,
      khoa: khoa ?? this.khoa,
      classId: classId ?? this.classId,
      departmentId: departmentId ?? this.departmentId,
      faceUrl: faceUrl ?? this.faceUrl,
      isFaceRegistered: isFaceRegistered ?? this.isFaceRegistered,
    );
  }
}
