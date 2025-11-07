import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final AttendanceHistoryService _service = AttendanceHistoryService();
  
  // 🔥 SỬA HOÀN TOÀN: State management đơn giản
  String? _studentId;
  bool _isLoading = true;
  bool _hasError = false;
  List<AttendanceHistory> _historyData = [];
  Map<String, dynamic> _statsData = {
    'total': 0,
    'present': 0,
    'absent': 0,
    'late': 0,
    'attendanceRate': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      print('🎬 INIT: Initializing attendance history screen');
      
      // 1. Lấy user từ Firebase Auth
      final User? user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print('❌ No user logged in');
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      _studentId = user.uid;
      print('✅ User found: $_studentId');

      // 2. Load data
      await _loadData();
      
    } catch (e) {
      print('💥 Error initializing: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadData() async {
    if (_studentId == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('🔄 Loading attendance data...');
      
      // 🔥 SỬA: Dùng await để đảm bảo load xong mới update UI
      final history = await _service.getStudentAttendanceHistory(_studentId!);
      final stats = await _service.getAttendanceStats(_studentId!);
      
      print('✅ Data loaded successfully: ${history.length} items');
      
      setState(() {
        _historyData = history;
        _statsData = stats;
        _isLoading = false;
        _hasError = false;
      });
      
    } catch (e) {
      print('💥 Error loading data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  Future<void> _refreshData() async {
    await _loadData();
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 🔥 SỬA: Logic hiển thị đơn giản
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_studentId == null) {
      return _buildNoUserState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatisticsCard(),
          const SizedBox(height: 16),
          _buildFilterCard(),
          const SizedBox(height: 24),
          _buildHistoryList(),
        ],
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Thống kê chuyên cần
  // ======================
  Widget _buildStatisticsCard() {
    final total = _statsData['total'] as int;
    final present = _statsData['present'] as int;
    final absent = _statsData['absent'] as int;
    final lateCount = _statsData['late'] as int;
    final attendanceRate = _statsData['attendanceRate'] as double;

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
                    onPressed: () => _onFilterChanged(filter),
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
    if (_historyData.isEmpty) {
      return _buildEmptyState();
    }

    final filteredHistory = _filterHistory(_historyData, selectedFilter);

    if (filteredHistory.isEmpty) {
      return _buildNoResultState();
    }

    return Column(
      children: filteredHistory.map((item) => _buildHistoryItem(item)).toList(),
    );
  }

  // ======================
  // 🔸 WIDGET: Item lịch sử
  // ======================
  Widget _buildHistoryItem(AttendanceHistory item) {
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
                    color: const Color.fromARGB(255, 82, 134, 255),
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

  // ======================
  // 🔸 WIDGET: Các trạng thái
  // ======================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải lịch sử điểm danh...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Lỗi tải dữ liệu',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoUserState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy thông tin người dùng',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeData,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

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
  // 🔸 HELPER METHODS
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