import 'package:flutter/material.dart';

class BackupConfigPage extends StatefulWidget {
  const BackupConfigPage({Key? key}) : super(key: key);

  @override
  State<BackupConfigPage> createState() => _BackupConfigPageState();
}

class _BackupConfigPageState extends State<BackupConfigPage> {
  final Map<String, dynamic> config = {
    'qrTimeout': 30,
    'maxSession': 8,
    'logRetention': 30,
    'autoBackup': true,
    'backupFrequency': 'daily',
    'maxFileSize': 100,
    'emailNotifications': true,
    'faceRecognitionThreshold': 0.8,
  };

  final List<Map<String, dynamic>> backupHistory = [
    {
      'date': '2024-01-15 02:00',
      'type': 'Tự động',
      'size': '2.5 GB',
      'status': 'Thành công',
      'statusColor': Colors.green,
    },
    {
      'date': '2024-01-14 02:00',
      'type': 'Tự động',
      'size': '2.3 GB',
      'status': 'Thành công',
      'statusColor': Colors.green,
    },
    {
      'date': '2024-01-13 15:30',
      'type': 'Thủ công',
      'size': '2.4 GB',
      'status': 'Thành công',
      'statusColor': Colors.green,
    },
    {
      'date': '2024-01-12 02:00',
      'type': 'Tự động',
      'size': '2.2 GB',
      'status': 'Lỗi',
      'statusColor': Colors.red,
    },
  ];

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
              'Backup & Cấu hình hệ thống',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Backup Section
            _buildBackupSection(),
            const SizedBox(height: 24),

            // Configuration Section
            _buildConfigurationSection(),
            const SizedBox(height: 24),

