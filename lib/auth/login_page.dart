import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'login_page_web.dart';
import 'login_page_mobile.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const LoginPageWeb();
    } else {
      return const LoginPageMobile();
    }
  }
}
