import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

enum AttendanceStatus { present, absent, late }

class AttendanceModel implements HasId {
  final String _id;
  final String sessionId;
  final String studentId;
  final String classId; // để dễ thống kê
  final Timestamp timestamp;
  final AttendanceStatus status;

  AttendanceModel({
    required String id,
    required this.sessionId,
    required this.studentId,
    required this.classId,
    required this.timestamp,
    required this.status,
  }) : _id = id;

  @override
  String get id => _id;

  /// Factory từ Firestore
  factory AttendanceModel.fromMap(Map<String, dynamic> data, String id) {
    return AttendanceModel(
      id: id,
      sessionId: data['session_id'] as String,
      studentId: data['student_id'] as String,
      classId: data['class_id'] as String,
      timestamp: data['timestamp'] as Timestamp,
      status: _parseStatus(data['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'student_id': studentId,
      'class_id': classId,
      'timestamp': timestamp,
      'status': status.name, // lưu dưới dạng string
    };
  }

  AttendanceModel copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? classId,
    Timestamp? timestamp,
    AttendanceStatus? status,
  }) {
    return AttendanceModel(
      id: id ?? _id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  // ===== Helper parsing =====
  static AttendanceStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'late':
        return AttendanceStatus.late;
      case 'absent':
      default:
        return AttendanceStatus.absent;
    }
  }
}
