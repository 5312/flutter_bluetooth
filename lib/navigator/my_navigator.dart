import 'package:flutter/material.dart';
import 'package:bluetooth_mini/db/my_sp.dart';
import 'package:bluetooth_mini/pages/login_page.dart';
import 'package:bluetooth_mini/pages/navigator_page.dart';
import 'package:bluetooth_mini/pages/detail_page.dart';
import 'package:bluetooth_mini/blue/bluetooth_list.dart';
import 'package:bluetooth_mini/pages/setting.dart';
import 'package:bluetooth_mini/pages/probe_monitoring.dart';
import 'package:bluetooth_mini/pages/time_out.dart';
import 'package:bluetooth_mini/pages/data.dart';
import 'package:bluetooth_mini/pages/repo.dart';
import 'package:bluetooth_mini/pages/cloud.dart';

class MyNavigator {
  static MyNavigator? _instance;

  MyNavigator._();

  // 单例模式
  static MyNavigator getInstance() {
    _instance ??= MyNavigator._();
    return _instance!;
  }

  // 路由钩子（能监听到命名路由跳转，但是手机自带的物理返回按钮不行）
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    String? routeName;
    routeName = routeBeforeHook(settings);
    return MaterialPageRoute(builder: (context) {
      /// 注意：如果路由的形式为: '/a/b/c'
      /// 那么将依次检索 '/' -> '/a' -> '/a/b' -> '/a/b/c'
      /// 所以，这里的路由命名最好避免使用 '/xxx' 形式
      switch (routeName) {
        case "login":
          return LoginPage();
        case "navigator":
          return const NavigatorPage();
        case "detail":
          return const DetailPage(id: 1);
        case "bluetoothList":
          return const FlutterBlueApp();
        case "setting":
          return const Setting();
        case "scan":
          return const Probe();
        case 'timeout':
          return const TimeOut();
        case 'data':
          return const DataTransmission();
        case 'repo':
          return const Repo();
        case 'cloud':
          return const Cloud();
        default:
          return Scaffold(
            body: Center(
              child: Text("页面不存在"),
            ),
          );
      }
    });
  }

  // 路由拦截器
  String? routeBeforeHook(RouteSettings settings) {
    final token = MySP.getToken() ?? '';
    // adaadaa
    if (token != '') {
      if (settings.name == 'login') {
        return 'navigator';
      }
      return settings.name;
    }

    return 'login';
  }
}
