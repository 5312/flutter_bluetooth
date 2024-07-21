import 'package:flutter/material.dart';
import 'package:bluetooth_mini/widgets/setting_list.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('钻孔基础信息设置'),
      body: Container(
          color: const Color.fromRGBO(238, 239, 241, 0.8),
          child: const Padding(
              padding:
                  EdgeInsets.only(left: 19, right: 19, top: 19, bottom: 19),
              child: Row(children: <Widget>[
                Expanded(
                  child: ListCard(buttonText: '添加矿区'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListCard(buttonText: '添加工作圈'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListCard(buttonText: '添加钻厂'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ListCard(buttonText: '添加钻孔'),
                ),
              ]))),
    );
  }
}
