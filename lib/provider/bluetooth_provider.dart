import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import  '../utils/extra.dart';
class BluetoothManager with ChangeNotifier {
  // 当前连接设备
  BluetoothDevice? _currentDevice;
  // 获取当前连接设备
  BluetoothDevice? get currentDevice => _currentDevice;
  // 当前设备连接状态
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;
  
  // 重连次数
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 3;
  
  // 连接超时时间
  static const Duration connectionTimeout = Duration(seconds: 10);
  
  // 当前设备连接状态订阅
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<BluetoothConnectionState>? get connectionStateSubscription => _connectionStateSubscription;

  // 设置当前连接设备
  Future<void> setCurrentDevice(BluetoothDevice device) async {
    if (_connectionStateSubscription != null) {
      await _connectionStateSubscription!.cancel();
    }
    
    _currentDevice = device;
    _reconnectAttempts = 0;
    
    _connectionStateSubscription = device.connectionState.listen((state) async {
      _connectionState = state;
      
      if (state == BluetoothConnectionState.disconnected) {
        if (_reconnectAttempts < maxReconnectAttempts) {
          _reconnectAttempts++;
          try {
            await device.connectAndUpdateStream().timeout(
              connectionTimeout,
              onTimeout: () {
                throw TimeoutException('Connection timed out');
              },
            );
          } catch (e) {
            debugPrint('Reconnection attempt $_reconnectAttempts failed: $e');
            if (_reconnectAttempts >= maxReconnectAttempts) {
              _currentDevice = null;
            }
          }
        } else {
          _currentDevice = null;
        }
      } else if (state == BluetoothConnectionState.connected) {
        _reconnectAttempts = 0;
      }
      
      notifyListeners();
    });
  }

  // 获取连接状态
  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }
  
  // 断开连接
  Future<void> disconnect() async {
    if (_currentDevice != null) {
      await _currentDevice!.disconnectAndUpdateStream();
      _currentDevice = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectionStateSubscription?.cancel();
    super.dispose();
  }
}
