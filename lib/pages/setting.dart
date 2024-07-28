import 'package:flutter/material.dart';
import 'package:bluetooth_mini/widgets/setting_list.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/db/my_setting.dart';

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

  List<String> _miningArea = [];
  List<String> _work = [];
  List<String> _factory = [];
  List<String> _drilling = [];

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

  /// 工作面组件模块
  Widget _buildRowWorkSelect() {
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

  /// 钻厂组件模块
  Widget _buildRowFactorySelect() {
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

  /// 钻厂组件模块
  Widget _buildRowDrillSelect() {
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
                Expanded(
                  child: ListCard(
                    items: _miningArea,
                    buttonText: '添加矿区',
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
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black26),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _miningArea.add(_controller.text);
                            MySetting.setMine(_miningArea);
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onDele: () {
                      MySetting.setMine(_miningArea);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListCard(
                    buttonText: '添加工作面',
                    items: _work,
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
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black26),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _work.add(_controller_work.text);
                            MySetting.setWork(_work);
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onDele: () {
                      MySetting.setWork(_work);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListCard(
                    buttonText: '添加钻厂',
                    items: _factory,
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
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black26),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _factory.add(_controller_factory.text);
                            MySetting.setFactory(_factory);
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onDele: () {
                      MySetting.setFactory(_factory);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListCard(
                    buttonText: '添加钻孔',
                    items: _drilling,
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
                                '矿区名称:',
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
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black26),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消',
                            style: TextStyle(color: Colors.black)),
                      ),
                      TextButton(
                        style:
                            TextButton.styleFrom(backgroundColor: Colors.blue),
                        onPressed: () {
                          setState(() {
                            _drilling.add(_controller_drilling.text);
                            MySetting.setDrilling(_drilling);
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    onDele: () {
                      MySetting.setDrilling(_drilling);
                    },
                  ),
                ),
              ]))),
    );
  }
}
