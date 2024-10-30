import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  // 提示文字
  final String label;
  final String suffixIcon;
  final TextEditingController controller;

  const MyForm(
      {Key? key,
      required this.label,
      required this.suffixIcon,
      required this.controller})
      : super(key: key);

  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 40,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 90,
                child: Text(
                  '${widget.label} :',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  keyboardType: widget.label == '检测名称'
                      ? TextInputType.text
                      : TextInputType.number, // 限制输入为数字
                  decoration: InputDecoration(
                    hintText: '请输入${widget.label}',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      // 为后缀文本添加右侧内边距
                      child: Text(widget.suffixIcon,
                          style: const TextStyle(fontSize: 15)),
                    ), // 后缀文本
                    //border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.only(
                      top: 0,
                      left: 10,
                      right: 10,
                      bottom: 0,
                    ), // 调整内部间距
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入一些内容';
                    } else if (widget.label == '钻杆长度') {
                      if (int.tryParse(value) == null) {
                        return '请输入有效的数字';
                      }
                      return null;
                    } else {
                      return '';
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
