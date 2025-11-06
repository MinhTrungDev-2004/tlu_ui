import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/session_model.dart'; // Import SessionModel của bạn
import 'dart:async';

class SessionService {
  final CollectionReference<SessionModel> _sessionsRef;

  SessionService()
      : _sessionsRef = FirebaseFirestore.instance
      .collection('sessions') // Tên collection của bạn
      .withConverter<SessionModel>(

    // Cách Firestore đọc (chuyển Map thành Model)
    fromFirestore: (snapshot, _) =>
        SessionModel.fromMap(snapshot.data()!, snapshot.id),

    // Cách Firestore ghi (chuyển Model thành Map)
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

  /// Tạo một loạt buổi học lặp lại (ví dụ: Thứ 2, 4, 6 trong 3 tháng)
  /// Hàm này sẽ tạo session "cha" (template) và tất cả session "con".
  Future<String> createRecurringSessions(SessionModel template) async {
    if (!template.isRecurring ||
        template.repeatDays == null ||
        template.repeatUntil == null) {
      // Nếu không phải lặp, chỉ cần tạo 1 session
      return createSession(template);
    }

    final batch = FirebaseFirestore.instance.batch();

    // 1. Tạo session "cha" (template)
    final parentDoc = _sessionsRef.doc();
    final parentSession = template.copyWith(
      id: parentDoc.id,
      isRecurring: true, // Đảm bảo đây là template
    );
    batch.set(parentDoc, parentSession);

    // 2. Lặp qua các ngày để tạo các session "con"
    DateTime currentDate = template.date;
    final endDate = template.repeatUntil!;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {

      // Kiểm tra xem ngày hiện tại có trong danh sách lặp (repeatDays) không
      if (template.repeatDays!.contains(currentDate.weekday)) {
        final childDoc = _sessionsRef.doc();
        final childSession = template.copyWith(
          id: childDoc.id,
          date: currentDate,
          isRecurring: false, // Session con không phải là template
          parentSessionId: parentDoc.id, // Liên kết về session cha
          qrCode: null,
          qrExpiry: null,
          attendanceIds: [],
          status: SessionStatus.scheduled,
          createdAt: DateTime.now(),
        );
        batch.set(childDoc, childSession);
      }
      // Tăng lên ngày tiếp theo
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // 3. Commit toàn bộ batch
    await batch.commit();
    return parentDoc.id; // Trả về ID của session cha (template)
  }

  // --- 2. READ (Đọc) ---

  /// Lấy một session cụ thể bằng ID
  Future<SessionModel?> getSession(String id) async {
    final doc = await _sessionsRef.doc(id).get();
    return doc.data();
  }

  /// Lấy (stream) danh sách các buổi học cho một lớp (classId)
  /// Sắp xếp theo ngày và giờ bắt đầu
  Stream<List<SessionModel>> streamSessionsForClass(String classId) {
    final query = _sessionsRef
        .where('class_id', isEqualTo: classId)
        .orderBy('date')
        .orderBy('start_time');

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Lấy (stream) danh sách buổi học của giảng viên (lecturerId) VÀO MỘT NGÀY CỤ THỂ
  Stream<List<SessionModel>> streamSessionsForLecturerOnDate(
      String lecturerId, DateTime date) {

    // ⭐ SỬA: Tạo khoảng thời gian trong ngày để truy vấn Timestamp
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final query = _sessionsRef
        .where('lecturer_id', isEqualTo: lecturerId)
        .where('date', isGreaterThanOrEqualTo: startOfDay) // ⭐ SỬA: Truyền trực tiếp DateTime
        .where('date', isLessThanOrEqualTo: endOfDay)       // ⭐ SỬA: Truyền trực tiếp DateTime
        .orderBy('date')
        .orderBy('start_time');

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Lấy (stream) các buổi học đang diễn ra (ongoing) cho một lớp
  Stream<List<SessionModel>> streamOngoingSessions(String classId) {
    final query = _sessionsRef
        .where('class_id', isEqualTo: classId)
        .where('status', isEqualTo: SessionStatus.ongoing.name);

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => doc.data()).toList());
  }


  // --- 3. UPDATE (Cập nhật) ---

  /// Cập nhật một session với dữ liệu Map
  /// (Dùng cho các cập nhật chung)
  Future<void> updateSessionData(String id, Map<String, dynamic> data) async {
    // Tự động thêm 'updated_at'
    data['updated_at'] = FieldValue.serverTimestamp();
    await _sessionsRef.doc(id).update(data);
  }

  /// Tạo QR code và cập nhật session (business logic)
  Future<void> generateAndSaveQr(String sessionId, Duration validity) async {
    final session = await getSession(sessionId);
    if (session == null) return;

    final qrData = session.generateQrData();
    final qrExpiry = DateTime.now().add(validity);

    await updateSessionData(sessionId, {
      'qr_code': qrData,
      'qr_expiry': qrExpiry.toIso8601String(), // Lưu theo chuẩn của model
      'status': SessionStatus.ongoing.name, // Chuyển trạng thái
    });
  }

  /// Điểm danh cho sinh viên (business logic)
  Future<void> markAttendance(String sessionId, String studentId) async {
    // Dùng FieldValue.arrayUnion để đảm bảo an toàn khi nhiều
    // sinh viên điểm danh cùng lúc và tránh trùng lặp.
    await _sessionsRef.doc(sessionId).update({
      'attendance_ids': FieldValue.arrayUnion([studentId]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  /// Hủy điểm danh (nếu cần)
  Future<void> unmarkAttendance(String sessionId, String studentId) async {
    await _sessionsRef.doc(sessionId).update({
      'attendance_ids': FieldValue.arrayRemove([studentId]),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  // --- 4. DELETE (Xóa) ---

  /// Xóa một session (và các session con nếu là lặp lại)
  Future<void> deleteSession(String sessionId, {bool deleteAllRecurring = false}) async {
    final session = await getSession(sessionId);
    if (session == null) return;

    if (deleteAllRecurring) {
      // Tìm parentId (là chính nó nếu là cha, hoặc parentSessionId nếu là con)
      String parentId = session.isRecurring ? session.id : (session.parentSessionId ?? sessionId);

      // Xóa tất cả các session (con) có cùng parentSessionId
      final query = _sessionsRef.where('parent_session_id', isEqualTo: parentId);
      final batch = FirebaseFirestore.instance.batch();
      final childDocs = await query.get();

      for (final doc in childDocs.docs) {
        batch.delete(doc.reference);
      }

      // Xóa luôn session cha (template)
      batch.delete(_sessionsRef.doc(parentId));

      await batch.commit();

    } else {
      // Chỉ xóa một session đơn lẻ
      await _sessionsRef.doc(sessionId).delete();
    }
  }
}