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
  final List<List<int>> _backList = [];

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
      SmartDialog.showToast('未连接设备');
      return;
    }
    if (!onConnectdevice.isConnected) {
      SmartDialog.showToast('请连接设备后再试！');
      return;
    }
    try {
      EasyLoading.show(status: '正在获取设备服务...');
      List<BluetoothService> services = await onConnectdevice.discoverServices()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('获取服务超时');
      });
      
      await onConnectdevice.requestMtu(512);
      
      // 检查是否找到了目标服务
      bool foundTargetService = false;
      services.forEach((service) {
        if (service.uuid.toString() == 'ffe0') {
          foundTargetService = true;
          readServiceFunction(service);
        }
      });
      
      if (!foundTargetService) {
        EasyLoading.dismiss();
        SmartDialog.showToast('未找到目标服务，请检查设备');
      }
    } catch (e) {
      EasyLoading.dismiss();
      SmartDialog.showToast('获取设备服务出错: $e');
    }
  }
  // 发送命令
  Future<void> handleSync(BluetoothCharacteristic c) async {
    // 写入数据到特征码 启动采集
    try {
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
      
      EasyLoading.show(status: '正在等待设备返回...');
      
      // 创建一个超时标志
      bool hasReceivedData = false;
      
      // 设置超时处理
      Future.delayed(const Duration(seconds: 10), () {
        if (!hasReceivedData) {
          EasyLoading.dismiss();
          SmartDialog.showToast('设备响应超时，请重试');
          _lastValueSubscription?.cancel();
        }
      });
      // 监听特征码的通知
      await c.setNotifyValue(true);
      _lastValueSubscription = c.onValueReceived.listen((value) {
        hasReceivedData = true;
        _backList.add(value);
        print('value: $value');
        // 每次接收到数据后立即同步
        getData(_backList);
      }, onError: (error) {
        EasyLoading.dismiss();
        SmartDialog.showToast('数据接收出错: $error');
      }, onDone: () {
        EasyLoading.dismiss();
      });
    } catch (e) {
      EasyLoading.dismiss();
      SmartDialog.showToast('发送命令失败: $e');
    }
  }
  void getData(List<List<int>> originalArray) {
    print('originalArray: $originalArray');
    // 打印每一段
    for (var chunk in originalArray) {
      // 这里不需要再次dismiss，因为已经在接收监听中处理了
      try {
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
      } catch (e) {
        SmartDialog.showToast('数据解析错误: $e');
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
  Widget get orificeButton => ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)), // 设置圆角为10
      ),
    ),
    child:
        const Text('孔口校正', style: TextStyle(fontSize: 16, color: Colors.white)),
    onPressed: () {
      // 检查蓝牙连接状态
      if (bluetooth.currentDevice == null || !bluetooth.isConnected) {
        SmartDialog.showToast('请先连接蓝牙设备');
        return;
      }
      
      // 显示孔口校正对话框
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("孔口校正"),
            content: const Text("确定要执行孔口校正操作吗？"),
            actions: <Widget>[
              TextButton(
                child: const Text("取消"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: const Text("确定"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _performOrificeCorrection();
                },
              ),
            ],
          );
        },
      );
    },
  );
  
  // 执行孔口校正操作
  Future<void> _performOrificeCorrection() async {
    if (targetCharacteristic == null) {
      SmartDialog.showToast('请先执行探管取数');
      return;
    }
    
    try {
      EasyLoading.show(status: '正在执行孔口校正...');
      
      // 这里添加孔口校正的具体逻辑，例如发送特定命令到设备
      await targetCharacteristic!.write([
        0x68,
        0x0C,
        0x00,
        0x74, // 假设这是孔口校正的命令代码
        0x02,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x00,
        0x82
      ], withoutResponse: false);
      
      EasyLoading.dismiss();
      SmartDialog.showToast('孔口校正完成');
    } catch (e) {
      EasyLoading.dismiss();
      SmartDialog.showToast('孔口校正失败: $e');
    }
  }

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
