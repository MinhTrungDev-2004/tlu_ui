import 'dart:io';
import 'dart:convert'; 
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:math';
import '../../models/user/user_model.dart';
import '../../models/face_data_model.dart';
import '../firestore_service.dart';

class StudentService {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance; 

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
  /// Đã thay đổi return type để trả về URL, bucketName và filePath
  Future<Map<String, String>> uploadFaceImage({ // [THAY ĐỔI 1/6]
    required File imageFile,
    required String studentId,
    required String pose,
  }) async {
    try {
      print('🔄 Đang upload ảnh $pose cho sinh viên $studentId...');

      // Tạo tên file unique - SỬA THEO CẤU TRÚC CLOUD FUNCTION
      String fileName = 'student_faces/$studentId/${pose}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      
      // Upload file
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      
      // Lấy download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('✅ Upload thành công: $pose - $downloadUrl');
      
      // Trả về cả URL, Bucket Name và File Path
      return {
        'url': downloadUrl,
        'bucketName': snapshot.ref.bucket,
        'filePath': snapshot.ref.fullPath,
      };
    } catch (e) {
      print('❌ Lỗi upload ảnh $pose: $e');
      throw Exception('Lỗi khi upload ảnh khuôn mặt: $e');
    }
  }

  /// 🔹 Upload nhiều ảnh khuôn mặt (3 hướng)
  /// Đã thay đổi return type để chứa thông tin bucket/path
  Future<Map<String, Map<String, String>>> uploadMultipleFaceImages({ // [THAY ĐỔI 2/6]
    required String studentId,
    required File frontalImage,
    required File leftImage,
    required File rightImage,
  }) async {
    try {
      print('🔄 Bắt đầu upload 3 ảnh cho sinh viên $studentId...');

      // Sẽ chứa: {'pose': {'url': '...', 'bucketName': '...', 'filePath': '...'}}
      Map<String, Map<String, String>> poseData = {};

      // Upload từng ảnh
      poseData['frontal'] = await uploadFaceImage(
        imageFile: frontalImage,
        studentId: studentId,
        pose: 'face', // ← SỬA THÀNH 'face' ĐỂ TRÙNG VỚI CLOUD FUNCTION
      );

      poseData['left'] = await uploadFaceImage(
        imageFile: leftImage,
        studentId: studentId,
        pose: 'left',
      );

      poseData['right'] = await uploadFaceImage(
        imageFile: rightImage,
        studentId: studentId,
        pose: 'right',
      );

      print('🎉 Đã upload thành công 3 ảnh cho sinh viên $studentId');
      return poseData; // Trả về cấu trúc mới
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

  // ==================== GỌI CLOUD FUNCTIONS ====================

  /// 🔹 Gọi Cloud Function để trích xuất embedding từ ảnh
  /// Đã thay đổi input để truyền bucketName và filePath
  Future<List<double>> extractFaceEmbedding(String bucketName, String filePath) async { // [THAY ĐỔI 3/6]
    try {
      print('🔄 Gọi Cloud Function extractFaceEmbedding...');
      
      final HttpsCallable callable = _functions.httpsCallable('extractFaceEmbedding');
      // Truyền bucketName và filePath thay vì imageUrl
      final result = await callable.call({
        'bucketName': bucketName,
        'filePath': filePath,
      });
      
      final List<double> embedding = List<double>.from(result.data['embedding']);
      print('✅ Trích xuất embedding thành công, dimension: ${embedding.length}');
      
      return embedding;
    } catch (e) {
      print('❌ Lỗi trích xuất embedding: $e');
      throw Exception('Lỗi khi trích xuất embedding: $e');
    }
  }

  /// 🔹 Gọi Cloud Function để so sánh 2 embeddings
  Future<Map<String, dynamic>> compareFaces(List<double> embedding1, List<double> embedding2) async {
    try {
      print('🔄 Gọi Cloud Function compareFaces...');
      
      final HttpsCallable callable = _functions.httpsCallable('compareFaces');
      final result = await callable.call({
        'embedding1': embedding1,
        'embedding2': embedding2,
      });
      
      print('✅ So sánh thành công, similarity: ${result.data['similarity']}');
      return {
        'similarity': result.data['similarity'],
        'isMatch': result.data['isMatch'],
        'matchPercentage': result.data['matchPercentage'],
      };
    } catch (e) {
      print('❌ Lỗi so sánh faces: $e');
      throw Exception('Lỗi khi so sánh khuôn mặt: $e');
    }
  }

  /// 🔹 Trích xuất embeddings từ nhiều ảnh
  /// Đã thay đổi input để nhận poseData thay vì chỉ URLs
  Future<Map<String, List<double>>> extractMultipleEmbeddings(Map<String, Map<String, String>> poseData) async { // [THAY ĐỔI 4/6]
    try {
      print('🔄 Trích xuất embeddings từ ${poseData.length} ảnh...');
      
      Map<String, List<double>> embeddings = {};
      
      for (var entry in poseData.entries) {
        final String pose = entry.key;
        final String bucketName = entry.value['bucketName']!; // Lấy bucketName
        final String filePath = entry.value['filePath']!;     // Lấy filePath
        
        print('📸 Đang trích xuất embedding cho $pose...');
        // Truyền bucketName và filePath
        final embedding = await extractFaceEmbedding(bucketName, filePath); 
        embeddings[pose] = embedding;
        
        print('✅ Đã trích xuất embedding cho $pose (${embedding.length} dimensions)');
      }
      
      return embeddings;
    } catch (e) {
      print('❌ Lỗi trích xuất multiple embeddings: $e');
      throw Exception('Lỗi khi trích xuất embeddings từ nhiều ảnh: $e');
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

  /// 🔹 Đăng ký khuôn mặt cho sinh viên (FULL - có embeddings)
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

      print('🎉 ĐĂNG KÝ KHUÔN MẶT THÀNH CÔNG!');
      print('📸 Ảnh: ${poseImageUrls.length}');
      print('🧮 Embeddings: ${poseEmbeddings.length}');

    } catch (e) {
      throw Exception('Lỗi khi đăng ký khuôn mặt: $e');
    }
  }

  /// 🔹 ĐĂNG KÝ KHUÔN MẶT HOÀN CHỈNH (TỰ ĐỘNG TRÍCH XUẤT EMBEDDINGS)
  Future<void> registerFaceWithEmbeddings({ // [THAY ĐỔI 5/6]
    required String studentId,
    required File frontalImage,
    required File leftImage,
    required File rightImage,
  }) async {
    try {
      print('🚀 Bắt đầu đăng ký khuôn mặt HOÀN CHỈNH...');

      // 1. Upload ảnh lên Storage (nhận poseData mới)
      // poseData: {'pose': {'url': '...', 'bucketName': '...', 'filePath': '...'}}
      final Map<String, Map<String, String>> poseData = await uploadMultipleFaceImages(
        studentId: studentId,
        frontalImage: frontalImage,
        leftImage: leftImage,
        rightImage: rightImage,
      );

      // Tách riêng poseImageUrls (chỉ cần URL cho Firestore)
      final Map<String, String> imageUrls = poseData.map((key, value) => MapEntry(key, value['url']!));


      // 2. Trích xuất embeddings từ Cloud Functions (SỬ DỤNG poseData)
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
        'poseEmbeddings': newPoseEmbeddings,
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

  // ==================== ĐIỂM DANH BẰNG KHUÔN MẶT ====================

  /// 🔹 Điểm danh bằng khuôn mặt
  Future<Map<String, dynamic>> markAttendanceWithFace(File faceImage) async { // [THAY ĐỔI 6/6]
    try {
      print('📸 Bắt đầu điểm danh bằng khuôn mặt...');

      // 1. Upload ảnh điểm danh tạm thời
      final String tempPath = 'attendance_temp/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref(tempPath);
      await ref.putFile(faceImage);
      
      // 2. Trích xuất embedding từ ảnh điểm danh
      // Truyền bucketName và filePath thay vì imageUrl
      final List<double> queryEmbedding = await extractFaceEmbedding(ref.bucket, ref.fullPath);

      // 3. Xóa ảnh tạm
      await ref.delete();

      // 4. Tìm sinh viên khớp
      final matchedStudent = await _findMatchingStudent(queryEmbedding);
      
      if (matchedStudent != null) {
        // 5. Ghi nhận điểm danh
        await _recordAttendance(matchedStudent);
        
        return {
          'success': true,
          'student': matchedStudent,
          'message': 'Điểm danh thành công cho ${matchedStudent['name']}',
        };
      } else {
        return {
          'success': false,
          'message': 'Không tìm thấy sinh viên phù hợp',
        };
      }
    } catch (e) {
      print('❌ Lỗi điểm danh: $e');
      return {
        'success': false,
        'message': 'Lỗi điểm danh: $e',
      };
    }
  }

  /// 🔹 Tìm sinh viên khớp từ database
  Future<Map<String, dynamic>?> _findMatchingStudent(List<double> queryEmbedding) async {
    try {
      final students = await _firestoreService.queryDocuments<FaceDataModel>(
        field: 'userRole',
        isEqualTo: 'student',
      );

      double bestSimilarity = 0.6; // Ngưỡng tối thiểu
      Map<String, dynamic>? bestMatch;

      for (final faceData in students) {
        // Lấy embedding chính (frontal) để so sánh
        final frontalEmbedding = faceData.poseEmbeddings['frontal'];
        if (frontalEmbedding != null && frontalEmbedding.isNotEmpty) {
          final similarity = _cosineSimilarity(queryEmbedding, frontalEmbedding);
          
          if (similarity > bestSimilarity) {
            bestSimilarity = similarity;
            
            // Lấy thông tin sinh viên
            final student = await getStudentById(faceData.userId);
            if (student != null) {
              bestMatch = {
                'studentId': student.id,
                'name': student.name,
                'email': student.email,
                'className': student.classIds,
                'similarity': similarity,
                'imageUrl': student.faceUrls?.first,
              };
            }
          }
        }
      }

      print('🔍 Best match similarity: ${(bestSimilarity * 100).toStringAsFixed(1)}%');
      return bestMatch;
    } catch (e) {
      print('❌ Lỗi tìm sinh viên khớp: $e');
      return null;
    }
  }

  /// 🔹 Ghi nhận điểm danh
  Future<void> _recordAttendance(Map<String, dynamic> student) async {
    try {
      final attendanceId = 'att_${DateTime.now().millisecondsSinceEpoch}';
      
      await FirebaseFirestore.instance.collection('attendance').doc(attendanceId).set({
        'studentId': student['studentId'],
        'name': student['name'],
        'className': student['className'],
        'timestamp': FieldValue.serverTimestamp(),
        'date': '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
        'similarity': student['similarity'],
        'type': 'face_recognition',
      });

      print('✅ Đã ghi nhận điểm danh cho ${student['name']}');
    } catch (e) {
      print('❌ Lỗi ghi nhận điểm danh: $e');
    }
  }

  // ==================== TIỆN ÍCH ====================

  /// 🔹 Helper encode embeddings
  Map<String, String> _encodeEmbeddings(Map<String, List<double>> embeddings) {
    Map<String, String> result = {};
    embeddings.forEach((pose, embedding) {
      result[pose] = jsonEncode(embedding);
    });
    return result;
  }

  /// 🔹 Tính cosine similarity
  double _cosineSimilarity(List<double> a, List<double> b) {
    double dotProduct = 0;
    double normA = 0;
    double normB = 0;
    
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  // 🔹 QUAN TRỌNG: Sửa method này để kiểm tra chính xác
  Future<bool> hasRegisteredFace(String studentId) async {
    try {
      final student = await getStudentById(studentId);
      
      // Kiểm tra cả 2 điều kiện
      bool hasFaceData = student?.isFaceRegistered == true;
      bool hasFaceUrls = student?.faceUrls?.isNotEmpty == true;
      
      print('🔍 Kiểm tra đăng ký khuôn mặt:');
      print('   - Student ID: $studentId');
      print('   - isFaceRegistered: ${student?.isFaceRegistered}');
      print('   - faceUrls: ${student?.faceUrls?.length} ảnh');
      print('   - Kết quả: ${hasFaceData && hasFaceUrls}');
      
      return hasFaceData && hasFaceUrls;
    } catch (e) {
      print('❌ Lỗi khi kiểm tra trạng thái đăng ký khuôn mặt: $e');
      return false;
    }
  }

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
      // Tuy hàm uploadMultipleFaceImages trả về poseData, ta chỉ cần phần URLs
      final Map<String, Map<String, String>> poseData = await uploadMultipleFaceImages(
        studentId: studentId,
        frontalImage: frontalImage,
        leftImage: leftImage,
        rightImage: rightImage,
      );
      
      final Map<String, String> imageUrls = poseData.map((key, value) => MapEntry(key, value['url']!));


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