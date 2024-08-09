import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_mini/utils/snackbar.dart';
import 'dart:async';
import 'package:bluetooth_mini/utils/extra.dart';

import 'dart:io';

class BluetoothCore {
  BluetoothCore() {
    // 初始化蓝牙
    _initialize();
  }

  void _initialize() {
    // 开启蓝牙
    if (FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
      openBluetooth();
    }
  }

  // 连接设备
  Future<void> _connectDevice(BluetoothDevice device) async {
    try {
      await device.connectAndUpdateStream().catchError((e) {
        Snackbar.show(ABC.c, prettyException("连接失败:", e), success: false);
      });
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Connect Error:", e),
          success: false);
    }
  }

  // 开启蓝牙
  Future<void> openBluetooth() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (e) {
      Snackbar.show(ABC.a, prettyException("Error Turning On:", e),
          success: false);
    }
  }

  // 开始扫描
  Future<void> onScanPressed() async {
    try {
      // startScan在 Android 上，每 30 秒只能调用5 次。这是平台限制。
      // 15秒后停止扫描
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          withServices: [Guid('0000FFE0-0000-1000-8000-00805F9B34FB')]);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
  }
}
