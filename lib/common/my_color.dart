import 'package:flutter/material.dart';

/// 全局颜色

class MyColor {
  // 主题色
  static const MaterialColor primary = Colors.indigo;

  // 纯白色
  static const MaterialColor white =  MaterialColor(
    0xFFFFFFFF,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(0xFFFFFFFF),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );

  // Dark Mode 相关
  static  Color light_red =const Color(0xFFFF4759);
  static  Color dark_red =const Color(0xFFE03E4E);
  static  Color dark_bg =const Color(0xFF18191A);
}
