import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/snackbar.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';
import '../utils/extra.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  // 设备列表
  List<BluetoothDevice> _systemDevices = [];

  // 连接结果
  List<ScanResult> _scanResults = [];

  //  监听扫描结果
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  // 监听扫描状态
  late StreamSubscription<bool> _isScanningSubscription;

  // 蓝牙适配器状态
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  // 是否扫描
  bool _isScanning = false;

  // 适配器
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();

    // 监听蓝牙适配器状态变化
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });

      // 如果蓝牙关闭，清空设备列表和扫描结果
      if (state == BluetoothAdapterState.off) {
        setState(() {
          _systemDevices = [];
          _scanResults = [];
        });
      }
    });

    // 监听扫描结果
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        _scanResults = results;

      });
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    // 监听扫描状态
    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      setState(() {
        _isScanning = state;
      });
    });
  }

  @override
  void dispose() {
    // 取消订阅以释放资源
    _adapterStateSubscription.cancel();
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  // 开始扫描
  Future<void> onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e),
          success: false);
    }
    try {
      await FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          withServices: [Guid('0000FFE0-0000-1000-8000-00805F9B34FB')]);
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e),
          success: false);
    }
    if (mounted) {
      setState(() {});
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

  // 构建扫描按钮
  Widget buildScanButton(BuildContext context) {
    if (_adapterState == BluetoothAdapterState.on) {
      if (_isScanning) {
        return FloatingActionButton(
          onPressed: onStopPressed,
          backgroundColor: Colors.red,
          child: const Icon(Icons.stop),
        );
      } else {
        return FloatingActionButton(
          onPressed: onScanPressed,
          child: const Text("搜索"),
        );
      }
    } else {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          child: const Text('开启蓝牙'),
          onPressed: () async {
            try {
              if (Platform.isAndroid) {
                await FlutterBluePlus.turnOn();
              }
            } catch (e) {
              Snackbar.show(ABC.a, prettyException("Error Turning On:", e),
                  success: false);
            }
          },
        ),
      );
    }
  }

  // 刷新列表
  Future<void> onRefresh() async {
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  // 连接设备
  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("连接失败:", e), success: false);
    });
  }

  // 构建系统设备列表
  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => {},
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

  // 构建扫描结果列表
  List<Widget> _buildScanResultTiles(BuildContext context) {
    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            onTap: () => onConnectPressed(r.device),
          ),
        )
        .toList();
  }

  // 构建主界面
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: const CustomAppBar('蓝牙列表'),
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              ..._buildSystemDeviceTiles(context),
              ..._buildScanResultTiles(context),
            ],
          ),
        ),
        floatingActionButton: buildScanButton(context),
      ),
    );
  }
}
