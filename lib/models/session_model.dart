import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String classId;
  final String lecturerId;
  final DateTime date;
  final String? qrCodeUrl;
  final bool isOpen;

  SessionModel({
    required this.id,
    required this.classId,
    required this.lecturerId,
    required this.date,
    this.qrCodeUrl,
    this.isOpen = true,
  });

  factory SessionModel.fromMap(Map<String, dynamic> data, String id) {
    return SessionModel(
      id: id,
      classId: data['class_id'],
      lecturerId: data['lecturer_id'],
      date: (data['date'] as Timestamp).toDate(),
      qrCodeUrl: data['qr_code'],
      isOpen: data['is_open'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'class_id': classId,
    'lecturer_id': lecturerId,
    'date': Timestamp.fromDate(date),
    'qr_code': qrCodeUrl,
    'is_open': isOpen,
  };
}
