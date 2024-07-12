import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String nameAndType;

  const HomeCard(this.nameAndType, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(nameAndType);
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/$nameAndType.png'),
            fit: BoxFit
                .fill, // 可以根据需要调整 BoxFit 的属性，如 BoxFit.cover, BoxFit.fill, 等
          ),
        ),
      ),
    ));
  }
}
