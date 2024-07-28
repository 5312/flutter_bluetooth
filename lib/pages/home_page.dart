import 'package:flutter/material.dart';
import 'package:bluetooth_mini/widgets/home_card.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/widgets/layout_btn.dart';
import 'package:bluetooth_mini/widgets/bluetooth_devices.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    // 跳转 homecard 不会执行这里
    // 退出登录会执行
    // print('homedispose');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar('钻孔轨迹仪'),
      body: Padding(
        padding: EdgeInsets.only(left: 33, right: 33, top: 20, bottom: 33),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  DevicesState(),
                  SizedBox(height: 13),
                  LayoutBtn(),
                ],
              ),
            ),
            SizedBox(width: 13),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(flex: 1, child: HomeCard('setting')),
                SizedBox(height: 13),
                Expanded(
                  flex: 1,
                  child: HomeCard('data'),
                ),
              ],
            ),
            SizedBox(width: 13),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: HomeCard('scan'),
                ),
                SizedBox(height: 13),
                Expanded(
                  flex: 1,
                  child: HomeCard('repo'),
                ),
              ],
            ),
            SizedBox(width: 13),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: HomeCard('timeout'),
                ),
                SizedBox(height: 13),
                Expanded(flex: 1, child: HomeCard('cloud')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
