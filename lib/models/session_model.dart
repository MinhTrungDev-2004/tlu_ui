import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // ⭐ THÊM IMPORT NÀY
import '../../services/firestore_service.dart';
import 'dart:convert';

class SessionModel implements HasId {
  final String _id;
  final String courseId;
  final String classId;
  final DateTime date;
  final String startTime;          // ⭐ SỬA: String "HH:mm" thay vì TimeOfDay
  final String endTime;            // ⭐ SỬA: String "HH:mm"
  final String? room;
  final String? lecturerId;
  final List<String>? attendanceIds;
  final SessionStatus status;
  final String? qrCode;
  final DateTime? qrExpiry;
  
  // ⭐ THÊM: Thông tin lặp lại
  final bool isRecurring;
  final List<int>? repeatDays;        // [1,3,5] = Thứ 2,4,6
  final DateTime? repeatUntil;
  final String? parentSessionId;      // Session gốc (nếu là session lặp)

  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.isRecurring = false,
    this.repeatDays,
    this.repeatUntil,
    this.parentSessionId,
    this.createdAt,
    this.updatedAt,
  })  : _id = id,
        status = status ?? SessionStatus.scheduled;

  @override
  String get id => _id;

  factory SessionModel.fromMap(Map<String, dynamic> data, String id) {
    return SessionModel(
      id: id,
      courseId: _getString(data, 'course_id'),
      classId: _getString(data, 'class_id'),
      date: _parseDate(data['date']),
      startTime: _getString(data, 'start_time', '07:00'),
      endTime: _getString(data, 'end_time', '09:00'),
      room: _getString(data, 'room'),
      lecturerId: _getString(data, 'lecturer_id'),
      attendanceIds: _getListString(data, 'attendance_ids'),
      status: _parseSessionStatus(data['status']),
      qrCode: _getString(data, 'qr_code'),
      qrExpiry: _parseDate(data['qr_expiry']),
      isRecurring: data['is_recurring'] ?? false,
      repeatDays: _getListInt(data, 'repeat_days'),
      repeatUntil: _parseDate(data['repeat_until']),
      parentSessionId: _getString(data, 'parent_session_id'),
      createdAt: _parseDate(data['created_at']),
      updatedAt: _parseDate(data['updated_at']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'class_id': classId,
      'date': date.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      if (room != null && room!.isNotEmpty) 'room': room,
      if (lecturerId != null && lecturerId!.isNotEmpty) 'lecturer_id': lecturerId,
      if (attendanceIds != null) 'attendance_ids': attendanceIds,
      'status': status.name,
      if (qrCode != null && qrCode!.isNotEmpty) 'qr_code': qrCode,
      if (qrExpiry != null) 'qr_expiry': qrExpiry!.toIso8601String(),
      'is_recurring': isRecurring,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (repeatUntil != null) 'repeat_until': repeatUntil!.toIso8601String(),
      if (parentSessionId != null) 'parent_session_id': parentSessionId,
      'created_at': createdAt?.toIso8601String() ?? FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  SessionModel copyWith({
    String? id,
    String? courseId,
    String? classId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? room,
    String? lecturerId,
    List<String>? attendanceIds,
    SessionStatus? status,
    String? qrCode,
    DateTime? qrExpiry,
    bool? isRecurring,
    List<int>? repeatDays,
    DateTime? repeatUntil,
    String? parentSessionId,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      isRecurring: isRecurring ?? this.isRecurring,
      repeatDays: repeatDays ?? this.repeatDays,
      repeatUntil: repeatUntil ?? this.repeatUntil,
      parentSessionId: parentSessionId ?? this.parentSessionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ===== PARSER METHODS =====
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    if (date is Timestamp) return date.toDate();
    return DateTime.now();
  }

  static String _getString(Map<String, dynamic> data, String key, [String defaultValue = '']) {
    final value = data[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  static List<String>? _getListString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) return value.whereType<String>().toList();
    return null;
  }

  static List<int>? _getListInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value == null) return null;
    if (value is List) return value.whereType<int>().toList();
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

  // ===== BUSINESS LOGIC METHODS =====
  
  /// Chuyển startTime string thành TimeOfDay (cho UI)
  TimeOfDay get startTimeOfDay {
    final parts = startTime.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 7,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 7, minute: 0);
  }

  /// Chuyển endTime string thành TimeOfDay (cho UI)
  TimeOfDay get endTimeOfDay {
    final parts = endTime.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 9, minute: 0);
  }

  /// Lấy DateTime hoàn chỉnh từ date + startTime
  DateTime get startDateTime {
    final time = startTimeOfDay;
    return DateTime(
      date.year, date.month, date.day,
      time.hour, time.minute,
    );
  }

  /// Lấy DateTime hoàn chỉnh từ date + endTime
  DateTime get endDateTime {
    final time = endTimeOfDay;
    return DateTime(
      date.year, date.month, date.day,
      time.hour, time.minute,
    );
  }

  /// Format thời gian đẹp cho hiển thị
  String get timeDisplay {
    return '$startTime - $endTime';
  }

  /// Format ngày tháng đẹp
  String get dateDisplay {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Kiểm tra trạng thái
  bool get isOngoing => status == SessionStatus.ongoing;
  bool get isCompleted => status == SessionStatus.done;
  bool get isCancelled => status == SessionStatus.cancelled;
  bool get isScheduled => status == SessionStatus.scheduled;
  
  /// Kiểm tra QR code còn hiệu lực
  bool get isQrValid {
    if (qrExpiry == null) return false;
    return DateTime.now().isBefore(qrExpiry!);
  }
  
  /// Kiểm tra buổi học có phải hôm nay không
  bool get isToday {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }
  
  /// Kiểm tra buổi học có đang diễn ra không
  bool get isHappeningNow {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }
  
  /// Kiểm tra sinh viên đã điểm danh chưa
  bool isStudentAttended(String studentId) {
    return attendanceIds?.contains(studentId) ?? false;
  }

  /// Điểm danh sinh viên
  SessionModel markAttendance(String studentId) {
    final newAttendanceIds = List<String>.from(attendanceIds ?? []);
    if (!newAttendanceIds.contains(studentId)) {
      newAttendanceIds.add(studentId);
    }
    return copyWith(attendanceIds: newAttendanceIds);
  }

  /// Hủy điểm danh sinh viên
  SessionModel unmarkAttendance(String studentId) {
    final newAttendanceIds = List<String>.from(attendanceIds ?? []);
    newAttendanceIds.remove(studentId);
    return copyWith(attendanceIds: newAttendanceIds);
  }

  /// Tính thời lượng buổi học (phút)
  int get durationInMinutes {
    return endDateTime.difference(startDateTime).inMinutes;
  }

  /// Kiểm tra có phải session lặp không
  bool get isRecurrence => parentSessionId != null;

  /// Tạo session tiếp theo (cho lịch lặp)
  SessionModel? getNextRecurrence() {
    if (!isRecurring || repeatDays == null || repeatUntil == null) return null;
    
    final nextDate = _findNextRecurrenceDate();
    if (nextDate == null) return null;

    return copyWith(
      id: '${id}_${nextDate.millisecondsSinceEpoch}',
      date: nextDate,
      parentSessionId: isRecurrence ? parentSessionId : id,
      qrCode: null,
      qrExpiry: null,
      attendanceIds: [],
      status: SessionStatus.scheduled,
    );
  }

  DateTime? _findNextRecurrenceDate() {
    if (repeatDays == null) return null;
    
    DateTime nextDate = date.add(const Duration(days: 1));
    while (nextDate.isBefore(repeatUntil!)) {
      if (repeatDays!.contains(nextDate.weekday)) {
        return nextDate;
      }
      nextDate = nextDate.add(const Duration(days: 1));
    }
    return null;
  }

  /// Tạo QR code data cho buổi học
  String generateQrData() {
    final qrData = {
      'sessionId': id,
      'courseId': courseId,
      'classId': classId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(qrData);
  }

  @override
  String toString() {
    return 'SessionModel(id: $id, course: $courseId, class: $classId, date: $dateDisplay, time: $timeDisplay, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum SessionStatus {
  scheduled,  // Sắp diễn ra
  ongoing,    // Đang diễn ra
  done,       // Đã kết thúc
  cancelled,  // Đã hủy
}