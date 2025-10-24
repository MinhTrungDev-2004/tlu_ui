import 'package:flutter/material.dart';
import 'role_manager.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static NavigatorState? get navigator => navigatorKey.currentState;
  
  static Future<dynamic> navigateToRole(UserRole role) {
    final route = RoleManager.getRoleRoute(role);
    RoleManager.setRole(role);
    return navigator!.pushNamedAndRemoveUntil(route, (route) => false);
  }
  
  static Future<dynamic> navigateTo(String routeName) {
    return navigator!.pushNamed(routeName);
  }
  
  static Future<dynamic> navigateAndReplace(String routeName) {
    return navigator!.pushReplacementNamed(routeName);
  }
  
  static void goBack() {
    navigator!.pop();
  }
  
  static void goBackToRoot() {
    navigator!.popUntil((route) => route.isFirst);
  }
}
