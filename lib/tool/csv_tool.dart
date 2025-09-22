import 'dart:io';

import 'package:custom_base64/page/model_mix/model_mix_page.dart';

class CsvTool {
  Map<String, dynamic> csvMap = {};
  Map<String, dynamic> csvReverseMap = {};
  Map<String, dynamic> apiIdMap = {};
  Map<String, dynamic> apiIdObsMap = {};
  CsvTool();

  /// 解析接口对应对应的字符-header里面需要用到
  Future<void> parseApiIdObs(List<String> lines) async {
    int replaceTokenIdx = 0;
    for (final line in lines) {
      final fields = line.split(',');
      if (fields.length < 3) {
        continue;
      }
      String api = fields[1].replaceAll(RegExp(r'\/\{[^}]*\}'), '');
      String obs = fields[2];
      if (replaceTokenIdx == 0) {
        replaceTokenIdx = fields.indexWhere((e) => e == "api_replace_token");
        if (replaceTokenIdx == -1) {
          replaceTokenIdx = 2;
        }
        continue;
      }
      obs = fields[replaceTokenIdx];
      apiIdObsMap[api] = {
        "obs": obs,
      };
    }
  }

  Future<void> parse({required List<String> lines, bool isApi = false}) async {
    int i = 0;
    int idxToken = 0;
    int idxType = 0;
    int idxReplace = 0;
    for (final line in lines) {
      final fields = line.split(',');
      if (fields.length < 4) {
        continue;
      }
      if (idxToken == 0) {
        idxToken = fields.indexWhere((e) => e == "token");
        idxReplace = fields.indexWhere((e) => e == "replace_token");
        idxType = fields.indexWhere((e) => e == "type" || e == "param_type");
        continue;
      }
      final normalApi = fields[0].replaceAll(RegExp(r'\/\{[^}]*\}'), '');
      final token1 = fields[idxToken].replaceFirst("/", '');
      final token2 = toCamelCase(fields[idxToken]).replaceFirst('/', "");

      final replaceToken = fields[idxReplace];
      final type = fields[idxType];
      csvReverseMap
          .putIfAbsent(normalApi, () => <String, dynamic>{})
          .putIfAbsent(type, () => <String, dynamic>{})[replaceToken] = token1;
      final content = csvMap
          .putIfAbsent(normalApi, () => <String, dynamic>{})
          .putIfAbsent(type, () => <String, dynamic>{});
      content[token1] = replaceToken;
      if (token1.contains("/")) {
        content[token1.split("/").last] = replaceToken;
      }
      if (token2 != token1) {
        content[token2] = replaceToken;
      }
      i++;
    }
  }

  // 下划线变驼峰
  static String toCamelCase(String str) {
    // 将字符串转换为小写，然后处理下划线
    str = str.toLowerCase();
    return str.replaceAllMapped(RegExp(r'(_)([a-z])'), (match) {
      return match.group(2)!.toUpperCase();
    });
  }

  static String replaceAllQuotedContent(String text, String replacement) {
    return text.replaceAllMapped(RegExp(r'"([^"]*)"'), (match) {
      return '"$replacement"';
    });
  }

  static String replaceAllQuotedContent2(String text, String replacement) {
    return text.replaceAllMapped(RegExp(r"'([^']*)'"), (match) {
      return "'$replacement'";
    });
  }

  ///
  /// model 解析混淆
  /// apiPath: 未混淆接口路径
  /// modelPath: model结果路径
  List<String> createDartModel(
      {required List<String> fileContent, required String apiPath}) {
    final resMap =
        csvMap[apiPath][apiPath == "\\N" ? "ADHOC" : "JSON_PROPERTY"];
    final replaceContent = <String>[];
    for (String t in fileContent) {
      if (t.contains("'") || t.contains("\"")) {
        String key = extractQuotedContent(t).first;
        final replace = resMap[key];
        if (replace == null) {
          t = "$t // 未处理";
        } else {
          if (t.contains("'")) {
            t = CsvTool.replaceAllQuotedContent2(t, replace);
          } else {
            t = CsvTool.replaceAllQuotedContent(t, replace);
          }
        }
        replaceContent.add(t);
      } else if (t.contains("\":")) {
        String key = extractQuotedContent(t).first;
        final replace = resMap[key];
        if (replace == null) {
          t = "$t // 未处理";
        } else {
          t = CsvTool.replaceAllQuotedContent(t, replace);
        }
        replaceContent.add(t);
      } else {
        replaceContent.add(t);
      }
    }
    return replaceContent;
  }

  List<String> reverseDartModel(
      {required List<String> fileContent, required String apiPath}) {
    final resMap =
        csvReverseMap[apiPath][apiPath == "\\N" ? "ADHOC" : "JSON_PROPERTY"];
    final replaceContent = <String>[];
    for (String t in fileContent) {
      if (t.contains("'") || t.contains("\"")) {
        String key = extractQuotedContent(t).first;
        final replace = resMap[key];
        if (replace == null) {
          t = "$t // 未处理";
        } else {
          if (t.contains("'")) {
            t = CsvTool.replaceAllQuotedContent2(t, replace);
          } else {
            t = CsvTool.replaceAllQuotedContent(t, replace);
          }
        }
        replaceContent.add(t);
      } else if (t.contains("\":")) {
        String key = extractQuotedContent(t).first;
        final replace = resMap[key];
        if (replace == null) {
          t = "$t // 未处理";
        } else {
          t = CsvTool.replaceAllQuotedContent(t, replace);
        }
        replaceContent.add(t);
      } else {
        replaceContent.add(t);
      }
    }
    return replaceContent;
  }

