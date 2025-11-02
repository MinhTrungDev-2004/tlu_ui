import 'package:flutter/material.dart';
import '../../../models/user/user_model.dart';
import '../../../services/teacher/teacher_service.dart';

// Giữ nguyên các hằng số màu
const Color kPrimaryBlue = Color(0xFF19325B);
const Color kButtonBlue = Color(0xFF1976D2);

class TeacherManagementPage extends StatefulWidget {
  const TeacherManagementPage({super.key});

  @override
  State<TeacherManagementPage> createState() => _TeacherManagementPageState();
}

class _TeacherManagementPageState extends State<TeacherManagementPage> {
  // Danh sách giảng viên từ Firebase (UserModel với role = lecturer)
  List<UserModel> _teachers = [];
  List<UserModel> _filteredTeachers = [];
  
  // Loading state
  bool _isLoading = true;
  String? _errorMessage;
  
  // Search controller
  final TextEditingController _searchController = TextEditingController();
  
  // Form controllers
  final TextEditingController _maGvController = TextEditingController();
  final TextEditingController _tenGvController = TextEditingController();
  final TextEditingController _khoaController = TextEditingController();
  
  // Dropdown options
  final List<String> _hocHamHocViOptions = const [
    'GS',
    'PGS',
    'Tiến sĩ',
    'Thạc sĩ',
    'Cử nhân'
  ];
  String? _formHocHamHocVi;
  
  // Trạng thái chỉnh sửa
  String? _editingTeacherId; // = user.uid

