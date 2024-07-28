import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  // 提示文字
  final String label;
  final String suffixIcon;

  const MyForm({Key? key,required this.label,required this.suffixIcon}) : super(key: key);

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
                width: 100,
                child: Text(
                  '${widget.label} :',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: '请输入',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      // 为后缀文本添加右侧内边距
                      child: Text(widget.suffixIcon,
                          style: const TextStyle(fontSize: 15)),
                    ), // 后缀文本
                    border: const OutlineInputBorder(),
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
                    }
                    return null;
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
