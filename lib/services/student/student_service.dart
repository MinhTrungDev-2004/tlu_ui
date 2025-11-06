import 'dart:io';
import 'dart:convert'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user/user_model.dart';
import '../../models/face_data_model.dart';
import '../firestore_service.dart';

class StudentService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== QUẢN LÝ THÔNG TIN SINH VIÊN ====================

  /// 🔹 Lấy thông tin sinh viên theo ID
  Future<UserModel?> getStudentById(String studentId) async {
    try {
      return await _firestoreService.getDocument<UserModel>(studentId);
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin sinh viên: $e');
    }
  }

  /// 🔹 Lấy thông tin sinh viên theo email
  Future<UserModel?> getStudentByEmail(String email) async {
    try {
      final students = await _firestoreService.queryDocuments<UserModel>(
        field: 'email',
        isEqualTo: email,
      );
      return students.isNotEmpty ? students.first : null;
    } catch (e) {
      throw Exception('Lỗi khi lấy thông tin sinh viên theo email: $e');
    }
  }

  /// 🔹 Lấy tất cả sinh viên
  Future<List<UserModel>> getAllStudents() async {
    try {
      return await _firestoreService.queryDocuments<UserModel>(
        field: 'role',
        isEqualTo: 'student',
      );
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách sinh viên: $e');
    }
  }

  /// 🔹 Lấy sinh viên theo lớp
  Future<List<UserModel>> getStudentsByClass(String classId) async {
    try {
      return await _firestoreService.queryDocuments<UserModel>(
        field: 'classId',
        isEqualTo: classId,
      );
    } catch (e) {
      throw Exception('Lỗi khi lấy sinh viên theo lớp: $e');
    }
  }

  /// 🔹 Cập nhật thông tin sinh viên
  Future<void> updateStudentProfile(String studentId, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.updateDocument<UserModel>(studentId, updates);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông tin sinh viên: $e');
    }
  }

  // ==================== QUẢN LÝ ẢNH KHUÔN MẶT ====================

  /// 🔹 Upload ảnh khuôn mặt lên Firebase Storage
  Future<String> uploadFaceImage({
    required File imageFile,
    required String studentId,
    required String pose,
  }) async {
    try {
      print('🔄 Đang upload ảnh $pose cho sinh viên $studentId...');

      // Tạo tên file unique
      String fileName = 'faces/$studentId/${pose}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      
      // Upload file
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Lấy download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Upload thành công: $pose - $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Lỗi upload ảnh $pose: $e');
      throw Exception('Lỗi khi upload ảnh khuôn mặt: $e');
    }
  }

  /// 🔹 Upload nhiều ảnh khuôn mặt (3 hướng)
  Future<Map<String, String>> uploadMultipleFaceImages({
    required String studentId,
    required File frontalImage,
    required File leftImage,
    required File rightImage,
  }) async {
    try {
      print('🔄 Bắt đầu upload 3 ảnh cho sinh viên $studentId...');

      Map<String, String> imageUrls = {};

      // Upload từng ảnh
      imageUrls['frontal'] = await uploadFaceImage(
        imageFile: frontalImage,
        studentId: studentId,
        pose: 'frontal',
      );

      imageUrls['left'] = await uploadFaceImage(
        imageFile: leftImage,
        studentId: studentId,
        pose: 'left',
      );

      imageUrls['right'] = await uploadFaceImage(
        imageFile: rightImage,
        studentId: studentId,
        pose: 'right',
      );

      print('🎉 Đã upload thành công 3 ảnh cho sinh viên $studentId');
      return imageUrls;
    } catch (e) {
      print('❌ Lỗi upload 3 ảnh: $e');
      throw Exception('Lỗi khi upload nhiều ảnh khuôn mặt: $e');
    }
  }

  /// 🔹 Xóa ảnh khuôn mặt cũ
  Future<void> deleteOldFaceImages(List<String> oldImageUrls) async {
    try {
      for (String url in oldImageUrls) {
        try {
          Reference ref = _storage.refFromURL(url);
          await ref.delete();
        } catch (e) {
          print('Lỗi khi xóa ảnh cũ: $e');
          // Tiếp tục xóa ảnh khác, không throw error
        }
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa ảnh khuôn mặt cũ: $e');
    }
  }

  /// 🔹 Lấy URLs ảnh khuôn mặt của sinh viên
  Future<List<String>> getStudentFaceUrls(String studentId) async {
    try {
      final student = await getStudentById(studentId);
      return student?.faceUrls ?? [];
    } catch (e) {
      throw Exception('Lỗi khi lấy URLs ảnh khuôn mặt: $e');
    }
  }

  // ==================== QUẢN LÝ FACE DATA ====================

  /// 🔹 Lấy face data của sinh viên
  Future<FaceDataModel?> getStudentFaceData(String studentId) async {
    try {
      final faceDataId = 'face_$studentId';
      return await _firestoreService.getDocument<FaceDataModel>(faceDataId);
    } catch (e) {
      throw Exception('Lỗi khi lấy face data: $e');
    }
  }

  /// 🔹 Đăng ký khuôn mặt cho sinh viên
  Future<void> registerStudentFace({
    required String studentId,
    required Map<String, String> poseImageUrls,
    required Map<String, List<double>> poseEmbeddings,
  }) async {
    try {
      // 1. Lấy thông tin sinh viên
      final student = await getStudentById(studentId);
      if (student == null) {
        throw Exception('Không tìm thấy sinh viên');
      }

      // 2. Tạo hoặc cập nhật FaceData
      final faceDataId = 'face_$studentId';
      FaceDataModel faceData = FaceDataModel(
        id: faceDataId,
        userId: studentId,
        userEmail: student.email,
        userRole: 'student',
        poseImageUrls: poseImageUrls,
        poseEmbeddings: poseEmbeddings,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        version: 1,
      );

      await _firestoreService.addDocument<FaceDataModel>(faceData);

      // 3. Cập nhật UserModel
      await _firestoreService.updateDocument<UserModel>(studentId, {
        'faceUrls': poseImageUrls.values.toList(),
        'isFaceRegistered': true,
        'faceDataId': faceDataId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw Exception('Lỗi khi đăng ký khuôn mặt: $e');
    }
  }

  /// 🔹 Cập nhật khuôn mặt (overwrite)
  Future<void> updateStudentFace({
    required String studentId,
    required Map<String, String> newPoseImageUrls,
    required Map<String, List<double>> newPoseEmbeddings,
  }) async {
    try {
      // 1. Lấy thông tin cũ để xóa ảnh
      final student = await getStudentById(studentId);
      final oldFaceUrls = student?.faceUrls ?? [];

      // 2. Xóa ảnh cũ (nếu có)
      if (oldFaceUrls.isNotEmpty) {
        await deleteOldFaceImages(oldFaceUrls);
      }

      // 3. Cập nhật FaceData
      await _firestoreService.updateDocument<FaceDataModel>('face_$studentId', {
        'poseImageUrls': newPoseImageUrls,
        'poseEmbeddings': _encodeEmbeddings(newPoseEmbeddings),
        'updatedAt': FieldValue.serverTimestamp(),
        'version': FieldValue.increment(1),
      });

      // 4. Cập nhật UserModel
      await _firestoreService.updateDocument<UserModel>(studentId, {
        'faceUrls': newPoseImageUrls.values.toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      throw Exception('Lỗi khi cập nhật khuôn mặt: $e');
    }
  }

  /// 🔹 Helper encode embeddings
  Map<String, String> _encodeEmbeddings(Map<String, List<double>> embeddings) {
    Map<String, String> result = {};
    embeddings.forEach((pose, embedding) {
      result[pose] = jsonEncode(embedding);
    });
    return result;
  }

  // 🔹 QUAN TRỌNG: Sửa method này để kiểm tra chính xác
  Future<bool> hasRegisteredFace(String studentId) async {
    try {
      final student = await getStudentById(studentId);
      
      // Kiểm tra cả 2 điều kiện
      bool hasFaceData = student?.isFaceRegistered == true;
      bool hasFaceUrls = student?.faceUrls?.isNotEmpty == true;
      
      print('🔍 Kiểm tra đăng ký khuôn mặt:');
      print('   - Student ID: $studentId');
      print('   - isFaceRegistered: ${student?.isFaceRegistered}');
      print('   - faceUrls: ${student?.faceUrls?.length} ảnh');
      print('   - Kết quả: ${hasFaceData && hasFaceUrls}');
      
      return hasFaceData && hasFaceUrls;
    } catch (e) {
      print('❌ Lỗi khi kiểm tra trạng thái đăng ký khuôn mặt: $e');
      return false;
    }
  }

  // ==================== TIỆN ÍCH ====================

  /// 🔹 Stream real-time thông tin sinh viên
  Stream<UserModel?> watchStudent(String studentId) {
    return _firestoreService.watchDocument<UserModel>(studentId);
  }

  /// 🔹 Stream real-time face data
  Stream<FaceDataModel?> watchStudentFaceData(String studentId) {
    return _firestoreService.watchDocument<FaceDataModel>('face_$studentId');
  }

  /// 🔹 Kiểm tra sinh viên tồn tại
  Future<bool> studentExists(String studentId) async {
    try {
      return await _firestoreService.documentExists<UserModel>(studentId);
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra sinh viên tồn tại: $e');
    }
  }

  /// 🔹 Lấy sinh viên theo mã sinh viên
  Future<UserModel?> getStudentByCode(String studentCode) async {
    try {
      final students = await _firestoreService.queryDocuments<UserModel>(
        field: 'studentCode',
        isEqualTo: studentCode,
      );
      return students.isNotEmpty ? students.first : null;
    } catch (e) {
      throw Exception('Lỗi khi lấy sinh viên theo mã: $e');
    }
  }

  // ==================== METHOD CHO CAMERA ====================

  /// 🔹 LƯU THÔNG TIN ẢNH VÀO FIRESTORE (KHÔNG CÓ EMBEDDINGS)
  Future<void> saveFaceImagesOnly({
    required String studentId,
    required Map<String, String> imageUrls,
  }) async {
    try {
      print('🔄 Đang lưu thông tin ảnh vào Firestore...');

      // 1. Lấy thông tin sinh viên
      final student = await getStudentById(studentId);
      if (student == null) {
        throw Exception('Không tìm thấy sinh viên $studentId');
      }

      // 2. Tạo FaceData với embeddings RỖNG
      final faceDataId = 'face_$studentId';
      FaceDataModel faceData = FaceDataModel(
        id: faceDataId,
        userId: studentId,
        userEmail: student.email,
        userRole: 'student',
        poseImageUrls: imageUrls,
        poseEmbeddings: {}, // embeddings RỖNG - để sau
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
        version: 1,
      );

      await _firestoreService.addDocument<FaceDataModel>(faceData);

      // 3. Cập nhật UserModel
      await _firestoreService.updateDocument<UserModel>(studentId, {
        'faceUrls': imageUrls.values.toList(),
        'isFaceRegistered': true,
        'faceDataId': faceDataId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Đã lưu thông tin ảnh thành công!');
      print('📸 URLs ảnh: ${imageUrls.values}');
    } catch (e) {
      print('❌ Lỗi lưu thông tin ảnh: $e');
      throw Exception('Lỗi khi lưu thông tin ảnh: $e');
    }
  }

  /// 🔹 ĐĂNG KÝ KHUÔN MẶT ĐƠN GIẢN (CHỈ ẢNH)
  Future<void> registerFaceImagesOnly({
    required String studentId,
    required File frontalImage,
    required File leftImage,
    required File rightImage,
  }) async {
    try {
      print('🚀 Bắt đầu đăng ký khuôn mặt (ảnh only)...');

      // 1. Upload ảnh lên Storage
      final Map<String, String> imageUrls = await uploadMultipleFaceImages(
        studentId: studentId,
        frontalImage: frontalImage,
        leftImage: leftImage,
        rightImage: rightImage,
      );

      // 2. Lưu thông tin vào Firestore
      await saveFaceImagesOnly(
        studentId: studentId,
        imageUrls: imageUrls,
      );

      print('🎉 ĐĂNG KÝ THÀNH CÔNG! Ảnh đã được lưu, embeddings để sau.');
    } catch (e) {
      print('❌ Lỗi đăng ký khuôn mặt: $e');
      throw Exception('Lỗi đăng ký khuôn mặt: $e');
    }
  }

  // 🔹 THÊM: Method kiểm tra nhanh (dùng trong login)
  Future<bool> checkFaceRegistrationQuick(String studentId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users') // hoặc 'students' tùy collection của bạn
          .doc(studentId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        bool isRegistered = data?['isFaceRegistered'] == true;
        List faceUrls = data?['faceUrls'] ?? [];
        
        return isRegistered && faceUrls.length >= 3;
      }
      return false;
    } catch (e) {
      print('❌ Lỗi kiểm tra nhanh: $e');
      return false;
    }
  }
}