import 'package:bluetooth_mini/models/time_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  // 设置钻孔
  static Future<bool?> setMonName(string) async {
    return await prefs?.setString('time_name', string);
  }

  // 数据
  static List<TimeModel> getTimeData() {
    List<String>? employeeJsonList = prefs?.getStringList('probe_monitoring');
    if (employeeJsonList == null) {
      return [];
    }
    return employeeJsonList
        .map((e) => TimeModel.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<bool?> setTimeData(List<TimeModel> list) async {
    List<String> employeeJsonList =
        list.map((e) => jsonEncode(e.toJson())).toList();
    return await prefs?.setStringList('probe_monitoring', employeeJsonList);
  }
}
