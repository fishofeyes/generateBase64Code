import 'dart:io';

import 'package:custom_base64/tool/csv_event.dart';
import 'package:custom_base64/tool/global.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/vs2015.dart';

class ParseEnumPage extends StatefulWidget {
  const ParseEnumPage({super.key});

  @override
  State<ParseEnumPage> createState() => _ParseEnumPageState();
}

class _ParseEnumPageState extends State<ParseEnumPage>
    with AutomaticKeepAliveClientMixin {
  List<DropItem> _list = [];

  bool _dragging = false;
  CsvEventTool tool = CsvEventTool();
  List<String> data = [];
  String enumCode = "";
  String currProjectName = "";
  CodeEnum intTab = CodeEnum.dart;
  @override
  void initState() {
    super.initState();
    // Initialize the highlighter.
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _initCsv() {
    if (_list.isNotEmpty) {
      final f = _list.first;
      if (f.name.toLowerCase().endsWith("csv") == false) {
        _list = [];
        showDialog(
            context: context,
            builder: (c) {
              return AlertDialog(
                title: const Text("Only support csv file"),
                content: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                ),
              );
            });
        return;
      }
      final p = File(f.path);
      final lines = p.readAsLinesSync();
      tool.init(lines);
      if (lines.isNotEmpty) {
        final temp = lines.first.split(",");
        temp.removeAt(0);
        temp.removeAt(0);
        data = temp.where((e) => e.isNotEmpty).toList();
      }
      setState(() {});
    }
  }

  void _onSelect(String? e) {
    if (e != null) {
      currProjectName = e;
      List<String> res;
      switch (intTab) {
        case CodeEnum.dart:
          res = tool.parse(currProjectName);
          break;
        case CodeEnum.swift:
          res = tool.parseSwift(currProjectName);
          break;
        case CodeEnum.kotlin:
          res = tool.parseKotlin(currProjectName);
          break;
      }
      enumCode = res.join("\n");
      setState(() {});
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropTarget(
                      onDragDone: (detail) {
                        setState(() {
                          _list = detail.files;
                        });
                        _initCsv();
                      },
                      onDragEntered: (detail) {
                        setState(() {
                          _dragging = true;
                        });
                      },
                      onDragExited: (detail) {
                        setState(() {
                          _dragging = false;
                        });
                      },
                      child: Container(
                        height: 100,
                        width: 200,
                        decoration: BoxDecoration(
                          color: _dragging
                              ? Colors.blue.withOpacity(0.4)
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        child: _list.isEmpty
                            ? const Center(child: Text("Drop csv file here"))
                            : Text(_list.first.name),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Choose project name",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownMenu<String>(
                      menuHeight: 200,
                      width: 200,
                      initialSelection: currProjectName,
                      onSelected: _onSelect,
                      dropdownMenuEntries: _buildMenuList(data),
                    ),
                    const Text(
                      "注意：1. 需要自行过滤未使用的埋点枚举。\n2. 自行修改类名，变量名。防止代码重复",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
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
                          _onSelect(currProjectName);
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
