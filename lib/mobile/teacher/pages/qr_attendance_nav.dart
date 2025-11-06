import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'teacher_home.dart';
import 'teacher_schedule.dart';
import 'teacher_report.dart';
import 'teacher_profile.dart';
import 'nav_teacher.dart';
// DATA
import '../../../services/teacher/teacher_service.dart';
import '../../../models/user/user_model.dart';

import '../../../models/session_model.dart';
import '../../../services/session_service.dart';

import '../../../models/course_model.dart';
import '../../../services/course_service.dart';

import '../../../models/class_model.dart';
import '../../../services/class_service.dart';

class QRAttendanceNavigation extends StatefulWidget {
  const QRAttendanceNavigation({super.key});

  @override
  State<QRAttendanceNavigation> createState() => _QRAttendanceNavigationState();
}

class _QRAttendanceNavigationState extends State<QRAttendanceNavigation> {
  int _selectedIndex = 2; // Mặc định chọn tab "Điểm danh"

  static const List<Widget> _pages = <Widget>[
    TeacherHome(),
    TeacherSchedule(),
    QRAttendanceContent(),
    TeacherReport(),
    TeacherProfile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavTeacherUi(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ======================= QR CONTENT (ĐÃ ĐỔ DỮ LIỆU) =======================

class QRAttendanceContent extends StatefulWidget {
  final String? sessionId; // nếu bạn muốn truyền từ ngoài vào
  final VoidCallback? onHideQR;

  const QRAttendanceContent({super.key, this.sessionId, this.onHideQR});

  @override
  State<QRAttendanceContent> createState() => _QRAttendanceContentState();
}

class _QRAttendanceContentState extends State<QRAttendanceContent> {
  // UI state
  bool _isAttendanceActive = false; // trạng thái hiển thị switch
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Services
  final SessionService _sessionService = SessionService();
  final CourseService _courseService = CourseService();
  final ClassService _classService = ClassService();

  // Cache
  final Map<String, CourseModel?> _courseCache = {};
  final Map<String, ClassModel?> _classCache = {};

  // Helpers cho tiêu đề ngày/giờ
  String get _nowText => DateFormat('HH:mm').format(DateTime.now());

  // Lấy 1 buổi học cho hôm nay của GV: ưu tiên đang diễn ra -> sắp tới
  Widget _buildSessionSelector(BuildContext context, UserModel teacher) {
    final String lecturerKey =
        FirebaseAuth.instance.currentUser?.uid ?? teacher.id;

    return StreamBuilder<List<SessionModel>>(
      stream: _sessionService.streamSessionsForLecturerOnDate(
        lecturerKey,
        DateTime.now(),
      ),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final sessions = (snapshot.data ?? [])
          ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

        SessionModel? display;
        if (sessions.isNotEmpty) {
          display = sessions.firstWhereOrNull((s) => s.isHappeningNow);
          display ??=
              sessions.firstWhereOrNull((s) => s.startDateTime.isAfter(DateTime.now()));
        }

        if (isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('Lỗi tải lịch hôm nay: ${snapshot.error}'),
          );
        }
        if (display == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'Hôm nay chưa có buổi học nào đang diễn ra hoặc sắp tới.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Sync trạng thái switch theo session (QR còn hạn -> đang diễn ra)
        _isAttendanceActive = display.isQrValid || display.isOngoing;

        return _buildQRSection(context, teacher, display);
      },
    );
  }

  // Khối UI giữ nguyên layout: Switch trạng thái -> giờ -> QR -> chú thích -> danh sách SV (mock/tạm)
  Widget _buildQRSection(
      BuildContext context, UserModel teacher, SessionModel session) {
    return Column(
      children: [
        // Nút trạng thái điểm danh (giữ UI)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: _isAttendanceActive ? const Color(0xFFE3F2FD) : Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isAttendanceActive ? const Color(0xFF2196F3) : Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isAttendanceActive
                    ? 'Điểm danh đang diễn ra...'
                    : 'Điểm danh đã kết thúc',
                style: TextStyle(
                  color: _isAttendanceActive
                      ? const Color(0xFF2196F3)
                      : Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: _isAttendanceActive,
                onChanged: (value) async {
                  // Bật = tạo QR (valid 5 phút) + set session ongoing
                  // Tắt = không tạo QR mới, chỉ đổi UI; nếu muốn kết thúc thật sự -> cập nhật status done
                  if (value) {
                    await _startAttendance(session);
                  } else {
                    // nếu muốn kết thúc hẳn: cập nhật status về scheduled/done tùy logic
                    await _sessionService.updateSessionData(session.id, {
                      'status': SessionStatus.scheduled.name,
                      'qr_code': null,
                      'qr_expiry': null,
                    });
                  }
                  setState(() {
                    _isAttendanceActive = value;
                  });
                },
                activeThumbColor: const Color(0xFF2196F3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        FutureBuilder<_SessionDisplayInfo>(
          future: _loadDisplayInfo(session),
          builder: (context, snap) {
            final info = snap.data;
            final isLoading = snap.connectionState == ConnectionState.waiting;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  if (isLoading) ...[
                    const SizedBox(height: 12),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                  ] else ...[
                    QrImageView(
                      data: session.qrCode ?? session.generateQrData(),
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                    ),
                    if (info != null) ...[
                      if (session.isQrValid && session.qrExpiry != null) ...[
                        const SizedBox(height: 6),
                        _QrCountdownWidget(
                          expiryTime: session.qrExpiry!,
                          onExpired: () {
                            // Callback này được gọi khi đồng hồ đếm về 0
                            // Chúng ta sẽ cập nhật UI (tắt Switch) một cách an toàn
                            if (mounted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _isAttendanceActive = false;
                                  });
                                }
                              });
                            }
                          },
                        ),
                      ],
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'Sinh viên quét QR này để điểm danh',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Nút "Tạo/Refresh QR" (tuân UI đang có – bạn bật/tắt bằng switch ở trên cũng được)
                    ElevatedButton.icon(
                      onPressed: () async => _startAttendance(session),
                      icon: const Icon(Icons.qr_code),
                      label: const Text('Tạo / làm mới QR (5 phút)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Danh sách sinh viên',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),

              // Thanh tìm kiếm (giữ UI)
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sinh viên',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'Chưa kết nối danh sách sinh viên.\n'
                  'Gợi ý: lấy studentIds từ ClassModel -> load UserModel của SV -> lọc theo tìm kiếm -> hiển thị & gọi AttendanceService.upsert khi điểm danh thủ công.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Gọi khi bật switch hoặc bấm nút làm mới QR
  Future<void> _startAttendance(SessionModel session) async {
    await _sessionService.generateAndSaveQr(session.id, const Duration(minutes: 5));
    if (mounted) setState(() => _isAttendanceActive = true);
  }

  // Load tên môn & tên lớp (có cache)
  Future<_SessionDisplayInfo> _loadDisplayInfo(SessionModel session) async {
    CourseModel? course = _courseCache[session.courseId];
    if (course == null) {
      course = await _courseService.getCourseById(session.courseId);
      _courseCache[session.courseId] = course;
    }
    ClassModel? clazz = _classCache[session.classId];
    if (clazz == null) {
      clazz = await _classService.getClassById(session.classId);
      _classCache[session.classId] = clazz;
    }
    return _SessionDisplayInfo(
      courseName: course?.name ?? 'Môn học',
      className: clazz?.name ?? 'Lớp',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Header xanh (giữ nguyên)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      if (widget.onHideQR != null) widget.onHideQR!();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  ),
                  const Text(
                    'Điểm danh sinh viên',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // BODY: load giảng viên rồi chọn buổi hôm nay
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FutureBuilder<UserModel?>(
                  future: TeacherService
                      .getTeacherById(FirebaseAuth.instance.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Lỗi tải người dùng: ${snapshot.error}');
                    }
                    final user = snapshot.data;
                    if (user == null) {
                      return const Text('Không tìm thấy thông tin giảng viên.');
                    }
                    return _buildSessionSelector(context, user);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Struct hiển thị
class _SessionDisplayInfo {
  final String courseName;
  final String className;
  const _SessionDisplayInfo({required this.courseName, required this.className});
}

class _QrCountdownWidget extends StatefulWidget {
  final DateTime expiryTime;
  final VoidCallback? onExpired; // Callback khi hết giờ

  const _QrCountdownWidget({
    required this.expiryTime,
    this.onExpired,
  });

  @override
  State<_QrCountdownWidget> createState() => _QrCountdownWidgetState();
}

class _QrCountdownWidgetState extends State<_QrCountdownWidget> {
  Timer? _timer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _updateTime(); // Chạy ngay lập tức để hiển thị
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  @override
  void didUpdateWidget(covariant _QrCountdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu thời gian hết hạn thay đổi (VD: giảng viên bấm làm mới QR)
    // chúng ta cần hủy timer cũ và bắt đầu timer mới
    if (widget.expiryTime != oldWidget.expiryTime) {
      _timer?.cancel();
      _updateTime(); // Cập nhật text ngay lập tức
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _updateTime();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Rất quan trọng: hủy timer khi widget bị xóa
    super.dispose();
  }

  void _updateTime() {
    if (!mounted) return; // Nếu widget đã bị xóa, không làm gì cả

    final now = DateTime.now();
    final duration = widget.expiryTime.difference(now);

    if (duration.isNegative || duration.inSeconds < 1) {
      _timer?.cancel();
      setState(() {
        _countdownText = 'QR đã hết hạn';
      });
      // Gọi callback báo cho widget cha là đã hết hạn
      widget.onExpired?.call();
    } else {
      // Format thời gian thành "mm:ss"
      final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
      setState(() {
        _countdownText = 'QR hết hạn sau: $minutes:$seconds';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _countdownText,
      style: TextStyle(
        fontSize: 12,
        // Đổi màu nếu đã hết hạn
        color: _countdownText.contains("hết hạn")
            ? Colors.red.shade700
            : Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}