import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('钻孔轨迹仪'), centerTitle: true),
      body: Center(
        child: ElevatedButton(
          child: Text("连接蓝牙"),
          onPressed: () {
            Navigator.of(context).pushNamed('blueoothList');
          },
        ),
      ),
    );
  }
}
