import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyInput extends StatelessWidget {
  final TextEditingController controller;
  final List<TextInputFormatter>? formatter;
  final int? maxLine;
  final String? hintText;
  const MyInput(
      {super.key,
      required this.controller,
      this.formatter,
      this.maxLine,
      this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: maxLine,
      controller: controller,
      inputFormatters: formatter,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.16),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.16),
          ),
        ),
      ),
    );
  }
}
