import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

class SessionModel implements HasId {
  final String _id;
  final String courseId;
  final String classId;
  final Timestamp date;
  final Timestamp startTime;
  final Timestamp endTime;
  
  final String? room;                // Phòng học
  final String? lecturerId;          // Giảng viên dạy buổi này
  final List<String>? attendanceIds; // danh sách attendance document IDs
  final String? status;              // scheduled | done | cancelled

  SessionModel({
    required String id,
    required this.courseId,
    required this.classId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.room,
    this.lecturerId,
    this.attendanceIds,
    this.status,
  }) : _id = id;

  @override
  String get id => _id;

  factory SessionModel.fromMap(Map<String, dynamic> data, String id) {
    return SessionModel(
      id: id,
      courseId: data['course_id'] as String,
      classId: data['class_id'] as String,
      date: data['date'] as Timestamp,
      startTime: data['start_time'] as Timestamp,
      endTime: data['end_time'] as Timestamp,
      room: data['room'] as String?,
      lecturerId: data['lecturer_id'] as String?,
      attendanceIds: _getListString(data, 'attendance_ids'),
      status: data['status'] as String? ?? 'scheduled',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'class_id': classId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      if (room != null) 'room': room,
      if (lecturerId != null) 'lecturer_id': lecturerId,
      if (attendanceIds != null) 'attendance_ids': attendanceIds,
      'status': status ?? 'scheduled',
    };
  }

  SessionModel copyWith({
    String? id,
    String? courseId,
    String? classId,
    Timestamp? date,
    Timestamp? startTime,
    Timestamp? endTime,
    String? room,
    String? lecturerId,
    List<String>? attendanceIds,
    String? status,
  }) {
    return SessionModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      lecturerId: lecturerId ?? this.lecturerId,
      attendanceIds: attendanceIds ?? this.attendanceIds,
      status: status ?? this.status,
    );
  }

  // ===== Helper =====
  static List<String>? _getListString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) return value.map((e) => e.toString()).toList();
    return null;
  }
}
