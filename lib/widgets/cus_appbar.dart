import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  const CustomAppBar(this.title, {Key? key, this.height = kToolbarHeight})
      : super(key: key);

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
          leading: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  'navigator',
                  (route) => false,
                );
                // 在这里处理返回逻辑，比如Navigator.pop(context);
              },
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
