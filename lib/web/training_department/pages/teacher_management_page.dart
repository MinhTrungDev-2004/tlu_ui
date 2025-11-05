import 'package:flutter/material.dart';
import '../../../models/user/user_model.dart';
import '../../../services/teacher/teacher_service.dart';

// Màu sắc
const Color kPrimaryBlue = Color(0xFF19325B);
const Color kButtonBlue = Color(0xFF1976D2);
const Color kDangerRed = Color(0xFFD32F2F);

class TeacherManagementPage extends StatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  State<TeacherManagementPage> createState() => _TeacherManagementPageState();
}

class _TeacherManagementPageState extends State<TeacherManagementPage> {
  List<UserModel> _teachers = [];
  List<UserModel> _filteredTeachers = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tenGvController = TextEditingController();
  final TextEditingController _khoaController = TextEditingController();

  final List<String> _hocHamHocViOptions = const [
    'GS', 'PGS', 'Tiến sĩ', 'Thạc sĩ', 'Cử nhân'
  ];
  String? _formHocHamHocVi;
  String? _editingTeacherId;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
    _searchController.addListener(_filterTeachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tenGvController.dispose();
    _khoaController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final teachers = await TeacherService.getAllTeachers();
      setState(() {
        _teachers = teachers;
        _filteredTeachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải danh sách: $e';
        _isLoading = false;
      });
    }
  }

  void _filterTeachers() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredTeachers = query.isEmpty
          ? _teachers
          : _teachers.where((t) {
              final code = (t.lecturerCode ?? '').toLowerCase();
              final name = t.name.toLowerCase();
              final email = t.email.toLowerCase();
              return code.contains(query) || name.contains(query) || email.contains(query);
            }).toList();
    });
  }

  void _resetForm() {
    _tenGvController.clear();
    _khoaController.clear();
    _formHocHamHocVi = null;
    _editingTeacherId = null;
  }

  // ==================== SỬA GIẢNG VIÊN ====================
  Future<void> _openEditDialog(UserModel teacher) async {
    _tenGvController.text = teacher.name;
    _khoaController.text = teacher.faculty ?? ''; // 🔹 SỬA: khoa → faculty

    // SỬA LỖI: Đảm bảo value luôn có trong danh sách
    final savedHocVi = teacher.academicTitle; // 🔹 SỬA: hocHamHocVi → academicTitle
    _formHocHamHocVi = _hocHamHocViOptions.contains(savedHocVi)
        ? savedHocVi
        : _hocHamHocViOptions.first;

    _editingTeacherId = teacher.uid;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit, color: kButtonBlue),
              const SizedBox(width: 8),
              const Text('Sửa giảng viên', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _tenGvController,
                    decoration: InputDecoration(
                      labelText: 'Tên giảng viên',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (v) => v?.trim().isEmpty == true ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _khoaController,
                    decoration: InputDecoration(
                      labelText: 'Khoa',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    validator: (v) => v?.trim().isEmpty == true ? 'Bắt buộc' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _formHocHamHocVi,
                    decoration: InputDecoration(
                      labelText: 'Học hàm - học vị',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.school),
                    ),
                    items: _hocHamHocViOptions
                        .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                        .toList(),
                    onChanged: (v) => setState(() => _formHocHamHocVi = v),
                    validator: (v) => v == null ? 'Bắt buộc' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _resetForm();
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final updated = teacher.copyWith(
                  name: _tenGvController.text.trim(),
                  faculty: _khoaController.text.trim(), // 🔹 SỬA: khoa → faculty
                  academicTitle: _formHocHamHocVi, // 🔹 SỬA: hocHamHocVi → academicTitle
                );

                try {
                  await TeacherService.updateTeacher(_editingTeacherId!, updated);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật thành công!'), backgroundColor: Colors.green),
                    );
                  }
                  Navigator.pop(context);
                  _resetForm();
                  _loadTeachers();
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Lưu'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kButtonBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== XÓA GIẢNG VIÊN ====================
  Future<void> _confirmDelete(UserModel teacher) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: kDangerRed),
            const SizedBox(width: 8),
            const Text('Xác nhận xóa'),
          ],
        ),
        content: Text('Xóa giảng viên:\n${teacher.name} (${teacher.lecturerCode})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: kDangerRed),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await TeacherService.deleteTeacher(teacher.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa thành công!'), backgroundColor: Colors.green),
        );
      }
      _loadTeachers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quản lý giảng viên', style: TextStyle(color: kPrimaryBlue, fontWeight: FontWeight.bold, fontSize: 20)),
            Text(
              'Quản lý thông tin các giảng viên trong Trường Đại Học Thủy Lợi',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.grey),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tìm kiếm + Thêm
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo mã giảng viên hoặc tên...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: kButtonBlue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 32),

            // Tiêu đề bảng
            Text(
              'Danh sách giảng viên',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryBlue),
            ),
            const SizedBox(height: 12),

            // Bảng
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _buildDataTable(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadTeachers,
            icon: const Icon(Icons.refresh),
            label: const Text('Tải lại'),
            style: ElevatedButton.styleFrom(backgroundColor: kButtonBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (_filteredTeachers.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isEmpty ? 'Chưa có giảng viên nào' : 'Không tìm thấy kết quả',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  headingRowHeight: 56,
                  dataRowHeight: 64,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kPrimaryBlue,
                    fontSize: 14,
                  ),
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(label: Text('STT'), numeric: true),
                    DataColumn(label: Text('Mã GV')),
                    DataColumn(label: Text('Tên giảng viên')),
                    DataColumn(label: Text('Khoa')),
                    DataColumn(label: Text('Học hàm - học vị')),
                    DataColumn(label: Text('Thao tác')),
                  ],
                  rows: _filteredTeachers.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final t = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text('$index', style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(t.lecturerCode ?? '-', style: const TextStyle(fontWeight: FontWeight.w500))),
                        DataCell(Text(t.name, style: const TextStyle(fontSize: 14))),
                        DataCell(Text(t.faculty ?? '-', style: const TextStyle(fontSize: 14))), // 🔹 SỬA: khoa → faculty
                        DataCell(Text(t.academicTitle ?? '-', style: const TextStyle(fontSize: 14))), // 🔹 SỬA: hocHamHocVi → academicTitle
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                                onPressed: () => _openEditDialog(t),
                                tooltip: 'Sửa',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: kDangerRed, size: 18),
                                onPressed: () => _confirmDelete(t),
                                tooltip: 'Xóa',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}