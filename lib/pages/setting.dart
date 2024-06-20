import 'package:flutter/material.dart';


class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('钻孔基础信息设置'),
      ),
      body: ListView(
        padding: EdgeInsets.only(
          left: 35,
          right: 35,
        ),
        children: [

        ],
      ),
    );
  }
}
