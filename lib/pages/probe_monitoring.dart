import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/employee_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/provider/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:bluetooth_mini/utils/hex.dart';
import 'package:bluetooth_mini/widgets/cus_dialog.dart';
import 'package:bluetooth_mini/widgets/time_form.dart';
import 'package:bluetooth_mini/db/database_helper.dart';

import 'package:bluetooth_mini/models/repo_model.dart';
import 'dart:math';

// 探管监测
class Probe extends StatefulWidget {
  const Probe({Key? key}) : super(key: key);

  @override
  State<Probe> createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  final List<Employee> _employees = <Employee>[];
  late EmployeeDataSource _employeeDataSource;
  late BluetoothManager bluetooth;
  bool received = false;
  final TextEditingController _controller = TextEditingController();

  // 选中特征码
  BluetoothCharacteristic? targetCharacteristic;

  // 监听订阅
  StreamSubscription<List<int>>? _lastValueSubscription;

  // 倾角
  String _roll = '0';
  String _heading = '0';

  @override
  void initState() {
    super.initState();
    _employeeDataSource = EmployeeDataSource(employeeData: _employees);

    bluetooth = Provider.of<BluetoothManager>(context, listen: false);

    // if (bluetooth.nowConnectDevice == null) {
    //   Navigator.of(context).pop();
    //   SmartDialog.showToast('请连接蓝牙');
    // }
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

  // 启动采集
  Future<void> sendCollection(
      BluetoothCharacteristic? targetCharacteristic) async {
    if (received) {
      return;
    }
    // 写入数据到特征码 启动采集
    await targetCharacteristic!
        .write([0x68, 0x05, 0x00, 0x71, 0x02, 0x78], withoutResponse: false);
    // 监听特征码的通知
    targetCharacteristic.setNotifyValue(true);
    _lastValueSubscription =
        targetCharacteristic.onValueReceived.listen((value) {
      // 返回值为10进制数据不用转换
      received = true;
      // 转为16进制数据用来查看文档对照
      List<String> hexArray = bytesToHexArray(value);
      if (hexArray[3] == 'f0') {
        // 在这里处理接收到的数据
        print('启动采集返回值');
        // 【3】-fo-对应和 HCM600 命令字 0x84
        // 【5】【6】【7】之和为第几条数据
        // 【8】【9】【10】pitch 俯仰角
        // 【11】【12】【13】roll 倾斜角
        // 【14】【15】【16】heading 方位角
        String roll = readAngle(hexArray[11], hexArray[12], hexArray[13]);
        String heading = readAngle(hexArray[14], hexArray[15], hexArray[16]);
        setState(() {
          _roll = roll;
          _heading = heading;
        });
      }
    });
    // 等待3秒，如果没有接收到数据，则重新执行函数
    await Future.delayed(const Duration(seconds: 3));

    if (!received) {
      print('没有收到数据，重新执行...');
      await sendCollection(targetCharacteristic); // 递归调用
    }
  }

  //
  String readAngle(String roll1, String roll2, String roll3) {
    // 从第一个元素中取出第一个字符
    String firstChar = roll1[0];
    String data = '';
    if (firstChar == '0') {
      data += '+';
    } else {
      data += '-';
    }
    // 使用字符串插值来拼接结果
    data += '${roll1[1]}$roll2.$roll3';
    return data;
  }

  @override
  void deactivate() {
    super.deactivate();
    //print('probe:--deactiveate');
  }

  @override
  void dispose() {
    _lastValueSubscription?.cancel();
    if (targetCharacteristic != null) {
      targetCharacteristic!.setNotifyValue(false);
      // 停止采集
      targetCharacteristic!
          .write([0x68, 0x05, 0x00, 0x71, 0x00, 0x76], withoutResponse: false);
    }
    _roll = '';
    _heading = '';
    super.dispose();
  }

  Widget rollText() {
    return Text(
      "倾角：$_roll",
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 12,
      ),
    );
  }

  Widget headingText() {
    return Text(
      "方位角：$_heading",
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 12,
      ),
    );
  }

  int generateRandomId({int min = 1, int max = 1000000}) {
    final Random random = Random();
    return random.nextInt(max - min + 1) + min;
  }

  // 储存
  Future<void> _onStore() async {
    if (_controller.text != '') {
      print(_controller.text);
      DateTime time = DateTime.now();
      print(time);
      int randomId = generateRandomId();
      await DatabaseHelper().insertRepo(
        RepoModel(
            id: randomId, name: _controller.text, mnTime: time.toString()),
      );
      int randomId2 = generateRandomId();
      List<Employee> e = _employees.map((e) {
        return Employee(
          id: e.id,
          inclination: e.inclination,
          azimuth: e.azimuth,
          repoId: randomId,
        );
      }).toList();
      await DatabaseHelper().insertEmployees(e);
      Navigator.of(context).pop();
    } else {
      SmartDialog.showToast('请填写信息');
    }
  }

  void open() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogKeyboard(
          contentBody: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 500, // 设置最大宽度
              ),
              child: Column(
                children: <Widget>[
                  MyForm(
                    label: '检测名称',
                    suffixIcon: '',
                    controller: _controller,
                  ),
                ],
              )),
          title: const Text(
            '添加矿区',
            style: TextStyle(fontSize: 14),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: _onStore,
              child: const Text(
                '下一步',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // 采集
  void _addEmployee() {
    int id = _employeeDataSource.rows.length + 1;
    Employee rows = Employee(
        id: id,
        inclination: double.parse(_roll),
        azimuth: double.parse(_heading),
        repoId: null);
    _employees.add(rows);
    // 保存操作的逻辑
    _employeeDataSource = EmployeeDataSource(employeeData: _employees);
  }

  @override
  Widget build(BuildContext context) {
    if (targetCharacteristic == null) {
      // discoverServices(bluetooth.nowConnectDevice);
    } else {
      // 启动采集
      sendCollection(targetCharacteristic);
    }

    return Scaffold(
      appBar: const CustomAppBar('探管检测'),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 5, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      // 可选：根据需要调整按钮间的间距
                      children: [
                        rollText(),
                        const SizedBox(width: 10),
                        headingText()
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end, // 可选：根据需要调整按钮间的间距
                    children: [
                      // ElevatedButton(
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.white,
                      //     shape: const RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.all(
                      //           Radius.circular(10)), // 设置圆角为10
                      //     ),
                      //   ),
                      //   child: const Text('储存',
                      //       style: TextStyle(fontSize: 16, color: Colors.blue)),
                      //   onPressed: () {
                      //     // 添加操作的逻辑
                      //     open();
                      //   },
                      // ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(10)), // 设置圆角为10
                          ),
                        ),
                        onPressed: _addEmployee,
                        child: const Text('采集',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              )),
          const SizedBox(
            height: 16,
          ),
          Expanded(
              flex: 1,
              child: SfDataGrid(
                source: _employeeDataSource,
                columnWidthMode: ColumnWidthMode.fill,
                columns: <GridColumn>[
                  GridColumn(
                      columnName: 'id',
                      label: Container(
                          padding: const EdgeInsets.all(16.0),
                          alignment: Alignment.center,
                          child: const Text(
                            '序号',
                          ))),
                  GridColumn(
                      columnName: 'inclination',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text('倾角/'))),
                  GridColumn(
                      columnName: 'azimuth',
                      label: Container(
                          padding: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            '方位角/°',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ],
              ))
        ],
      ),
    );
  }
}
