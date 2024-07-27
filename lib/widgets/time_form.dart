import 'package:flutter/material.dart';

class MyForm extends StatefulWidget {
  // 提示文字
  final String label;
  final String suffixIcon;
  const MyForm(this.label,this.suffixIcon);

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 40,
          child: Row(
            children: <Widget>[
              Container(
                width: 100,
                child: Text(
                  '${widget.label} :',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: '请输入',
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      // 为后缀文本添加右侧内边距
                      child: Text('${widget.suffixIcon}', style: TextStyle(fontSize: 15)),
                    ), // 后缀文本
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(
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
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
