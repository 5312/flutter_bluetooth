import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import '../utils/snackbar.dart';

class BluetoothManager with ChangeNotifier {
  // 连接到当前应用的设备列表
  List<BluetoothDevice> connectedDevices = [];

  // 连接到当前应用的设备
  BluetoothDevice? nowConnectDevice;

  // 蓝牙适配器监听
  late StreamSubscription<BluetoothAdapterState> adapterStateSubscription;

  //  监听扫描结果监听
  late StreamSubscription<List<ScanResult>> scanResultsSubscription;

  // 监听扫描状态监听
  late StreamSubscription<bool> isScanningSubscription;

  // 适配器状态
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  // 扫描结果list
  List<ScanResult> scanResults = [];

  // 是否扫描
  bool isScanning = false;

  // 构造函数
  BluetoothManager() {
    // 监听蓝牙适配器状态变化
    adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      adapterState = state;
      // 如果蓝牙关闭，清空设备列表和扫描结果
      if (state == BluetoothAdapterState.off) {
        connectedDevices = [];
        scanResults = [];
        if (hasListeners) {
          notifyListeners();
        }
      }
    });

    // 监听扫描结果
    scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      scanResults = results;
      if (scanResults.isNotEmpty) {
        // 扫描结果实时刷新
        if (hasListeners) {
          notifyListeners();
        }
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    // 监听扫描状态
    isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      isScanning = state;
      print('扫描');
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  // 监听设备状态
  void onDevice() {
    if (nowConnectDevice != null) {
      _connectionStateSubscription =
          nowConnectDevice!.connectionState.listen((state) {
        _connectionState = state;
        if (state != BluetoothConnectionState.connected) {
          nowConnectDevice = null;
          print('断开连接');
          notifyListeners();
        }
      });
    }
  }

  // 初始化连接逻辑
  Future<void> initHomeConnect() async {
    // 不管如何都调用一次 启动蓝牙
    // turnOnBlue().then
    if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.on) {
      await onConnectedDevices();
      // 当前无连接
      if (connectedDevices.isEmpty) {
        // 开始扫描
        onScanPressed();
      } else {
        nowConnectDevice = connectedDevices.first;
        notifyListeners();
        onDevice();
      }
    } else {
      await turnOnBlue();
    }
  }

  // 开启蓝牙
  Future<void> turnOnBlue() async {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }
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

  // 停止扫描
  Future<void> onStopPressed() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e),
          success: false);
    }
  }

  // 获取当前连接到应用的设备列表
  Future<void> onConnectedDevices() async {
    try {
      connectedDevices = FlutterBluePlus.connectedDevices;
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e),
          success: false);
    }
  }

  // 更新已连接设备
  void updateNowDevice(BluetoothDevice? d) {
    nowConnectDevice = d;
    onDevice();
    if (hasListeners) {
      notifyListeners();
    }
  }
}
