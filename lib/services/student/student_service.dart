import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user/user_model.dart';
import '../../models/face_data_model.dart';
import '../firestore_service.dart';

class StudentService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== QUẢN LÝ THÔNG TIN SINH VIÊN ====================

  Future<UserModel?> getStudentById(String studentId) async {
    try {
      return await _firestoreService.getDocument<UserModel>(studentId);
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin sinh viên $studentId: $e');
      throw Exception('Lỗi khi lấy thông tin sinh viên: $e');
    }
  }

  Future<UserModel?> getStudentByEmail(String email) async {
    try {
      final students = await _firestoreService.queryDocuments<UserModel>(
        field: 'email',
        isEqualTo: email,
      );
      return students.isNotEmpty ? students.first : null;
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin sinh viên theo email $email: $e');
      throw Exception('Lỗi khi lấy thông tin sinh viên theo email: $e');
    }
  }

  Future<List<UserModel>> getAllStudents() async {
    try {
      return await _firestoreService.queryDocuments<UserModel>(
        field: 'role',
        isEqualTo: 'student',
      );
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách sinh viên: $e');
      throw Exception('Lỗi khi lấy danh sách sinh viên: $e');
    }
  }

  Future<List<UserModel>> getStudentsByClass(String classId) async {
    try {
      return await _firestoreService.queryDocuments<UserModel>(
        field: 'classId',
        isEqualTo: classId,
      );
    } catch (e) {
      print('❌ Lỗi khi lấy sinh viên theo lớp $classId: $e');
      throw Exception('Lỗi khi lấy sinh viên theo lớp: $e');
    }
  }

  Future<void> updateStudentProfile(String studentId, Map<String, dynamic> updates) async {
    try {
      await _firestoreService.updateDocument<UserModel>(studentId, updates);
      print('✅ Cập nhật thông tin sinh viên $studentId thành công');
    } catch (e) {
      print('❌ Lỗi khi cập nhật thông tin sinh viên $studentId: $e');
      throw Exception('Lỗi khi cập nhật thông tin sinh viên: $e');
    }
  }

  // ==================== QUẢN LÝ ẢNH KHUÔN MẶT ====================

  Future<Map<String, String>> uploadFaceImage({
    required File imageFile,
    required String studentId,
    required String pose,
  }) async {
    try {
      print('🔄 Đang upload ảnh $pose cho sinh viên $studentId...');
      
      String fileName = 'student_faces/$studentId/${pose}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Upload thành công: $pose - $downloadUrl');
      
      return {
        'url': downloadUrl,
        'bucketName': snapshot.ref.bucket,
        'filePath': snapshot.ref.fullPath,
      };
    } catch (e) {
      print('❌ Lỗi upload ảnh $pose cho $studentId: $e');
      throw Exception('Lỗi khi upload ảnh khuôn mặt: $e');
    }
  }

  Future<Map<String, Map<String, String>>> uploadMultipleFaceImages({
    required String studentId,
    required File frontalImage,
    required File leftImage,
    required File rightImage,
  }) async {
    try {
      print('🔄 Bắt đầu upload 3 ảnh cho sinh viên $studentId...');
      
      Map<String, Map<String, String>> poseData = {};
      
      poseData['frontal'] = await uploadFaceImage(
        imageFile: frontalImage, 
        studentId: studentId, 
        pose: 'frontal'
      );
      
      poseData['left'] = await uploadFaceImage(
        imageFile: leftImage, 
        studentId: studentId, 
        pose: 'left'
      );
      
      poseData['right'] = await uploadFaceImage(
        imageFile: rightImage, 
        studentId: studentId, 
        pose: 'right'
      );
      
      print('🎉 Đã upload thành công 3 ảnh cho sinh viên $studentId');
      return poseData;
    } catch (e) {
      print('❌ Lỗi upload 3 ảnh cho $studentId: $e');
      throw Exception('Lỗi khi upload nhiều ảnh khuôn mặt: $e');
    }
  }

  Future<void> deleteOldFaceImages(List<String> oldImageUrls) async {
    try {
      for (String url in oldImageUrls) {
        try {
          Reference ref = _storage.refFromURL(url);
          await ref.delete();
          print('✅ Đã xóa ảnh cũ: $url');
        } catch (e) {
          print('⚠️ Không thể xóa ảnh cũ $url: $e');
        }
      }
    } catch (e) {
      print('❌ Lỗi khi xóa ảnh khuôn mặt cũ: $e');
      throw Exception('Lỗi khi xóa ảnh khuôn mặt cũ: $e');
    }
  }

  Future<List<String>> getStudentFaceUrls(String studentId) async {
    try {
      final student = await getStudentById(studentId);
      return student?.faceUrls ?? [];
    } catch (e) {
      print('❌ Lỗi khi lấy URLs ảnh khuôn mặt của $studentId: $e');
      throw Exception('Lỗi khi lấy URLs ảnh khuôn mặt: $e');
    }
  }

  // ==================== CLOUD FUNCTIONS ====================

  Future<List<double>> extractFaceEmbedding(String imageUrl) async {
    try {
      print('🔄 Gọi Cloud Function extractFaceEmbedding...');
      
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final HttpsCallable callable = functions.httpsCallable(
        'extractFaceEmbedding',
        options: HttpsCallableOptions(
          limitedUseAppCheckToken: false,
          timeout: const Duration(seconds: 60),
        ),
      );

      final result = await callable.call({'imageUrl': imageUrl});
      final data = result.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        final List<dynamic> embeddingList = data['embedding'] as List<dynamic>;
        
        final List<double> embedding = embeddingList.map((value) {
          if (value is int) return value.toDouble();
          if (value is double) return value;
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }).toList();
        
        // Kiểm tra embedding hợp lệ
        if (embedding.isEmpty) {
          throw Exception('Embedding trống');
        }
        
        print('✅ Embedding trích xuất thành công: ${embedding.length} dimensions');
        return embedding;
      } else {
        throw Exception('Extract embedding failed: ${data['error']}');
      }
    } on FirebaseFunctionsException catch (e) {
      print('❌ Lỗi Firebase Functions: ${e.code} - ${e.message}');
      throw Exception('Lỗi kết nối đến server: ${e.message}');
    } catch (e) {
      print('❌ Lỗi trích xuất embedding: $e');
      throw Exception('Lỗi khi trích xuất embedding: $e');
    }
  }

  Future<Map<String, List<double>>> extractMultipleEmbeddings(Map<String, Map<String, String>> poseData) async {
    try {
      print('🔄 Trích xuất embeddings từ ${poseData.length} ảnh...');
      
      Map<String, List<double>> embeddings = {};
      
      for (var entry in poseData.entries) {
        final String pose = entry.key;
        final String imageUrl = entry.value['url']!;
        
        print('📸 Đang trích xuất embedding cho $pose...');
        
        final embedding = await extractFaceEmbedding(imageUrl);
        embeddings[pose] = embedding;
        
        print('✅ Đã trích xuất embedding cho $pose (${embedding.length} dimensions)');
      }
      
      return embeddings;
    } catch (e) {
      print('❌ Lỗi trích xuất multiple embeddings: $e');
      throw Exception('Lỗi khi trích xuất embeddings từ nhiều ảnh: $e');
    }
  }

  // ==================== FACE DATA ====================

  Future<FaceDataModel?> getStudentFaceData(String studentId) async {
    try {
      final faceDataId = 'face_$studentId';
      return await _firestoreService.getDocument<FaceDataModel>(faceDataId);
    } catch (e) {
      print('❌ Lỗi khi lấy face data của $studentId: $e');
      throw Exception('Lỗi khi lấy face data: $e');
    }
  }

  Future<void> registerStudentFace({
    required String studentId,
    required Map<String, String> poseImageUrls,
    required Map<String, List<double>> poseEmbeddings,
  }) async {
    try {
      // Kiểm tra dữ liệu đầu vào
      if (poseImageUrls.length != 3 || poseEmbeddings.length != 3) {
        throw Exception('Cần đủ 3 ảnh và 3 embeddings từ các góc độ');
      }
      
      for (var embedding in poseEmbeddings.values) {
        if (embedding.isEmpty) {
          throw Exception('Embedding không hợp lệ');
        }
      }

      // Lấy thông tin sinh viên
      final student = await getStudentById(studentId);
      if (student == null) throw Exception('Không tìm thấy sinh viên');

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

      // Kiểm tra trùng lặp trước khi lưu
      final existingFaceData = await getStudentFaceData(studentId);
      if (existingFaceData != null) {
        print('⚠️ Đã có face data, sẽ ghi đè...');
        // Xóa ảnh cũ nếu có
        await deleteOldFaceImages(existingFaceData.poseImageUrls.values.toList());
      }

      await _firestoreService.addDocument<FaceDataModel>(faceData);

      // Cập nhật UserModel
      await _firestoreService.updateDocument<UserModel>(studentId, {
        'faceUrls': poseImageUrls.values.toList(),
        'isFaceRegistered': true,
        'faceDataId': faceDataId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('🎉 ĐĂNG KÝ KHUÔN MẶT THÀNH CÔNG!');
      print('📸 Ảnh: ${poseImageUrls.length}');
      print('🧮 Embeddings: ${poseEmbeddings.length}');

    } catch (e) {
      print('❌ Lỗi khi đăng ký khuôn mặt: $e');
      // Xóa ảnh đã upload nếu lỗi
      try {
        await deleteOldFaceImages(poseImageUrls.values.toList());
      } catch (deleteError) {
        print('⚠️ Không thể xóa ảnh đã upload: $deleteError');
      }
      throw Exception('Lỗi khi đăng ký khuôn mặt: $e');
    }
  }

  Future<void> registerFaceWithEmbeddings({
    required String studentId,
    required File frontalImage,
    required File leftImage,
    required File rightImage,
  }) async {
    try {
      print('🚀 Bắt đầu đăng ký khuôn mặt HOÀN CHỈNH...');

      // 1. Upload ảnh lên Storage
      final Map<String, Map<String, String>> poseData = await uploadMultipleFaceImages(
        studentId: studentId,
        frontalImage: frontalImage,
        leftImage: leftImage,
        rightImage: rightImage,
      );

      // Tách riêng poseImageUrls
      final Map<String, String> imageUrls = poseData.map((key, value) => MapEntry(key, value['url']!));

      // 2. Trích xuất embeddings từ Cloud Functions
      final Map<String, List<double>> embeddings = await extractMultipleEmbeddings(poseData);

      // 3. Đăng ký với embeddings
      await registerStudentFace(
        studentId: studentId,
        poseImageUrls: imageUrls,
        poseEmbeddings: embeddings,
      );

      print('🎉 ĐĂNG KÝ HOÀN CHỈNH THÀNH CÔNG! Có cả ảnh và embeddings.');

    } catch (e) {
      print('❌ Lỗi đăng ký khuôn mặt hoàn chỉnh: $e');
      throw Exception('Lỗi đăng ký khuôn mặt hoàn chỉnh: $e');
    }
  }

  // ==================== ĐIỂM DANH BẰNG KHUÔN MẶT ====================

  Future<Map<String, dynamic>> markAttendanceWithFace(File faceImage) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'success': false, 
          'message': 'Vui lòng đăng nhập để điểm danh',
          'errorCode': 'NOT_LOGGED_IN'
        };
      }

      final String loggedInStudentId = currentUser.uid;
      print('🔐 Sinh viên đang đăng nhập: $loggedInStudentId');

      // 1. Kiểm tra sinh viên đã đăng ký khuôn mặt chưa
      final faceData = await getStudentFaceData(loggedInStudentId);
      if (faceData == null || faceData.poseEmbeddings['frontal'] == null) {
        return {
          'success': false, 
          'message': 'Sinh viên chưa đăng ký khuôn mặt trực diện',
          'errorCode': 'FACE_NOT_REGISTERED'
        };
      }

      // 2. Upload ảnh điểm danh tạm thời
      final uploadResult = await uploadFaceImage(
        imageFile: faceImage,
        studentId: 'temp_attendance',
        pose: 'attendance_${DateTime.now().millisecondsSinceEpoch}',
      );
      final String imageUrl = uploadResult['url']!;

      // 3. Trích xuất embedding từ ảnh điểm danh
      final List<double> queryEmbedding = await extractFaceEmbedding(imageUrl);

      // 4. Xóa ảnh tạm ngay sau khi extract
      try {
        Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
        print('✅ Đã xóa ảnh tạm điểm danh');
      } catch (e) {
        print('⚠️ Không thể xóa ảnh tạm: $e');
      }

      // 5. So sánh với embedding đã đăng ký
      final List<double> registeredEmbedding = List<double>.from(faceData.poseEmbeddings['frontal']!);
      final double similarity = _cosineSimilarity(queryEmbedding, registeredEmbedding);

      print('🔍 KẾT QUẢ SO SÁNH:');
      print('   - Sinh viên: ${faceData.userEmail}');
      print('   - Similarity: ${(similarity * 100).toStringAsFixed(1)}%');
      print('   - Threshold: 88%');

      // 6. Quyết định điểm danh
      if (similarity >= 0.88) {
        // ✅ THÀNH CÔNG: Khuôn mặt khớp
        await _recordAttendance({
          'studentId': loggedInStudentId,
          'name': faceData.userEmail ?? 'Unknown',
          'className': 'Unknown',
          'similarity': similarity,
        });
        
        return {
          'success': true,
          'message': 'Điểm danh thành công!',
          'similarity': similarity,
          'student': {
            'studentId': loggedInStudentId,
            'name': faceData.userEmail ?? 'Unknown',
            'similarity': similarity,
          }
        };
      } else {
        // ❌ THẤT BẠI: Khuôn mặt không khớp
        return {
          'success': false,
          'message': 'Khuôn mặt không khớp với thông tin đăng ký (${(similarity * 100).toStringAsFixed(1)}%)',
          'similarity': similarity,
          'errorCode': 'FACE_MISMATCH'
        };
      }

    } catch (e) {
      print('❌ Lỗi điểm danh: $e');
      return {
        'success': false, 
        'message': 'Lỗi hệ thống: ${e.toString()}',
        'errorCode': 'SYSTEM_ERROR'
      };
    }
  }

  Future<void> _recordAttendance(Map<String, dynamic> student) async {
    try {
      final attendanceId = 'att_${DateTime.now().millisecondsSinceEpoch}';
      final String studentId = student['studentId']?.toString() ?? '';
      final String studentName = student['name']?.toString() ?? 'Unknown';
      final double similarity = (student['similarity'] ?? 0.0).toDouble();

      await FirebaseFirestore.instance.collection('attendance').doc(attendanceId).set({
        'id': attendanceId,
        'studentId': studentId,
        'name': studentName,
        'className': student['className']?.toString() ?? 'Unknown',
        'timestamp': FieldValue.serverTimestamp(),
        'date': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
        'similarity': similarity,
        'similarityPercentage': (similarity * 100).toStringAsFixed(1),
        'type': 'face_recognition',
        'status': _determineAttendanceStatus(DateTime.now()),
        'confidence': _getConfidenceLevel(similarity),
      });

      print('✅ Đã ghi nhận điểm danh cho $studentName - Similarity: ${(similarity * 100).toStringAsFixed(1)}%');
    } catch (e) {
      print('❌ Lỗi ghi nhận điểm danh: $e');
      throw Exception('Lỗi ghi nhận điểm danh: $e');
    }
  }

  String _determineAttendanceStatus(DateTime attendanceTime) {
    final now = DateTime.now();
    final sessionStart = DateTime(now.year, now.month, now.day, 7, 0);
    final lateThreshold = sessionStart.add(const Duration(minutes: 15));
    
    if (attendanceTime.isBefore(lateThreshold)) {
      return 'present';
    } else if (attendanceTime.isBefore(sessionStart.add(const Duration(minutes: 30)))) {
      return 'late';
    } else {
      return 'absent';
    }
  }

  String _getConfidenceLevel(double similarity) {
    if (similarity >= 0.90) return 'very_high';
    if (similarity >= 0.85) return 'high';
    if (similarity >= 0.80) return 'medium';
    return 'low';
  }

  // ==================== TIỆN ÍCH ====================

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;
    
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  Future<bool> hasRegisteredFace(String studentId) async {
    try {
      final student = await getStudentById(studentId);
      
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

  Stream<UserModel?> watchStudent(String studentId) {
    return _firestoreService.watchDocument<UserModel>(studentId);
  }

  Stream<FaceDataModel?> watchStudentFaceData(String studentId) {
    return _firestoreService.watchDocument<FaceDataModel>('face_$studentId');
  }

  Future<bool> studentExists(String studentId) async {
    try {
      return await _firestoreService.documentExists<UserModel>(studentId);
    } catch (e) {
      print('❌ Lỗi khi kiểm tra sinh viên tồn tại: $e');
      throw Exception('Lỗi khi kiểm tra sinh viên tồn tại: $e');
    }
  }

  Future<UserModel?> getStudentByCode(String studentCode) async {
    try {
      final students = await _firestoreService.queryDocuments<UserModel>(
        field: 'studentCode',
        isEqualTo: studentCode,
      );
      return students.isNotEmpty ? students.first : null;
    } catch (e) {
      print('❌ Lỗi khi lấy sinh viên theo mã: $e');
      throw Exception('Lỗi khi lấy sinh viên theo mã: $e');
    }
  }

  // ==================== CLEANUP ====================

  Future<void> cleanupTempFiles() async {
    try {
      final tempRef = _storage.ref().child('student_faces/temp_attendance');
      final listResult = await tempRef.listAll();
      
      for (var item in listResult.items) {
        try {
          await item.delete();
          print('✅ Đã xóa file tạm: ${item.name}');
        } catch (e) {
          print('⚠️ Không thể xóa file tạm: ${item.name}');
        }
      }
    } catch (e) {
      print('⚠️ Lỗi khi cleanup temp files: $e');
    }
  }

  void dispose() {
    // Giải phóng tài nguyên nếu cần
  }
}