import 'package:flutter/material.dart';
import '../../../../models/session_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListClassScreen extends StatelessWidget {
  final List<SessionModel> sessions;
  final DateTime selectedDate;

  const ListClassScreen({
    super.key,
    required this.sessions,
    required this.selectedDate,
  });

  Future<String> _getLecturerName(String? lecturerId) async {
    if (lecturerId == null || lecturerId.isEmpty) return 'Chưa có giảng viên';
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(lecturerId).get();
      if (!doc.exists) return 'Không tìm thấy';
      final data = doc.data();
      return data?['name'] ?? data?['fullName'] ?? data?['displayName'] ?? 'Không rõ';
    } catch (e) {
      print('❌ Lỗi khi lấy tên giảng viên: $e');
      return 'Lỗi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedSessions = List<SessionModel>.from(sessions)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    if (sortedSessions.isEmpty) {
      return const Center(
        child: Text(
          'Hôm nay bạn không có lịch học nào.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(sortedSessions[index], index);
      },
    );
  }

  Widget _buildSessionCard(SessionModel session, int index) {
    final borderColors = [Colors.green, Colors.red, Colors.blue];
    final borderColor = borderColors[index % borderColors.length];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 2),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Môn học
            Text(
              session.courseId,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: borderColor,
              ),
            ),
            const SizedBox(height: 8),

            // Mã lớp + Ngày học
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                  icon: Icons.class_outlined,
                  text: session.classId,
                ),
                Text(
                  'Ngày ${session.dateDisplay}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Phòng học
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              text: session.room ?? 'Chưa có phòng',
            ),
            const SizedBox(height: 8),

            // Giảng viên + Giờ học
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Giảng viên
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giảng viên',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // ✅ Hiển thị tên giảng viên từ Firestore
                    FutureBuilder<String>(
                      future: _getLecturerName(session.lecturerId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Đang tải...',
                              style: TextStyle(fontSize: 14, color: Colors.black54));
                        }
                        return Text(
                          snapshot.data ?? 'Không rõ',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Giờ học
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Thời gian',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session.timeDisplay,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // ⭐ THÊM: Trạng thái buổi học
            const SizedBox(height: 8),
            _buildSessionStatus(session),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ⭐ THÊM: Hiển thị trạng thái buổi học
  Widget _buildSessionStatus(SessionModel session) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (session.status) {
      case SessionStatus.scheduled:
        statusColor = Colors.blue;
        statusText = 'Sắp diễn ra';
        statusIcon = Icons.schedule;
      case SessionStatus.ongoing:
        statusColor = Colors.green;
        statusText = 'Đang diễn ra';
        statusIcon = Icons.play_arrow;
      case SessionStatus.done:
        statusColor = Colors.grey;
        statusText = 'Đã kết thúc';
        statusIcon = Icons.check_circle;
      case SessionStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        statusIcon = Icons.cancel;
    }

    // ⭐ THÊM: Hiển thị thông báo đặc biệt
    if (session.isHappeningNow) {
      statusColor = Colors.orange;
      statusText = 'ĐANG DIỄN RA NGAY BÂY GIỜ';
      statusIcon = Icons.notifications_active;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}