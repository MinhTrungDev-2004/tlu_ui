import 'package:flutter/material.dart';
import 'admin/pages/admin_layout.dart';
import 'admin/pages/home_page.dart';
import '../auth/login_page.dart';
import '../auth/splash_screen.dart';
import 'training_department/pages/training_department_home.dart';
import 'student/pages/student_home.dart';
import 'supervisor/pages/supervisor_home.dart';

class AppRouterWeb {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String trainingDepartmentRoute = '/training-department';
  static const String adminRoute = '/admin';
  static const String studentRoute = '/student';
  static const String supervisorRoute = '/supervisor';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case trainingDepartmentRoute:
        return MaterialPageRoute(
          builder: (_) => const TrainingDepartmentHome(),
          settings: settings,
        );
      case adminRoute:
        return MaterialPageRoute(
          builder: (_) => const AdminLayout(),
          settings: settings,
        );
      case studentRoute:
        return MaterialPageRoute(
          builder: (_) => const StudentHome(),
          settings: settings,
        );
      case supervisorRoute:
        return MaterialPageRoute(
          builder: (_) => const SupervisorHome(),
          settings: settings,
        );
      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}