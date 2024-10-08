import 'package:bluetooth_mini/db/my_setting.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bluetooth_mini/db/my_sp.dart';
import 'package:bluetooth_mini/db/my_time.dart';

/// 全局初始化数据

class MyInit {
  static Future<dynamic> init() async {
    // 初始化 SharedPreferences
    await MySP.init();
    await MySetting.init();
    await MyTime.init();

    // 配置 EasyLoading 单例
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      // 期间是否允许用户操作
      ..userInteractions = false
      // 点击背景是否关闭
      ..dismissOnTap = false
      // 遮蔽层
      ..maskType = EasyLoadingMaskType.black
      // Toast 出现的位置
      ..toastPosition = EasyLoadingToastPosition.bottom;
  }
}
