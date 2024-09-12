import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:bluetooth_mini/provider/bluetooth_provider.dart';
import 'package:bluetooth_mini/utils/snackbar.dart';
import 'dart:async';
import 'package:bluetooth_mini/utils/bluetooth_core.dart';
import 'package:bluetooth_mini/utils/extra.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// 设备状态card
class DevicesState extends StatefulWidget {
  const DevicesState({Key? key}) : super(key: key);

  @override
  State<DevicesState> createState() => _DevicesStateState();
}

class _DevicesStateState extends State<DevicesState> with RouteAware {
  BluetoothManager? bluetoothManagerInstant;

  //  监听扫描结果监听
  StreamSubscription<List<ScanResult>>? scanResultsSubscription;

  // 扫描结果list
  List<ScanResult> _scanResults = [];

  // 电量
  int _power = 0;

  // 初始化
  @override
  void initState() {
    super.initState();
    bluetoothManagerInstant = Provider.of<BluetoothManager>(context,
        listen: false); // listen true 会监听值的变化

    onConnectedDevices();
  }

  // 首页自动连接逻辑
  Future<void> autoConnect(BluetoothCore b) async {
    b.onScanPressed();
    // 监听扫描结果
    scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;

      if (_scanResults.isNotEmpty) {
        // 自动连接第一个设备
        _connectDevice(_scanResults[0].device);
      }
    }, onError: (e) {
      if (mounted) {
        Snackbar.show(ABC.b, prettyException("扫描失败:", e), success: false);
      }
    });
  }

  // 连接设备
  Future<void> _connectDevice(BluetoothDevice device) async {
    // 判断连接状态
    if (device.isConnected) {
      if (mounted) {
        bluetoothManagerInstant!.setCurrentDevice(device);
        scanResultsSubscription?.cancel();
        scanResultsSubscription = null;
      }
      return;
    }
    try {
      await device.connectAndUpdateStream();
      // 连接成功
      if (mounted) {
        Snackbar.show(ABC.c, "连接成功", success: true);
      }
      bluetoothManagerInstant!.setCurrentDevice(device);
      scanResultsSubscription?.cancel();
      scanResultsSubscription = null;
      // 查询电量
      queryPower(device);
    } catch (e) {
      if (mounted) {
        Snackbar.show(ABC.b, prettyException("连接失败:", e), success: false);
      }
    }
  }

  // 获取当前连接到应用的设备列表 及状态
  Future<void> onConnectedDevices({bool isAuto = true}) async {
    // 蓝牙核心
    BluetoothCore b = BluetoothCore();
    try {
      List<BluetoothDevice> connectedDevices = FlutterBluePlus.connectedDevices;
      if (connectedDevices.isNotEmpty) {
        if (connectedDevices.first.isConnected) {
          if (mounted) {
            bluetoothManagerInstant!.setCurrentDevice(connectedDevices.first);
            // 查询电量
            queryPower(connectedDevices.first);
            scanResultsSubscription?.cancel();
            scanResultsSubscription = null;
          }
        }
      } else {
        if (isAuto) autoConnect(b);
      }
      // 获取设备状态
    } catch (e) {
      if (mounted) {
        Snackbar.show(ABC.b, prettyException("获取系统连接设备错误:", e), success: false);
      }
    }
  }

  // 查询电量
  Future<void> queryPower(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach(yourFunction);
  }

  // 读取特征值
  void yourFunction(service) {
    // 具名函数的内容
    if (service.uuid.toString() == 'ffe0') {
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == 'ffe1') {
          // 例如读取特征码的值
          // targetCharacteristic = c;
          // 写入数据到特征码 查询电量命令
          const List<int> command = [0x68, 0x05, 0x00, 0x74, 0x00, 0x79];
          sendCommand(c, command);
        }
      }
    }
  }

  // 发送命令
  Future<void> sendCommand(
      BluetoothCharacteristic characteristic, List<int> command) async {
    EasyLoading.show(status: '正在读取电量...');
    // 写入数据到特征码 查询电量命令
    await characteristic.write(command, withoutResponse: false);
    // 监听特征码的通知
    await characteristic.setNotifyValue(true);
    StreamSubscription<List<int>>? lastValueSubscription;
    // 监听特征码的通知
    lastValueSubscription = characteristic.onValueReceived.listen((value) {
      print('电量通知：$value');
      if (value[0] == 0x68 && value[1] == 0x14 && value[2] == 0x00) {
        // 电量
        if (mounted) {
          setState(() {
            _power = value[5];
          });
        }
        characteristic.setNotifyValue(true);
        lastValueSubscription?.cancel();
        lastValueSubscription = null;
        EasyLoading.dismiss();
      }
    });
  }

  // 跳转到蓝牙列表
  Future<void> goBluetoothList() async {
    await Navigator.of(context).pushNamed('bluetoothList');
    setState(() {});
  }

  // 构建界面
  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothManager>(
      builder:
          (BuildContext context, BluetoothManager bluetooth, Widget? child) {
        String stateText = bluetooth.isConnected ? '已连接' : '未连接';
        // 蓝牙管理器
        return Expanded(
          flex: 2,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/home/device.png'),
                fit: BoxFit.fill,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text(
                      "当前设备",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                        "设备信息：${bluetooth.currentDevice?.platformName ?? '-'}",
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                        softWrap: false),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      "当前电量：$_power%",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: 2, bottom: 0),
                    child: Text(
                      "当前状态：$stateText",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: 2, bottom: 0),
                    child: SizedBox(
                      height: 25,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: goBluetoothList,
                        child: const Text(
                          "连接蓝牙",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('销毁');
    scanResultsSubscription?.cancel();
    scanResultsSubscription = null;
  }
}
