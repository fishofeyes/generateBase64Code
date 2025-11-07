import 'dart:convert';
import 'dart:math';

import 'package:custom_base64/page/base64/view/my_input.dart';
import 'package:custom_base64/tool/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Base64Page extends StatefulWidget {
  const Base64Page({super.key});

  @override
  State<Base64Page> createState() => _Base64PageState();
}

class _Base64PageState extends State<Base64Page>
    with AutomaticKeepAliveClientMixin {
  String result = "";
  String decodeResult = "";
  String useStr = "";
  String useDetailStr = "";
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _lengthVC = TextEditingController();
  final TextEditingController _randomVc = TextEditingController();
  final ascCode = const AsciiCodec();
  List<String> randomList = [];
  CodeEnum intTab = CodeEnum.dart; // 0: dart 1: swift, 2: kotlin
  bool isEncode = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _lengthVC.dispose();
    _randomVc.dispose();
    super.dispose();
  }

  void _base64Encode() {
    isEncode = true;
    final i = _inputController.text;
    final str = base64Encode(utf8.encode(i));
    setState(() {
      result = str;
    });
  }

  void _convert() {
    isEncode = true;
    if (randomList.isEmpty) {
      _generateStr();
    }
    final randomStr = _randomVc.text;
    final String t = _randomVc.text;
    final i = _inputController.text;
    final str = base64Encode(utf8.encode(i));
    final length = str.length;
    final idx = Random().nextInt(length - 2);
    final encodeStr = str.substring(0, idx) + t + str.substring(idx);
    setState(() {
      result = encodeStr;
      switch (intTab) {
        case CodeEnum.dart:
          useStr = 'utf8.decode(base64Decode("".replaceAll("$randomStr", "")))';
          useDetailStr =
              'utf8.decode(base64Decode("$encodeStr".replaceAll("$randomStr", "")))';
          break;
        case CodeEnum.swift:
          useStr =
              'String(data: Data(base64Encoded: "".replacingOccurrences(of: "$randomStr", with: ""))!, encoding: .utf8)';
          useDetailStr =
              'String(data: Data(base64Encoded: "$encodeStr".replacingOccurrences(of: "$randomStr", with: ""))!, encoding: .utf8)';
          break;
        case CodeEnum.kotlin:
          useStr = 'String(Base64.decode("".replace("$randomStr", ""), 0))';
          useDetailStr =
              'String(Base64.decode("$encodeStr".replace("$randomStr", ""), 0))';
          break;
      }
    });
  }

  void _decode() {
    isEncode = false;
    decodeResult = utf8.decode(
        base64Decode(_inputController.text.replaceAll(_randomVc.text, "")));
    setState(() {});
  }

  void _copy(String text) {
    myCopy(context, text);
  }

  void _generateStr() {
    int length = 10;
    randomList.clear();
    for (int i = 0; i < length; i++) {
      final str = generateRandomStringSecure(int.tryParse(_lengthVC.text) ?? 0);
      randomList.add(str);
    }
    _randomVc.text = randomList.first;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          children: [
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
                            "Random string length",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: MyInput(
                                  controller: _lengthVC,
                                  hintText: "random length default: 10",
                                  formatter: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _generateStr,
                                icon: const Icon(Icons.check_circle),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                const Text("Random string: "),
                                Expanded(
                                  child: TextField(controller: _randomVc),
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
                                          _randomVc.text = e;
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
                                      icon: const Icon(Icons.copy),
                                      iconSize: 14,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          MyInput(
                            controller: _inputController,
                            maxLine: 5,
                            hintText: "Paste content",
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
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
                                      "insert random str base64 encode",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: InkWell(
                                  onTap: _base64Encode,
                                  child: Container(
                                    width: double.infinity,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "base64 encode",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: _decode,
                            child: Container(
                              width: double.infinity,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "decode",
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
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Visibility(
                          visible: !isEncode,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  decodeResult,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 100,
                                ),
                              ),
                              TextButton(
                                onPressed: () => _copy(decodeResult),
                                child: const Icon(
                                  Icons.copy,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                        Visibility(
                          visible: result.isNotEmpty && isEncode,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      result,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
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
                                  tabs: CodeEnum.values
                                      .map((e) => Tab(
                                            text: e.name,
                                          ))
                                      .toList(),
                                  onTap: (e) {
                                    intTab = CodeEnum.values[e];
                                    _convert();
                                  },
                                ),
                              ),
                              const Text(
                                "use empty str:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      useStr,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
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
                              const Text(
                                "use detail str:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      useDetailStr,
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
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

  @override
  bool get wantKeepAlive => true;
}
