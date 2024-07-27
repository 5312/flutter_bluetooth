import 'package:flutter/material.dart';

class TimeDrop extends StatefulWidget {
  // 提示文字
  final String label;

  const TimeDrop(this.label);

  @override
  _TimeDropState createState() => _TimeDropState();
}

class _TimeDropState extends State<TimeDrop> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedOption;
  final List<String> _options = ['1', '2', '3'];

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
                  '${widget.label}:',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedOption,
                  hint: Text('请选择一个选项'),
                  items: _options.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedOption = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请选择一个选项';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(
                      top: 0,
                      left: 10,
                      bottom: 0,
                    ),
                  ),
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
