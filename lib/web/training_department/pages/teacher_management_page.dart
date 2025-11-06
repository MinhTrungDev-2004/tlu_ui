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
    _khoaController.text = teacher.faculty ?? '';

    final savedHocVi = teacher.academicTitle;
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
                  faculty: _khoaController.text.trim(),
                  academicTitle: _formHocHamHocVi,
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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- Hàng Tiêu đề ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý giảng viên',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
                    ),
              ),
              // Đã bỏ nút "Thêm giảng viên"
            ],
          ),
          const SizedBox(height: 20),

          // --- Thanh tìm kiếm ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo mã giảng viên hoặc tên...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: kButtonBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // --- Bảng Dữ liệu (DataTable) ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : _buildDataTable(),
          ),
        ],
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

    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          headingRowColor:
              MaterialStateProperty.all(kPrimaryBlue.withOpacity(0.1)),
          columns: const [
            DataColumn(
                label: Text('STT',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Mã GV',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Tên giảng viên',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Khoa',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Học hàm',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Hành động',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: _filteredTeachers.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final t = entry.value;
            return DataRow(
              cells: [
                DataCell(Text('$index')),
                DataCell(Text(t.lecturerCode ?? '-')),
                DataCell(Text(t.name)),
                DataCell(Text(t.faculty ?? '-')),
                DataCell(
                  Chip(
                    label: Text(
                      t.academicTitle ?? '-',
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide.none,
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                  ),
                ),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _openEditDialog(t),
                      tooltip: 'Sửa',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(t),
                      tooltip: 'Xóa',
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}