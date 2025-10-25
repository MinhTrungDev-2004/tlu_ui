import 'app_router.dart';

enum UserRole {
  teacher,
  guest,
  student,
  admin,
  supervisor,
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
      case UserRole.student:
        return AppRouter.studentRoute;
      case UserRole.supervisor:
        return AppRouter.supervisorRoute;
      case UserRole.admin:
        return AppRouter.adminRoute;
      case UserRole.guest:
        return AppRouter.loginRoute;
    }
  }
  
  static bool canAccessRoute(String route, UserRole role) {
    switch (route) {
      case AppRouter.teacherRoute:
        return role == UserRole.teacher;
      case AppRouter.studentRoute:
        return role == UserRole.student;
      case AppRouter.adminRoute:
        return role == UserRole.admin;
      case AppRouter.supervisorRoute:
        return role == UserRole.supervisor;
      case AppRouter.loginRoute:
        return true;
      default:
        return false;
    }
  }
}
