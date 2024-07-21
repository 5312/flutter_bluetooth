import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences
class MySP {
  static SharedPreferences? prefs;

  // 初始化
  static Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    return true;
  }

  //获取 token
  static String? getToken() {
    return prefs?.getString('token');
  }
  // 设置token
  static Future<bool?> setToken(string) async {
    return await prefs?.setString('token', string);
  }

  //获取 name
  static String? getName() {
    return prefs?.getString('name');
  }
  // 设置name
  static Future<bool?> setName(string) async {
    return await prefs?.setString('name', string);
  }
  // 删除token
  static Future<bool?> removeToken() async {
    return await prefs?.remove('token');
  }

  // Theme Mode
  static String? getThemeMode() {
    return prefs?.getString('theme-mode');
  }

  static Future<bool?> setThemeMode(string) async {
    return await prefs?.setString('theme-mode', string);
  }
}
