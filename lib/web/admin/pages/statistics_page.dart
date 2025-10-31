import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Thống kê hệ thống',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            _buildStatisticsCards(),
            const SizedBox(height: 24),

            // Charts Row
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildUserRoleChart()),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildSystemOverview()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildUserRoleChart(),
                      const SizedBox(height: 24),
                      _buildSystemOverview(),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 24),

            // Recent Activity Logs
            _buildActivityLogs(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final stats = [
      {
        'title': 'Tổng người dùng',
        'value': '1,250',
        'icon': Icons.people,
        'color': Colors.blue,
        'change': '+12%',
        'changeColor': Colors.green,
      },
      {
        'title': 'Số lớp học',
        'value': '45',
        'icon': Icons.class_,
        'color': Colors.green,
        'change': '+3',
        'changeColor': Colors.green,
      },
      {
        'title': 'Số khoa',
        'value': '8',
        'icon': Icons.school,
        'color': Colors.orange,
        'change': '0',
        'changeColor': Colors.grey,
      },
      {
        'title': 'Số môn học',
        'value': '120',
        'icon': Icons.book,
        'color': Colors.purple,
        'change': '+5',
        'changeColor': Colors.green,
      },
      {
        'title': 'Điểm danh hôm nay',
        'value': '2,340',
        'icon': Icons.check_circle,
        'color': Colors.teal,
        'change': '+8%',
        'changeColor': Colors.green,
      },
      {
        'title': 'Tỷ lệ có mặt',
        'value': '94.2%',
        'icon': Icons.trending_up,
        'color': Colors.red,
        'change': '+2.1%',
        'changeColor': Colors.green,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      stat['icon'] as IconData,
                      color: stat['color'] as Color,
                      size: 32,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (stat['changeColor'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        stat['change'] as String,
                        style: TextStyle(
                          color: stat['changeColor'] as Color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: stat['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserRoleChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân bố người dùng theo vai trò',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: 45,
                      title: 'Sinh viên\n45%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.green,
                      value: 30,
                      title: 'Giảng viên\n30%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: 15,
                      title: 'Quản lý\n15%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.purple,
                      value: 10,
                      title: 'Admin\n10%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan hệ thống',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildOverviewItem('Lớp học đang hoạt động', '45/45', Colors.green),
            _buildOverviewItem('Khoa', '8', Colors.blue),
            _buildOverviewItem('Môn học', '120', Colors.orange),
            _buildOverviewItem('Giảng viên', '150', Colors.purple),
            _buildOverviewItem('Sinh viên', '1,100', Colors.teal),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Trạng thái hệ thống',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildStatusItem('Database', 'Hoạt động bình thường', Colors.green),
            _buildStatusItem('API Server', 'Hoạt động bình thường', Colors.green),
            _buildStatusItem('Face Recognition', 'Hoạt động bình thường', Colors.green),
            _buildStatusItem('Backup', 'Hoàn thành 2h trước', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String service, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              service,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLogs() {
    final logs = [
      {
        'time': '14:30',
        'action': 'Nguyễn Văn A đã đăng nhập',
        'type': 'login',
        'icon': Icons.login,
        'color': Colors.blue,
      },
      {
        'time': '14:25',
        'action': 'Điểm danh lớp CNTT1 thành công',
        'type': 'attendance',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'time': '14:20',
        'action': 'Trần Thị B đã cập nhật thông tin lớp',
        'type': 'update',
        'icon': Icons.edit,
        'color': Colors.orange,
      },
      {
        'time': '14:15',
        'action': 'Hệ thống backup dữ liệu hoàn thành',
        'type': 'backup',
        'icon': Icons.backup,
        'color': Colors.purple,
      },
      {
        'time': '14:10',
        'action': 'Lê Văn C đã đăng xuất',
        'type': 'logout',
        'icon': Icons.logout,
        'color': Colors.red,
      },
      {
        'time': '14:05',
        'action': 'Cảnh báo: Lớp CNTT2 có tỷ lệ vắng cao',
        'type': 'warning',
        'icon': Icons.warning,
        'color': Colors.amber,
      },
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log hoạt động gần nhất',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...logs.map((log) => _buildLogItem(log)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (log['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              log['icon'] as IconData,
              color: log['color'] as Color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log['action'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  log['time'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