            // Backup History
            _buildBackupHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý Backup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 600) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildBackupCard(
                          'Xuất dữ liệu',
                          'Tạo bản sao lưu thủ công',
                          Icons.download,
                          Colors.blue,
                          () => _exportData(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBackupCard(
                          'Phục hồi dữ liệu',
                          'Khôi phục từ bản sao lưu',
                          Icons.restore,
                          Colors.green,
                          () => _restoreData(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildBackupCard(
                          'Lên lịch Backup',
                          'Cấu hình backup tự động',
                          Icons.schedule,
                          Colors.orange,
                          () => _scheduleBackup(),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildBackupCard(
                        'Xuất dữ liệu',
                        'Tạo bản sao lưu thủ công',
                        Icons.download,
                        Colors.blue,
                        () => _exportData(),
                      ),
                      const SizedBox(height: 16),
                      _buildBackupCard(
                        'Phục hồi dữ liệu',
                        'Khôi phục từ bản sao lưu',
                        Icons.restore,
                        Colors.green,
                        () => _restoreData(),
                      ),
                      const SizedBox(height: 16),
                      _buildBackupCard(
                        'Lên lịch Backup',
                        'Cấu hình backup tự động',
                        Icons.schedule,
                        Colors.orange,
                        () => _scheduleBackup(),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Thông tin Backup:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Dung lượng hiện tại', '2.5 GB'),
            _buildInfoRow('Lần backup cuối', '2024-01-15 02:00'),
            _buildInfoRow('Tần suất backup', 'Hàng ngày'),
            _buildInfoRow('Trạng thái', 'Hoạt động bình thường'),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cấu hình hệ thống',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildConfigItem(
              'Thời gian chờ QR code hết hạn (Giây)',
              '',
              config['qrTimeout'],
              (value) => setState(() => config['qrTimeout'] = value),
              isNumber: true,
            ),
            _buildConfigItem(
              'Thời gian tối đa cho một phiên đăng nhập (giờ)',
              '',
              config['maxSession'],
              (value) => setState(() => config['maxSession'] = value),
              isNumber: true,
            ),
            _buildConfigItem(
              'Số ngày lưu trữ log hệ thống (ngày)',
              '',
              config['logRetention'],
              (value) => setState(() => config['logRetention'] = value),
              isNumber: true,
            ),
            _buildConfigItem(
              'Kích thước tối đa cho file upload (MB)',
              '',
              config['maxFileSize'],
              (value) => setState(() => config['maxFileSize'] = value),
              isNumber: true,
            ),
            _buildConfigItem(
              'Ngưỡng độ chính xác nhận diện khuôn mặt',
              '',
              config['faceRecognitionThreshold'],
              (value) => setState(() => config['faceRecognitionThreshold'] = value),
              isNumber: true,
              isDouble: true,
            ),
            _buildConfigItem(
              'Tần suất hỗ trợ tự động',
              '',
              config['backupFrequency'] = 'Ngày',
              (value) => setState(() => config['backupFrequency'] = value),
              isDropdown: true,
                options: ['Giờ', 'Ngày', 'Tuần', 'Tháng'],
            ),
            _buildConfigItem(
              'Bật/tắt hỗ trợ tự động',
              '',
              config['autoBackup'],
              (value) => setState(() => config['autoBackup'] = value),
              isSwitch: true,
            ),
            _buildConfigItem(
              'Gửi thông báo qua email',
              '',
              config['emailNotifications'],
              (value) => setState(() => config['emailNotifications'] = value),
              isSwitch: true,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 400) {
                  return Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _saveConfiguration,
                        icon: const Icon(Icons.save),
                        label: const Text('Lưu cấu hình'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _resetConfiguration,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset về mặc định'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveConfiguration,
                          icon: const Icon(Icons.save),
                          label: const Text('Lưu cấu hình'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D47A1),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _resetConfiguration,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset về mặc định'),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(
    String title,
    String subtitle,
    dynamic value,
    Function(dynamic) onChanged, {
    bool isNumber = false,
    bool isDouble = false,
    bool isSwitch = false,
    bool isDropdown = false,
    List<String>? options,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildConfigInput(
                    value,
                    onChanged,
                    isNumber: isNumber,
                    isDouble: isDouble,
                    isSwitch: isSwitch,
                    isDropdown: isDropdown,
                    options: options,
                  ),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                _buildConfigInput(
                  value,
                  onChanged,
                  isNumber: isNumber,
                  isDouble: isDouble,
                  isSwitch: isSwitch,
                  isDropdown: isDropdown,
                  options: options,
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildConfigInput(
    dynamic value,
    Function(dynamic) onChanged, {
    bool isNumber = false,
    bool isDouble = false,
    bool isSwitch = false,
    bool isDropdown = false,
    List<String>? options,
  }) {
    if (isSwitch) {
      return Switch(
        value: value as bool,
        onChanged: onChanged,
        activeColor: const Color(0xFF0D47A1),
      );
    } else if (isDropdown) {
      return DropdownButton<String>(
        value: value as String,
        isExpanded: true,
        items: options!.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      );
    } else if (isNumber || isDouble) {
      return TextFormField(
        initialValue: value.toString(),
        keyboardType: isDouble ? TextInputType.numberWithOptions(decimal: true) : TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: (val) {
          if (isDouble) {
            onChanged(double.tryParse(val) ?? 0.0);
          } else {
            onChanged(int.tryParse(val) ?? 0);
          }
        },
      );
    } else {
      return TextFormField(
        initialValue: value.toString(),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        onChanged: onChanged,
      );
    }
  }

  Widget _buildBackupHistory() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch sử Backup',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 800) {
                  // Mobile view - List cards
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: backupHistory.length,
                    itemBuilder: (context, index) {
                      final backup = backupHistory[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    backup['date'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  _buildStatusChip(backup['status'], backup['statusColor']),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Loại: ${backup['type']}'),
                              Text('Kích thước: ${backup['size']}'),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download, color: Colors.blue),
                                    onPressed: () => _downloadBackup(backup),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.restore, color: Colors.green),
                                    onPressed: () => _restoreFromBackup(backup),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteBackup(backup),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // Desktop view - DataTable
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Ngày giờ')),
                        DataColumn(label: Text('Loại')),
                        DataColumn(label: Text('Kích thước')),
                        DataColumn(label: Text('Trạng thái')),
                        DataColumn(label: Text('Hành động')),
                      ],
                      rows: backupHistory.map((backup) {
                        return DataRow(
                          cells: [
                            DataCell(Text(backup['date'])),
                            DataCell(Text(backup['type'])),
                            DataCell(Text(backup['size'])),
                            DataCell(_buildStatusChip(backup['status'], backup['statusColor'])),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download, color: Colors.blue),
                                    onPressed: () => _downloadBackup(backup),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.restore, color: Colors.green),
                                    onPressed: () => _restoreFromBackup(backup),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteBackup(backup),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  void _exportData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xuất dữ liệu'),
        content: const Text('Bạn có chắc chắn muốn tạo bản sao lưu dữ liệu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tạo bản sao lưu...')),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _restoreData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phục hồi dữ liệu'),
        content: const Text('Chọn file backup để phục hồi dữ liệu'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang phục hồi dữ liệu...')),
              );
            },
            child: const Text('Chọn file'),
          ),
        ],
      ),
    );
  }

  void _scheduleBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lên lịch Backup'),
        content: const Text('Cấu hình backup tự động sẽ được triển khai'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _saveConfiguration() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu cấu hình hệ thống')),
    );
  }

  void _resetConfiguration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset cấu hình'),
        content: const Text('Bạn có chắc chắn muốn reset về cấu hình mặc định?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã reset cấu hình về mặc định')),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _downloadBackup(Map<String, dynamic> backup) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang tải xuống backup ${backup['date']}')),
    );
  }

  void _restoreFromBackup(Map<String, dynamic> backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phục hồi từ backup'),
        content: Text('Bạn có chắc chắn muốn phục hồi từ backup ${backup['date']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đang phục hồi từ backup ${backup['date']}')),
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _deleteBackup(Map<String, dynamic> backup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa backup'),
        content: Text('Bạn có chắc chắn muốn xóa backup ${backup['date']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                backupHistory.remove(backup);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã xóa backup ${backup['date']}')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}