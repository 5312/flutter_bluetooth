import 'package:flutter/material.dart';
import 'package:bluetooth_mini/db/my_sp.dart';
import 'package:bluetooth_mini/widgets/login_input.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey _formKey = GlobalKey<FormState>();
  TextEditingController _userController = TextEditingController(text: 'admin');
  TextEditingController _passwordController =
  TextEditingController(text: '12345678');

  // '记住密码' 复选框
  bool? _savePassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ListView 可以自适应键盘，防止键盘弹起后遮挡
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login/bg-logo.png'),
              fit: BoxFit.fitHeight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.only(
              top: 60,
              left: 35,
              right: 35,
            ),
            children: [
              Container(
                width: 100,
                height: 100,
              ),

              _form(),
              // _save(),
              _button(),
            ],
          ),
        ));
  }

  // 表单
  Widget _form() {
    return Form(
      // 设置 globalKey，用于后面获取 FormState
      key: _formKey,
      // 不开启自动校验表单，而是选择在点击登录按钮时校验
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 20, left: 200, right: 200),
            child: LoginInput(
              '请输入用户名',
              Icon(Icons.perm_identity),
              _userController,
              validator: (value) {
                return value!.trim().length > 0 ? null : "用户名不能为空";
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 20, left: 200, right: 200),
            child: LoginInput(
              '请输入密码',
              Icon(Icons.lock_outline),
              _passwordController,
              obscureText: true,
              validator: (value) {
                return value!.trim().length >= 8 ? null : "密码不能少于8位";
              },
            ),
          ),
        ],
      ),
    );
  }

  // 记住密码
  _save() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 50,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Checkbox(
            value: _savePassword,
            onChanged: (value) {
              setState(() {
                _savePassword = value;
              });
            },
          ),
          Text("记住密码"),
        ],
      ),
    );
  }

  // 登录按钮
  Widget _button() {
    return Padding(
      padding: EdgeInsets.only(bottom: 20, left: 200, right: 200),
      child: FractionallySizedBox(
        // 子元素占父元素的宽度比例
        child: SizedBox(
          height: 45,
          child: ElevatedButton(
            child: Text("登录"),
            style: ElevatedButton.styleFrom(
              // 圆角
              shape: StadiumBorder(),
            ),
            onPressed: () async {
              if ((_formKey.currentState as FormState).validate()) {
                // 验证通过提交数据
                // EasyLoading.show();
                // var res = await Api.login({
                //   'username': _userController.text.trim(),
                //   'password': _passwordController.text.trim(),
                // });
                // // 保存登录令牌
                MySP.setToken('adaadaa'); //res['data']['accessToken']);
                // EasyLoading.dismiss();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  'navigator',
                      (route) => false,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
