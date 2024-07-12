import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  const CustomAppBar(this.title, {Key? key, this.height = kToolbarHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PreferredSize(
      preferredSize: const Size.fromHeight(40.0), // 设置 AppBar 的高度
      child: AppBar(
          title:  Padding(
            padding: EdgeInsets.only(
              top: 20,
              bottom:20
            ),
            child: Text(
              this.title,
              style: TextStyle(fontSize: 18),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
