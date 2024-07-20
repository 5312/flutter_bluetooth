import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bluetooth_mini/common/my_init.dart';
import 'package:bluetooth_mini/navigator/my_navigator.dart';
import 'package:bluetooth_mini/provider/my_provider.dart';
import 'package:bluetooth_mini/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 不加这个强制横竖屏会报错
  // 横屏
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
  // 网格线
  // debugPaintSizeEnabled = true;
  // Flutter 版本 (1.12.13+hotfix.5) 后，初始化插件必须加 ensureInitialized

  // 应用入口
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final easy = EasyLoading.init();
  final smartDialog = FlutterSmartDialog.init();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // 进行项目的预初始化
      future: MyInit.init(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // 初始化完成
          return MultiProvider(
            providers: topProviders,
            // 这里通过 Consumer 读取数据，灵活度高
            // 还有其他的读取方式，比如 context.read<ThemeProvider>()
            child: Consumer<ThemeProvider>(
              builder: (
                BuildContext context,
                ThemeProvider themeProvider,
                Widget? child,
              ) {
                return MaterialApp(
                  title: 'bluetooth_mini',
                  theme: themeProvider.getTheme(),
                  darkTheme: themeProvider.getTheme(isDarkMode: true),
                  themeMode: themeProvider.getThemeMode(),
                  localizationsDelegates: const [
                    // 本地化的代理类
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en', 'US'), // 美国英语
                    Locale('cn', 'ZH'), // 中文简体
                  ],
                  builder: (context, child) {
                    child = easy(context, child);
                    child = smartDialog(context, child);
                    return child;
                  },
                  initialRoute: 'navigator',
                  onGenerateRoute: MyNavigator.getInstance().onGenerateRoute,
                  navigatorObservers: [FlutterSmartDialog.observer],
                );
              },
            ),
          );
        } else {
          // 初始化未完成时，显示 loading 动画
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
