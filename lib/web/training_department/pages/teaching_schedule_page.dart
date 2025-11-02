import 'package:flutter/material.dart';

const Color kPrimaryBlue = Color(0xFF19325B);
const Color kButtonBlue = Color(0xFF1976D2); // Màu xanh dương cho nút

class TeachingScheduleManagementPage extends StatefulWidget {
  const TeachingScheduleManagementPage({super.key});

  @override
  State<TeachingScheduleManagementPage> createState() =>
      _TeachingScheduleManagementPageState();
}

class _TeachingScheduleManagementPageState
    extends State<TeachingScheduleManagementPage> {
  // Dữ liệu giả (mock data) để hiển thị
  final List<Map<String, String>> _scheduleData = [
    {
      'stt': '1',
      'ngay': '24/08/2025',
      'start': '07:00:00',
      'end': '08:00:00',
      'mon': 'Android',
      'lop': '64KTPM3',
      'phong': '302-C5'
    },
    {
      'stt': '2',
      'ngay': '25/08/2025',
      'start': '07:00:00',
      'end': '08:00:00',
      'mon': 'Android',
      'lop': '64KTPM3',
      'phong': '302-C5'
    },
    {
      'stt': '4',
      'ngay': '27/08/2025',
      'start': '07:00:00',
      'end': '08:00:00',
      'mon': 'Android',
      'lop': '64KTPM3',
      'phong': '302-C5'
    },
    {
      'stt': '5',
      'ngay': '29/08/2025',
      'start': '07:00:00',
      'end': '08:00:00',
      'mon': 'Android',
      'lop': '64KTPM3',
      'phong': '302-C5'
    },
    {
      'stt': '6',
      'ngay': '31/08/2025',
      'start': '07:00:00',
      'end': '08:00:00',
      'mon': 'Android',
      'lop': '64KTPM3',
      'phong': '302-C5'
    },
  ];

  String? _selectedLecturer = 'kieu_tuan_dung';

  // Danh sách giảng viên (giả lập)
  final List<Map<String, String>> _lecturers = const [
    {'id': 'kieu_tuan_dung', 'name': 'Kiều Tuấn Dũng'},
    {'id': 'ngo_minh_trang', 'name': 'Ngô Minh Trang'},
    {'id': 'tran_van_a', 'name': 'Trần Văn A'},
  ];

  // Danh sách dữ liệu chọn (giả lập)
  final List<String> _subjects = const [
    'Android', 'Flutter', 'Web', 'CSDL', 'Kỹ năng mềm'
  ];
  final List<String> _classes = const [
    '64KTPM1', '64KTPM2', '64KTPM3', '64KTPM4'
  ];
  final List<String> _rooms = const [
    '301-C5', '302-C5', '303-C5', '304-C5'
  ];
  final List<String> _startTimes = const [
    '07:00', '09:00', '13:30', '15:30'
  ];
  final List<String> _endTimes = const [
    '08:00', '10:00', '15:00', '17:00'
  ];

  // State chọn trong form thêm lịch
  String? _formSelectedLecturerId;
  String? _formStartTime;
  String? _formEndTime;
  String? _formSubject;
  String? _formClass;
  String? _formRoom;

  // Controller cho ngày (nhập liệu)
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Nền trắng
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 1. Tiêu đề
          _buildHeader(),
          const SizedBox(height: 20),

          // 2. Thanh Filter và Nút bấm
          _buildFilterBar(),
          const SizedBox(height: 30),

          // 3. Bảng dữ liệu (Expanded để chiếm hết không gian còn lại)
          Expanded(
            child: SingleChildScrollView(
              // Dùng SingleChildScrollView để nội dung dài có thể cuộn
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleTable(),
                  const SizedBox(height: 20),
                  _buildPagination(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget cho Tiêu đề
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý lịch giảng dạy',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Quản lý thông tin lịch giảng dạy trong Trường Đại học Thủy Lợi',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Widget cho Thanh Filter
  Widget _buildFilterBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end, // Căn các item xuống dưới
      children: [
        // Thanh Tìm kiếm
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo môn học, phòng, giảng viên, ...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0), // Bo tròn
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(color: kPrimaryBlue, width: 2),
              ),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Dropdown Giảng viên
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn giảng viên:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                ),
                value: _selectedLecturer,
                items: const [
                  DropdownMenuItem(
                      value: 'all', child: Text('Tất cả giảng viên')),
                  DropdownMenuItem(
                      value: 'kieu_tuan_dung', child: Text('Kiều Tuấn Dũng')),
                  DropdownMenuItem(
                      value: 'ngo_minh_trang', child: Text('Ngô Minh Trang')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLecturer = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(width: 20),

        // Nút Thêm lịch
        ElevatedButton.icon(
          onPressed: () {
            _openAddScheduleDialog();
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text('Thêm lịch giảng',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: kButtonBlue, // Màu xanh dương
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _openAddScheduleDialog() async {
    _formSelectedLecturerId = _lecturers.first['id'];
    _dateController.clear();
    _formStartTime = _startTimes.first;
    _formEndTime = _endTimes.first;
    _formSubject = _subjects.first;
    _formClass = _classes.first;
    _formRoom = _rooms.first;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Thêm lịch giảng dạy'),
              content: SizedBox(
                width: 600,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                    // Giảng viên
                    DropdownButtonFormField<String>(
                      value: _formSelectedLecturerId,
                      decoration: const InputDecoration(
                        labelText: 'Giảng viên',
                        border: OutlineInputBorder(),
                      ),
                      items: _lecturers
                          .map((e) => DropdownMenuItem<String>(
                                value: e['id'],
                                child: Text(e['name'] ?? ''),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          _formSelectedLecturerId = v;
                        });
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 12),

                    // Ngày học (nhập + chọn lịch)
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Ngày học (dd/MM/yyyy)',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: now,
                              firstDate: DateTime(now.year - 1),
                              lastDate: DateTime(now.year + 2),
                            );
                            if (picked != null) {
                              final d = picked.day.toString().padLeft(2, '0');
                              final m = picked.month.toString().padLeft(2, '0');
                              final y = picked.year.toString();
                              _dateController.text = '$d/$m/$y';
                            }
                          },
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                    ),
                    const SizedBox(height: 12),

                    // Thời gian bắt đầu - kết thúc (Dropdown)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _formStartTime,
                            decoration: const InputDecoration(
                              labelText: 'Bắt đầu',
                              border: OutlineInputBorder(),
                            ),
                            items: _startTimes
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) {
                              setStateDialog(() {
                                _formStartTime = v;
                              });
                            },
                            validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _formEndTime,
                            decoration: const InputDecoration(
                              labelText: 'Kết thúc',
                              border: OutlineInputBorder(),
                            ),
                            items: _endTimes
                                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) {
                              setStateDialog(() {
                                _formEndTime = v;
                              });
                            },
                            validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Môn - Lớp - Phòng (Dropdown)
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _formSubject,
                            decoration: const InputDecoration(
                              labelText: 'Môn học',
                              border: OutlineInputBorder(),
                            ),
                            items: _subjects
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) {
                              setStateDialog(() {
                                _formSubject = v;
                              });
                            },
                            validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _formClass,
                            decoration: const InputDecoration(
                              labelText: 'Lớp học',
                              border: OutlineInputBorder(),
                            ),
                            items: _classes
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) {
                              setStateDialog(() {
                                _formClass = v;
                              });
                            },
                            validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _formRoom,
                      decoration: const InputDecoration(
                        labelText: 'Phòng học',
                        border: OutlineInputBorder(),
                      ),
                      items: _rooms
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          _formRoom = v;
                        });
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Bắt buộc' : null,
                    ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) return;
                    final nextStt = (_scheduleData.length + 1).toString();
                    setState(() {
                      _scheduleData.add({
                        'stt': nextStt,
                        'ngay': _dateController.text.trim(),
                        'start': '${_formStartTime ?? ''}:00',
                        'end': '${_formEndTime ?? ''}:00',
                        'mon': _formSubject ?? '',
                        'lop': _formClass ?? '',
                        'phong': _formRoom ?? '',
                      });
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: kButtonBlue),
                  child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<String> _generateDateOptions() {
    final now = DateTime.now();
    final List<String> dates = [];
    for (int i = 0; i < 30; i++) {
      final d = now.add(Duration(days: i));
      final dd = d.day.toString().padLeft(2, '0');
      final mm = d.month.toString().padLeft(2, '0');
      final yy = d.year.toString();
      dates.add('$dd/$mm/$yy');
    }
    return dates;
  }

  // Widget cho Bảng dữ liệu
  Widget _buildScheduleTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề Bảng (Thay đổi dựa trên giảng viên được chọn)
        Text(
          _selectedLecturer == 'kieu_tuan_dung'
              ? 'Lịch giảng dạy của Kiều Tuấn Dũng'
              : 'Danh sách lịch giảng dạy',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),

        // Bảng dữ liệu
        Container(
          width: double.infinity, // Mở rộng hết chiều ngang
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            headingTextStyle:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            columns: const [
              DataColumn(label: Text('STT')),
              DataColumn(label: Text('Ngày học')),
              DataColumn(label: Text('Thời gian bắt đầu')),
              DataColumn(label: Text('Thời gian kết thúc')),
              DataColumn(label: Text('Môn học')),
              DataColumn(label: Text('Lớp học')),
              DataColumn(label: Text('Phòng học')),
              DataColumn(label: Text('Thao tác')),
            ],
            rows: _scheduleData.map((item) {
              return DataRow(
                cells: [
                  DataCell(Text(item['stt']!)),
                  DataCell(Text(item['ngay']!)),
                  DataCell(Text(item['start']!)),
                  DataCell(Text(item['end']!)),
                  DataCell(Text(item['mon']!)),
                  DataCell(Text(item['lop']!)),
                  DataCell(Text(item['phong']!)),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Colors.blue[700], size: 20),
                        onPressed: () { /* Sửa */ },
                        tooltip: 'Sửa',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Colors.red[700], size: 20),
                        onPressed: () { /* Xóa */ },
                        tooltip: 'Xóa',
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Widget cho Phân trang
  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hiển thị 1 - 5 của 100 lịch giảng dạy', // Dữ liệu giả
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        Row(
          children: [
            TextButton(onPressed: () {}, child: const Text('< Trước')),
            const SizedBox(width: 5),
            _buildPageNumberButton('1', isActive: true),
            const SizedBox(width: 5),
            _buildPageNumberButton('2'),
            const SizedBox(width: 5),
            _buildPageNumberButton('3'),
            const SizedBox(width: 5),
            TextButton(onPressed: () {}, child: const Text('Tiếp >')),
          ],
        )
      ],
    );
  }

  // Widget con cho nút số trang
  Widget _buildPageNumberButton(String text, {bool isActive = false}) {
    return SizedBox(
      width: 36,
      height: 36,
      child: isActive
          ? ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: kButtonBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.zero,
        ),
        child: Text(text),
      )
          : OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5)),
          side: BorderSide(color: Colors.grey[300]!),
          padding: EdgeInsets.zero,
        ),
        child: Text(text),
      ),
    );
  }
}