import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final double height;

  const CustomAppBar(this.title, {Key? key, this.height = kToolbarHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

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
          leading:new IconButton(onPressed: (){
            print('----');
            Navigator.of(context).pop(context);
          }, icon:Icon(Icons.arrow_back)) ,
          centerTitle: true,
          backgroundColor: Colors.white),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
