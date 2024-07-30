import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/data_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/db/my_time.dart';
import 'package:bluetooth_mini/provider/bluetooth_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_mini/utils/hex.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'dart:async';

class DataTransmission extends StatefulWidget {
  const DataTransmission({Key? key}) : super(key: key);

  @override
  State<DataTransmission> createState() => _DataTransmissionState();
}

class _DataTransmissionState extends State<DataTransmission> {
  late BluetoothManager bluetooth;

  List<DataModel> employees = <DataModel>[];
  late EmployeeDataSource employeeDataSource;

  String _mineString = '';
  String _workString = '';
  String _factoryString = '';
  String _drillingString = '';
  String _name = '';

  // 选中特征码
  BluetoothCharacteristic? targetCharacteristic;

  // 监听订阅
  StreamSubscription<List<int>>? _lastValueSubscription;

  @override
  void initState() {
    _mineString = MyTime.getMine() ?? '';
    _workString = MyTime.getWork() ?? '';
    _factoryString = MyTime.getFactory() ?? '';
    _drillingString = MyTime.getDirlling() ?? '';
    _name = MyTime.getMonName() ?? '';
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);

    // 先弹窗
    bluetooth = Provider.of<BluetoothManager>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('--------------页面buildOver-------------------');

      if (bluetooth.nowConnectDevice == null) {
        Navigator.of(context).pop();
        SmartDialog.showToast('请连接蓝牙');
      }
    });
    super.initState();
  }

  // foreach 读取特征值
  void readServiceFunction(service) {
    // 具名函数的内容
    if (service.uuid.toString() == 'ffe0') {
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == 'ffe1') {
          // 例如读取特征码的值
          if (mounted) {
            setState(() {
              targetCharacteristic = c;
              handleSync(targetCharacteristic);
            });
          }

          // readCharacteristicValue();
          // writeAndListen();
        }
      }
    }
  }

  // 读取指定服务及特征值
  void discoverServices(BluetoothDevice? onConnectdevice) async {
    if (onConnectdevice == null) {
      return;
    }
    if (!onConnectdevice.isConnected) {
      SmartDialog.showToast('请连接设备后再试！');
      return;
    }
    List<BluetoothService> services = await onConnectdevice.discoverServices();
    services.forEach(readServiceFunction);
  }

  // 发送命令
  Future<void> handleSync(BluetoothCharacteristic? targetCharacteristic) async {
    if (targetCharacteristic == null) {
      return;
    }
    // 写入数据到特征码 启动采集
    // await targetCharacteristic!
    //     .write([0x68, 0x0C, 0x00, 0x73, 0x02, 0x78], withoutResponse: false);
    print('探管取数');
    EasyLoading.show(status: '正在同步中...');
    // 监听特征码的通知
    // await targetCharacteristic.setNotifyValue(true);
    // _lastValueSubscription =
    //     targetCharacteristic.onValueReceived.listen((value) {
    //   // 转为16进制数据用来查看文档对照
    //   List<String> hexArray = bytesToHexArray(value);
    //   EasyLoading.dismiss();
    //   print('探管取数返回');
    //   print(hexArray);
    // });
    print(_lastValueSubscription);
  }

  @override
  void dispose() {
    _lastValueSubscription?.cancel();
    if (targetCharacteristic != null) {
      targetCharacteristic!.setNotifyValue(false);

    }
    super.dispose();
  }

  // 数据同步
  Widget dataButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('数据同步', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  // 孔口校正
  Widget orificeButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('孔口校正', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  // 数据保存
  Widget dataSaveButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('数据保存', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('数据传输'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // 可选：根据需要调整按钮间的间距
              children: [
                Text('矿区：$_mineString'),
                Text('工作面：$_workString'),
                Text('钻厂：$_factoryString'),
                Text('钻孔：$_drillingString'),
                Text('检测名称：$_name'),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
              flex: 1,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(10)), // 设置圆角为10
                              ),
                            ),
                            child: const Text('探管取数',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                            onPressed: () {
                              // 保存操作的逻辑

                              // handleSync(bluetooth?.targetCharacteristic);
                              discoverServices(bluetooth.nowConnectDevice);
                            },
                          ),
                          dataButton,
                          orificeButton,
                          dataSaveButton,
                          const Padding(
                            padding:
                                EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Text(
                              '数据传输总数： 7',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black38),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: SfDataGrid(
                        source: employeeDataSource,
                        gridLinesVisibility: GridLinesVisibility.none,
                        columnWidthMode: ColumnWidthMode.fill,
                        columns: <GridColumn>[
                          GridColumn(
                              columnName: 'id',
                              label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                color: const Color.fromRGBO(234, 236, 255, 1),
                                child: const Text(
                                  '序号',
                                  style: TextStyle(color: Colors.black),
                                ),
                              )),
                          GridColumn(
                              columnName: 'timeData',
                              label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: const Color.fromRGBO(234, 236, 255, 1),
                                  child: const Text(
                                    '时间',
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                          GridColumn(
                              columnName: 'deep',
                              label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: const Color.fromRGBO(234, 236, 255, 1),
                                  child: const Text('深度/m'))),
                          GridColumn(
                              columnName: 'inclination',
                              label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: const Color.fromRGBO(234, 236, 255, 1),
                                  child: const Text(
                                    '倾角/°',
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                          GridColumn(
                              columnName: 'azimuth',
                              label: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  color: const Color.fromRGBO(234, 236, 255, 1),
                                  child: const Text(
                                    '方位角/°',
                                    overflow: TextOverflow.ellipsis,
                                  ))),
                        ],
                      ))
                ],
              ))
        ],
      ),
    );
  }

  List<DataModel> getEmployeeData() {
    return [
     // DataModel(10001, '00:04:02', 3.0, 0.2, 4.11),
      //DataModel(10002, '00:04:02', 3.0, 0.2, 4.11),
    ];
  }
}
