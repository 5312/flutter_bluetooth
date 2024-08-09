import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:bluetooth_mini/widgets/time_form.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_mini/utils/hex.dart';
import 'package:provider/provider.dart';
import 'package:bluetooth_mini/provider/bluetooth_provider.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bluetooth_mini/widgets/cus_dialog.dart';
import 'package:bluetooth_mini/db/my_setting.dart';
import 'package:bluetooth_mini/db/my_time.dart';
import 'package:bluetooth_mini/db/database_helper.dart';
import '../utils/analytical.dart';
import '../models/data_list_model.dart';
import 'dart:async';

// import 'package:bluetooth_mini/models/time_model.dart';

// 定时同步
class TimeOut extends StatefulWidget {
  const TimeOut({Key? key}) : super(key: key);

  @override
  State<TimeOut> createState() => _TimeOutState();
}

class _TimeOutState extends State<TimeOut> {
  late BluetoothManager bluetooth;

  List<DataListModel> employees = <DataListModel>[];
  late EmployeeDataSource employeeDataSource;

  final TextEditingController _controllerLen = TextEditingController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerPitch = TextEditingController();
  final TextEditingController _controllerHeading = TextEditingController();

  bool isSync = false;
  bool isFixed = false;
  bool isPop = false;

  // 选中特征码
  BluetoothCharacteristic? targetCharacteristic;

  // 监听订阅
  StreamSubscription<List<int>>? _lastValueSubscription;

  int _currentTime = 0;

  String? _selectedMine;
  String? _selectedWork;
  String? _selectedFactory;
  String? _selectedDrilling;

  List<String> _miningArea = [];
  List<String> _work = [];
  List<String> _factory = [];
  List<String> _drilling = [];

  String _mineString = '';
  String _workString = '';
  String _factoryString = '';
  String _drillingString = '';
  String _nString = '';
  String _pitch = '';
  String _designPitch = '';
  String _designHeading = '';
  String _time = '';

