import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences
class MyTime {
  static SharedPreferences? prefs;

  // 初始化
  static Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    return true;
  }

  //获取 矿区
  static String? getMine() {
    return prefs?.getString('time_mine');
  }

  // 设置矿区
  static Future<bool?> setMine(string) async {
    return await prefs?.setString('time_mine', string);
  }

  //获取 工作面
  static String? getWork() {
    return prefs?.getString('time_work');
  }

  // 设置工作面
  static Future<bool?> setWork(string) async {
    return await prefs?.setString('time_work', string);
  }

  //获取 钻厂
  static String? getFactory() {
    return prefs?.getString('time_factory');
  }

  // 设置钻厂
  static Future<bool?> setFactory(string) async {
    return await prefs?.setString('time_factory', string);
  }

  //获取 钻孔
  static String? getDirlling() {
    return prefs?.getString('time_dirlling');
  }

  // 设置钻孔
  static Future<bool?> setDirlling(string) async {
    return await prefs?.setString('time_dirlling', string);
  }

  //获取 钻孔
  static String? getMonName() {
    return prefs?.getString('time_name');
  }

  // 设置钻杆长度
  static Future<bool?> setLength(string) async {
    return await prefs?.setString('time_length', string);
  }

  // 获取钻杆长度
  static String? getLength() {
    return prefs?.getString('time_length');
  }

  // 设置钻孔
  static Future<bool?> setMonName(string) async {
    return await prefs?.setString('time_name', string);
  }

  // 设计俯仰角
  static String? getPitch() {
    return prefs?.getString('time_pitch');
  }

  // 设置设计俯仰角
  static Future<bool?> setPitch(string) async {
    return await prefs?.setString('time_pitch', string);
  }

  // 设计方位角
  static String? getHeading() {
    return prefs?.getString('time_heading');
  }

  // 设置设计方位角
  static Future<bool?> setHeading(string) async {
    return await prefs?.setString('time_heading', string);
  }
}
