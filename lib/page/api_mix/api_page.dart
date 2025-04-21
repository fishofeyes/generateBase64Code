import 'package:custom_base64/page/base64/view/my_input.dart';
import 'package:custom_base64/tool/csv_tool.dart';
import 'package:custom_base64/tool/global.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';

class ApiPage extends StatefulWidget {
  const ApiPage({super.key});

  @override
  State<ApiPage> createState() => _ApiPageState();
}

class _ApiPageState extends State<ApiPage> with AutomaticKeepAliveClientMixin {
  DropItem? _apiIdFile;
  DropItem? _apiFile;
  bool _apiApiDragging = false;
  bool _apiIdDragging = false;
  String enumCode = "";
  CodeEnum intTab = CodeEnum.dart;
  CsvTool tool = CsvTool();
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _checkItem(DropItem item) {
    if (item.name.toLowerCase().endsWith("csv") == false) {
      alertTitle(context, "only support csv file");
      return false;
    }
    return true;
  }

  void _initCsv() async {
    if (_apiIdFile == null) return;
    if (_apiFile == null) return;

    if (_checkItem(_apiIdFile!)) {
      final r = await _apiIdFile!.readAsString();
      await tool.parseApiIdObs(r.split("\n"));
    }
    if (_checkItem(_apiFile!)) {
      final r = await _apiFile!.readAsString();
      await tool.parse(lines: r.split("\n"));
    }
  }

  void _convertApi() async {
    List<String> res = [];
    if (_controller.text.isEmpty) return;
    final content = _controller.text;
    switch (intTab) {
      case CodeEnum.dart:
        res = tool.createDartApiEnum(content.split("\n"));
        break;
      case CodeEnum.swift:
        res = tool.createDartApiEnum(content.split("\n"));
        break;
      case CodeEnum.kotlin:
        // res = tool.parseKotlin(currProjectName);
        res = tool.createDartApiEnum(content.split("\n"));
        break;
    }
    enumCode = res.join("\n");
    setState(() {});
  }

  String _getHintText() {
    switch (intTab) {
      case CodeEnum.dart:
        return '''
dart example:
enum NetworkServiceApi {
  openPage("/v1/app/open/data", ""), // 类名可自行修改
  openDec("/v1/app/open/file", ""),
  playUrl("/v1/app/download/file", ""),
  appPost("/v1/app/events", ""),
  ;
  final String desc;
  final String val;
  const NetworkServiceApi(this.desc, this.val);
}
                        ''';
      case CodeEnum.kotlin:
        return '''
kotlin example：
enum class MyEnum(val api: String, val id: String) {
    openPage("/v1/app/open/data", ""), // 类名可自行修改
    openDec("/v1/app/open/file/", ""),
    playUrl("/v1/app/download/file/", ""),
    appPost("/v1/app/events", ""),
}
        ''';
      case CodeEnum.swift:
        return '''
struct MyEnum {
    static let openPage = ("/v1/app/open/data", "") // 类名可自行修改
    static let openDec = ("/v1/app/open/file/", "")
    static let playUrl = ("/v1/app/download/file/", "")
    static let appPost = ("/v1/app/events", "")
}
        ''';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "混淆映射表 CSV:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropTarget(
                        onDragDone: (detail) {
                          setState(() {
                            _apiFile = detail.files.first;
                          });
                          _initCsv();
                        },
                        onDragEntered: (detail) {
                          setState(() {
                            _apiApiDragging = true;
                          });
                        },
                        onDragExited: (detail) {
                          setState(() {
                            _apiApiDragging = false;
                          });
                        },
                        child: Container(
                          height: 100,
                          width: 200,
                          decoration: BoxDecoration(
                            color: _apiApiDragging
                                ? Colors.blue.withOpacity(0.4)
                                : Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          child: _apiFile == null
                              ? const Center(child: Text("Drop csv file here"))
                              : Text(_apiFile!.name),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "API ID CSV:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropTarget(
                        onDragDone: (detail) {
                          setState(() {
                            _apiIdFile = detail.files.first;
                          });
                          _initCsv();
                        },
                        onDragEntered: (detail) {
                          setState(() {
                            _apiIdDragging = true;
                          });
                        },
                        onDragExited: (detail) {
                          setState(() {
                            _apiIdDragging = false;
                          });
                        },
                        child: Container(
                          height: 100,
                          width: 200,
                          decoration: BoxDecoration(
                            color: _apiIdDragging
                                ? Colors.blue.withOpacity(0.4)
                                : Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          child: _apiIdFile == null
                              ? const Center(
                                  child: Text("Drop API ID csv file here"))
                              : Text(_apiIdFile!.name),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Paste api enum:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      MyInput(
                        maxLine: 10,
                        controller: _controller,
                        hintText: _getHintText(),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _convertApi,
                        child: Container(
                          width: double.infinity,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            "API 混淆",
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
                  children: [
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
                          _convertApi();
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: SingleChildScrollView(
                              child: HighlightView(
                                enumCode,
                                language: intTab.name,
                                theme: vs2015Theme,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 12,
                            top: 12,
                            child: InkWell(
                              onTap: () {
                                myCopy(context, enumCode);
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.copy,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
