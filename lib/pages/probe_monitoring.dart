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
  _ProbeState createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;
  late BluetoothManager bluetooth;

  // 启动采集
  Future<void> sendCollection(targetCharacteristic) async {
    bool received = false;
    // 写入数据到特征码 查询电量命令
    await targetCharacteristic!
        .write([0x68, 0x05, 0x00, 0x71, 0x02, 0x78], withoutResponse: false);
    // 监听特征码的通知
    targetCharacteristic!.setNotifyValue(true);
    targetCharacteristic!.onValueReceived.listen((value) {
      if (value != null) {
        received = true;
        // 在这里处理接收到的数据
        print('启动采集');
        print(value);
        // 将十六进制整数列表转换为十进制整数列表
        List<dynamic> decimalList =
            value.map((hex) => '0x' + hex.toRadixString(16)).toList();
        if(decimalList[5] == 0xf6){
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

  @override
  void initState() {
    super.initState();
    employees = getEmployeeData();
    employeeDataSource = EmployeeDataSource(employeeData: employees);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      bluetooth = Provider.of<BluetoothManager>(context, listen: false);
      // if (bluetooth.targetCharacteristic != null) {
      //   sendCollection(bluetooth.targetCharacteristic);
      // }
    });
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
