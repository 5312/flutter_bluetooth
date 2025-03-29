import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/provider/bluetooth_provider.dart';
import 'package:provider/provider.dart';

import 'device_screen.dart';
import '../utils/snackbar.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';
import '../utils/extra.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
      Snackbar.show(ABC.b, prettyException("Scan Error:", e), success: false);
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future<void> onConnectPressed(BluetoothDevice device) async {
    try {
      await device.connectAndUpdateStream().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('连接超时');
        },
      );
      
      if (mounted) {
        // 更改provider状态
        Provider.of<BluetoothManager>(context, listen: false)
            .setCurrentDevice(device);
            
        Snackbar.show(ABC.c, "连接成功", success: true);
        
        // 停止扫描
        await FlutterBluePlus.stopScan();
        
        // 返回上一页
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (e is FlutterBluePlusException &&
          e.code == FbpErrorCode.connectionCanceled.index) {
        return; // 忽略用户取消的连接
      }
      
      if (mounted) {
        Snackbar.show(ABC.c, prettyException("连接失败:", e), success: false);
      }
      
      // 如果是超时错误，尝试重新连接
      if (e is TimeoutException && mounted) {
        Snackbar.show(ABC.c, "正在重试连接...", success: true);
        await Future.delayed(const Duration(seconds: 2));
        return onConnectPressed(device);
      }
    }
  }

  Future onScanPressed() async {
    try {
      List<Guid> withServices = [Guid("0000FFE0-0000-1000-8000-00805F9B34FB")];
      _systemDevices = await FlutterBluePlus.systemDevices(withServices);
    } catch (e) {
      if (mounted) {
        Snackbar.show(ABC.b, prettyException("获取系统设备错误:", e), success: false);
      }
      return;
    }
    
    try {
      // 15秒后停止扫描
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [Guid('0000FFE0-0000-1000-8000-00805F9B34FB')]
      );
    } catch (e) {
      if (mounted) {
        Snackbar.show(ABC.b, prettyException("扫描失败:", e), success: false);
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  Future onStopPressed() async {
    try {
      await FlutterBluePlus.stopScan();
    } catch (e) {
      if (mounted) {
        Snackbar.show(ABC.b, prettyException("停止扫描失败:", e), success: false);
      }
    }
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(
          timeout: const Duration(seconds: 15),
          withServices: [Guid('0000FFE0-0000-1000-8000-00805F9B34FB')]
      );
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        onPressed: onStopPressed,
        backgroundColor: Colors.red,
        child: const Icon(Icons.stop),
      );
    } else {
      return FloatingActionButton(
        onPressed: onScanPressed,
        child: const Text("扫描"),
      );
    }
  }

  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
            device: d,
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DeviceScreen(device: d),
                settings: const RouteSettings(name: '/DeviceScreen'),
              ),
            ),
            onConnect: () => onConnectPressed(d),
          ),
        )
        .toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
