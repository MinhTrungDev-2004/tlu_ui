import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';

/// Mô hình dữ liệu đại diện cho một buổi học (Session)
class SessionModel implements HasId {
  final String _id;
  final String courseId;               // Mã môn học
  final String classId;                // Mã lớp
  final Timestamp date;                // Ngày học
  final Timestamp startTime;           // Giờ bắt đầu
  final Timestamp endTime;             // Giờ kết thúc
  final String? room;                  // Phòng học
  final String? lecturerId;            // Mã giảng viên dạy buổi này
  final List<String>? attendanceIds;   // Danh sách ID điểm danh
  final String? status;                // scheduled | ongoing | done | cancelled
  final String? qrCode;                // Mã QR điểm danh (chuỗi)
  final Timestamp? qrExpiry;           // Thời điểm hết hạn của mã QR

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
    this.qrCode,
    this.qrExpiry,
  }) : _id = id;

  @override
  String get id => _id;

  // ===== Factory: From Firestore Map =====
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
      qrCode: data['qr_code'] as String?,
      qrExpiry: data['qr_expiry'] as Timestamp?,
    );
  }

  // ===== Convert to Firestore Map =====
  @override
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
      if (qrCode != null) 'qr_code': qrCode,
      if (qrExpiry != null) 'qr_expiry': qrExpiry,
    };
  }

  // ===== Copy With =====
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
    String? qrCode,
    Timestamp? qrExpiry,
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
      qrCode: qrCode ?? this.qrCode,
      qrExpiry: qrExpiry ?? this.qrExpiry,
    );
  }

  // ===== Helper: Parse List<String> =====
  static List<String>? _getListString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }
}
