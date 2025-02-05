import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CodeEnum { dart, swift, kotlin }

void myCopy(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  const snackBar = SnackBar(
    content: Text('Copy successfully!'),
    showCloseIcon: true,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void alertTitle(BuildContext context, String title) {
  showDialog(
      context: context,
      builder: (c) {
        return AlertDialog(
          title: Text(title),
          content: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        );
      });
}
