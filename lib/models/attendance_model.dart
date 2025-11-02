import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String sessionId;
  final String classId;
  final String studentId;
  final bool faceVerified;
  final DateTime checkinTime;
  final double? latitude;
  final double? longitude;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.classId,
    required this.studentId,
    required this.faceVerified,
    required this.checkinTime,
    this.latitude,
    this.longitude,
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> data, String id) {
    return AttendanceModel(
      id: id,
      sessionId: data['session_id'],
      classId: data['class_id'],
      studentId: data['student_id'],
      faceVerified: data['face_verified'] ?? false,
      checkinTime: (data['checkin_time'] as Timestamp).toDate(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'session_id': sessionId,
    'class_id': classId,
    'student_id': studentId,
    'face_verified': faceVerified,
    'checkin_time': Timestamp.fromDate(checkinTime),
    'latitude': latitude,
    'longitude': longitude,
  };
}
