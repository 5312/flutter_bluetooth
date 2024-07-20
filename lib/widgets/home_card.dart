import 'package:flutter/material.dart';
import 'package:bluetooth_mini/provider/BluetoothManager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class HomeCard extends StatelessWidget {
  final String nameAndType;

  const HomeCard(this.nameAndType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BluetoothManager bluetooth =
        Provider.of<BluetoothManager>(context, listen: false);

    return Material(
        child: InkWell(
      onTap: () {
        if (bluetooth.adapterState == BluetoothAdapterState.off) {
          SmartDialog.showToast('请连接设备后再试！');
          return;
        } else {
          Navigator.of(context).pushNamed(nameAndType);
        }
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/$nameAndType.png'),
            fit: BoxFit
                .fill, // 可以根据需要调整 BoxFit 的属性，如 BoxFit.cover, BoxFit.fill, 等
          ),
        ),
      ),
    ));
  }
}
