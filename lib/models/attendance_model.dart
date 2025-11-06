import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import 'package:flutter/material.dart';

enum AttendanceStatus { present, absent, late }

class AttendanceModel implements HasId {
  final String _id;
  final String sessionId;
  final String studentId;
  final String classId;
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

  /// Factory từ Firestore - XỬ LÝ LỖI TỐT HƠN
  factory AttendanceModel.fromMap(Map<String, dynamic> data, String id) {
    try {
      return AttendanceModel(
        id: id,
        sessionId: data['session_id']?.toString() ?? '', // ⭐ THÊM NULL CHECK
        studentId: data['student_id']?.toString() ?? '',
        classId: data['class_id']?.toString() ?? '',
        timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(), // ⭐ THÊM FALLBACK
        status: _parseStatus(data['status']?.toString() ?? 'absent'), // ⭐ THÊM FALLBACK
      );
    } catch (e) {
      print('Error parsing AttendanceModel: $e');
      rethrow; // hoặc return default value tùy use case
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'student_id': studentId,
      'class_id': classId,
      'timestamp': timestamp,
      'status': status.name,
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

  // ===== EXTENSION CHO STATUS (QUAN TRỌNG) =====
  String get statusDisplayText {
    switch (status) {
      case AttendanceStatus.present:
        return 'Có mặt';
      case AttendanceStatus.late:
        return 'Muộn';
      case AttendanceStatus.absent:
        return 'Vắng';
    }
  }

  Color get statusColor {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.absent:
        return Colors.red;
    }
  }

  // ===== VALIDATION METHODS =====
  bool get isValid {
    return sessionId.isNotEmpty && 
           studentId.isNotEmpty && 
           classId.isNotEmpty;
  }

  bool get isFromToday {
    final now = DateTime.now();
    final attendanceDate = timestamp.toDate();
    return now.year == attendanceDate.year &&
           now.month == attendanceDate.month &&
           now.day == attendanceDate.day;
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

  // ===== OVERRIDE toString, ==, hashCode =====
  @override
  String toString() {
    return 'AttendanceModel(id: $id, student: $studentId, session: $sessionId, status: $status, time: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel &&
        other.id == id &&
        other.sessionId == sessionId &&
        other.studentId == studentId;
  }

  @override
  int get hashCode => Object.hash(id, sessionId, studentId);
}