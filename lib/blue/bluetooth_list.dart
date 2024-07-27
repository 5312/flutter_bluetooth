import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/provider/BluetoothManager.dart';
import 'package:provider/provider.dart';

import '../widgets/system_device_tile.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bluetooth_mini/utils/extra.dart';
import 'package:bluetooth_mini/utils/snackbar.dart';

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  BluetoothManager? bluetoothManagerInstant;

  List<ScanResult> _scanResult = [];
  List<BluetoothDevice> _connectedResult = [];

  @override
  void initState() {
    super.initState();
    bluetoothManagerInstant =
        Provider.of<BluetoothManager>(context, listen: false);
    _scanResult = bluetoothManagerInstant?.scanResults ?? [];
    _connectedResult = bluetoothManagerInstant?.connectedDevices ?? [];
    filterOnconnected();
  }

  List<Widget> _buildScanResultDeviceTiles(BuildContext context) {
    return _scanResult
        .map(
          (d) => SystemDeviceTile(
            device: d.device,
            disConnect: () => disconnectTheDevice(d.device),
            onConnect: () => connectTheDevice(d.device),
          ),
        )
        .toList();
  }

  List<Widget> _buildConnectedDeviceTiles(BuildContext context) {
    return _connectedResult
        .map(
          (d) => SystemDeviceTile(
            device: d,
            disConnect: () => disconnectTheDevice(d),
            onConnect: () => connectTheDevice(d),
          ),
        )
        .toList();
  }

  // 开始连接
  Future<void> connectTheDevice(BluetoothDevice onDevice) async {
    EasyLoading.show();
    print('连接 状态：');
    print(onDevice.isConnected);
    if (!onDevice.isConnected) {
      //await onDevice.disconnectAndUpdateStream();
      await onDevice.connectAndUpdateStream().catchError((e) {
        Snackbar.show(ABC.c, prettyException("Connect Error:", e),
            success: false);
      });
    }
    if (!onDevice.isConnected) {
      bluetoothManagerInstant?.updateNowDevice(onDevice);
    }
    EasyLoading.dismiss();
  }

  // 断开连接
  Future<void> disconnectTheDevice(BluetoothDevice onDevice) async {
    EasyLoading.show();
    await onDevice.disconnectAndUpdateStream();
    bluetoothManagerInstant?.updateNowDevice(null);
    EasyLoading.dismiss();
  }

  // 从扫描列表中排除 已连接设备
  void filterOnconnected() {
    print(_scanResult);
    print(_connectedResult);

    setState(() {
      // _scanResult = _scanResult
      //     .where((element) => !_connectedResult.contains(element.device))
      _connectedResult = _connectedResult
          .where((element) => !_scanResult.contains(element))
          .toList();
    });
  }

  // 构建主界面
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothManager>(
      builder: (BuildContext context, BluetoothManager bluetoothManager,
          Widget? child) {
        print('bl-list');
        _scanResult = bluetoothManager.scanResults ?? [];
        _connectedResult = bluetoothManager.connectedDevices ?? [];

        return ScaffoldMessenger(
          child: Scaffold(
            appBar: const CustomAppBar('蓝牙列表'),
            body: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                children: <Widget>[
                  ..._buildScanResultDeviceTiles(context),
                  ..._buildConnectedDeviceTiles(context)
                ],
              ),
            ),
            floatingActionButton: buildScanButton(context),
          ),
        );
      },
    );
  }

  Widget buildScanButton(BuildContext context) {
    if (FlutterBluePlus.isScanningNow) {
      return FloatingActionButton(
        child: const Icon(Icons.stop),
        onPressed: bluetoothManagerInstant?.onStopPressed,
        // backgroundColor: Colors.red,
      );
    } else {
      return FloatingActionButton(
          onPressed: bluetoothManagerInstant?.onScanPressed,
          // child: const Text("扫描")
          child: const Icon(Icons.bluetooth));
    }
  }

  // 刷新列表
  Future<void> onRefresh() async {
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }
}
