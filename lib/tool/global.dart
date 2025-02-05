import 'dart:math';

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

String generateRandomStringSecure(int length) {
  const String chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random random = Random.secure();
  String result = '';
  if (length == 0) length = 10;
  for (int i = 0; i < length; i++) {
    result += chars[random.nextInt(chars.length)];
  }

  return result;
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
