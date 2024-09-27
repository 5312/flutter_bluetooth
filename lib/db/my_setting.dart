import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'interfaceDb.dart';

// SharedPreferences
class MySetting {
  static SharedPreferences? prefs;

  // 初始化
  static Future<bool> init() async {
    prefs = await SharedPreferences.getInstance();
    return true;
  }

  // 矿区
  static List<MyMine> getMine() {
    final List<String>? jsonList = prefs?.getStringList('setting_mines');
    if (jsonList != null) {
      return jsonList.map((json) => MyMine.fromJson(json)).toList();
    }
    return [];
  }

  static Future<bool?> setMine(List<MyMine> myMines) async {
    List<String> jsonList = myMines.map((item) => item.toJson()).toList();
    return await prefs?.setStringList('setting_mines', jsonList);
  }

  //-------------------
  // 工作面
  static List<MyWork> getWork() {
    final List<String>? jsonList = prefs?.getStringList('setting_works');
    if (jsonList != null) {
      return jsonList.map((json) => MyWork.fromJson(json)).toList();
    }
    return [];
  }

  static Future<bool?> setWork(List<MyWork> list) async {
    List<String> jsonList = list.map((item) => item.toJson()).toList();
    return await prefs?.setStringList('setting_works', jsonList);
  }

  // ------------------
  // 钻厂
  static List<MyFactory> getFactory() {
    final List<String>? jsonList = prefs?.getStringList('setting_factorys');
    if (jsonList != null) {
      return jsonList.map((json) => MyFactory.fromJson(json)).toList();
    }
    return [];
  }

  static Future<bool?> setFactory(List<MyFactory> list) async {
    List<String> jsonList = list.map((item) => item.toJson()).toList();
    return await prefs?.setStringList('setting_factorys', jsonList);
  }

  //--------------------
  // 钻孔
  static List<MyDrilling> getDrilling() {
    final List<String>? jsonList = prefs?.getStringList('setting_drillings');
    if (jsonList != null) {
      return jsonList.map((json) => MyDrilling.fromJson(json)).toList();
    }
    return [];
  }

  static Future<bool?> setDrilling(List<MyDrilling> list) async {
    List<String> jsonList = list.map((item) => item.toJson()).toList();
    return await prefs?.setStringList('setting_drillings', jsonList);
  }
}
