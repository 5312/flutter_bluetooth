import 'package:flutter/material.dart';
import 'package:bluetooth_mini/widgets/setting_list.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _miningArea = [];
  final List<String> _work = [];
  final List<String> _factory = [];
  final List<String> _drilling = [];
  final List<String> data = ['语文', '数学', '英语', '物理', '化学', '生物', '地理'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSelect(String? value) {
    setState(() {
    });
  }

  List<DropdownMenuEntry<String>> _buildMenuList(List<String> data) {
    return data.map((String value) {
      return DropdownMenuEntry<String>(value: value, label: value);
    }).toList();
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
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
                          DropdownMenu<String>(
                            menuHeight: 200,
                            initialSelection: data.first,
                            onSelected: _onSelect,
                            dropdownMenuEntries: _buildMenuList(data),
                          ),
                          Row(
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
                            _work.add(_controller.text);
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
                            _factory.add(_controller.text);
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
                            _drilling.add(_controller.text);
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '保存',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ]))),
    );
  }
}
