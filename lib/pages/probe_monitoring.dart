import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/provider/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:bluetooth_mini/utils/hex.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import '../utils/analytical.dart';

// 探管监测
class Probe extends StatefulWidget {
  const Probe({Key? key}) : super(key: key);

  @override
  State<Probe> createState() => _ProbeState();
}

class _ProbeState extends State<Probe> {
  final List<DataListModel> _employees = <DataListModel>[];
  late EmployeeDataSource _employeeDataSource;

  late BluetoothManager bluetooth;
  bool received = false;

  // 选中特征码
  BluetoothCharacteristic? targetCharacteristic;

  // 监听订阅
  StreamSubscription<List<int>>? _lastValueSubscription;

  // 翻滚角
  String _pitch = '0';
  String _heading = '0';

  @override
  void initState() {
    super.initState();
    // 表格数据
    _employeeDataSource = EmployeeDataSource(employeeData: _employees);

    bluetooth = Provider.of<BluetoothManager>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bluetooth.currentDevice == null) {
        Navigator.of(context).pop();
        SmartDialog.showToast('请连接蓝牙');
      }
    });
  }


  // 读取指定服务及特征值
  void discoverServices(BluetoothDevice? onConnectDevice) async {
    if (onConnectDevice == null) {
      return;
    }
    if (!onConnectDevice.isConnected) {
      SmartDialog.showToast('请连接设备后再试！');
      return;
    }
    List<BluetoothService> services = await onConnectDevice.discoverServices();
    services.forEach(readServiceFunction);
  }

  // foreach 读取特征值
  void readServiceFunction(service) {
    // 具名函数的内容
    if (service.uuid.toString() == 'ffe0') {
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.uuid.toString() == 'ffe1') {
          sendCollection(c);
        }
      }
    }
  }

  // 启动采集
  Future<void> sendCollection(BluetoothCharacteristic c) async {
    targetCharacteristic = c;
    if (received) {
      return;
    }
    // 写入数据到特征码 启动采集
    await c.write([0x68, 0x05, 0x00, 0x71, 0x02, 0x78], withoutResponse: false);
    // 监听特征码的通知
    c.setNotifyValue(true);
    _lastValueSubscription = c.onValueReceived.listen((value) {
      // 返回值为10进制数据不用转换
      received = true;
      // 转为16进制数据用来查看文档对照
      List<String> hexArray = bytesToHexArray(value);
      if (hexArray[3] == 'f0') {
        Analytical analytical = Analytical(value);
        // String roll = analytical.getRoll();
        String pitch = analytical.getPitch();
        String heading = analytical.getHeading();
        setState(() {
          _pitch = pitch;
          _heading = heading;
        });
      }
    });
    // 等待3秒，如果没有接收到数据，则重新执行函数
    await Future.delayed(const Duration(seconds: 3));
    if (!received) {
      await sendCollection(c); // 递归调用
    }
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
    _pitch = '';
    _heading = '';
    super.dispose();
  }

  Widget rollText() {
    return Text(
      "俯仰角：$_pitch",
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

  // 采集 仅保存当前表格
  void _addEmployee() {
    int id = _employeeDataSource.rows.length + 1;
    DataListModel rows = DataListModel(
        id: id,
        pitch: double.parse(_pitch),
        depth: 0,
        roll: null,
        heading: double.parse(_heading),
        repoId: null);
    _employees.add(rows);
    // 保存操作的逻辑
    _employeeDataSource = EmployeeDataSource(employeeData: _employees);
  }

  @override
  Widget build(BuildContext context) {

    discoverServices(bluetooth.currentDevice);
    return Scaffold(
      appBar: const CustomAppBar('探管检测'),
      body:Container(
        color: const Color.fromRGBO(238, 239, 241, 0.8),
        child:  Container(
          color: Colors.white,
          margin: const EdgeInsets.only(
            left: 10,
            bottom: 10,
            right: 10,
            top: 10,
          ),
          child: Column(
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
                    headerRowHeight: 40,
                    source: _employeeDataSource,
                    columnWidthMode: ColumnWidthMode.fill,
                    columns: <GridColumn>[
                      GridColumn(
                          columnName: 'id',
                          label: Container(
                              padding: const EdgeInsets.all(0),
                              alignment: Alignment.center,
                              color: Colors.black12,
                              // const Color.fromRGBO( 234, 236, 255, 1),
                              child: const Text(
                                '序号',
                              ))),
                      GridColumn(
                          columnName: 'pitch',
                          label: Container(
                              padding: const EdgeInsets.all(0.0),
                              alignment: Alignment.center,
                              color: Colors.black12,
                              // const Color.fromRGBO( 234, 236, 255, 1),
                              child: const Text('俯仰角（°）'))),
                      GridColumn(
                          columnName: 'heading',
                          label: Container(
                              padding: const EdgeInsets.all(0.0),
                              alignment: Alignment.center,
                              color: Colors.black12,
                              // const Color.fromRGBO( 234, 236, 255, 1),
                              child: const Text(
                                '方位角/°',
                                overflow: TextOverflow.ellipsis,
                              ))),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<DataListModel> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: e.id),
              DataGridCell<Object>(columnName: 'pitch', value: e.pitch),
              DataGridCell<Object>(columnName: 'heading', value: e.heading),
            ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
