import 'package:bluetooth_mini/provider/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:bluetooth_mini/provider/bluetooth_manager.dart';



List<SingleChildWidget> topProviders = [
  ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ChangeNotifierProvider(create: (_) => BluetoothManager()),

];