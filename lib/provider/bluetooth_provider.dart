import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import '../utils/snackbar.dart';

class BluetoothManager with ChangeNotifier {
  // 当前连接设备
  BluetoothDevice? _currentDevice;
  // 获取当前连接设备
  BluetoothDevice? get currentDevice => _currentDevice;
  // 当前设备连接状态
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  // 当前设备连接状态订阅
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  // 设置当前连接设备
  void setCurrentDevice(BluetoothDevice device) {
    // 设置并监听当前连接状态
    _currentDevice = device;
    _connectionStateSubscription = device.connectionState.listen((state) {
      _currentDevice = device; // 有时会先执行一次断开
      _connectionState = state;
      if (state == BluetoothConnectionState.disconnected) {
        _currentDevice = null;
      }
      notifyListeners(); // 状态改变通知
    });
  }

  // 获取连接状态
  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }
}
