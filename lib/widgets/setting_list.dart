import 'package:flutter/material.dart';
import 'package:bluetooth_mini/widgets/cus_dialog.dart';

class ListCard extends StatefulWidget {
  final String buttonText;
  final List<String> items;
  final Widget? contentBody;
  final Widget? title;
  final List<Widget>? actions;
  final void Function() onDele;

  const ListCard(
      {Key? key,
      required this.buttonText,
      required this.items,
      this.contentBody,
      this.title,
      this.actions,
      required this.onDele})
      : super(key: key);

  @override
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  // 假设的添加新项的方法
  void addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogKeyboard(
          contentBody: widget.contentBody,
          title: widget.title,
          actions: widget.actions,
        );
      },
    );
  }

  // 删除
  void _deleteItem(int index) {
    setState(() {
      widget.items.removeAt(index);
      widget.onDele();
    });
  }

  // final text = widget.buttonText
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                addItem(); // 点击按钮时添加新项
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(10)), // 设置圆角为10
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8), // 可选，添加一些间距
                  Text(widget.buttonText,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
            // 动态列表
            Expanded(
              child: ListView.builder(
                itemCount: widget.items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(widget.items[index]),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteItem(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
