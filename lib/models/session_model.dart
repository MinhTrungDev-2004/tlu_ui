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
  final SessionStatus status;          // Trạng thái buổi học
  final String? qrCode;                // Mã QR điểm danh (chuỗi)
  final Timestamp? qrExpiry;           // Thời điểm hết hạn của mã QR
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

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
    SessionStatus? status,
    this.qrCode,
    this.qrExpiry,
    this.createdAt,
    this.updatedAt,
  })  : _id = id,
        status = status ?? SessionStatus.scheduled;

  @override
  String get id => _id;

  // ===== Factory: From Firestore Map =====
  factory SessionModel.fromMap(Map<String, dynamic> data, String id) {
    return SessionModel(
      id: id,
      courseId: _getString(data, 'course_id'),
      classId: _getString(data, 'class_id'),
      date: data['date'] as Timestamp,
      startTime: data['start_time'] as Timestamp,
      endTime: data['end_time'] as Timestamp,
      room: _getString(data, 'room'),
      lecturerId: _getString(data, 'lecturer_id'),
      attendanceIds: _getListString(data, 'attendance_ids'),
      status: _parseSessionStatus(data['status']),
      qrCode: _getString(data, 'qr_code'),
      qrExpiry: data['qr_expiry'] as Timestamp?,
      createdAt: data['created_at'] as Timestamp?,
      updatedAt: data['updated_at'] as Timestamp?,
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
      if (room != null && room!.isNotEmpty) 'room': room,
      if (lecturerId != null && lecturerId!.isNotEmpty) 'lecturer_id': lecturerId,
      if (attendanceIds != null) 'attendance_ids': attendanceIds,
      'status': status.name,
      if (qrCode != null && qrCode!.isNotEmpty) 'qr_code': qrCode,
      if (qrExpiry != null) 'qr_expiry': qrExpiry,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
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
    SessionStatus? status,
    String? qrCode,
    Timestamp? qrExpiry,
    Timestamp? createdAt,
    Timestamp? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===== Helper Methods =====
  static String _getString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  static List<String>? _getListString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return null;
  }

  static SessionStatus _parseSessionStatus(dynamic status) {
    if (status == null) return SessionStatus.scheduled;
    if (status is String) {
      return SessionStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => SessionStatus.scheduled,
      );
    }
    return SessionStatus.scheduled;
  }

  // ===== Business Logic Methods =====
  
  /// Kiểm tra buổi học có đang diễn ra không
  bool get isOngoing => status == SessionStatus.ongoing;
  
  /// Kiểm tra buổi học đã kết thúc chưa
  bool get isCompleted => status == SessionStatus.done;
  
  /// Kiểm tra buổi học đã bị hủy chưa
  bool get isCancelled => status == SessionStatus.cancelled;
  
  /// Kiểm tra QR code còn hiệu lực không
  bool get isQrValid {
    if (qrExpiry == null) return false;
    return DateTime.now().isBefore(qrExpiry!.toDate());
  }
  
  /// Kiểm tra buổi học có phải là hôm nay không
  bool get isToday {
    final now = DateTime.now();
    final sessionDate = date.toDate();
    return now.year == sessionDate.year &&
        now.month == sessionDate.month &&
        now.day == sessionDate.day;
  }
  
  /// Lấy thời gian bắt đầu dưới dạng DateTime
  DateTime get startDateTime {
    final sessionDate = date.toDate();
    final start = startTime.toDate();
    return DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      start.hour,
      start.minute,
    );
  }
  
  /// Lấy thời gian kết thúc dưới dạng DateTime
  DateTime get endDateTime {
    final sessionDate = date.toDate();
    final end = endTime.toDate();
    return DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      end.hour,
      end.minute,
    );
  }
  
  /// Kiểm tra buổi học có đang diễn ra theo thời gian thực không
  bool get isHappeningNow {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }
  
  /// Kiểm tra sinh viên đã điểm danh chưa
  bool isStudentAttended(String studentId) {
    return attendanceIds?.contains(studentId) ?? false;
  }

  @override
  String toString() {
    return 'SessionModel(id: $id, courseId: $courseId, classId: $classId, date: ${date.toDate()}, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Trạng thái của buổi học
enum SessionStatus {
  scheduled,  // Sắp diễn ra
  ongoing,    // Đang diễn ra
  done,       // Đã kết thúc
  cancelled,  // Đã hủy
}