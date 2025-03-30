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
          physics: const NeverScrollableScrollPhysics(),
          children: [
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              title: title,
              content: contentBody,
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              buttonPadding: const EdgeInsets.symmetric(horizontal: 4),
              actions: actions,
            ),
          ],
        ),
      ),
    );
  }
}
