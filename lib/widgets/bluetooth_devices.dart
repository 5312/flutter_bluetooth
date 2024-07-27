import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:bluetooth_mini/provider/BluetoothManager.dart';
import 'package:bluetooth_mini/utils/extra.dart';
import 'package:bluetooth_mini/utils/snackbar.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';

// 设备状态card
class DevicesState extends StatefulWidget {
  const DevicesState({Key? key}) : super(key: key);

  @override
  State<DevicesState> createState() => _DevicesStateState();
}

class _DevicesStateState extends State<DevicesState> {
  BluetoothManager? bluetoothManagerInstant;

  String _devicesNmae = '-';
  bool _isPower = false;
  int _power = 0;
  String _connectState = '未连接';

  // 选中特征码
  BluetoothCharacteristic? targetCharacteristic;

  // 特征值监听器
  // StreamSubscription? streamSubscription;
  late StreamSubscription<List<int>> _lastValueSubscription;

  @override
  void initState() {
    super.initState();
    // 进入首页 默认连接 然后查询电量
    bluetoothManagerInstant =
        Provider.of<BluetoothManager>(context, listen: false);
    // 初始化逻辑
    bluetoothManagerInstant?.initHomeConnect();
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose');
    // 跳转 homecard 不会执行这里
    // 退出登录会执行
    if (bluetoothManagerInstant != null) {
      // 更改navicat 模式后不需要取消订阅了
      // bluetoothManagerInstant?.adapterStateSubscription.cancel();
      //bluetoothManagerInstant?.scanResultsSubscription.cancel();
      // bluetoothManagerInstant?.isScanningSubscription.cancel();
    }
  }

  // 连接状态
  Widget useDeviceIsConnect(BluetoothManager bluetoothManager) {
    return Text(
      "当前状态：$_connectState",
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 12,
      ),
    );
  }

  // 开始连接
  Future<void> connectTheDevice(BluetoothDevice onDevice) async {
    print('开始连接');
    EasyLoading.show();
    await onDevice.connectAndUpdateStream().catchError((e) {
      Snackbar.show(ABC.c, prettyException("Connect Error:", e),
          success: false);
    });
    bluetoothManagerInstant?.updateNowDevice(onDevice);
    EasyLoading.dismiss();
  }

  // 自动连接第一个
  void autoConnect(List<ScanResult> scanResult) {
    if (scanResult.isNotEmpty) {
      connectTheDevice(scanResult.first.device);
    }
  }

  // 读取指定服务及特征值
  void discoverServices(BluetoothDevice? onConnectdevice) async {
    if (onConnectdevice == null) {
      return;
    }
    List<BluetoothService> services = await onConnectdevice!.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == 'ffe0') {
        // Reads all characteristics
        var characteristics = service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString() == 'ffe1') {
            // 例如读取特征码的值
            if (mounted) {
              setState(() {
                targetCharacteristic = c;
              });
            }

            // readCharacteristicValue();
            // writeAndListen();
          }
        }
      }
    });
  }

  void readCharacteristicValue() async {
    if (targetCharacteristic == null) {
      return;
    }
    List<int> value = await targetCharacteristic!.read();
    print('Characteristic value: $value');
  }

  // // 读取电量
  void writeAndListen() async {
    // 查过不在查询
    if (_isPower) {
      return;
    }
    if (targetCharacteristic == null) {
      return;
    }
    print('查询电量');

    // 写入数据到特征码 查询电量命令
    await targetCharacteristic!
        .write([0x68, 0x05, 0x00, 0x74, 0x00, 0x79], withoutResponse: false);
    // isPower = true;
    // 监听特征码的通知
    await targetCharacteristic!.setNotifyValue(true);
    _lastValueSubscription =
        targetCharacteristic!.onValueReceived.listen((value) {
      // 在这里处理接收到的数据
      int hex = value[5];
      print(value);
      readCharacteristicValue();
      if (mounted) {
        setState(() {
          _isPower = true;
          _power = hex; // int.parse(hex.toString(), radix: 16);
        });
      }
      _lastValueSubscription?.cancel();
      targetCharacteristic!.setNotifyValue(false);
      //print('取消订阅');
      //print(_lastValueSubscription);
    });
  }

  void deactivate() {
    super.deactivate();
    print('deactiveate');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothManager>(
      builder: (BuildContext context, BluetoothManager bluetoothManager,
          Widget? child) {
        print('bluetooth_devices');
        print(bluetoothManager.nowConnectDevice);
        if (bluetoothManager.nowConnectDevice == null) {
          _devicesNmae = '-';
          _connectState = '未连接';
          _power = 0;
          // 无连接时 ，自动连接第一个
          autoConnect(bluetoothManager.scanResults);
        } else {
          // TODO 存在有值，但未连接的情况
          bool isConn = bluetoothManager.nowConnectDevice?.isConnected ?? false;
          _devicesNmae = bluetoothManager.nowConnectDevice?.platformName ?? '-';

          if (!isConn) {
            _connectState = '未连接';
            _power = 0;
          } else {
            _connectState = '已连接';
            // 特征值 查询
            if (targetCharacteristic == null) {
              discoverServices(bluetoothManager.nowConnectDevice);
            } else {
              // 查询电量
              writeAndListen();
            }
          }
        }
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
                      "设备信息：$_devicesNmae",
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
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
                    child: useDeviceIsConnect(bluetoothManager),
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
                        onPressed: () {
                          Navigator.of(context).pushNamed('bluetoothList');
                        },
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
}
