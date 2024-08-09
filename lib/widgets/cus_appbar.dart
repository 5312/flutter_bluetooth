import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  const CustomAppBar(this.title, {Key? key, this.height = kToolbarHeight})
      : super(key: key);

  // 弹出对话框
  Future<bool?> showDeleteConfirmDialog1(context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("提示"),
          content: const Text("您确定要退出定时同步吗?"),
          actions: <Widget>[
            TextButton(
              child: const Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            TextButton(
              child: const Text("确定"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
                Navigator.of(context).pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (title == '钻孔轨迹仪') {
      return PreferredSize(
        preferredSize: const Size.fromHeight(20.0), // 设置 AppBar 的高度
        child: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white),
      );
    }
    return PreferredSize(
      preferredSize: const Size.fromHeight(20.0), // 设置 AppBar 的高度
      child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          leading: IconButton(
              onPressed: () {
                print('---');
                print(title);
                if (title == '定时同步') {
                  showDeleteConfirmDialog1(context);
                } else {
                  Navigator.of(context).pop(context);
                }
              },
              icon: const Icon(Icons.arrow_back)),
          centerTitle: true,
          backgroundColor: Colors.white),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
