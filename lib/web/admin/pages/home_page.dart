import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
//import 'sidebar_page.dart';


const Color primaryColor = Color(0xFF0D47A1);
const Color backgroundColor = Color(0xFFF5F5F5);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Trang chủ",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // 1. Hàng thẻ thống kê
            const InfoCardGrid(),
            const SizedBox(height: 32),

            // 2. Lịch và Biểu đồ
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 700) {
                  return const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: CalendarCard()),
                      SizedBox(width: 24),
                      Expanded(flex: 2, child: AttendanceChartCard()),
                    ],
                  );
                } else {
                  return const Column(
                    children: [
                      CalendarCard(),
                      SizedBox(height: 24),
                      AttendanceChartCard(),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 32),

            // 3. Bảng xếp hạng lớp
            const TopClassTableCard(),
          ],
        ),
      ),
    );
  }
}

// ------------------ THẺ THÔNG TIN ------------------

class InfoCardGrid extends StatelessWidget {
  const InfoCardGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {
        'value': '230',
        'subtitle': 'Sinh viên đang hoạt động',
        'icon': Icons.person,
        'color': const Color(0xFF1E88E5)
      },
      {
        'value': '15 buổi',
        'subtitle': 'Số buổi học hôm nay',
        'icon': Icons.calendar_today,
        'color': const Color(0xFF43A047)
      },
      {
        'value': '1,200 lượt',
        'subtitle': 'Điểm danh thành công',
        'icon': Icons.verified,
        'color': const Color(0xFFFDD835)
      },
      {
        'value': '10',
        'subtitle': 'Cảnh báo vắng nhiều',
        'icon': Icons.warning_amber,
        'color': const Color(0xFFE53935)
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return InfoCard(
          value: item['value'] as String,
          subtitle: item['subtitle'] as String,
          icon: item['icon'] as IconData,
          iconColor: item['color'] as Color,
        );
      },
    );
  }
}

class InfoCard extends StatelessWidget {
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const InfoCard({
    super.key,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(value,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: iconColor)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                      const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ LỊCH ------------------

class CalendarCard extends StatefulWidget {
  const CalendarCard({super.key});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Lịch học hôm nay",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2026, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ BIỂU ĐỒ ------------------

class AttendanceChartCard extends StatelessWidget {
  const AttendanceChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    const present = 70.0;
    const absent = 30.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Tỷ lệ điểm danh hôm nay",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: present,
                      title: "",
                      radius: 40,
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: absent,
                      title: "",
                      radius: 40,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                _Legend(color: Colors.green, text: "Có mặt"),
                SizedBox(width: 12),
                _Legend(color: Colors.red, text: "Vắng"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}

// ------------------ BẢNG XẾP HẠNG ------------------

class TopClassTableCard extends StatelessWidget {
  const TopClassTableCard({super.key});

  static const classes = [
    {'Lớp': 'CNTT1', 'Tỷ lệ': '95%'},
    {'Lớp': 'CNTT2', 'Tỷ lệ': '90%'},
    {'Lớp': 'CNPM', 'Tỷ lệ': '88%'},
    {'Lớp': 'HTTT', 'Tỷ lệ': '85%'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Top lớp có tỷ lệ điểm danh cao",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            DataTable(
              columns: const [
                DataColumn(label: Text('Lớp')),
                DataColumn(label: Text('Tỷ lệ')),
              ],
              rows: classes
                  .map((e) => DataRow(cells: [
                DataCell(Text(e['Lớp']!)),
                DataCell(Text(e['Tỷ lệ']!)),
              ]))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
