import 'package:flutter/material.dart';
import 'package:bluetooth_mini/db/my_sp.dart';
import 'package:bluetooth_mini/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class MePage extends StatefulWidget {
  const MePage({Key? key}) : super(key: key);

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('我的'),
      ),
      body: ListView(
        padding:const EdgeInsets.only(
          left: 35,
          right: 35,
        ),
        children: [
          OutlinedButton(
            child: const Text("亮色模式"),
            onPressed: () {
              context.read<ThemeProvider>().setThemeMode(ThemeMode.light);
            },
          ),
          OutlinedButton(
            child:const  Text("黑暗模式"),
            onPressed: () {
              context.read<ThemeProvider>().setThemeMode(ThemeMode.dark);
            },
          ),
          OutlinedButton(
            child: const Text("跟随系统"),
            onPressed: () {
              context.read<ThemeProvider>().setThemeMode(ThemeMode.system);
            },
          ),
          ElevatedButton(
            child:const  Text("退出登录"),
            onPressed: () {
              MySP.removeToken();
              Navigator.of(context).pushNamedAndRemoveUntil(
                'login',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
