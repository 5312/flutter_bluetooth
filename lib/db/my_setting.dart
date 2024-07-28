import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// SharedPreferences
class MySetting {
  static SharedPreferences? prefs;

  // 初始化
  static Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    return true;
  }

  // 矿区
  static List<String> getMine() {
    final String? itemsString = prefs?.getString('setting_mine');
    if (itemsString != null) {
      return List<String>.from(json.decode(itemsString));
    }
    return [];
  }

  static Future<bool?> setMine(List<String> list) async {
    return await prefs?.setString('setting_mine', json.encode(list));
  }

  // 工作面
  static List<String> getWork() {
    final String? itemsString = prefs?.getString('setting_work');
    if (itemsString != null) {
      return List<String>.from(json.decode(itemsString));
    }
    return [];
  }

  static Future<bool?> setWork(List<String> list) async {
    return await prefs?.setString('setting_work', json.encode(list));
  }
  // 钻厂
  static List<String> getFactory() {
    final String? itemsString = prefs?.getString('setting_factory');
    if (itemsString != null) {
      return List<String>.from(json.decode(itemsString));
    }
    return [];
  }

  static Future<bool?> setFactory(List<String> list) async {
    return await prefs?.setString('setting_factory', json.encode(list));
  }

  // 钻空
  static List<String> getDrilling() {
    final String? itemsString = prefs?.getString('setting_drilling');
    if (itemsString != null) {
      return List<String>.from(json.decode(itemsString));
    }
    return [];
  }

  static Future<bool?> setDrilling(List<String> list) async {
    return await prefs?.setString('setting_drilling', json.encode(list));
  }
}
