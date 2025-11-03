import 'package:flutter/material.dart';

/// AppBar dùng chung cho toàn bộ ứng dụng
PreferredSizeWidget buildMainAppBar({
  required BuildContext context,
  required String title,
  bool showBack = true,
  List<Widget>? actions,
}) {
  return AppBar(
    backgroundColor: const Color(0xFF1470E2),
    elevation: 3,
    centerTitle: false,
    titleSpacing: 0,

    // ✅ Đặt màu trắng cho tất cả icon trong AppBar (bao gồm nút menu)
    iconTheme: const IconThemeData(color: Colors.white),

    // ✅ Nếu showBack = true → hiện nút back
    // ✅ Nếu showBack = false → hiện nút menu (3 gạch)
    leading: showBack
        ? IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          )
        : Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),

    // ✅ Tiêu đề AppBar
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // ✅ Các nút hành động bên phải (ví dụ: chuông thông báo)
    actions: actions,
  );
}
