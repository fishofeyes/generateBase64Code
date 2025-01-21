import 'package:flutter/material.dart';

class ParseEnumPage extends StatefulWidget {
  const ParseEnumPage({super.key});

  @override
  State<ParseEnumPage> createState() => _ParseEnumPageState();
}

class _ParseEnumPageState extends State<ParseEnumPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _chooseFile() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _chooseFile,
                    child: Text(
                      "choose file",
                      style: TextStyle(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
