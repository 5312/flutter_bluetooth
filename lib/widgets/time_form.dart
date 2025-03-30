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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 30, // 进一步减小高度
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 70, // 减小标签宽度
                child: Text(
                  '${widget.label} :',
                  style: const TextStyle(fontSize: 11), // 减小标签字体
                ),
              ),
              const SizedBox(
                width: 2, // 减小间距
              ),
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  style: const TextStyle(fontSize: 12), // 减小字体大小
                  keyboardType: widget.label == '检测名称'
                      ? TextInputType.text
                      : TextInputType.number, // 限制输入为数字
                  decoration: InputDecoration(
                    isDense: true, // 使表单更紧凑
                    hintText: '请输入${widget.label}',
                    hintStyle: const TextStyle(fontSize: 11), // 减小提示文字大小
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(top: 2), // 减小上间距
                      // 为后缀文本添加右侧内边距
                      child: Text(widget.suffixIcon,
                          style: const TextStyle(fontSize: 11)), // 减小后缀字体大小
                    ), // 后缀文本
                    //border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.only(
                      top: 0,
                      left: 5, // 减小左间距
                      right: 5, // 减小右间距
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
          height: 2, // 进一步减小底部间距
        )
      ],
    );
  }
}