  List<String> createSwiftModel(
      {required List<String> fileContent,
      required String apiPath,
      required CodeSwiftRuler ruler}) {
    final resMap = csvMap[apiPath]?["JSON_PROPERTY"];
    if (resMap == null) return [];
    List<String> replaceContent = [];
    switch (ruler) {
      case CodeSwiftRuler.swift1:
        for (String t in fileContent) {
          if (t.trim().startsWith("var ")) {
            String key = t.trim().split(" ")[1].replaceAll(":", "");
            final replace = resMap[key];
            if (replace == null) {
              replaceContent.add("$t //未处理");
            } else {
              replaceContent.add(t.replaceFirst(key, replace));
            }
          } else {
            replaceContent.add(t);
          }
        }
        break;
      case CodeSwiftRuler.swift2:
        replaceContent = [
          "override func mapping(mapper: HelpingMapper) {",
          "        super.mapping(mapper: mapper)"
        ];
        for (String t in fileContent) {
          if (t.trim().startsWith("var ")) {
            String key = t.trim().split(" ")[1].replaceAll(":", "");
            final replace = resMap[key];
            if (replace == null) {
              t = '        mapper.specify(property: &$key, name: "")';
            } else {
              t = '        mapper.specify(property: &$key, name: "$replace")';
            }
            replaceContent.add(t);
          } else {
            replaceContent.add(t);
          }
        }
        replaceContent.add("}");
        break;
    }
    return replaceContent;
  }

  List<String> reverseSwiftModel(
      {required List<String> fileContent,
      required String apiPath,
      required CodeSwiftRuler ruler}) {
    final resMap = csvReverseMap[apiPath]["JSON_PROPERTY"];
    List<String> replaceContent = [];
    switch (ruler) {
      case CodeSwiftRuler.swift1:
        for (String t in fileContent) {
          if (t.trim().startsWith("var ")) {
            String key = t.trim().split(" ")[1].replaceAll(":", "");
            final replace = resMap[key];
            if (replace == null) {
              replaceContent.add("$t //未处理");
            } else {
              replaceContent.add(t.replaceFirst(key, replace));
            }
          } else {
            replaceContent.add(t);
          }
        }
        break;
      case CodeSwiftRuler.swift2:
        replaceContent = [
          "override func mapping(mapper: HelpingMapper) {",
          "        super.mapping(mapper: mapper)"
        ];
        for (String t in fileContent) {
          if (t.trim().startsWith("var ")) {
            String key = t.trim().split(" ")[1].replaceAll(":", "");
            final replace = resMap[key];
            if (replace == null) {
              t = '        mapper.specify(property: &$key, name: "")';
            } else {
              t = '        mapper.specify(property: &$key, name: "$replace")';
            }
            replaceContent.add(t);
          } else {
            replaceContent.add(t);
          }
        }
        replaceContent.add("}");
        break;
    }
    return replaceContent;
  }

  List<String> extractQuotedContent(String text) {
    return RegExp(r"""(["'])(.*?)\1""")
        .allMatches(text)
        .map((match) => match.group(2)!)
        .toList();
  }

  /// 解析为枚举类型
  List<String> createDartApiEnum(List<String> str) {
    final contents = <String>[];
    for (String i in str) {
      if (i.trim().startsWith("//")) {
        contents.add(i);
        continue;
      }
      if (i.contains("\"") || i.contains("'")) {
        RegExp regExp = RegExp(r'"([^"]*)"');
        String? key = regExp.firstMatch(i)?.group(1);
        bool isSingle = false;
        if (key == null) {
          isSingle = true;
          regExp = RegExp(r"'([^']*)'");
          key = regExp.firstMatch(i)?.group(1);
        }
        final obj = apiIdObsMap[key];
        if (key == null) {
          contents.add(i);
        } else {
          final Map<String, dynamic>? map = csvMap[key]?["PATH"];
          String apiPath = key;
          if (map != null) {
            for (final k in map.keys) {
              apiPath = apiPath.replaceFirst(k, map[k]);
            }
          }
          final newString = i.replaceAll(key, apiPath);
          if (obj != null) {
            if (newString.contains("''") || newString.contains('""')) {
              if (isSingle) {
                contents.add(newString.replaceAll("''", "'${obj['obs']}'"));
              } else {
                contents.add(newString.replaceAll('""', '"${obj['obs']}"'));
              }
            } else {
              contents.add('$newString;//${obj['obs']}');
            }
          } else {
            contents.add(newString);
          }
        }
      } else {
        contents.add(i);
      }
    }
    return contents;
  }
}
