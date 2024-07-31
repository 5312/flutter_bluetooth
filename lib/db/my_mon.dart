import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bluetooth_mini/models/employee_model.dart';

// SharedPreferences
class MyMon {
  static SharedPreferences? prefs;

  // 初始化
  static Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    return true;
  }

  //
  static List<Employee> getMon() {
    List<String>? employeeJsonList = prefs?.getStringList('probe_monitoring');
    if (employeeJsonList == null) {
      return [];
    }
    return employeeJsonList
        .map((e) => Employee.fromJson(jsonDecode(e)))
        .toList();
  }

  static Future<bool?> setMon(List<Employee> list) async {
    List<String> employeeJsonList =
        list.map((e) => jsonEncode(e.toJson())).toList();
    return await prefs?.setStringList('probe_monitoring', employeeJsonList);
  }
}
