// user_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static String? _currentUserId;
  static String? _currentUserEmail;
  static String? _currentUserName;
  static String? _currentUserRole;
  static bool _profileCompleted = false;
  static Map<String, dynamic>? _currentUserData;

  // Getters
  static String? get currentUserId => _currentUserId;
  static String? get currentUserEmail => _currentUserEmail;
  static String? get currentUserName => _currentUserName;
  static String? get currentUserRole => _currentUserRole;
  static bool get isProfileCompleted => _profileCompleted;
  static bool get isLoggedIn => _currentUserId != null;
  static Map<String, dynamic>? get currentUserData => _currentUserData;

  // Role checking methods
  static bool get isAdmin => _currentUserRole == 'admin';
  static bool get isStudent => _currentUserRole == 'student';
  static bool get isLecturer => _currentUserRole == 'lecturer';
  static bool get isFacultyManager => _currentUserRole == 'faculty_manager';
  static bool get isAcademicAffairs => _currentUserRole == 'academic_affairs';
  static bool get isSupervisor => _currentUserRole == 'supervisor';

  // Login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // 1. Firebase Authentication
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'error': 'Đăng nhập thất bại'};
      }

      // 2. Get user data from Firestore
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        await auth.signOut();
        return {'success': false, 'error': 'Tài khoản không tồn tại trong hệ thống'};
      }

      final userData = userDoc.data()!;

      // 3. Check account status
      if (userData['status'] == 'Tạm khóa') {
        await auth.signOut();
        return {'success': false, 'error': 'Tài khoản đã bị khóa'};
      }

      // 4. Update user info
      _currentUserId = user.uid;
      _currentUserEmail = user.email;
      _currentUserName = userData['name'];
      _currentUserRole = userData['role'];
      _profileCompleted = userData['profileCompleted'] ?? false;
      _currentUserData = userData;

      // 5. Update last login
      await firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      print('✅ Login successful - Role: $_currentUserRole, Profile Completed: $_profileCompleted');

      return {
        'success': true,
        'user': userData,
        'profileCompleted': _profileCompleted,
      };

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đăng nhập thất bại!';
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Email không tồn tại!';
          break;
        case 'wrong-password':
          errorMessage = 'Sai mật khẩu!';
          break;
        case 'user-disabled':
          errorMessage = 'Tài khoản đã bị vô hiệu hóa!';
          break;
        default:
          errorMessage = 'Lỗi: ${e.message}';
      }
      return {'success': false, 'error': errorMessage};
    } catch (e) {
      return {'success': false, 'error': 'Lỗi hệ thống: $e'};
    }
  }

  // Logout method
  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    _currentUserId = null;
    _currentUserEmail = null;
    _currentUserName = null;
    _currentUserRole = null;
    _profileCompleted = false;
    _currentUserData = null;
  }

  // Initialize user from cache
  static Future<void> initializeUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          _currentUserId = user.uid;
          _currentUserEmail = user.email;
          _currentUserName = userData['name'];
          _currentUserRole = userData['role'];
          _profileCompleted = userData['profileCompleted'] ?? false;
          _currentUserData = userData;
        }
      }
    } catch (e) {
      print('Error initializing user: $e');
    }
  }

  // Check access permission
  static bool hasAccess(List<String> allowedRoles) {
    if (_currentUserRole == null) return false;
    return allowedRoles.contains(_currentUserRole);
  }

  // Get home route based on role
  static String getHomeRoute() {
    if (_currentUserRole == null) return '/login';

    if (!_profileCompleted) {
      return '/profile'; // Force profile completion
    }

    switch (_currentUserRole) {
      case 'admin':
        return '/admin';
      case 'student':
        return '/student';
      case 'lecturer':
        return '/lecturer';
      case 'faculty_manager':
        return '/faculty-manager';
      case 'academic_affairs':
        return '/academic-affairs';
      case 'supervisor':
        return '/supervisor';
      default:
        return '/login';
    }
  }
}