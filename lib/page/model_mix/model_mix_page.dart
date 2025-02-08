import 'package:custom_base64/page/base64/view/my_input.dart';
import 'package:custom_base64/tool/csv_tool.dart';
import 'package:custom_base64/tool/global.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';

class ModelMixPage extends StatefulWidget {
  const ModelMixPage({super.key});

  @override
  State<ModelMixPage> createState() => _ModelMixPageState();
}

class _ModelMixPageState extends State<ModelMixPage>
    with AutomaticKeepAliveClientMixin {
  DropItem? _apiFile;
  bool _apiApiDragging = false;
  String enumCode = "";
  CodeEnum intTab = CodeEnum.dart;
  CsvTool tool = CsvTool();
  List<String> data = [];
  String currApi = "";
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
    if (_apiFile == null) return;
    if (_checkItem(_apiFile!)) {
      final r = await _apiFile!.readAsString();
      await tool.parse(lines: r.split("\n"));
      data = tool.csvMap.keys.toList();
      setState(() {});
    }
  }

  void _convertApi() async {
    List<String> res = [];
    final content = _controller.text.split("\n");
    if (content.isEmpty) return;
    switch (intTab) {
      case CodeEnum.dart:
        res = tool.createDartModel(fileContent: content, apiPath: currApi);
        break;
      case CodeEnum.swift:
        res = tool.createDartApiEnum(content);
        break;
      case CodeEnum.kotlin:
        // res = tool.parseKotlin(currProjectName);
        res = tool.createDartApiEnum(content);
        break;
    }
    enumCode = res.join("\n");
    setState(() {});
  }

  void _onSelect(String? e) {
    if (e != null) {
      currApi = e;
      _convertApi();
    }
  }

  String _getHintText() {
    switch (intTab) {
      case CodeEnum.dart:
        return '''
dart example:
factory PresentModel.fromJson(Map<String, dynamic> json) => PresentModel(
        id: json["id"],
        createTime: json["create_time"],
        fileId: json["file_id"],
        vidQty: json["vid_qty"],
        directory: json["directory"],
        video: json["video"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "create_time": createTime,
        "file_id": fileId,
        "file_meta": fileMeta?.toJson(),
        "vid_qty": vidQty,
        "directory": directory,
        "video": video,
      };
                        ''';
      case CodeEnum.kotlin:
        return '''
kotlin example：
xx
        ''';
      case CodeEnum.swift:
        return '''
kotlin example：
xx
        ''';
    }
  }

  List<DropdownMenuEntry<String>> _buildMenuList(List<String> data) {
    return data.map((String value) {
      return DropdownMenuEntry<String>(value: value, label: value);
    }).toList();
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
                          fontSize: 14,
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
                        "Paste model(换行内容可能会导致无法识别):",
                        style: TextStyle(
                          fontSize: 14,
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
                      const SizedBox(height: 16),
                      const Text(
                        "选择API(可输入搜索): ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      DropdownMenu<String>(
                        menuHeight: 200,
                        width: 300,
                        initialSelection: currApi,
                        onSelected: _onSelect,
                        dropdownMenuEntries: _buildMenuList(data),
                      ),
                      const Text(
                        "注意：1. 未处理的字段需要自己修改。2. displayName等这种/xx/xx/类型的字段需要自己处理。",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
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
                          SingleChildScrollView(
                            child: HighlightView(
                              enumCode,
                              language: intTab.name,
                              theme: vs2015Theme,
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
