import 'package:flutter/material.dart';
import '../../register_face/widgets/main_appbar.dart'; // 🔹 IMPORT APP BAR CHUNG

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String selectedFilter = "Tất cả";

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      // 🔹 SỬ DỤNG MAIN APP BAR CHUNG
      appBar: buildMainAppBar(
        context: context,
        title: "Lịch sử điểm danh",
        showBack: true, // 🔹 HIỆN NÚT BACK
        // actions: [ // 🔹 CÓ THỂ THÊM ACTIONS NẾU CẦN
        //   IconButton(
        //     icon: const Icon(Icons.refresh),
        //     onPressed: () {},
        //   ),
        // ],
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

            // 🔹 Khu vực hiển thị danh sách (nếu có dữ liệu)
            _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Thống kê chuyên cần
  // ======================
  Widget _buildStatisticsCard() {
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
            children: const [
              Column(
                children: [
                  Text("0%", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                  Text("Tỷ lệ có mặt", style: TextStyle(fontSize: 14)),
                ],
              ),
              Column(
                children: [
                  Text("0", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                  Text("Tổng buổi học", style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statusBox("Có mặt", Colors.green, 0),
              _statusBox("Muộn", Colors.amber, 0),
              _statusBox("Vắng", Colors.red, 0),
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
        // 🔹 Hàng tiêu đề: icon + chữ "Bộ lọc"
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

        // 🔹 Hàng các nút bộ lọc
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: filters.map((filter) {
            final isSelected = selectedFilter == filter;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        isSelected ? const Color(0xFF1470E2) : Colors.white,
                    side: BorderSide(
                      color:
                          isSelected ? const Color(0xFF1470E2) : Colors.grey.shade300,
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
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  // ======================
  // 🔸 WIDGET: Trạng thái trống
  // ======================
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "Chưa có dữ liệu điểm danh.",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
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