import 'dart:async';
import 'dart:math';

import 'package:bluetooth_mini/db/database_helper.dart';
import 'package:bluetooth_mini/db/my_setting.dart';
import 'package:bluetooth_mini/db/my_time.dart';
import 'package:bluetooth_mini/models/repo_model.dart';
import 'package:bluetooth_mini/provider/bluetooth_provider.dart';
import 'package:bluetooth_mini/utils/hex.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/widgets/cus_dialog.dart';
import 'package:bluetooth_mini/widgets/time_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bluetooth_mini/db/interfaceDb.dart';
import '../models/data_list_model.dart';
import '../utils/analytical.dart';

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

  MyMine? _selectedMine;
  MyWork? _selectedWork;
  MyFactory? _selectedFactory;
  MyDrilling? _selectedDrilling;

  List<MyMine> _miningArea = [];
  List<MyWork> _work = [];
  List<MyFactory> _factory = [];
  List<MyDrilling> _drilling = [];

  String _mineString = '';
  String _workString = '';
  String _factoryString = '';
  String _drillingString = '';
  String _nString = '';
  String _pitch = '';
  String _designPitch = '';
  String _designHeading = '';
  String _length = '';
  String _time = '';
  int _repoId = 0;
  Timer? _timer;

  late DataGridController scrollController;

  @override
  void initState() {
    super.initState();

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
      // if (bluetooth.currentDevice == null) {
      //   Navigator.of(context).pop();
      //   SmartDialog.showToast('请连接蓝牙');
      // } else {
      //   open();
      // }
    });
    scrollController = DataGridController();
  }

  // 弹窗
  void open() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter state) {
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
                      minWidth: 550, // 设置最小宽度
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _buildRowMineSelect(state),
                          _buildRowWorkSelect(state),
                          _buildRowFactorySelect(state),
                          _buildRowDrillSelect(state),
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
                      ),
                    )),
                title: const Text(
                  '添加矿区',
                  style: TextStyle(fontSize: 14),
                ),
                actions: <Widget>[
                  TextButton(
                    style:
                        TextButton.styleFrom(backgroundColor: Colors.black12),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      '取消',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () async {
                      if (_controllerName.text != '' &&
                          _controllerPitch.text != '' &&
                          _controllerHeading.text != '') {
                        print('长度');
                        print(int.tryParse(_controllerLen.text));
                        int id = await DatabaseHelper().insertRepo(RepoModel(
                            len: int.tryParse(_controllerLen.text)!,
                            name: _controllerName.text,
                            mnTime: DateTime.now().toString()));
                        _repoId = id;
                        MyTime.setRepoId(_repoId);
                        setState(() {
                          isSync = true;
                          // 矿区
                          _mineString = _selectedMine!.name;
                          MyTime.setMine(_mineString);
                          // 工作面
                          _workString = _selectedWork!.name;
                          MyTime.setWork(_workString);
                          // 钻厂
                          _factoryString = _selectedFactory!.name;
                          MyTime.setFactory(_factoryString);
                          // 钻孔
                          _drillingString = _selectedDrilling!.name;
                          MyTime.setDirlling(_drillingString);
                          // 钻杆长度
                          _length = _controllerLen.text;
                          MyTime.setLength(_length);
                          // 检测名称
                          _nString = _controllerName.text;
                          MyTime.setMonName(_nString);
                          // 设计俯仰角
                          _designPitch = _controllerPitch.text;
                          MyTime.setPitch(_designPitch);
                          // 设计方位角
                          _designHeading = _controllerHeading.text;
                          MyTime.setHeading(_designHeading);
                          // repoid
                          //关闭对话框并保存repo
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
        });
      },
    );
  }

  /// 矿区
  Widget _buildRowMineSelect(StateSetter state) {
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
          child: DropdownButtonFormField<MyMine>(
            value: _selectedMine,
            hint: const Text('请选择一个选项'),
            items: _miningArea.map((MyMine value) {
              return DropdownMenuItem<MyMine>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            onChanged: (MyMine? newValue) {
              state(() {
                _selectedMine = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
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
  Widget _buildRowWorkSelect(StateSetter state) {
    List<MyWork> showList =
        _work.where((i) => i.mineId == _selectedMine?.id).toList();
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
          child: DropdownButtonFormField<MyWork>(
            value: _selectedWork,
            hint: const Text('请选择一个选项'),
            items: showList.map((MyWork value) {
              return DropdownMenuItem<MyWork>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            onChanged: (MyWork? newValue) {
              state(() {
                _selectedWork = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
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
  Widget _buildRowFactorySelect(StateSetter state) {
    List<MyFactory> showList =
        _factory.where((i) => i.workId == _selectedWork?.id).toList();
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
          child: DropdownButtonFormField<MyFactory>(
            value: _selectedFactory,
            hint: const Text('请选择一个选项'),
            items: showList.map((MyFactory value) {
              return DropdownMenuItem<MyFactory>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            onChanged: (MyFactory? newValue) {
              state(() {
                _selectedFactory = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
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
  Widget _buildRowDrillSelect(StateSetter state) {
    List<MyDrilling> showList =
        _drilling.where((i) => i.factoryId == _selectedFactory?.id).toList();
    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            '钻孔:',
            style: TextStyle(fontSize: 12),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField<MyDrilling>(
            value: _selectedDrilling,
            hint: const Text('请选择一个选项'),
            items: showList.map((MyDrilling value) {
              return DropdownMenuItem<MyDrilling>(
                value: value,
                child: Text(value.name),
              );
            }).toList(),
            onChanged: (MyDrilling? newValue) {
              state(() {
                _selectedDrilling = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
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
    print('定时同步');
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
        // _time = analytical.dataTime();
        String pitch = analytical.getPitch();
        setState(() {
          _pitch = pitch;
        });
      }
    });
  }

  //定点测量
  Future<void> savePitch() async {
    // 最后一条数据
    List<DataListModel> endLen = await DatabaseHelper()
        .getDataListByRepoId(_repoId); // employees[employees.length - 1];

    String _times = Analytical([]).formatTime(_currentTime);
    int id = await DatabaseHelper().insertDataList(DataListModel(
      time: _times,
      // 深度等于长度的累加
      depth: (endLen.length + 1) * int.parse(_length),
      repoId: _repoId,
      designPitch: double.parse(_designPitch),
      designHeading: double.parse(_designHeading),
    ));
    DataListModel rows = DataListModel(
      id: id,
      // pitch: null,
      time: _times,
      // 长度累加
      depth: (endLen.length + 1) * int.parse(_length),
    );

    setState(() {
      employees.add(rows);
      employeeDataSource = EmployeeDataSource(employeeData: employees);
    });
    // 在数据更新后滚动到底部
    Future.delayed(Duration(milliseconds: 100), () {
      scrollController.scrollToRow(employeeDataSource.rows.length - 1);
    });
  }

  //删除末尾数据
  void delePop() {
    print(employees.last.id);
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
        child: Container(
          color: const Color.fromRGBO(238, 239, 241, 0.8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 确保高度适应内容
              children: [
                Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(
                    left: 10,
                    bottom: 10,
                    right: 10,
                    top: 10,
                  ),
                  child: Padding(
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
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 130,
                  child: Row(
                    children: [
                      Container(
                        color: Colors.white,
                        margin: const EdgeInsets.only(
                          left: 10,
                          bottom: 10,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                                '累计时间：${Analytical([]).formatTime(_currentTime)}'),
                            const SizedBox(
                              height: 20,
                            ),
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
                                // savePitch();
                                if (isFixed) {
                                  savePitch();
                                }
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
                                //删除末尾数据
                                if (isPop) {
                                  delePop();
                                }
                              },
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.white,
                          margin: const EdgeInsets.only(
                              left: 10, right: 10, bottom: 10),
                          child: SfDataGrid(
                            headerRowHeight: 40,
                            source: employeeDataSource,
                            controller: scrollController,
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
                                  columnName: 'depth',
                                  label: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      color: Colors.black12,
                                      // const Color.fromRGBO( 234, 236, 255, 1),
                                      child: const Text('深度'))),
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
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
              ],
            ),
          ),
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
        .asMap() // 将列表转换为 Map，key 为 index
        .entries // 获取键值对 (index, element)
        .map<DataGridRow>((entry) => DataGridRow(cells: [
              DataGridCell<int>(columnName: 'id', value: entry.key + 1),
              DataGridCell<num>(columnName: 'depth', value: entry.value.depth),
              DataGridCell<String>(columnName: 'time', value: entry.value.time),
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
