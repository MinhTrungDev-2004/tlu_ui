import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cammera_attendance_screen.dart';
import '../../register_face/widgets/main_appbar.dart';
import '../../../../../models/session_model.dart';

class ClassInfoScreen extends StatefulWidget {
  final SessionModel session;

  const ClassInfoScreen({
    super.key,
    required this.session,
  });

  @override
  State<ClassInfoScreen> createState() => _ClassInfoScreenState();
}

class _ClassInfoScreenState extends State<ClassInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Biến để lưu tên môn học và giảng viên
  String _courseName = '';
  String _lecturerName = '';
  bool _isLoading = true;

  // Lấy UID sinh viên từ Firebase Auth
  String get _studentId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadCourseAndLecturerData();
  }

  Future<void> _loadCourseAndLecturerData() async {
    try {
      // Load tên môn học
      final courseDoc = await _firestore
          .collection('courses')
          .doc(widget.session.courseId)
          .get();
      
      if (courseDoc.exists) {
        setState(() {
          _courseName = courseDoc.data()?['name'] ?? widget.session.courseId;
        });
      } else {
        setState(() {
          _courseName = widget.session.courseId;
        });
      }

      // Load tên giảng viên (nếu có lecturerId)
      if (widget.session.lecturerId != null && widget.session.lecturerId!.isNotEmpty) {
        final lecturerDoc = await _firestore
            .collection('user')
            .doc(widget.session.lecturerId)
            .get();
        
        if (lecturerDoc.exists) {
          final data = lecturerDoc.data();
          final String fullName = '${data?['firstName'] ?? ''} ${data?['lastName'] ?? ''}'.trim();
          final String title = data?['title'] ?? '';
          
          setState(() {
            _lecturerName = title.isNotEmpty ? '$title $fullName' : fullName;
          });
        } else {
          setState(() {
            _lecturerName = widget.session.lecturerId!;
          });
        }
      } else {
        setState(() {
          _lecturerName = 'Chưa xác định';
        });
      }
    } catch (e) {
      print('Lỗi khi load dữ liệu: $e');
      // Fallback nếu có lỗi
      setState(() {
        _courseName = widget.session.courseId;
        _lecturerName = widget.session.lecturerId ?? 'Chưa xác định';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: buildMainAppBar(
        context: context,
        title: 'Thông tin buổi học',
        showBack: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải thông tin...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Thông tin lớp học
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tên môn học (lấy từ Firebase)
                          Text(
                            'Môn học: $_courseName', // ✅ TÊN MÔN HỌC THỰC
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Tên giảng viên (lấy từ Firebase)
                          Row(
                            children: [
                              const Icon(Icons.person, size: 20, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(_lecturerName), // ✅ TÊN GIẢNG VIÊN THỰC
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          // Thông tin ngày
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(widget.session.dateDisplay),
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          // Thông tin thời gian
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text('${widget.session.startTime} - ${widget.session.endTime}'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          
                          // Thông tin phòng học
                          Text('Phòng: ${widget.session.room ?? 'Chưa xác định'}'),
                          const SizedBox(height: 6),
                          
                          // Trạng thái buổi học
                          Text('Trạng thái: ${_getStatusText(widget.session.status)}'),
                          
                          const SizedBox(height: 8),
                          
                          // Thông tin QR code
                          Text(
                            widget.session.qrCode != null 
                              ? 'Mã QR có hiệu lực trong 15 phút'
                              : 'Mã QR chưa được kích hoạt',
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                          
                          // Hiển thị trạng thái QR hợp lệ
                          if (widget.session.isQrValid) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.green),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Mã QR hợp lệ',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Kiểm tra sinh viên đã đăng nhập chưa
                  if (_studentId.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Vui lòng đăng nhập để điểm danh',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Nút Điểm danh - chỉ hiển thị khi session hợp lệ VÀ đã đăng nhập
                  if (widget.session.isHappeningNow && widget.session.isQrValid && _studentId.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FaceAttendanceScreen(
                              session: widget.session,
                              studentId: _studentId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1470E2),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Điểm danh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                  // Thông báo khi không thể điểm danh
                  if (!widget.session.isHappeningNow && _studentId.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.session.isCompleted 
                                ? 'Buổi học đã kết thúc'
                                : 'Chưa đến giờ điểm danh',
                              style: TextStyle(color: Colors.orange[700]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Thông báo QR hết hạn
                  if (!widget.session.isQrValid && widget.session.qrCode != null && _studentId.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Mã QR đã hết hạn',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Nút Quét lại QR
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Quét lại QR'),
                  ),
                ],
              ),
            ),
    );
  }

  // Hàm chuyển đổi trạng thái sang text
  String _getStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return 'Sắp diễn ra';
      case SessionStatus.ongoing:
        return 'Đang diễn ra';
      case SessionStatus.done:
        return 'Đã kết thúc';
      case SessionStatus.cancelled:
        return 'Đã hủy';
    }
  }
}