
import 'package:flutter/material.dart';
import 'package:bluetooth_mini/db/my_sp.dart';
import 'package:bluetooth_mini/widgets/home_card.dart';
import 'package:bluetooth_mini/widgets/cus_appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar('钻孔轨迹仪'),
        body: Padding(
          padding:
              const EdgeInsets.only(left: 33, right: 33, top: 33, bottom: 33),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image:
                                  AssetImage('assets/images/home/device.png'),
                              fit: BoxFit
                                  .fill, // 可以根据需要调整 BoxFit 的属性，如 BoxFit.cover, BoxFit.fill, 等
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // 水平方向（垂直对齐）向左对齐
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.all(5.0), // 可选：添加一些内边距
                                  child: Text(
                                    "当前设备",
                                    textAlign: TextAlign.left, // 文本向左对齐
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(5.0), // 可选：添加一些内边距
                                  child: Text(
                                    "设备信息：TV410u-E3E",
                                    textAlign: TextAlign.left, // 文本向左对齐
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(
                                      top: 5, left: 5, bottom: 0),
                                  // 可选：添加一些内边距
                                  child: Text(
                                    "当前状态：断开",
                                    textAlign: TextAlign.left, // 文本向左对齐
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, left: 5, bottom: 0),
                                    // 可选：添加一些内边距
                                    child: SizedBox(
                                      height: 35,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushNamed('bluetoothList');
                                        },
                                        child: const Text(
                                          "连接蓝牙",
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          )),
                    ),
                    const SizedBox(height: 13),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/home/bottomlogin.png'),
                            fit: BoxFit
                                .fill, // 可以根据需要调整 BoxFit 的属性，如 BoxFit.cover, BoxFit.fill, 等
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            const Expanded(
                                flex: 1,
                                child: Center(
                                  child: Text(
                                    '当前用户：admin',
                                    style: TextStyle(color: Colors.blueAccent),
                                  ),
                                )),
                            Expanded(
                                flex: 1,
                                child: Material(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(9),
                                    // 左下角圆角半径
                                    bottomRight: Radius.circular(9), // 右下角圆角半径
                                  ),
                                  // 如果您不希望显示Material本身的背景颜色
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.5),
                                    // 设置水波纹颜色
                                    highlightColor:
                                        Colors.white.withOpacity(0.3),
                                    // 设置高亮颜色
                                    onTap: () {
                                      // 点击事件的处理函数
                                      // print('Container clicked!');
                                      MySP.removeToken();
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        'login',
                                        (route) => false,
                                      );
                                    },
                                    child: Container(
                                        width: double.infinity,
                                        child: const Center(
                                          child: Text(
                                            '注销',
                                            textAlign: TextAlign.center,
                                            // 文本向左对齐
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )),
                                  ),
                                ))
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 13),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, //垂直方向居中对齐
                  children: <Widget>[
                    Expanded(flex: 1, child: HomeCard('setting')),
                    const SizedBox(height: 13),
                    Expanded(
                      flex: 1,
                      child: HomeCard('data'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 13),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, //垂直方向居中对齐
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: HomeCard('scan'),
                    ),
                    const SizedBox(height: 13),
                    Expanded(
                      flex: 1,
                      child: HomeCard('repo'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 13),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, //垂直方向居中对齐
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: HomeCard('timeout'),
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    Expanded(flex: 1, child: HomeCard('cloud')),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
