import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/session_model.dart';
import 'dart:convert';

class SessionService {
  final CollectionReference<SessionModel> _sessionsRef;

  SessionService()
      : _sessionsRef = FirebaseFirestore.instance
          .collection('sessions')
          .withConverter<SessionModel>(
            fromFirestore: (snapshot, _) =>
                SessionModel.fromMap(snapshot.data()!, snapshot.id),
            toFirestore: (session, _) => session.toMap(),
          );

  // --- 1. CREATE (Tạo) ---

  /// Tạo một buổi học (session) đơn lẻ
  Future<String> createSession(SessionModel session) async {
    try {
      final docRef = await _sessionsRef.add(session);
      return docRef.id;
    } catch (e) {
      print("Lỗi khi tạo session: $e");
      rethrow;
    }
  }

  /// Tạo một loạt buổi học lặp lại
  Future<List<String>> createRecurringSessions(SessionModel template) async {
    if (!template.isRecurring ||
        template.repeatDays == null ||
        template.repeatUntil == null) {
      final sessionId = await createSession(template);
      return [sessionId];
    }

    final batch = FirebaseFirestore.instance.batch();
    final createdSessionIds = <String>[];

    // 1. Tạo session "cha" (template)
    final parentDoc = _sessionsRef.doc();
    final parentSession = template.copyWith(
      id: parentDoc.id,
      isRecurring: true,
    );
    batch.set(parentDoc, parentSession);
    createdSessionIds.add(parentDoc.id);

    // 2. Lặp qua các ngày để tạo các session "con"
    DateTime currentDate = template.date;
    final endDate = template.repeatUntil!;

    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Kiểm tra ngày trong tuần
      if (template.repeatDays!.contains(currentDate.weekday)) {
        final childDoc = _sessionsRef.doc();
        final childSession = template.copyWith(
          id: childDoc.id,
          date: currentDate,
          isRecurring: false,
          parentSessionId: parentDoc.id,
          qrCode: null,
          qrExpiry: null,
          attendanceIds: [],
          status: SessionStatus.scheduled,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        batch.set(childDoc, childSession);
        createdSessionIds.add(childDoc.id);
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    await batch.commit();
    return createdSessionIds;
  }

  // --- 2. READ (Đọc) ---

  /// Lấy một session cụ thể bằng ID
  Future<SessionModel?> getSession(String id) async {
    try {
      final doc = await _sessionsRef.doc(id).get();
      return doc.data();
    } catch (e) {
      print("Lỗi khi lấy session: $e");
      return null;
    }
  }

  /// Lấy session từ QR data
  Future<SessionModel?> getSessionFromQR(String qrData) async {
    try {
      final qrMap = jsonDecode(qrData);
      final sessionId = qrMap['sessionId'] as String?;
      
      if (sessionId == null) return null;
      return await getSession(sessionId);
    } catch (e) {
      print('Error parsing QR data: $e');
      return null;
    }
  }

  /// Lấy danh sách sessions cho một lớp
  Stream<List<SessionModel>> streamSessionsForClass(String classId) {
    try {
      final query = _sessionsRef
          .where('class_id', isEqualTo: classId)
          .orderBy('date')
          .orderBy('start_time');

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print("Lỗi khi stream sessions: $e");
      return Stream.value([]);
    }
  }

  /// Lấy sessions của giảng viên trong ngày
  Stream<List<SessionModel>> streamSessionsForLecturerOnDate(
      String lecturerId, DateTime date) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final query = _sessionsRef
          .where('lecturer_id', isEqualTo: lecturerId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .orderBy('date')
          .orderBy('start_time');

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print("Lỗi khi stream sessions lecturer: $e");
      return Stream.value([]);
    }
  }

  /// Lấy sessions đang diễn ra
  Stream<List<SessionModel>> streamOngoingSessions(String classId) {
    try {
      final query = _sessionsRef
          .where('class_id', isEqualTo: classId)
          .where('status', isEqualTo: SessionStatus.ongoing.name);

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print("Lỗi khi stream ongoing sessions: $e");
      return Stream.value([]);
    }
  }

  // --- 3. UPDATE (Cập nhật) ---

  /// Cập nhật session với dữ liệu Map
  Future<void> updateSessionData(String id, Map<String, dynamic> data) async {
    try {
      data['updated_at'] = FieldValue.serverTimestamp();
      await _sessionsRef.doc(id).update(data);
    } catch (e) {
      print("Lỗi khi cập nhật session: $e");
      rethrow;
    }
  }

  /// Tạo và lưu QR code
  Future<void> generateAndSaveQr(String sessionId, Duration validity) async {
    try {
      final session = await getSession(sessionId);
      if (session == null) throw Exception('Session not found');

      final qrData = session.generateQrData();
      final qrExpiry = DateTime.now().add(validity);

      await updateSessionData(sessionId, {
        'qr_code': qrData,
        'qr_expiry': qrExpiry.toIso8601String(),
        'status': SessionStatus.ongoing.name,
      });
    } catch (e) {
      print("Lỗi khi tạo QR: $e");
      rethrow;
    }
  }

  /// Điểm danh sinh viên
  Future<bool> markAttendance({
    required String sessionId,
    required String studentId,
    required String faceImageUrl,
  }) async {
    try {
      // Cập nhật session
      await _sessionsRef.doc(sessionId).update({
        'attendance_ids': FieldValue.arrayUnion([studentId]),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Tạo attendance record
      await FirebaseFirestore.instance.collection('attendance_records').add({
        'session_id': sessionId,
        'student_id': studentId,
        'face_image_url': faceImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'method': 'face_recognition',
        'status': 'present',
      });

      return true;
    } catch (e) {
      print("Lỗi khi điểm danh: $e");
      return false;
    }
  }

  /// Hủy điểm danh
  Future<void> unmarkAttendance(String sessionId, String studentId) async {
    try {
      await _sessionsRef.doc(sessionId).update({
        'attendance_ids': FieldValue.arrayRemove([studentId]),
        'updated_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Lỗi khi hủy điểm danh: $e");
      rethrow;
    }
  }

  /// Kiểm tra sinh viên đã điểm danh chưa
  Future<bool> hasStudentAttended(String sessionId, String studentId) async {
    try {
      final session = await getSession(sessionId);
      return session?.isStudentAttended(studentId) ?? false;
    } catch (e) {
      print("Lỗi khi kiểm tra điểm danh: $e");
      return false;
    }
  }

  /// Kiểm tra session có hợp lệ để điểm danh
  String? validateSessionForAttendance(SessionModel session) {
    final now = DateTime.now();
    
    if (session.isCancelled) return 'Buổi học đã bị hủy';
    if (session.isCompleted) return 'Buổi học đã kết thúc';
    if (now.isBefore(session.startDateTime)) return 'Buổi học chưa bắt đầu';
    if (now.isAfter(session.endDateTime)) return 'Buổi học đã kết thúc';
    if (session.qrCode != null && !session.isQrValid) return 'Mã QR đã hết hạn';
    
    return null; // Hợp lệ
  }

  // --- 4. DELETE (Xóa) ---

  /// Xóa session
  Future<void> deleteSession(String sessionId, {bool deleteAllRecurring = false}) async {
    try {
      if (deleteAllRecurring) {
        final session = await getSession(sessionId);
        if (session == null) return;

        final parentId = session.isRecurring ? session.id : (session.parentSessionId ?? sessionId);
        
        // Xóa tất cả sessions có cùng parent
        final query = await _sessionsRef
            .where('parent_session_id', isEqualTo: parentId)
            .get();
        
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in query.docs) {
          batch.delete(doc.reference);
        }
        // Xóa session cha
        batch.delete(_sessionsRef.doc(parentId));
        await batch.commit();
      } else {
        await _sessionsRef.doc(sessionId).delete();
      }
    } catch (e) {
      print("Lỗi khi xóa session: $e");
      rethrow;
    }
  }

  /// Cập nhật trạng thái session
  Future<void> updateSessionStatus(String sessionId, SessionStatus status) async {
    try {
      await updateSessionData(sessionId, {
        'status': status.name,
      });
    } catch (e) {
      print("Lỗi khi cập nhật trạng thái: $e");
      rethrow;
    }
  }

  /// Lấy tất cả sessions trong khoảng thời gian
  Stream<List<SessionModel>> streamSessionsInDateRange(DateTime start, DateTime end) {
    try {
      final query = _sessionsRef
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date')
          .orderBy('start_time');

      return query.snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print("Lỗi khi stream sessions theo range: $e");
      return Stream.value([]);
    }
  }
}