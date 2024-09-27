import 'package:flutter/material.dart';
import 'package:bluetooth_mini/widgets/cus_dialog.dart';

class ListCard<T> extends StatefulWidget {
  final String buttonText;
  final List<T> items;
  final Widget? contentBody;
  final Widget? title;
  final List<Widget>? actions;
  final void Function(int itemId) onDele;
  final Function(int id,int index) onItemSelected;
  final int? selectedIndex;// 选中的索引
  final bool Function()? canOpen;

  const ListCard(
      {Key? key,
      required this.buttonText,
      required this.items,
      this.contentBody,
      this.title,
      this.selectedIndex,
      this.actions,
      required this.onDele,
      required this.onItemSelected,
      this.canOpen})
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
          actions: [_cancelBtn(), ...?widget.actions],
        );
      },
    );
  }

  // 取消按钮
  Widget _cancelBtn() {
    return TextButton(
      style: TextButton.styleFrom(backgroundColor: Colors.black26),
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: const Text('取消', style: TextStyle(color: Colors.black)),
    );
  }

  // 删除
  void _deleteItem(int index) {
    setState(() {
      int itemId = widget.items[index].id;
      widget.onDele(itemId);
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
                if (widget.canOpen!()) {
                  addItem();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(10)), // 设置圆角为10
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
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
                  final isSelected = widget.selectedIndex == index;
                  return Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromRGBO(235, 239, 255, 1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10), // 圆角半径
                    ),
                    child: ListTile(
                        title: Text(
                          widget.items[index].name,
                          style: TextStyle(
                            color: isSelected
                                ? const Color.fromRGBO(75, 116, 255, 1)
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        tileColor:
                            isSelected ? Colors.blueAccent : Colors.transparent,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteItem(index),
                        ),
                        onTap: () {
                          widget.onItemSelected(
                              widget.items[index].id,index); // 将选中的项传递给父组件
                        }),
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
