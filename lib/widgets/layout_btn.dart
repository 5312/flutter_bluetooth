import 'package:flutter/material.dart';
import 'package:bluetooth_mini/db/my_sp.dart';

// 用户名及注销按钮
class LayoutBtn extends StatefulWidget {
  const LayoutBtn({Key? key}) : super(key: key);

  @override
  State<LayoutBtn> createState() => _LayoutBtnState();
}

class _LayoutBtnState extends State<LayoutBtn> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // 异步函数来加载用户名称
  void _loadUserName() async {
    String userName = MySP.getName() ?? '';
    setState(() {
      _userName = userName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/bottomlogin.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  '当前用户：$_userName',
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Material(
                color: Colors.blue,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(9),
                  bottomRight: Radius.circular(9),
                ),
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.5),
                  highlightColor: Colors.white.withOpacity(0.3),
                  onTap: () {
                    MySP.removeToken();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      'login',
                      (route) => false,
                    );
                  },
                  child: const Center(
                    child: Text(
                      '注销',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
