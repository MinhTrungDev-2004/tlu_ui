import 'package:flutter/material.dart';
import '../teacher/pages/nav_teacher.dart';
import '../teacher/pages/qr_attendance_nav.dart';
import '../../auth/login_page.dart';
import '../../web/training_department/pages/training_department_home.dart';
import '../../web/admin/pages/home_page.dart';
import '../../mobile/student/pages/student_home.dart';
import '../../web/supervisor/pages/supervisor_home.dart';

class AppRouter {
  static const String teacherRoute = '/teacher';
  static const String qrAttendanceRoute = '/qr-attendance';
  static const String loginRoute = '/login';
  static const String trainingDepartmentRoute = '/training-department';
  static const String adminRoute = '/admin';
  static const String studentRoute = '/student';
  static const String supervisorRoute = '/supervisor';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case teacherRoute:
        return MaterialPageRoute(
          builder: (_) => const TeacherNavigation(),
          settings: settings,
        );
      case qrAttendanceRoute:
        return MaterialPageRoute(
          builder: (_) => const QRAttendanceNavigation(),
          settings: settings,
        );
      case trainingDepartmentRoute:
        return MaterialPageRoute(
          builder: (_) => const TrainingDepartmentHome(),
          settings: settings,
        );
      case adminRoute:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
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
          builder: (_) => const LoginPage(),
          settings: settings,
        );
    }
  }
}
