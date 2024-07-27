import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class ListCard extends StatefulWidget {
  final String buttonText;

  const ListCard({Key? key, required this.buttonText}) : super(key: key);

  @override
  _ListCardState createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  // 假设的列表数据
  List<String> items = [];

  final TextEditingController _controller = TextEditingController();

  // 假设的添加新项的方法
  void addItem() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            child: ListView(
              children: [
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  title: Text(
                    '添加矿区',
                    style: TextStyle(fontSize: 12),
                  ),
                  content: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 500, // 设置最大宽度
                    ),
                    child: Row(
                      children: [
                        Text('矿区名称:'),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                                // labelText: 'Input',
                                ),
                          ),
                        )
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('保存'),
                      onPressed: () {
                        // print(_controller.text);
                       setState(() {
                         items.add(_controller.text);
                       });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    // setState(() {
    //   items.add('Item ${items.length + 1}');
    // });
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
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]),
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