  @override
  void initState() {
    super.initState();
    _loadTeachers();
    _searchController.addListener(_filterTeachers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _maGvController.dispose();
    _tenGvController.dispose();
    _khoaController.dispose();
    super.dispose();
  }

  // Load danh sách giảng viên từ Firebase (users.role == lecturer)
  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teachers = await TeacherService.getAllTeachers(); // List<UserModel>
      setState(() {
        _teachers = teachers;
        _filteredTeachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải danh sách giảng viên: $e';
        _isLoading = false;
      });
    }
  }

  // Lọc giảng viên theo từ khóa tìm kiếm
  void _filterTeachers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredTeachers = _teachers;
      });
    } else {
      setState(() {
        _filteredTeachers = _teachers.where((t) {
          final maGV = (t.maGV ?? '').toLowerCase();
          final ten = (t.name).toLowerCase();
          final email = (t.email).toLowerCase();
          return maGV.contains(query) || ten.contains(query) || email.contains(query);
        }).toList();
      });
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
          _buildHeader(),
          const SizedBox(height: 20),
          _buildFilterBar(),
          const SizedBox(height: 30),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadTeachers,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLecturerTable(),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quản lý giảng viên',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Quản lý thông tin các giảng viên trong Trường Đại Học Thủy Lợi',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo mã giảng viên, tên, email...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
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
        ElevatedButton.icon(
          onPressed: _openAddLecturerDialog,
          icon: const Icon(Icons.add, color: Colors.white, size: 18),
          label: const Text(
            'Thêm giảng viên',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: kButtonBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Future<void> _openAddLecturerDialog() async {
    _resetForm();
    _formHocHamHocVi = _hocHamHocViOptions.first;
    _editingTeacherId = null;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(_editingTeacherId == null ? 'Thêm giảng viên' : 'Sửa giảng viên'),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _maGvController,
                          decoration: const InputDecoration(
                            labelText: 'Mã giảng viên',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tenGvController,
                          decoration: const InputDecoration(
                            labelText: 'Tên giảng viên',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _khoaController,
                          decoration: const InputDecoration(
                            labelText: 'Khoa',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _formHocHamHocVi,
                          decoration: const InputDecoration(
                            labelText: 'Học hàm - học vị',
                            border: OutlineInputBorder(),
                          ),
                          items: _hocHamHocViOptions
                              .map((h) =>
                                  DropdownMenuItem(value: h, child: Text(h)))
                              .toList(),
                          onChanged: (v) {
                            setStateDialog(() {
                              _formHocHamHocVi = v;
                            });
                          },
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Bắt buộc' : null,
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
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;
                    
                    // Kiểm tra mã GV đã tồn tại chưa (trừ khi đang sửa)
                    final maGVExists = await TeacherService.checkMaGVExists(
                      _maGvController.text.trim(),
                      excludeId: _editingTeacherId,
                    );

                    if (maGVExists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mã giảng viên đã tồn tại!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Thêm hoặc cập nhật
                    try {
                      final user = UserModel(
                        uid: '', // Firestore sẽ cấp khi .add()
                        name: _tenGvController.text.trim(),
                        email: '${_maGvController.text.trim()}@dummy.local', // nếu bạn có email thật thì thay ở đây
                        role: 'lecturer',
                        maGV: _maGvController.text.trim(),
                        hocHamHocVi: _formHocHamHocVi ?? '',
                        khoa: _khoaController.text.trim(),
                      );

                      if (_editingTeacherId == null) {
                        // Thêm mới
                        await TeacherService.addTeacher(user);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thêm giảng viên thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        // Cập nhật
                        await TeacherService.updateTeacher(
                          _editingTeacherId!,
                          user.copyWith(uid: _editingTeacherId!),
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cập nhật giảng viên thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }

                      Navigator.of(context).pop();
                      _loadTeachers();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
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

  Future<void> _openEditDialog(UserModel teacher) async {
    _maGvController.text = teacher.maGV ?? '';
    _tenGvController.text = teacher.name;
    _khoaController.text = teacher.khoa ?? '';
    _formHocHamHocVi = teacher.hocHamHocVi ?? _hocHamHocViOptions.first;
    _editingTeacherId = teacher.uid;

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Sửa giảng viên'),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _maGvController,
                          decoration: const InputDecoration(
                            labelText: 'Mã giảng viên',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _tenGvController,
                          decoration: const InputDecoration(
                            labelText: 'Tên giảng viên',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _khoaController,
                          decoration: const InputDecoration(
                            labelText: 'Khoa',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Bắt buộc' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _formHocHamHocVi,
                          decoration: const InputDecoration(
                            labelText: 'Học hàm - học vị',
                            border: OutlineInputBorder(),
                          ),
                          items: _hocHamHocViOptions
                              .map((h) =>
                                  DropdownMenuItem(value: h, child: Text(h)))
                              .toList(),
                          onChanged: (v) {
                            setStateDialog(() {
                              _formHocHamHocVi = v;
                            });
                          },
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Bắt buộc' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _resetForm();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() != true) return;

                    // Kiểm tra mã GV đã tồn tại chưa
                    final maGVExists = await TeacherService.checkMaGVExists(
                      _maGvController.text.trim(),
                      excludeId: _editingTeacherId,
                    );

                    if (maGVExists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mã giảng viên đã tồn tại!'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Cập nhật
                    try {
                      final updated = UserModel(
                        uid: _editingTeacherId!,
                        name: _tenGvController.text.trim(),
                        email: teacher.email, // giữ nguyên email cũ (nếu bạn cần sửa email, thêm input riêng)
                        role: 'lecturer',
                        maGV: _maGvController.text.trim(),
                        hocHamHocVi: _formHocHamHocVi ?? '',
                        khoa: _khoaController.text.trim(),
                      );

                      await TeacherService.updateTeacher(
                          _editingTeacherId!, updated);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cập nhật giảng viên thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }

                      Navigator.of(context).pop();
                      _resetForm();
                      _loadTeachers();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
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

  Future<void> _confirmDeleteTeacher(UserModel teacher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa giảng viên "${teacher.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed == true && teacher.uid.isNotEmpty) {
      try {
        await TeacherService.deleteTeacher(teacher.uid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa giảng viên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _loadTeachers();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _resetForm() {
    _maGvController.clear();
    _tenGvController.clear();
    _khoaController.clear();
    _editingTeacherId = null;
  }

  Widget _buildLecturerTable() {
    if (_filteredTeachers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Chưa có giảng viên nào'
                  : 'Không tìm thấy kết quả',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danh sách giảng viên (${_filteredTeachers.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
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
              DataColumn(label: Text('Mã GV')),
              DataColumn(label: Text('Tên giảng viên')),
              DataColumn(label: Text('Khoa')),
              DataColumn(label: Text('Học hàm - học vị')),
              DataColumn(label: Text('Thao tác')),
            ],
            rows: _filteredTeachers.asMap().entries.map((entry) {
              final index = entry.key;
              final t = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(t.maGV ?? '')),
                  DataCell(Text(t.name)),
                  DataCell(Text(t.khoa ?? '')),
                  DataCell(Text(t.hocHamHocVi ?? '')),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue[700], size: 20),
                        onPressed: () => _openEditDialog(t),
                        tooltip: 'Sửa',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[700], size: 20),
                        onPressed: () => _confirmDeleteTeacher(t),
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

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hiển thị ${_filteredTeachers.isEmpty ? 0 : 1} - ${_filteredTeachers.length} của ${_filteredTeachers.length} giảng viên',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
