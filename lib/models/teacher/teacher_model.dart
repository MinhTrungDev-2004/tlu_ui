// import 'package:cloud_firestore/cloud_firestore.dart';

// class TeacherModel {
//   final String? id; // Document ID từ Firestore
//   final String maGV; // Mã giảng viên
//   final String tenGV; // Tên giảng viên
//   final String khoa; // Khoa
//   final String hocHamHocVi; // Học hàm - học vị

//   TeacherModel({
//     this.id,
//     required this.maGV,
//     required this.tenGV,
//     required this.khoa,
//     required this.hocHamHocVi,
//   });

//   // Tạo TeacherModel từ Firestore document
//   factory TeacherModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     return TeacherModel(
//       id: doc.id,
//       maGV: data['maGV'] ?? '',
//       tenGV: data['tenGV'] ?? '',
//       khoa: data['khoa'] ?? '',
//       hocHamHocVi: data['hocHamHocVi'] ?? '',
//     );
//   }

//   // Tạo TeacherModel từ Map
//   factory TeacherModel.fromMap(Map<String, dynamic> map) {
//     return TeacherModel(
//       id: map['id'],
//       maGV: map['maGV'] ?? '',
//       tenGV: map['tenGV'] ?? '',
//       khoa: map['khoa'] ?? '',
//       hocHamHocVi: map['hocHamHocVi'] ?? '',
//     );
//   }

//   // Chuyển TeacherModel thành Map để lưu vào Firestore
//   Map<String, dynamic> toMap() {
//     return {
//       'maGV': maGV,
//       'tenGV': tenGV,
//       'khoa': khoa,
//       'hocHamHocVi': hocHamHocVi,
//     };
//   }

//   // Tạo bản sao với một số thay đổi
//   TeacherModel copyWith({
//     String? id,
//     String? maGV,
//     String? tenGV,
//     String? khoa,
//     String? hocHamHocVi,
//   }) {
//     return TeacherModel(
//       id: id ?? this.id,
//       maGV: maGV ?? this.maGV,
//       tenGV: tenGV ?? this.tenGV,
//       khoa: khoa ?? this.khoa,
//       hocHamHocVi: hocHamHocVi ?? this.hocHamHocVi,
//     );
//   }

//   @override
//   String toString() {
//     return 'TeacherModel(id: $id, maGV: $maGV, tenGV: $tenGV, khoa: $khoa, hocHamHocVi: $hocHamHocVi)';
//   }
// }
