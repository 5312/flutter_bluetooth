import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/snackbar.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';
import '../utils/extra.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/provider/BluetoothManager.dart';
import 'package:provider/provider.dart';

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  late BluetoothManager bluetooth;

  //  监听扫描结果
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;

  // 监听扫描状态
  late StreamSubscription<bool> _isScanningSubscription;

  // 蓝牙适配器状态
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;

  // 适配器
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;

  @override
  void initState() {
    super.initState();
    bluetooth = Provider.of<BluetoothManager>(context, listen: false);
    setState(() {
      _adapterState = bluetooth.adapterState;
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

  // 构建扫描按钮
  Widget buildScanButton(BuildContext context) {
    if (_adapterState == BluetoothAdapterState.on) {
      if (bluetooth.isScanning) {
        return FloatingActionButton(
          onPressed: bluetooth.onStopPressed,
          backgroundColor: Colors.red,
          child: const Icon(Icons.stop),
        );
      } else {
        return FloatingActionButton(
          onPressed: bluetooth.onScanPressed,
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

  // 构建扫描结果列表
  List<Widget> _buildScanResultTiles(BuildContext context) {
    List<ScanResult> _scanResults = [];
    List<BluetoothDevice> list = bluetooth.connectedDevices;

    _scanResults = bluetooth.scanResults.where((d) {
      // return true;
      return !list.any((de) => d.device.remoteId == de.remoteId);
    }).toList();

    return _scanResults
        .map(
          (r) => ScanResultTile(
            result: r,
            // onTap: () => onConnectPressed(r.device),
            onOpen:() {
              print(r.device);
              bluetooth.onConnectPressed(r.device);
              setState(() {});
            },
          ),
        )
        .toList();
  }

  // 设备列表
  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return bluetooth.connectedDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () {
              d.disconnect().then((_) {
                bluetooth.SetnotifyListeners();
              });
            },
            onConnect: () {
              d.connectAndUpdateStream().then((_) {
                bluetooth.SetnotifyListeners();
              });
            },
          ),
        )
        .toList();
  }

  // 构建主界面
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothManager>(
      builder: (BuildContext context, BluetoothManager bluetoothManager,
          Widget? child) {
        return ScaffoldMessenger(
          child: Scaffold(
            appBar: const CustomAppBar('蓝牙列表'),
            body: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                children: <Widget>[
                  ..._buildScanResultTiles(context),
                  ..._buildSystemDeviceTiles(context)
                ],
              ),
            ),
            floatingActionButton: buildScanButton(context),
          ),
        );
      },
    );
  }
}