  Timer? _timer;
  @override
  void initState() {
    _miningArea = MySetting.getMine();
    _work = MySetting.getWork();
    _factory = MySetting.getFactory();
    _drilling = MySetting.getDrilling();

    isSync = false;
    isFixed = false;
    isPop = false;

    employeeDataSource = EmployeeDataSource(employeeData: employees);
    // 先弹窗
    bluetooth = Provider.of<BluetoothManager>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bluetooth.currentDevice == null) {
        Navigator.of(context).pop();
        SmartDialog.showToast('请连接蓝牙');
      } else {
        open();
      }
    });
    super.initState();
  }

  // 弹窗
  void open() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              if (didPop) {
                return;
              }
              showDeleteConfirmDialog1(context);
            },
            child: DialogKeyboard(
              contentBody: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 550, // 设置最大宽度
                  ),
                  child: Column(
                    children: <Widget>[
                      _buildRowMineSelect(),
                      _buildRowWorkSelect(),
                      _buildRowFactorySelect(),
                      _buildRowDrillSelect(),
                      MyForm(
                        label: '设计俯仰角',
                        suffixIcon: '',
                        controller: _controllerPitch,
                      ),
                      MyForm(
                        label: '设计方位角',
                        suffixIcon: '',
                        controller: _controllerHeading,
                      ),
                      MyForm(
                        label: '钻杆长度',
                        suffixIcon: 'm',
                        controller: _controllerLen,
                      ),
                      MyForm(
                        label: '检测名称',
                        suffixIcon: '',
                        controller: _controllerName,
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
                  onPressed: () {
                    if (_controllerName.text != '' &&
                        _controllerPitch.text != '' &&
                        _controllerHeading.text != '') {
                      setState(() {
                        isSync = true;
                        // 矿区
                        _mineString = _selectedMine ?? '';
                        MyTime.setMine(_mineString);
                        // 工作面
                        _workString = _selectedWork ?? '';
                        MyTime.setWork(_workString);
                        // 钻厂
                        _factoryString = _selectedFactory ?? '';
                        MyTime.setFactory(_factoryString);
                        // 钻孔
                        _drillingString = _selectedDrilling ?? '';
                        MyTime.setDirlling(_drillingString);
                        // 检测名称
                        _nString = _controllerName.text;
                        MyTime.setMonName(_nString);
                        // 设计俯仰角
                        _designPitch = _controllerPitch.text;
                        MyTime.setPitch(_designPitch);
                        // 设计方位角
                        _designHeading = _controllerHeading.text;
                        MyTime.setHeading(_designHeading);
                      });
                      Navigator.of(context).pop();
                    } else {
                      SmartDialog.showToast('请填写信息');
                    }
                  },
                  child: const Text(
                    '下一步',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ));
      },
    );
  }

  /// 矿区
  Widget _buildRowMineSelect() {
    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            '矿区名称:',
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedMine,
            hint: const Text('请选择一个选项'),
            items: _miningArea.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedMine = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请选择一个选项';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.only(
                top: 0,
                left: 10,
                bottom: 0,
              ),
            ),
          ),
        )
      ],
    );
  }

  /// 工作面
  Widget _buildRowWorkSelect() {
    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            '工作面:',
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedWork,
            hint: const Text('请选择一个选项'),
            items: _work.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedWork = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请选择一个选项';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.only(
                top: 0,
                left: 10,
                bottom: 0,
              ),
            ),
          ),
        )
      ],
    );
  }

  /// 钻厂
  Widget _buildRowFactorySelect() {
    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            '钻厂:',
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedFactory,
            hint: const Text('请选择一个选项'),
            items: _factory.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedFactory = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请选择一个选项';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.only(
                top: 0,
                left: 10,
                bottom: 0,
              ),
            ),
          ),
        )
      ],
    );
  }

  /// 钻孔
  Widget _buildRowDrillSelect() {
    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            '钻厂:',
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedDrilling,
            hint: const Text('请选择一个选项'),
            items: _drilling.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedDrilling = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请选择一个选项';
              }
              return null;
            },
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              contentPadding: EdgeInsets.only(
                top: 0,
                left: 10,
                bottom: 0,
              ),
            ),
          ),
        )
      ],
    );
  }

  // 读取指定服务及特征值
  void discoverServices(BluetoothDevice? device) async {
    if (device == null) {
      return;
    }
    if (!device.isConnected) {
      SmartDialog.showToast('请连接设备后再试！');
      return;
    }
    List<BluetoothService> services = await device.discoverServices();
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
          // 例如读取特征码的值
          if (mounted) {
            setState(() {
              targetCharacteristic = c;
              handleSync(c);
            });
          }
        }
      }
    }
  }

  // 启动连接
  Future<void> handleSync(BluetoothCharacteristic c) async {
    bool iniTime = true;

    // 写入数据到特征码 启动采集
    await c.write([0x68, 0x05, 0x00, 0x71, 0x01, 0x77], withoutResponse: false);

    EasyLoading.show(status: '正在同步中...');
    // 监听特征码的通知
    c.setNotifyValue(true);
    _lastValueSubscription = c.onValueReceived.listen((value) {
      isSync = false;
      isFixed = true;
      isPop = true;
      // 第一次返回才开始计数
      if (iniTime) {
        backTime();
        iniTime = false;
      }
      // 转为16进制数据用来查看文档对照
      List<String> hexArray = bytesToHexArray(value);
      EasyLoading.dismiss();
      if (hexArray[3] == 'f0') {
        Analytical analytical = Analytical(value);
        _time = analytical.dataTime();
        String pitch = analytical.getPitch();
        setState(() {
          _pitch = pitch;
        });
      }
    });
  }

  //定点测量
  Future<void> savePitch() async {
    int id = employeeDataSource.rows.length + 1;
    DataListModel rows = DataListModel(
      id: id,
      pitch: double.parse(_pitch),
      time: _time,
    );
    employees.add(rows);
    print(rows.toJson());
    await DatabaseHelper().insertDataList(DataListModel(
      id: id,
      pitch: double.parse(_pitch),
      time: _time,
      repoId: null,
      designPitch: double.parse(_designPitch),
      designRoll: double.parse(_designHeading),
    ));

    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  //删除末尾数据
  void delePop() {
    // 覆盖
    DatabaseHelper().deleteDataList(employees.last.id ?? 0);
    employees.removeLast();
    employeeDataSource = EmployeeDataSource(employeeData: employees);
  }

  // 启动成功后倒计时
  void backTime() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime += 1;
        });
      }
    });
  }

  // 弹出对话框
  Future<bool?> showDeleteConfirmDialog1(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("提示"),
          content: const Text("您确定要退出定时同步吗?"),
          actions: <Widget>[
            TextButton(
              child: const Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: const Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                // 停止定时器
                _timer?.cancel();
                Navigator.of(context).pop(true);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('定时同步'),
      body: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          showDeleteConfirmDialog1(context);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 30, right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // 可选：根据需要调整按钮间的间距
                children: [
                  Text('矿区：$_mineString'),
                  Text('工作圈:$_workString'),
                  Text('钻厂：$_factoryString'),
                  Text('钻孔：$_drillingString'),
                  Text('检测名称：$_nString'),
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
                            Text('深度信息：$_pitch'),
                            Text(
                                '累计时间：${Analytical([]).formatTime(_currentTime)}'),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSync
                                    ? Colors.blueAccent
                                    : const Color.fromRGBO(242, 243, 247, 1),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)), // 设置圆角为10
                                ),
                              ),
                              child: Text('定时同步',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: isSync
                                          ? Colors.white
                                          : const Color.fromRGBO(
                                              147, 153, 177, 1))),
                              onPressed: () async {
                                if (isSync) {
                                  discoverServices(bluetooth.currentDevice);
                                }
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFixed
                                    ? Colors.blueAccent
                                    : const Color.fromRGBO(242, 243, 247, 1),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)), // 设置圆角为10
                                ),
                              ),
                              child: Text('定点测量',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: isFixed
                                          ? Colors.white
                                          : const Color.fromRGBO(
                                              147, 153, 177, 1))),
                              onPressed: () {
                                if (isFixed) {
                                  savePitch();
                                }
                                // 保存操作的逻辑
                              },
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPop
                                    ? Colors.blueAccent
                                    : const Color.fromRGBO(242, 243, 247, 1),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)), // 设置圆角为10
                                ),
                              ),
                              child: Text('删除末尾数据',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: isPop
                                          ? Colors.white
                                          : const Color.fromRGBO(
                                              147, 153, 177, 1))),
                              onPressed: () {
                                // 保存操作的逻辑
                                if (isPop) {
                                  delePop();
                                }
                              },
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
                                columnName: 'inclination',
                                label: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    color:
                                        const Color.fromRGBO(234, 236, 255, 1),
                                    child: const Text('深度/m'))),
                            GridColumn(
                                columnName: 'azimuth',
                                label: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    alignment: Alignment.center,
                                    color:
                                        const Color.fromRGBO(234, 236, 255, 1),
                                    child: const Text(
                                      '时间',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                          ],
                        ))
                  ],
                ))
          ],
        ),
      ),
    );
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

    // 停止定时器
    _timer?.cancel();
    super.dispose();
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
              DataGridCell<num>(columnName: 'pitch', value: e.pitch),
              DataGridCell<String>(columnName: 'time', value: e.time),
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
