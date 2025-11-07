import 'package:flutter/material.dart';
import '../../../models/class_model.dart';
import '../../../services/class_service.dart';
import '../../../services/teacher/teacher_service.dart';
import '../../../models/user/user_model.dart';

const Color kPrimaryBlue = Color(0xFF19325B);

// Widget chính của trang
class ClassManagementPage extends StatefulWidget {
  const ClassManagementPage({super.key});

  @override
  State<ClassManagementPage> createState() => _ClassManagementPageState();
}

class _ClassManagementPageState extends State<ClassManagementPage> {
  final ClassService _classService = ClassService();
  final TextEditingController _searchController = TextEditingController();
  
  // Cache để lưu tên khoa và tên GVCN
  final Map<String, String> _departmentNames = {
    'CNTT': 'Khoa Công nghệ thông tin',
    'XD': 'Khoa Kỹ thuật Xây dựng',
    'CK': 'Khoa Cơ khí',
    'TNN': 'Khoa Tài nguyên nước',
  };
  
  final Map<String, String> _teacherNames = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {}); // Trigger rebuild để filter lại danh sách
    });
    _loadTeacherNames();
  }

  // Load danh sách teachers để cache tên
  Future<void> _loadTeacherNames() async {
    try {
      final teachers = await TeacherService.getAllTeachers();
      setState(() {
        for (var teacher in teachers) {
          _teacherNames[teacher.uid] = teacher.name;
        }
      });
    } catch (e) {
      print('[ClassManagementPage] Lỗi khi load danh sách giảng viên: $e');
    }
  }

  // Helper để lấy tên khoa từ ID
  String _getDepartmentName(String? departmentId) {
    if (departmentId == null || departmentId.isEmpty) return '--';
    return _departmentNames[departmentId] ?? departmentId;
  }

  // Helper để lấy tên GVCN từ ID
  String _getTeacherName(String? teacherId) {
    if (teacherId == null || teacherId.isEmpty) return '--';
    return _teacherNames[teacherId] ?? teacherId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Hàm xử lý các hành động
  Future<void> _addClass() async {
    await _showAddClassDialog();
  }

  Future<void> _editClass(ClassModel classModel) async {
    await _showEditClassDialog(classModel);
  }

  Future<void> _showEditClassDialog(ClassModel classModel) async {
    // Danh sách khoa mẫu (có thể thay thế bằng service thực tế sau)
    final departments = [
      {'id': 'CNTT', 'name': 'Khoa Công nghệ thông tin'},
      {'id': 'XD', 'name': 'Khoa Kỹ thuật Xây dựng'},
      {'id': 'CK', 'name': 'Khoa Cơ khí'},
      {'id': 'TNN', 'name': 'Khoa Tài nguyên nước'},
    ];

    await showDialog(
      context: context,
      builder: (context) => _EditClassDialog(
        classModel: classModel,
        departments: departments,
        onSave: (name, departmentId, headTeacherId) async {
          try {
            // Cập nhật lớp học thông qua ClassService
            await _classService.updateClassData(classModel.id, {
              'name': name.trim(),
              'department_id': (departmentId != null && departmentId.isNotEmpty) ? departmentId : null,
              'head_teacher_id': (headTeacherId != null && headTeacherId.isNotEmpty) ? headTeacherId : null,
            });

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã cập nhật lớp học thành công'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('[ClassManagementPage] Lỗi khi cập nhật lớp học: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi khi cập nhật lớp: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deleteClass(ClassModel classModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa lớp "${classModel.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _classService.setActive(classModel.id, false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã vô hiệu hóa lớp học')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa lớp: $e')),
          );
        }
      }
    }
  }

  Future<void> _showAddClassDialog() async {
    // Danh sách khoa mẫu (có thể thay thế bằng service thực tế sau)
    final departments = [
      {'id': 'CNTT', 'name': 'Khoa Công nghệ thông tin'},
      {'id': 'XD', 'name': 'Khoa Kỹ thuật Xây dựng'},
      {'id': 'CK', 'name': 'Khoa Cơ khí'},
      {'id': 'TNN', 'name': 'Khoa Tài nguyên nước'},
    ];

    await showDialog(
      context: context,
      builder: (context) => _AddClassDialog(
        departments: departments,
        onSave: (name, departmentId, headTeacherId) async {
          try {
            // Tạo ClassModel mới - ID sẽ được Firestore tự động tạo khi gọi createClass()
            // ClassService sẽ kết nối đến collection 'classes' trong Firestore
            final newClass = ClassModel(
              id: '', // ID tạm thời, sẽ được Firestore tự động tạo mới
              name: name.trim(),
              departmentId: (departmentId != null && departmentId.isNotEmpty) ? departmentId : null,
              headTeacherId: (headTeacherId != null && headTeacherId.isNotEmpty) ? headTeacherId : null,
              courseIds: null, // Có thể thêm môn học sau
              studentIds: null, // Có thể thêm sinh viên sau
              sessionIds: null, // Có thể thêm buổi học sau
              isActive: true,
            );

            // Gọi ClassService.createClass() để lưu vào collection 'classes'
            // Method này sẽ:
            // 1. Tự động set created_at và updated_at
            // 2. Sử dụng _classesRef.add() để tạo document mới với ID tự động
            // 3. Trả về ID của document vừa tạo
            final createdId = await _classService.createClass(newClass);
            
            print('[ClassManagementPage] Đã tạo lớp học mới với ID: $createdId');

            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã thêm lớp học thành công vào collection classes'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            print('[ClassManagementPage] Lỗi khi thêm lớp học: $e');
            if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Lỗi khi thêm lớp: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  // Giao diện (Build method)
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- Hàng Tiêu đề và Nút "Thêm mới" ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý lớp học',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: kPrimaryBlue,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: _addClass,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Thêm lớp học',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- Ô tìm kiếm ---
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm lớp học...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          // --- Bảng Dữ liệu (DataTable) với StreamBuilder ---
          Expanded(
            child: StreamBuilder<List<ClassModel>>(
              stream: _classService.streamClasses(isActive: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Lỗi: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                final classes = snapshot.data ?? [];
                final searchQuery = _searchController.text.trim().toLowerCase();
                final filteredClasses = searchQuery.isEmpty
                    ? classes
                    : classes.where((cls) {
                        return cls.name.toLowerCase().contains(searchQuery) ||
                            (cls.departmentId ?? '')
                                .toLowerCase()
                                .contains(searchQuery);
                      }).toList();

                if (filteredClasses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.class_,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty
                              ? 'Chưa có lớp học nào'
                              : 'Không tìm thấy lớp học',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey),
                        ),
                        if (searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Hãy thêm lớp học mới bằng nút "Thêm lớp học"',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                          kPrimaryBlue.withOpacity(0.1)),
                  columns: const [
                    DataColumn(
                            label: Text('Tên lớp',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                            label: Text('Khoa',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('GVCN',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Sĩ số',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                            label: Text('Môn học',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(
                        label: Text('Hành động',
                            style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                      rows: filteredClasses.map((cls) {
                    return DataRow(
                      cells: [
                            DataCell(Text(cls.name)),
                            DataCell(Text(_getDepartmentName(cls.departmentId))),
                            DataCell(Text(_getTeacherName(cls.headTeacherId))),
                        DataCell(Text(cls.studentCount.toString())),
                            DataCell(Text(cls.courseCount.toString())),
                        DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue, size: 20),
                              onPressed: () => _editClass(cls),
                              tooltip: 'Sửa',
                            ),
                            IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                              onPressed: () => _deleteClass(cls),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog để thêm lớp học mới
class _AddClassDialog extends StatefulWidget {
  final List<Map<String, String>> departments;
  final Future<void> Function(String name, String? departmentId, String? headTeacherId) onSave;

  const _AddClassDialog({
    required this.departments,
    required this.onSave,
  });

  @override
  State<_AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<_AddClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? selectedDepartmentId;
  String? selectedHeadTeacherId;
  List<UserModel> teachers = [];
  bool isLoadingTeachers = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    try {
      final loadedTeachers = await TeacherService.getAllTeachers();
      if (mounted) {
        setState(() {
          teachers = loadedTeachers;
          isLoadingTeachers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingTeachers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách giảng viên: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSaving = true);

      try {
        final newClass = ClassModel(
          id: '', // Firestore sẽ tự sinh ID
          name: _nameController.text.trim(),
          departmentId: selectedDepartmentId, // Nếu có chọn khoa
            headTeacherId: selectedHeadTeacherId,
        );

        await ClassService().createClass(newClass);

        // ✅ Đóng dialog, quay lại danh sách
        if (mounted) Navigator.of(context).pop();

        // ❌ KHÔNG cần setState hay reload thủ công,
        // vì StreamBuilder sẽ tự cập nhật danh sách
      } catch (e) {
        print('Lỗi khi thêm lớp: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể thêm lớp.')),
        );
      } finally {
        if (mounted) setState(() => isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm lớp học mới'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên lớp *',
                    hintText: 'Ví dụ: CNTT-01 K62',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên lớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDepartmentId,
                  decoration: const InputDecoration(
                    labelText: 'Khoa',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('-- Chọn khoa --'),
                    ),
                    ...widget.departments.map((dept) => DropdownMenuItem<String>(
                          value: dept['id'] as String,
                          child: Text(dept['name'] as String),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDepartmentId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                isLoadingTeachers
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      )
                    : DropdownButtonFormField<String>(
                        value: selectedHeadTeacherId,
                        decoration: const InputDecoration(
                          labelText: 'Giảng viên chủ nhiệm',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('-- Chọn GVCN (tùy chọn) --'),
                          ),
                          ...teachers.map((teacher) => DropdownMenuItem<String>(
                                value: teacher.uid,
                                child: Text(teacher.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedHeadTeacherId = value;
                          });
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Thêm'),
        ),
      ],
    );
  }
}

// Dialog để sửa lớp học
class _EditClassDialog extends StatefulWidget {
  final ClassModel classModel;
  final List<Map<String, String>> departments;
  final Future<void> Function(String name, String? departmentId, String? headTeacherId) onSave;

  const _EditClassDialog({
    required this.classModel,
    required this.departments,
    required this.onSave,
  });

  @override
  State<_EditClassDialog> createState() => _EditClassDialogState();
}

class _EditClassDialogState extends State<_EditClassDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String? selectedDepartmentId;
  String? selectedHeadTeacherId;
  List<UserModel> teachers = [];
  bool isLoadingTeachers = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form với dữ liệu hiện tại
    _nameController = TextEditingController(text: widget.classModel.name);
    selectedDepartmentId = widget.classModel.departmentId;
    selectedHeadTeacherId = widget.classModel.headTeacherId;
    _loadTeachers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    try {
      final loadedTeachers = await TeacherService.getAllTeachers();
      if (mounted) {
        setState(() {
          teachers = loadedTeachers;
          isLoadingTeachers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingTeachers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách giảng viên: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSaving = true;
      });

      try {
        await widget.onSave(
          _nameController.text,
          selectedDepartmentId,
          selectedHeadTeacherId,
        );
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi cập nhật lớp: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sửa lớp học'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên lớp *',
                    hintText: 'Ví dụ: CNTT-01 K62',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên lớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDepartmentId,
                  decoration: const InputDecoration(
                    labelText: 'Khoa',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('-- Chọn khoa --'),
                    ),
                    ...widget.departments.map((dept) => DropdownMenuItem<String>(
                          value: dept['id'] as String,
                          child: Text(dept['name'] as String),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDepartmentId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                isLoadingTeachers
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      )
                    : DropdownButtonFormField<String>(
                        value: selectedHeadTeacherId,
                        decoration: const InputDecoration(
                          labelText: 'Giảng viên chủ nhiệm',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('-- Chọn GVCN (tùy chọn) --'),
                          ),
                          ...teachers.map((teacher) => DropdownMenuItem<String>(
                                value: teacher.uid,
                                child: Text(teacher.name),
                              )),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedHeadTeacherId = value;
                          });
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryBlue,
            foregroundColor: Colors.white,
          ),
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Cập nhật'),
        ),
      ],
    );
  }
}