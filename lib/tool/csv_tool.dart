import 'dart:io';

import 'package:custom_base64/page/model_mix/model_mix_page.dart';

class CsvTool {
  Map<String, dynamic> csvMap = {};
  Map<String, dynamic> apiIdMap = {};
  Map<String, dynamic> apiIdObsMap = {};
  CsvTool();

  /// 解析接口对应对应的字符-header里面需要用到
  Future<void> parseApiIdObs(List<String> lines) async {
    for (final line in lines) {
      final fields = line.split(',');
      if (fields.length < 3) {
        continue;
      }
      final id = fields[0];
      final api =
          fields[1].replaceAll(RegExp(r'\{.*?\}'), '').replaceAll("//", "/");
      final obs = fields[2];
      apiIdObsMap[api] = {
        "id": id,
        "obs": obs,
      };
    }
  }

  Future<void> parse({required List<String> lines, bool isApi = false}) async {
    int i = 0;
    for (final line in lines) {
      if (i == 0) {
        i++;
        continue;
      }
      final fields = line.split(',');
      if (fields.length < 4) {
        continue;
      }
      final normalApi =
          fields[0].replaceAll(RegExp(r'\{.*?\}'), '').replaceAll("//", "/");
      final token1 = fields[1].replaceFirst("/", '');
      final token2 = toCamelCase(fields[1]).replaceFirst('/', "");

      final replaceToken = fields[2];
      final type = fields[3];
      Map<String, dynamic>? content = csvMap[normalApi];
      if (content == null) {
        content = {
          type: {
            token1: replaceToken,
            if (token2 != token1) token2: replaceToken,
          },
        };
      } else {
        final tType = content[type];
        if (tType == null) {
          content[type] = {
            token1: replaceToken,
            if (token2 != token1) token2: replaceToken,
          };
        } else {
          if (token2 != token1) {
            content[type][token1] = replaceToken;
            content[type][token2] = replaceToken;
          } else {
            content[type][token1] = replaceToken;
          }
        }
      }
      csvMap[normalApi] = content;
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
        String key = "";
        if (t.contains('\'')) {
          key = extractQuotedContent2(t).first;
        } else {
          key = extractQuotedContent(t).first;
        }
        final replace = resMap[key];
        if (replace == null) {
          t = "$t // 未处理";
        } else {
          if (t.contains("['")) {
            t = CsvTool.replaceAllQuotedContent2(t, replace);
          } else {
            t = CsvTool.replaceAllQuotedContent(t, replace);
          }
        }
        replaceContent.add(t);
      } else if (t.contains("\":")) {
        String key = "";
        if (t.contains('\'')) {
          key = extractQuotedContent2(t).first;
        } else {
          key = extractQuotedContent(t).first;
        }
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
    final resMap = csvMap[apiPath]["JSON_PROPERTY"];
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

  List<String> createKotlinModel(
      {required List<String> fileContent, required String apiPath}) {
    final resMap = csvMap[apiPath]["JSON_PROPERTY"];
    final replaceContent = <String>[];
    for (String t in fileContent) {
      if (t.contains("'") || t.contains("\"")) {
        final str = t.trim().split("=").first;
        String key = str.split(".").last.trim();
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
      } else {
        replaceContent.add(t);
      }
    }
    return replaceContent;
  }

  /// 解析为普通字典类型
  void createApi(String apiPath) {
    final f = File(apiPath);
    final contents = [];
    final contentsApiIds = [];
    for (String i in f.readAsLinesSync()) {
      if (i.trim().startsWith("//")) {
        contents.add(i);
        continue;
      }
      if (i.contains("= '") || i.contains("= \"")) {
        late String key;
        if (i.contains('= "')) {
          key = extractQuotedContent(i).last;
        } else {
          key = extractQuotedContent2(i).last;
        }
        final l = i.trim().split(" ");
        if (i.trim().startsWith('static')) {
          final obj = apiIdObsMap[key];
          if (obj != null) {
            contentsApiIds.add("NetworkEndpoints.${l[2]}: \"${obj["obs"]}\",");
          } else {
            contentsApiIds.add("NetworkEndpoints.${l[2]}: null,");
          }
        }
        final Map<String, dynamic>? map = csvMap[key]?["PATH"];
        if (map != null) {
          List<String> tempLine = i.split("=");
          for (final k in map.keys) {
            tempLine[1] = tempLine.last.replaceFirst(k, map[k]);
          }
          contents.add(tempLine.join("="));
        } else {
          contents.add(i);
        }
      } else {
        if (i.trim() == "}") {
          contents.add('''
  static String? getAPIID(String key) {
    final map = {
      ${contentsApiIds.join("\n      ")}
    };
    return map[key];
  }
        ''');
        }
        contents.add(i);
      }
    }
    f.writeAsStringSync(contents.join("\n"));
  }

  List<String> extractQuotedContent(String text) {
    return RegExp(r'"([^"]*)"')
        .allMatches(text)
        .map((match) => match.group(1)!)
        .toList();
  }

  List<String> extractQuotedContent2(String text) {
    return RegExp(r"'([^']*)'")
        .allMatches(text)
        .map((match) => match.group(1)!)
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
        if (key == null || obj == null) {
          contents.add(i);
        } else {
          final Map<String, dynamic>? map = csvMap[key]?["PATH"];
          String apiPath = key;
          if (map != null) {
            for (final k in map.keys) {
              apiPath = apiPath.replaceFirst(k, map[k]);
            }
          }
          String newString = i.replaceFirstMapped(regExp, (match) {
            if (match.start > 0) {
              return '"$apiPath"';
            } else {
              return match.group(0)!;
            }
          });
          if (isSingle) {
            contents.add(newString.replaceAll("''", "'${obj['obs']}'"));
          } else {
            contents.add(newString.replaceAll('""', '"${obj['obs']}"'));
          }
        }
      } else {
        contents.add(i);
      }
    }
    return contents;
  }
}
