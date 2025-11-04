import 'package:flutter/material.dart';
import '../teacher/pages/nav_teacher.dart';
import '../teacher/pages/qr_attendance_nav.dart';
import '../../auth/login_page.dart';
import '../../auth/splash_screen.dart';
import '../../web/training_department/pages/training_department_home.dart';
import '../../web/admin/pages/home_page.dart';
import '../../mobile/student/pages/home_page/home_screen.dart';
import '../../web/supervisor/pages/supervisor_home.dart';
import '../student/pages/register_face/register_face_screen.dart'; // 🔹 THÊM IMPORT

class AppRouter {
  static const String splashRoute = '/';
  static const String teacherRoute = '/teacher';
  static const String qrAttendanceRoute = '/qr-attendance';
  static const String loginRoute = '/login';
  static const String trainingDepartmentRoute = '/training-department';
  static const String adminRoute = '/admin';
  static const String studentRoute = '/student';
  static const String supervisorRoute = '/supervisor';
  static const String faceRegistrationRoute = '/face-registration'; // 🔹 THÊM ROUTE MỚI

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
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
          builder: (_) => const HomeScreen(),
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
      case faceRegistrationRoute: // 🔹 THÊM CASE MỚI
        final studentId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => RegisterFaceScreen(userId: studentId),
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