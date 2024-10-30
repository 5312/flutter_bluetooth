import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/db/my_time.dart';
import 'package:bluetooth_mini/provider/bluetooth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bluetooth_mini/models/data_list_model.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import 'dart:async';
import '../utils/analytical.dart';

class DataTransmission extends StatefulWidget {
  const DataTransmission({Key? key}) : super(key: key);

  @override
  State<DataTransmission> createState() => _DataTransmissionState();
}

class _DataTransmissionState extends State<DataTransmission> {
  late BluetoothManager bluetooth;

  late List<DataListModel> employees = <DataListModel>[];
  late EmployeeDataSourceData employeeDataSource =
      EmployeeDataSourceData(dataModels: []);

  String _mineString = '';
  String _workString = '';
  String _factoryString = '';
  String _drillingString = '';
  String _name = '';
  int _repoId = 0;
  final List<int> _backList = [];

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
    _repoId = MyTime.getRepoId() ?? 0;

    getDatabaseData();
    // 先弹窗
    bluetooth = Provider.of<BluetoothManager>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bluetooth.currentDevice == null) {
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
              handleSync(c);
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
    await onConnectdevice.requestMtu(512);
    services.forEach(readServiceFunction);
  }

  // 发送命令
  Future<void> handleSync(BluetoothCharacteristic c) async {
    // 写入数据到特征码 启动采集
    await c.write([
      0x68,
      0x0C,
      0x00,
      0x73,
      0x02,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x81
    ], withoutResponse: false);
    EasyLoading.show(status: '正在读取探管数据...');
    // 监听特征码的通知
    await c.setNotifyValue(true);
    _lastValueSubscription = c.onValueReceived.listen((value) {
      EasyLoading.dismiss();
      _backList.addAll(value);
      // c.setNotifyValue(false);
    });
  }

  void getData(List<int> originalArray) {
    if (originalArray.length < 9) return;
    // 去掉前导部分
    List<int> trimmedArray = originalArray.sublist(9); // 去掉前 9 个元素

    // 分割数组，每段 21 个元素
    List<List<int>> chunks = [];
    for (int i = 0; i < trimmedArray.length; i += 21) {
      int end = (i + 21 < trimmedArray.length) ? i + 21 : trimmedArray.length;
      chunks.add(trimmedArray.sublist(i, end));
    }

    // 打印每一段
    for (var chunk in chunks) {
      EasyLoading.dismiss();
      Analytical analytical = Analytical(chunk);
      if (chunk.length == 21) {
        List<DataListModel> r = employees.map((e) {
          if (e.time == analytical.dataTime()) {
            e.roll = double.parse(analytical.getRoll());
            e.heading = double.parse(analytical.getHeading());
            e.pitch = double.parse(analytical.getPitch());
            return e;
          }
          return e;
        }).toList();
        setState(() {
          employees = r;
          employeeDataSource = EmployeeDataSourceData(dataModels: r);
        });
      }
    }
  }

  @override
  void dispose() {
    _lastValueSubscription?.cancel();

    targetCharacteristic = null;
    _lastValueSubscription = null;
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('数据传输'),
      body: Container(
        color: const Color.fromRGBO(238, 239, 241, 0.8),
        child: Container(
          // color: Colors.white,
          margin: const EdgeInsets.only(
            left: 10,
            bottom: 10,
            right: 10,
            top: 10,
          ),
          // padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 30, right: 30),
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
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Container(
                        color: Colors.white,
                        child: Padding(
                            padding: const EdgeInsets.all(5.0),
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
                                    discoverServices(bluetooth.currentDevice);
                                  },
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)), // 设置圆角为10
                                    ),
                                  ),
                                  child: const Text('数据同步',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                  onPressed: () {
                                    // 保存操作的逻辑
                                    getData(_backList);
                                  },
                                ),
                                orificeButton,
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)), // 设置圆角为10
                                    ),
                                  ),
                                  child: const Text('数据保存',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white)),
                                  onPressed: () {
                                    // 将原始数据保存
                                    for (var element in employees) {
                                      element.repoId = _repoId;
                                      DatabaseHelper().updateDataList(element);
                                    }
                                    SmartDialog.showToast('数据保存成功');
                                  },
                                ),
                              ],
                            )),
                      ),
                      Expanded(
                          flex: 1,
                          child: Container(
                            color: Colors.white,
                            margin: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: SfDataGrid(
                              headerRowHeight: 40,
                              source: employeeDataSource,
                              gridLinesVisibility: GridLinesVisibility.none,
                              columnWidthMode: ColumnWidthMode.fill,
                              columns: <GridColumn>[
                                GridColumn(
                                    columnName: 'id',
                                    label: Container(
                                      padding: const EdgeInsets.all(0.0),
                                      alignment: Alignment.center,
                                      color: Colors.black12,
                                      // const Color.fromRGBO( 234, 236, 255, 1),
                                      child: const Text(
                                        '序号',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    )),
                                GridColumn(
                                    columnName: 'time',
                                    label: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        alignment: Alignment.center,
                                        color: Colors.black12,
                                        // const Color.fromRGBO( 234, 236, 255, 1),
                                        child: const Text(
                                          '时间',
                                          overflow: TextOverflow.ellipsis,
                                        ))),
                                GridColumn(
                                    columnName: 'depth',
                                    label: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        alignment: Alignment.center,
                                        color: Colors.black12,
                                        // const Color.fromRGBO( 234, 236, 255, 1),
                                        child: const Text(
                                          '深度',
                                          overflow: TextOverflow.ellipsis,
                                        ))),
                                GridColumn(
                                    columnName: 'pitch',
                                    label: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        alignment: Alignment.center,
                                        color: Colors.black12,
                                        // const Color.fromRGBO( 234, 236, 255, 1),
                                        child: const Text('俯仰角（°）'))),
                                GridColumn(
                                    columnName: 'heading',
                                    label: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        alignment: Alignment.center,
                                        color: Colors.black12,
                                        // const Color.fromRGBO( 234, 236, 255, 1),
                                        child: const Text(
                                          '方位角（°）',
                                          overflow: TextOverflow.ellipsis,
                                        ))),
                              ],
                            ),
                          ))
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getDatabaseData() async {
    List<DataListModel> result =
        await DatabaseHelper().getDataListForRepoId(_repoId);


    setState(() {
      employees = result;
      employeeDataSource = EmployeeDataSourceData(dataModels: result);
    });
  }
}

class EmployeeDataSourceData extends DataGridSource {
  /// Creates the data source class with required details.
  EmployeeDataSourceData({required List<DataListModel> dataModels}) {
    _employeeData = dataModels
        .asMap() // 将列表转换为 Map，key 为 index
        .entries // 获取键值对 (index, element)
        .map<DataGridRow>((entry) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: entry.key + 1),
              DataGridCell<String>(columnName: 'time', value: entry.value.time),
              DataGridCell<Object>(
                  columnName: 'depth', value: entry.value.depth),
              DataGridCell<Object>(
                  columnName: 'pitch', value: entry.value.pitch ?? ''),
              DataGridCell<Object>(
                  columnName: 'heading', value: entry.value.heading ?? ''),
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
