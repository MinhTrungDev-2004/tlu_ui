import 'package:flutter/material.dart';
import '../../register_face/widgets/main_appbar.dart';
import '../../../../../models/attendance_model.dart';
import '../../../../../services/student/history_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String selectedFilter = "Tất cả";
  late Future<List<AttendanceHistory>> _historyFuture;
  late Future<Map<String, dynamic>> _statsFuture;
  final AttendanceHistoryService _service = AttendanceHistoryService();
  
  // Giả sử bạn có studentId từ auth hoặc params
  final String studentId = "student_123"; // Thay bằng studentId thực tế

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _historyFuture = _service.getStudentAttendanceHistory(studentId);
      _statsFuture = _service.getAttendanceStats(studentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: buildMainAppBar(
        context: context,
        title: "Lịch sử điểm danh",
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Thẻ thống kê chuyên cần
            _buildStatisticsCard(),

            const SizedBox(height: 16),

            // 🔹 Bộ lọc
            _buildFilterCard(),

            const SizedBox(height: 24),

            // 🔹 Danh sách lịch sử điểm danh
            _buildHistoryList(),
          ],
        ),
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Thống kê chuyên cần
  // ======================
  Widget _buildStatisticsCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildStatisticsLoading();
        }

        if (snapshot.hasError) {
          return _buildStatisticsError();
        }

        final stats = snapshot.data ?? {
          'total': 0,
          'present': 0,
          'absent': 0,
          'late': 0,
          'attendanceRate': 0.0,
        };

        final total = stats['total'] as int;
        final present = stats['present'] as int;
        final absent = stats['absent'] as int;
        final lateCount = stats['late'] as int;
        final attendanceRate = stats['attendanceRate'] as double;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Thống kê chuyên cần",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "${attendanceRate.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _getRateColor(attendanceRate),
                        ),
                      ),
                      const Text("Tỷ lệ có mặt", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "$total",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Text("Tổng buổi học", style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statusBox("Có mặt", Colors.green, present),
                  _statusBox("Muộn", Colors.amber, lateCount),
                  _statusBox("Vắng", Colors.red, absent),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thống kê chuyên cần",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          const Text(
            "Lỗi tải dữ liệu",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text("Thử lại"),
          ),
        ],
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Bộ lọc
  // ======================
  Widget _buildFilterCard() {
    final filters = ["Tất cả", "Có mặt", "Muộn", "Vắng"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.filter_list, color: Colors.black54, size: 20),
              SizedBox(width: 6),
              Text(
                "Bộ lọc",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: filters.map((filter) {
              final isSelected = selectedFilter == filter;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? const Color(0xFF1470E2) : Colors.white,
                      side: BorderSide(
                        color: isSelected ? const Color(0xFF1470E2) : Colors.grey.shade300,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() => selectedFilter = filter);
                    },
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Danh sách lịch sử
  // ======================
  Widget _buildHistoryList() {
    return FutureBuilder<List<AttendanceHistory>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingList();
        }

        if (snapshot.hasError) {
          return _buildErrorList();
        }

        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return _buildEmptyState();
        }

        // Lọc theo bộ lọc
        final filteredHistory = _filterHistory(history, selectedFilter);

        if (filteredHistory.isEmpty) {
          return _buildNoResultState();
        }

        return Column(
          children: filteredHistory.map((item) => _buildHistoryItem(item)).toList(),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return Column(
      children: List.generate(3, (index) => _buildHistoryItemShimmer()),
    );
  }

  Widget _buildErrorList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 12),
          const Text(
            "Lỗi tải lịch sử điểm danh",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text("Tải lại"),
          ),
        ],
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Item lịch sử
  // ======================
  Widget _buildHistoryItem(AttendanceHistory item) {
    // SỬA: Thêm Color cho status (tạm thời dùng logic đơn giản)
    Color getStatusColor(String statusColor) {
      switch (statusColor) {
        case 'green': return Colors.green;
        case 'orange': return Colors.orange;
        case 'red': return Colors.red;
        default: return Colors.grey;
      }
    }

    final statusColor = getStatusColor(item.statusColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          // Icon trạng thái
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Thông tin chi tiết
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.courseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.dateDisplay,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  item.timeDisplay,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Điểm danh: ${item.checkinTime}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Trạng thái
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              item.statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItemShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Trạng thái trống
  // ======================
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.history_toggle_off, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "Chưa có dữ liệu điểm danh",
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Không có kết quả cho '$selectedFilter'",
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Trạng thái
  // ======================
  Widget _statusBox(String label, Color color, int count) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ======================
  // 🔸 HELPER: Lọc dữ liệu
  // ======================
  List<AttendanceHistory> _filterHistory(List<AttendanceHistory> history, String filter) {
    switch (filter) {
      case "Có mặt":
        return history.where((item) => item.attendance.status == AttendanceStatus.present).toList();
      case "Muộn":
        return history.where((item) => item.attendance.status == AttendanceStatus.late).toList();
      case "Vắng":
        return history.where((item) => item.attendance.status == AttendanceStatus.absent).toList();
      default:
        return history;
    }
  }

  Color _getRateColor(double rate) {
    if (rate >= 80) return Colors.green;
    if (rate >= 60) return Colors.orange;
    return Colors.red;
  }

  // ======================
  // 🔸 STYLE: Card BoxDecoration
  // ======================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}