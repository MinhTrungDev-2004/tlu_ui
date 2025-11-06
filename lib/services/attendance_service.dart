import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

/// Thống kê nhanh cho 1 buổi học
class AttendanceStats {
  final int present;
  final int late;
  final int absent;

  const AttendanceStats({this.present = 0, this.late = 0, this.absent = 0});

  int get total => present + late + absent;

  AttendanceStats copyWith({int? present, int? late, int? absent}) {
    return AttendanceStats(
      present: present ?? this.present,
      late: late ?? this.late,
      absent: absent ?? this.absent,
    );
  }

  @override
  String toString() =>
      'AttendanceStats(total=$total, present=$present, late=$late, absent=$absent)';
}

class AttendanceService {
  final CollectionReference<AttendanceModel> _attRef;

  AttendanceService()
      : _attRef = FirebaseFirestore.instance
            .collection('attendances')
            .withConverter<AttendanceModel>(
              fromFirestore: (snap, _) =>
                  AttendanceModel.fromMap(snap.data()!, snap.id),
              toFirestore: (att, _) => att.toMap(),
            );

  // =========================
  // 1) CREATE / UPSERT
  // =========================

  /// Tạo mới bản ghi điểm danh
  Future<String> create(AttendanceModel att) async {
    final doc = await _attRef.add(att);
    return doc.id;
  }

  /// Upsert (tạo mới nếu chưa có; nếu đã có record của (sessionId, studentId) thì cập nhật status & timestamp)
  ///
  /// Trả về id của bản ghi hiện hành.
  Future<String> upsert({
    required String sessionId,
    required String studentId,
    required String classId,
    AttendanceStatus status = AttendanceStatus.present,
    Timestamp? at,
  }) async {
    final query = await _attRef
        .where('session_id', isEqualTo: sessionId)
        .where('student_id', isEqualTo: studentId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      // Tạo mới
      final model = AttendanceModel(
        id: '', // Firestore sẽ cấp
        sessionId: sessionId,
        studentId: studentId,
        classId: classId,
        status: status,
        timestamp: at ?? Timestamp.now(),
      );
      final id = await create(model);
      return id;
    } else {
      // Cập nhật bản ghi hiện có
      final doc = query.docs.first.reference;
      await doc.update({
        'status': status.name,
        'timestamp': FieldValue
            .serverTimestamp(), // dùng server time để đồng nhất, model parse OK
      });
      return doc.id;
    }
  }

  // =========================
  // 2) READ
  // =========================

  Future<AttendanceModel?> getById(String id) async {
    final snap = await _attRef.doc(id).get();
    return snap.data();
  }

  /// Stream danh sách theo session
  Stream<List<AttendanceModel>> streamBySession(String sessionId) {
    final q = _attRef
        .where('session_id', isEqualTo: sessionId)
        .orderBy('timestamp', descending: true);
    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Stream theo sinh viên (tùy chọn lọc khoảng thời gian)
  Stream<List<AttendanceModel>> streamByStudent(
    String studentId, {
    DateTime? from,
    DateTime? to,
  }) {
    Query<AttendanceModel> q =
        _attRef.where('student_id', isEqualTo: studentId);

    if (from != null) {
      q = q.where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from));
    }
    if (to != null) {
      q =
          q.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(to));
    }

    q = q.orderBy('timestamp', descending: true);
    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Stream điểm danh của 1 lớp trong **một ngày** (lọc trong ngày)
  Stream<List<AttendanceModel>> streamByClassOnDate(
      String classId, DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final q = _attRef
        .where('class_id', isEqualTo: classId)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true);

    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  /// Lấy danh sách điểm danh của (sessionId, optional status)
  Future<List<AttendanceModel>> listForSession(
      String sessionId, {
        AttendanceStatus? status,
      }) async {
    Query<AttendanceModel> q =
        _attRef.where('session_id', isEqualTo: sessionId);
    if (status != null) {
      q = q.where('status', isEqualTo: status.name);
    }
    final snap = await q.get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // =========================
  // 3) UPDATE
  // =========================

  /// Đổi trạng thái điểm danh (present/late/absent)
  Future<void> setStatus(String id, AttendanceStatus status) async {
    await _attRef.doc(id).update({
      'status': status.name,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Đổi trạng thái theo cặp (sessionId, studentId). Tự tạo nếu chưa có.
  Future<String> setStatusForStudentInSession({
    required String sessionId,
    required String studentId,
    required String classId,
    required AttendanceStatus status,
  }) async {
    return upsert(
      sessionId: sessionId,
      studentId: studentId,
      classId: classId,
      status: status,
    );
  }

  // =========================
  // 4) DELETE
  // =========================

  Future<void> deleteById(String id) async {
    await _attRef.doc(id).delete();
  }

  /// Xoá tất cả record của 1 buổi (cẩn thận!)
  Future<void> deleteAllOfSession(String sessionId) async {
    final snap =
        await _attRef.where('session_id', isEqualTo: sessionId).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  // =========================
  // 5) THỐNG KÊ NHANH
  // =========================

  /// Lấy thống kê hiện tại (1 lần) cho 1 session
  Future<AttendanceStats> getStatsForSession(String sessionId) async {
    final snap =
        await _attRef.where('session_id', isEqualTo: sessionId).get();
    int p = 0, l = 0, a = 0;
    for (final d in snap.docs) {
      final s = d.data().status;
      if (s == AttendanceStatus.present) p++;
      else if (s == AttendanceStatus.late) l++;
      else a++;
    }
    return AttendanceStats(present: p, late: l, absent: a);
  }

  /// Stream thống kê realtime cho 1 session
  Stream<AttendanceStats> streamStatsForSession(String sessionId) {
    final q = _attRef.where('session_id', isEqualTo: sessionId);
    return q.snapshots().map((snap) {
      int p = 0, l = 0, a = 0;
      for (final d in snap.docs) {
        final s = d.data().status;
        if (s == AttendanceStatus.present) p++;
        else if (s == AttendanceStatus.late) l++;
        else a++;
      }
      return AttendanceStats(present: p, late: l, absent: a);
    });
  }
}
