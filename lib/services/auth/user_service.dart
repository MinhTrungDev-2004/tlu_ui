import 'auth_service.dart';

enum UserRole {
  teacher,
  trainingDepartment,
  admin,
  student,
  supervisor,
}

class UserService {
  static UserRole? _currentUserRole;
  static Map<String, dynamic>? _currentUserData;
  // Lấy role hiện tại
  static UserRole? get currentUserRole => _currentUserRole;
  static Map<String, dynamic>? get currentUserData => _currentUserData;

  // Kiểm tra và lấy thông tin user khi đăng nhập
  static Future<UserRole?> initializeUser() async {
    final user = AuthService.currentUser;
    if (user == null) {
      _currentUserRole = null;
      _currentUserData = null;
      return null;
    }

    try {
      // Lấy thông tin user từ Firestore
      final userData = await AuthService.getUserData(user.uid);
      if (userData == null) {
        throw Exception('Không tìm thấy thông tin user');
      }
      _currentUserData = userData;
      // Xác định role từ dữ liệu Firestore
      final roleString = userData['role'] as String?;
      if (roleString == null) {
        throw Exception('User không có role được định nghĩa');
      }
      _currentUserRole = _parseRole(roleString);
      return _currentUserRole;
    } catch (e) {
      _currentUserRole = null;
      _currentUserData = null;
      return null;
    }
  }

  // role
  static UserRole _parseRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'teacher':
        return UserRole.teacher;
      case 'training_department':
        return UserRole.trainingDepartment;
      case 'admin':
        return UserRole.admin;
      case 'student':
        return UserRole.student;
      case 'supervisor':
        return UserRole.supervisor;
      default:
        throw Exception('Role không hợp lệ: $roleString');
    }
  }

  static bool get isTeacher => _currentUserRole == UserRole.teacher;
  static bool get isTrainingDepartment => _currentUserRole == UserRole.trainingDepartment;
  static bool get isAdmin => _currentUserRole == UserRole.admin;

  static String get displayName {
    if (_currentUserData == null) return 'User';
    
    final name = _currentUserData!['displayName'] as String?;
    final email = _currentUserData!['email'] as String?;
    
    return name ?? email ?? 'User';
  }

  static String get email {
    if (_currentUserData == null) return '';
    return _currentUserData!['email'] as String? ?? '';
  }

  static void clearUserData() {
    _currentUserRole = null;
    _currentUserData = null;
  }
}
