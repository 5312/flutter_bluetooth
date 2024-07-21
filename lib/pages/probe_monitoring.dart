import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/models/employee_model.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/provider/BluetoothManager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class Probe extends StatefulWidget {
  const Probe({Key? key}) : super(key: key);

  @override
  State<Probe> createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;
  late BluetoothManager bluetooth;
  bool received = false;
  // 选中特征码
  BluetoothCharacteristic? targetCharacteristic;

  @override
  void initState() {
    super.initState();
    employeeDataSource = EmployeeDataSource(employeeData: employees);

    bluetooth = Provider.of<BluetoothManager>(context, listen: false);
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

  // 启动采集
  Future<void> sendCollection(targetCharacteristic) async {
    if(received){
      return;
    }
    // 写入数据到特征码 查询电量命令
    await targetCharacteristic!
        .write([0x68, 0x05, 0x00, 0x71, 0x02, 0x78], withoutResponse: false);
    // 监听特征码的通知
    targetCharacteristic!.setNotifyValue(true);
    targetCharacteristic!.onValueReceived.listen((value) {
      if (value != null) {
        received = true;
        // 在这里处理接收到的数据
        print('启动采集返回值');
        print(value);
        // 将十六进制整数列表转换为十进制整数列表
        List<dynamic> decimalList =
            value.map((hex) => '0x' + hex.toRadixString(16)).toList();
        if (decimalList[5] == 0xf6) {
          print('启动成功');
        }
      }
    });
    // 等待3秒，如果没有接收到数据，则重新执行函数
    await Future.delayed(Duration(seconds: 3));

    if (!received) {
      print('没有收到数据，重新执行...');
      await sendCollection(targetCharacteristic); // 递归调用
    }
  }

  void deactivate() {
    super.deactivate();
    print('probe:--deactiveate');
  }

  @override
  void dispose() {
    super.dispose();
    print('probe:---dispose');
  }

  // 添加和保存按钮
  Widget addButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child: const Text('储存', style: TextStyle(fontSize: 16, color: Colors.blue)),
    onPressed: () {
      // 添加操作的逻辑
    },
  );

  Widget saveButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('保存', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 保存操作的逻辑
    },
  );

  @override
  Widget build(BuildContext context) {
    if (targetCharacteristic == null) {
      discoverServices(bluetooth.nowConnectDevice);
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
              mainAxisAlignment: MainAxisAlignment.end, // 可选：根据需要调整按钮间的间距
              children: [
                addButton,
                const SizedBox(
                  width: 10,
                ),
                saveButton,
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Expanded(
              flex: 1,
              child: SfDataGrid(
                source: employeeDataSource,
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

  List<Employee> getEmployeeData() {
    return [
      Employee(10001, 0.2, 4.11),
      Employee(10002, 0.2, 4.11),
    ];
  }
}
