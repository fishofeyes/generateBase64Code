import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result = "";
  String randomStr = "";
  String useStr = "";
  String useDetailStr = "";
  TextEditingController _inputController = TextEditingController();
  TextEditingController _lenthVC = TextEditingController();
  final ascCode = AsciiCodec();
  List<String> randomList = [];
  int intTab = 0; // 0: dart 1: swift, 2: kotlin
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _lenthVC.dispose();
    super.dispose();
  }

  void _convert() {
    if (randomStr.isEmpty) {
      _generateStr();
    }
    final String t = randomStr;
    final i = _inputController.text;
    final str = base64Encode(utf8.encode(i));
    final length = str.length;
    final idx = Random().nextInt(length - 2);
    final encodeStr = str.substring(0, idx) + t + str.substring(idx);
    setState(() {
      result = encodeStr;
      switch (intTab) {
        case 0:
          useStr = 'utf8.decode(base64Decode("".replaceAll("$randomStr", "")))';
          useDetailStr =
              'utf8.decode(base64Decode("$encodeStr".replaceAll("$randomStr", "")))';
          break;
        case 1:
          useStr =
              'String(data: Data(base64Encoded: "".replacingOccurrences(of: "$randomStr", with: ""))!, encoding: .utf8)';
          useDetailStr =
              'String(data: Data(base64Encoded: "$encodeStr".replacingOccurrences(of: "$randomStr", with: ""))!, encoding: .utf8)';
          break;
        case 2:
          useStr = 'String(Base64.decode("".replace("$randomStr", ""), 0))';
          useDetailStr =
              'String(Base64.decode("$encodeStr".replace("$randomStr", ""), 0))';
          break;
      }
    });
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    const snackBar = SnackBar(
      content: Text('Copy successfully!'),
      showCloseIcon: true,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  String _generateRandomStringSecure(int length) {
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

  void _generateStr() {
    int length = 10;
    randomList.clear();
    for (int i = 0; i < length; i++) {
      final str = _generateRandomStringSecure(int.tryParse(_lenthVC.text) ?? 0);
      randomList.add(str);
    }
    randomStr = randomList.first;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          children: [
            const Text(
              "Randomly insert characters",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Content",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _lenthVC,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: "random length default: 10",
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
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
                                ),
                              ),
                              IconButton(
                                onPressed: _generateStr,
                                icon: Icon(Icons.check_circle),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                const Text("Random string: "),
                                Text(
                                  randomStr,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            children: [
                              ...randomList.map(
                                (e) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          randomStr = e;
                                        });
                                      },
                                      child: SizedBox(
                                        width: 100,
                                        child: Text(
                                          e,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _copy(e),
                                      icon: Icon(Icons.copy),
                                      iconSize: 14,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            maxLines: 5,
                            controller: _inputController,
                            decoration: InputDecoration(
                              hintText: "paste content",
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
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _convert,
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "submit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Result: ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Visibility(
                          visible: result.isNotEmpty,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      result,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _copy(result),
                                    child: const Icon(
                                      Icons.copy,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              DefaultTabController(
                                length: 3,
                                child: TabBar(
                                  tabs: [
                                    Tab(text: "Dart"),
                                    Tab(text: "Swift"),
                                    Tab(text: "Kotlin"),
                                  ],
                                  onTap: (e) {
                                    intTab = e;
                                    _convert();
                                  },
                                ),
                              ),
                              Text(
                                "use empty str:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      useStr,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _copy(useStr),
                                    child: const Icon(
                                      Icons.copy,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "use detail str:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      useDetailStr,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => _copy(useDetailStr),
                                    child: const Icon(
                                      Icons.copy,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
