import 'dart:async';
import 'dart:io';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import '../utils/snackbar.dart';
import '../utils/extra.dart';

class BluetoothManager with ChangeNotifier {
  // 获取当前连接到您的应用程序的设备。
  List<BluetoothDevice> _connectedDevices = [];

  List<BluetoothDevice> get connectedDevices => _connectedDevices;

  // 当前连接设备
  BluetoothDevice? onConnectdevice;

  // 连接结果
  List<ScanResult> _scanResults = [];

  List<ScanResult> get scanResults => _scanResults;

  //  监听扫描结果
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  // 监听扫描状态
  late StreamSubscription<bool> _isScanningSubscription;

  // 蓝牙适配器状态
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  // 是否扫描
  bool _isScanning = false;

  bool get isScanning => _isScanning;

  // 适配器
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  BluetoothAdapterState get adapterState => _adapterState;

  // 特征值
  BluetoothCharacteristic? targetCharacteristic;
  late int power = 0;
  bool isPower = false;

  BluetoothManager() {
    // 监听蓝牙适配器状态变化
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      // 如果蓝牙关闭，清空设备列表和扫描结果
      if (state == BluetoothAdapterState.off) {
        _connectedDevices = [];
        _scanResults = [];
        notifyListeners();
      }
    });

    // 监听扫描结果
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;

      notifyListeners();

    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    // 监听扫描状态
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      notifyListeners();

    });
  }

  // 设置当前连接设备
  void setDevice(BluetoothDevice devices) {
    onConnectdevice = devices;
  }

  // 开始扫描
  Future<void> onScanPressed() async {
    await onConnectedDevices();

    try {
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          withServices: [Guid('0000FFE0-0000-1000-8000-00805F9B34FB')]);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
  }

  // 获取当前连接到应用的设备列表
  Future<void> onConnectedDevices() async {
    try {
      _connectedDevices = await FlutterBluePlus.connectedDevices;
      if (_connectedDevices.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e),
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

  @override
  void dispose() {
    // 取消订阅以释放资源
    _adapterStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  // 连接设备
  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().then((onValue) {
      _connectedDevices.add(device);
      notifyListeners();
      print('连接成功');
    }).catchError((e) {
      Snackbar.show(ABC.c, prettyException("连接失败:", e), success: false);
    });
  }
  // 读取指定服务及特征值
  void discoverServices() async {
    if (onConnectdevice == null) {
      return;
    }
    // print(device);
    List<BluetoothService> services = await onConnectdevice!.discoverServices();

    services.forEach((service) {
      if (service.uuid.toString() == 'ffe0') {
        // Reads all characteristics
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == 'ffe1') {
            // 例如读取特征码的值
            targetCharacteristic = c;
            readCharacteristicValue();
            writeAndListen();
          }
        }
      }
    });
  }

  // 读取特征码的值
  void readCharacteristicValue() async {
    if (targetCharacteristic == null) {
      return;
    }
    List<int> value = await targetCharacteristic!.read();
    print('Characteristic value: $value');
  }
  // 读取电量
  void writeAndListen() async {
    if (targetCharacteristic == null) {
      return;
    }
    print('发送查询');

    // 写入数据到特征码 查询电量命令
    await targetCharacteristic!
        .write([0x68, 0x05, 0x00, 0x74, 0x00, 0x79], withoutResponse: false);
    isPower = true;
    // 监听特征码的通知
    targetCharacteristic!.setNotifyValue(true);
    targetCharacteristic!.onValueReceived.listen((value) {
      if (value != null) {
        // 在这里处理接收到的数据
        int hex = value[5];
        power = int.parse(hex.toString(), radix: 16);
        notifyListeners();
      }
    });
  }
  // 全局响应
  void SetnotifyListeners(){
    notifyListeners();
  }

}
