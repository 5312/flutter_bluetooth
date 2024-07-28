import 'package:flutter/material.dart';

class DialogKeyboard extends StatelessWidget {
  final Widget? contentBody;
  final Widget? title;
  final List<Widget>? actions;

  const DialogKeyboard({Key? key, this.contentBody, this.title, this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        padding: const EdgeInsets.all(5),
        // height: 100,
        child: ListView(
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              title: title,
              content: contentBody,
              actions: actions,
            ),
          ],
        ),
      ),
    );
  }
}
