import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../models/user/user_model.dart';
import '../../models/face_data_model.dart';
import '../../models/session_model.dart';
import '../../models/attendance_model.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 1️⃣ Đăng ký khuôn mặt sinh viên (lưu ảnh + embeddings)
  Future<void> registerFace({
    required String studentId,
    required Uint8List faceImageBytes,
    required List<double> embeddings,
  }) async {
    try {
      // Upload ảnh lên Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child('faces/$studentId/$fileName');
      final uploadTask = await storageRef.putData(faceImageBytes);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Lấy document face_data hiện tại
      final docRef = _firestore.collection('face_data').doc(studentId);
      final existingDoc = await docRef.get();

      FaceDataModel newData;

      if (existingDoc.exists && existingDoc.data() != null) {
        // Nếu đã có dữ liệu → thêm ảnh + embeddings mới
        final existing = FaceDataModel.fromMap(existingDoc.data()!, existingDoc.id);
        final updatedImages = [...existing.imageUrls, imageUrl];
        final updatedEmbeddings = [...existing.embeddingsList, embeddings];

        newData = existing.copyWith(
          imageUrls: updatedImages,
          embeddingsList: updatedEmbeddings,
          updatedAt: Timestamp.now(),
          version: existing.version + 1,
        );
      } else {
        // Nếu chưa có dữ liệu → tạo mới
        newData = FaceDataModel(
          id: studentId,
          userId: studentId,
          imageUrls: [imageUrl],
          embeddingsList: [embeddings],
          updatedAt: Timestamp.now(),
          version: 1,
        );
      }

      // Lưu vào Firestore (encode embeddingsList thành List<String> để tránh lỗi nested array)
      final encodedEmbeddings = newData.embeddingsList
          .map((e) => e.map((v) => v.toString()).toList())
          .toList();

      await docRef.set({
        'user_id': newData.userId,
        'image_urls': newData.imageUrls,
        'embeddings_list': encodedEmbeddings,
        'updated_at': newData.updatedAt,
        'version': newData.version,
      });

      // Cập nhật user an toàn
      await _firestore.collection('users').doc(studentId).set({
        'faceUrl': imageUrl,
        'isFaceRegistered': true,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));

      print('✅ Đăng ký khuôn mặt thành công cho sinh viên $studentId');
    } catch (e) {
      print('❌ Lỗi khi đăng ký khuôn mặt: $e');
      rethrow;
    }
  }

  /// 2️⃣ Kiểm tra sinh viên đã đăng ký khuôn mặt chưa
  Future<bool> hasRegisteredFace(String studentId) async {
    try {
      final doc = await _firestore.collection('face_data').doc(studentId).get();
      return doc.exists && (doc.data()?['embeddings_list'] != null);
    } catch (e) {
      print('❌ Lỗi khi kiểm tra khuôn mặt: $e');
      return false;
    }
  }

  /// 3️⃣ Lấy danh sách buổi học hôm nay của một lớp
  Future<List<SessionModel>> getTodaySessions(String classId) async {
    try {
      final now = DateTime.now();
      final startOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 0, 0, 0));
      final endOfDay = Timestamp.fromDate(DateTime(now.year, now.month, now.day, 23, 59, 59));

      final snapshot = await _firestore
          .collection('sessions')
          .where('class_id', isEqualTo: classId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();

      return snapshot.docs.map((doc) => SessionModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('❌ Lỗi khi lấy buổi học hôm nay: $e');
      rethrow;
    }
  }

  /// 4️⃣ Điểm danh sinh viên
  Future<void> markAttendance({
    required String studentId,
    required String classId,
    required String sessionId,
    required AttendanceStatus status,
  }) async {
    try {
      final attendanceId = '${studentId}_$sessionId';

      final attendance = AttendanceModel(
        id: attendanceId,
        sessionId: sessionId,
        studentId: studentId,
        classId: classId,
        timestamp: Timestamp.now(),
        status: status,
      );

      await _firestore.collection('attendances').doc(attendanceId).set(attendance.toMap());

      print('✅ Điểm danh thành công cho sinh viên $studentId');
    } catch (e) {
      print('❌ Lỗi khi điểm danh: $e');
      rethrow;
    }
  }

  /// 5️⃣ Lịch sử điểm danh sinh viên
  Future<List<AttendanceModel>> getAttendanceHistory(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('attendances')
          .where('student_id', isEqualTo: studentId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => AttendanceModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('❌ Lỗi khi lấy lịch sử điểm danh: $e');
      rethrow;
    }
  }
}
