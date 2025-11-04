import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../register_face/register_face_screen.dart';
import 'widgets/history_attendance.dart';
import '../../../../services/student/student_service.dart';

class PersonalPage extends StatefulWidget {
  const PersonalPage({super.key});

  @override
  State<PersonalPage> createState() => _PersonalPageState();
}

class _PersonalPageState extends State<PersonalPage> {
  final StudentService _studentService = StudentService();
  Map<String, dynamic>? _userData;
  String? _frontalImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Lấy thông tin user từ Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data()!;
          });

          // Lấy URL ảnh khuôn mặt trực diện
          final faceData = await _studentService.getStudentFaceData(user.uid);
          if (faceData != null && faceData.poseImageUrls.containsKey('frontal')) {
            setState(() {
              _frontalImageUrl = faceData.poseImageUrls['frontal'];
            });
          }
        }
      }
    } catch (e) {
      print('❌ Lỗi load user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getUserName() {
    if (_userData == null) return 'Đang tải...';
    
    // Ưu tiên hiển thị tên đầy đủ
    if (_userData?['name'] != null) {
      return _userData!['name'];
    }
    
    // Hoặc hiển thị email nếu không có tên
    if (_userData?['email'] != null) {
      return _userData!['email'].split('@').first;
    }
    
    return 'Người dùng';
  }

  String _getUserEmail() {
    return _userData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? 'Chưa có email';
  }

  String _getStudentCode() {
    return _userData?['studentCode'] ?? _userData?['code'] ?? 'Chưa có mã SV';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              child: Column(
                children: [
                  // Avatar từ ảnh khuôn mặt đã đăng ký
                  _buildUserAvatar(),
                  const SizedBox(height: 10),
                  
                  // Tên người dùng
                  Text(
                    _getUserName(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  
                  
                  
                  const SizedBox(height: 25),

                  // Menu chức năng
                  _buildMenuItem(
                    context,
                    Icons.face_retouching_natural,
                    'Cập nhật khuôn mặt',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterFaceScreen()),
                      ).then((_) {
                        // Reload data khi quay lại từ trang đăng ký khuôn mặt
                        _loadUserData();
                      });
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.person_outline,
                    'Thông tin cá nhân',
                    () {
                      _showPersonalInfoDialog(context);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.history,
                    'Lịch sử điểm danh',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AttendanceHistoryScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.settings_outlined,
                    'Cài đặt',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang được phát triển')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.help_outline,
                    'Trợ giúp',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang được phát triển')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    Icons.feedback_outlined,
                    'Phản hồi / Góp ý',
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng đang được phát triển')),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Nút đăng xuất
                  _buildMenuItem(
                    context,
                    Icons.logout,
                    'Đăng xuất',
                    () => _showLogoutDialog(context),
                    color: Colors.black,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserAvatar() {
    return Stack(
      children: [
        // Avatar từ ảnh khuôn mặt đã đăng ký
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: _frontalImageUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: _frontalImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
                  ),
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
        ),
        
        // Badge trạng thái đăng ký khuôn mặt
        if (_frontalImageUrl != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? Colors.black),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: color ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _showPersonalInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Thông tin cá nhân',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Họ và tên', _getUserName()),
              _buildInfoRow('Email', _getUserEmail()),
              if (_getStudentCode() != 'Chưa có mã SV')
                _buildInfoRow('Mã sinh viên', _getStudentCode()),
              _buildInfoRow('Trạng thái khuôn mặt', 
                  _frontalImageUrl != null ? 'Đã đăng ký' : 'Chưa đăng ký'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await FirebaseAuth.instance.signOut();
                  // Điều hướng về login page (tuỳ vào setup navigation của bạn)
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi đăng xuất: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}