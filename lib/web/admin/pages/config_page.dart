import 'package:flutter/material.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final Map<String, dynamic> config = {
    'qrTimeout': 30,
    'maxSession': 8,
    'logRetention': 30,
    'maxFileSize': 100,
    'emailNotifications': true,
    'faceRecognitionThreshold': 0.8,
    'systemMaintenance': false,
    'debugMode': false,
  };

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
              'Cấu hình hệ thống',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // System Configuration
            _buildSystemConfig(),
            const SizedBox(height: 24),

            // Security Configuration
            _buildSecurityConfig(),
            const SizedBox(height: 24),

            // Notification Configuration
            _buildNotificationConfig(),
            const SizedBox(height: 24),

            // Save Button
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemConfig() {
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
              'Thời gian chờ QR code hết hạn (giây)',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityConfig() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cấu hình bảo mật',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildConfigItem(
              'Chế độ bảo trì',
              'Tạm dừng hệ thống để bảo trì',
              config['systemMaintenance'],
              (value) => setState(() => config['systemMaintenance'] = value),
              isSwitch: true,
            ),
            _buildConfigItem(
              'Chế độ debug',
              'Bật chế độ debug cho phát triển',
              config['debugMode'],
              (value) => setState(() => config['debugMode'] = value),
              isSwitch: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationConfig() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cấu hình thông báo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildConfigItem(
              'Thông báo email',
              'Gửi thông báo qua email',
              config['emailNotifications'],
              (value) => setState(() => config['emailNotifications'] = value),
              isSwitch: true,
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigInput(
    dynamic value,
    Function(dynamic) onChanged, {
    bool isNumber = false,
    bool isDouble = false,
    bool isSwitch = false,
  }) {
    if (isSwitch) {
      return Switch(
        value: value as bool,
        onChanged: onChanged,
        activeColor: const Color(0xFF0D47A1),
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

  Widget _buildSaveButton() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.info, color: Colors.blue),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Lưu tất cả thay đổi cấu hình để áp dụng',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _saveConfiguration,
              icon: const Icon(Icons.save),
              label: const Text('Lưu cấu hình'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _resetConfiguration,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
          ],
        ),
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
}
