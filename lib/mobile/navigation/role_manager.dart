import 'app_router.dart';

enum UserRole {
  teacher,
  guest,
}

class RoleManager {
  static UserRole _currentRole = UserRole.guest;
  
  static UserRole get currentRole => _currentRole;
  
  static void setRole(UserRole role) {
    _currentRole = role;
  }
  
  static String getRoleRoute(UserRole role) {
    switch (role) {
      case UserRole.teacher:
        return AppRouter.teacherRoute;
      case UserRole.guest:
        return AppRouter.loginRoute;
    }
  }
  
  static bool canAccessRoute(String route, UserRole role) {
    switch (route) {
      case AppRouter.teacherRoute:
        return role == UserRole.teacher;
      case AppRouter.loginRoute:
        return true;
      default:
        return false;
    }
  }
}
