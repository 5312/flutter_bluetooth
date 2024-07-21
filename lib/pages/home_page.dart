import 'package:flutter/material.dart';
import 'package:bluetooth_mini/widgets/home_card.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';
import 'package:bluetooth_mini/provider/BluetoothManager.dart';
import 'package:bluetooth_mini/widgets/layout_btn.dart';
import 'package:bluetooth_mini/widgets/bluetooth_devices.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
        padding:
            const EdgeInsets.only(left: 33, right: 33, top: 20, bottom: 33),
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
            const SizedBox(width: 13),
            const Column(
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
            const SizedBox(width: 13),
            const Column(
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
            const SizedBox(width: 13),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: HomeCard('timeout'),
                ),
                const SizedBox(height: 13),
                Expanded(flex: 1, child: HomeCard('cloud')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
