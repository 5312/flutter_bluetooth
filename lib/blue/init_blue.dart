

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/snackbar.dart';
import '../widgets/system_device_tile.dart';
import '../widgets/scan_result_tile.dart';
import '../utils/extra.dart';

//
// This widget shows BluetoothOffScreen or
// ScanScreen depending on the adapter state
//
class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;

  bool _isScanning = false;
  // 蓝牙状态
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> _adapterStateStateSubscription;

  @override
  void initState(){
    super.initState();
    // 监听蓝牙启动
    _adapterStateStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
      });
      if(state == BluetoothAdapterState.off){
        setState(() {
          _systemDevices = [];
          _scanResults = [];
        });
      }
      if (mounted) {
        setState(() {});
      }
    });

    // 监听蓝牙扫描
    _scanResultsSubscription =  FlutterBluePlus.scanResults.listen((results) {

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

  //关闭资源
  @override
  void dispose() {
    _adapterStateStateSubscription.cancel();

    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }


  // start scan
  Future onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      print('--scan not');
      Snackbar.show(ABC.b, prettyException("System Devices Error:", e), success: false);
    }
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Start Scan Error:", e), success: false);
    }
    // 判断页面是否释放
    if (mounted) {
      setState(() {});
    }
  }

 // stop scan
  Future onStopPressed() async {
    try {
      FlutterBluePlus.stopScan();
    } catch (e) {
      Snackbar.show(ABC.b, prettyException("Stop Scan Error:", e), success: false);
    }
  }

  // 点击按钮
  Widget buildScanButton(BuildContext context) {
    if(_adapterState == BluetoothAdapterState.on){
      if (FlutterBluePlus.isScanningNow) {
        return FloatingActionButton(
          child: const Icon(Icons.stop),
          onPressed: onStopPressed,
          backgroundColor: Colors.red,
        );
      } else {
        return FloatingActionButton(child: const Text("搜索"), onPressed: onScanPressed);
      }
    }else{
      return  Padding(
        padding: const EdgeInsets.all(20.0),
        child: ElevatedButton(
          child: const Text('开启蓝牙'),
          onPressed: () async {
            try {
              if (Platform.isAndroid) {
                await FlutterBluePlus.turnOn();
              }
            } catch (e) {
              Snackbar.show(ABC.a, prettyException("Error Turning On:", e), success: false);
            }
          },
        ),
      );
    }

  }
  // 刷新
  Future onRefresh() {
    // if (_isScanning == false) {
    //   FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    // }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(Duration(milliseconds: 500));
  }


  // 连接按钮
  void onConnectPressed(BluetoothDevice device) {
    device.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e), success: false);
    });
    // MaterialPageRoute route = MaterialPageRoute(
    //     builder: (context) => DeviceScreen(device: device), settings: RouteSettings(name: '/DeviceScreen'));
    // Navigator.of(context).push(route);
  }
  // 设备列表
  List<Widget> _buildSystemDeviceTiles(BuildContext context) {
    return _systemDevices
        .map(
          (d) => SystemDeviceTile(
        device: d,
        onOpen: () =>
        {}, onConnect: () => {},
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
  // build 方法
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      //key: Snackbar.snackBarKeyB,
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('查找设备'),
        // ),
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
