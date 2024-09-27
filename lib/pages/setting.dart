import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bluetooth_mini/widgets/setting_list.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/db/my_setting.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:bluetooth_mini/db/interfaceDb.dart';
import 'dart:convert';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller_work = TextEditingController();
  final TextEditingController _controller_factory = TextEditingController();
  final TextEditingController _controller_drilling = TextEditingController();

  String? _selectedMine;
  String? _selectedWork;
  String? _selectedFactory;

  List<MyMine> _miningArea = [];
  List<MyWork> _work = [];
  List<MyFactory> _factory = [];
  List<MyDrilling> _drilling = [];

  int? selectedItem1;
  int? selectedItem2;
  int? selectedItem3;

  int? selectedIndex1 = null;
  int? selectedIndex2 = null;
  int? selectedIndex3 = null;
  int? selectedIndex4 = null;

  @override
  void initState() {
    _miningArea = MySetting.getMine();
    _work = MySetting.getWork();

    _factory = MySetting.getFactory();
    _drilling = MySetting.getDrilling();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 矿区
  Widget _buildRowWorkSelect() {
    print(_miningArea.map((item) => item.toJson()).toList());

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
            items: _miningArea.map((MyMine value) {
              return DropdownMenuItem<String>(
                value: value.name,
                child: Text(value.name),
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
  Widget _buildRowFactorySelect() {
    final showList = _work.where((i) => i.mineId == selectedItem1).toList();
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
            items: showList.map((MyWork value) {
              return DropdownMenuItem<String>(
                value: value.name,
                child: Text(value.name),
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
  Widget _buildRowDrillSelect() {
    final showList = _factory.where((i) => i.workId == selectedItem2).toList();
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
            items: showList.map((MyFactory value) {
              return DropdownMenuItem<String>(
                value: value.name,
                child: Text(value.name),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('钻孔基础信息设置'),
      body: Container(
          color: const Color.fromRGBO(238, 239, 241, 0.8),
          child: Padding(
              padding: const EdgeInsets.only(
                  left: 19, right: 19, top: 19, bottom: 19),
              child: Row(children: <Widget>[
                // 矿区
                Expanded(
                  child: ListCard<MyMine>(
                    items: _miningArea,
                    selectedIndex: selectedIndex1,
                    buttonText: '添加矿区',
                    canOpen: () {
                      return true;
                    },
                    onItemSelected: (int item, int index) {
                      setState(() {
                        selectedItem2 = null;
                        selectedItem3 = null;
                        _selectedMine =
                            _miningArea.firstWhere((i) => i.id == item).name;
                        // 自己选中
                        if (selectedIndex1 == index) {
                          selectedIndex1 = null;
                        } else {
                          selectedIndex1 = index;
                        }
                        selectedItem1 = item; // 更新选中项
                        // 其他清空
                        _selectedWork = null;
                        selectedIndex2 = null;
                        selectedIndex3 = null;
                      });
                    },
                    contentBody: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 500, // 设置最大宽度
                      ),
                      child: Row(
                        children: [
                          const Text(
                            '矿区名称:',
                            style: TextStyle(fontSize: 12),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                            ),
                          )
                        ],
                      ),
                    ),
                    title: const Text(
                      '添加矿区',
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: <Widget>[
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(() {
                            _miningArea.add(MyMine(
                                _miningArea.length + 1, _controller.text));
                            MySetting.setMine(_miningArea);
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                    onDele: (int itemId) {
                      setState(() {
                        selectedItem1 = null;
                        _miningArea
                            .removeWhere((element) => element.id == itemId);
                        MySetting.setMine(_miningArea);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // 工作面
                Expanded(
                  child: ListCard<MyWork>(
                    buttonText: '添加工作面',
                    selectedIndex: selectedIndex2,
                    items:
                        _work.where((i) => i.mineId == selectedItem1).toList(),
                    canOpen: () {
                      if (selectedItem1 == null) {
                        SmartDialog.showToast('请先选择矿区');
                        return false;
                      } else {
                        return true;
                      }
                    },
                    onItemSelected: (int item, int index) {
                      setState(() {
                        selectedItem2 = item; // 更新选中项id
                        selectedItem3 = null;
                        _selectedWork =
                            _work.firstWhere((i) => i.id == item).name;
                        if (selectedIndex2 == index) {
                          selectedIndex2 = null;
                        } else {
                          selectedIndex2 = index;
                        }
                        // 其他清空
                        selectedIndex3 = null;
                      });
                    },
                    actions: <Widget>[
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            if (selectedItem1 != null) {
                              _work.add(MyWork(_work.length + 1, selectedItem1!,
                                  _controller_work.text));
                              MySetting.setWork(_work);
                            }
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onDele: (int itemId) {
                      setState(() {
                        selectedItem2 = null;
                        _work.removeWhere((element) => element.id == itemId);
                        MySetting.setWork(_work);
                      });
                    },
                    contentBody: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 500, // 设置最大宽度
                      ),
                      child: Column(
                        children: [
                          _buildRowWorkSelect(),
                          Row(
                            children: [
                              const SizedBox(
                                width: 100,
                                child: Text(
                                  '工作面名称:',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller_work,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    title: const Text(
                      '添加工作面',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 钻厂
                Expanded(
                  child: ListCard(
                    buttonText: '添加钻厂',
                    selectedIndex: selectedIndex3,
                    items: _factory
                        .where((i) => i.workId == selectedItem2)
                        .toList(),
                    canOpen: () {
                      if (selectedItem2 == null) {
                        SmartDialog.showToast('请先选择工作面');
                        return false;
                      } else {
                        return true;
                      }
                    },
                    onItemSelected: (int item, int index) {
                      setState(() {
                        selectedItem3 = item; // 更新选中项id
                        _selectedFactory =
                            _factory.firstWhere((i) => i.id == item).name;
                        if (selectedIndex3 == index) {
                          selectedIndex3 = null;
                        } else {
                          selectedIndex3 = index;
                        }
                      });
                    },
                    contentBody: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 500, // 设置最大宽度
                      ),
                      child: Column(
                        children: <Widget>[
                          _buildRowWorkSelect(),
                          _buildRowFactorySelect(),
                          Row(
                            children: [
                              const Text(
                                '钻厂名称:',
                                style: TextStyle(fontSize: 12),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller_factory,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    title: const Text(
                      '添加钻厂',
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: <Widget>[
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            if (selectedItem2 != null) {
                              _factory.add(MyFactory(_factory.length + 1,
                                  selectedItem2!, _controller_factory.text));
                              MySetting.setFactory(_factory);
                            }
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onDele: (int itemId) {
                      setState(() {
                        selectedItem3 = null;
                        _factory.removeWhere((element) => element.id == itemId);
                        MySetting.setFactory(_factory);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // 钻孔
                Expanded(
                  child: ListCard(
                    buttonText: '添加钻孔',
                    selectedIndex: selectedIndex4,
                    items: _drilling
                        .where((i) => i.factoryId == selectedItem3)
                        .toList(),
                    canOpen: () {
                      if (selectedItem3 == null) {
                        SmartDialog.showToast('请先选择钻孔');
                        return false;
                      } else {
                        return true;
                      }
                    },
                    onItemSelected: (int item, int index) {},
                    contentBody: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 500, // 设置最大宽度
                      ),
                      child: Column(
                        children: <Widget>[
                          _buildRowWorkSelect(),
                          _buildRowFactorySelect(),
                          _buildRowDrillSelect(),
                          Row(
                            children: [
                              const Text(
                                '钻孔名称:',
                                style: TextStyle(fontSize: 12),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller_drilling,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    title: const Text(
                      '添加钻孔',
                      style: TextStyle(fontSize: 14),
                    ),
                    actions: <Widget>[
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            if (selectedItem3 != null) {
                              _drilling.add(MyDrilling(_drilling.length + 1,
                                  selectedItem3!, _controller_drilling.text));
                              MySetting.setDrilling(_drilling);
                            }
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onDele: (int itemId) {
                      setState(() {
                        _drilling
                            .removeWhere((element) => element.id == itemId);
                        MySetting.setDrilling(_drilling);
                      });
                    },
                  ),
                ),
              ]))),
    );
  }
}
