import 'dart:math';

import 'package:custom_base64/tool/global.dart';

import 'csv_tool.dart';

class CsvEventTool {
  List<String> lines = [];
  CsvEventTool();

  void init(List<String> contents) {
    lines = contents;
  }

  List<String> parse(String projectName) {
    if (lines.isEmpty) return [];
    final idx = lines[0].split(',').indexOf(projectName);
    List<String> resList = ["enum MyEnum {"];
    int i = 0;
    for (final line in lines) {
      if (i == 0) {
        i++;
        continue;
      }
      final fields = line.split(',');
      if (fields.length < 3) break;
      final desc = fields[0];
      final key = fields[1];
      final val = fields[idx];
      final pKey = CsvTool.toCamelCase(key);
      resList.add('''    ${insertChar(pKey)}("$val"), // $desc''');
    }
    resList.add('''
;
    final String value;
    const MyEnum(this.value);
}
    ''');
    return resList;
  }

  String insertChar(String str) {
    final position = str.length ~/ 2;
    int length = Random().nextInt(str.length);
    if (length < 3) length = 3;
    if (length > 5) length = 5;
    final charToInsert = generateRandomStringSecure(length);
    return str.substring(0, position) + charToInsert + str.substring(position);
  }

  List<String> parseSwift(String projectName) {
    if (lines.isEmpty) return [];
    final idx = lines[0].split(',').indexOf(projectName);
    List<String> resList = ["enum MyEnum: String {"];
    int i = 0;
    for (final line in lines) {
      if (i == 0) {
        i++;
        continue;
      }
      final fields = line.split(',');
      if (fields.length < 3) break;
      final desc = fields[0];
      final key = fields[1];
      final val = fields[idx];
      resList.add(
          '''    case ${insertChar(CsvTool.toCamelCase(key))} = "$val" // $desc''');
    }
    resList.add('''
}
    ''');
    return resList;
  }

  List<String> parseKotlin(String projectName) {
    if (lines.isEmpty) return [];
    final idx = lines[0].split(',').indexOf(projectName);
    List<String> resList = ["enum class MyEnum(val desc: String) {"];
    int i = 0;
    for (final line in lines) {
      if (i == 0) {
        i++;
        continue;
      }
      final fields = line.split(',');
      if (fields.length < 3) break;
      final desc = fields[0];
      final key = fields[1];
      final val = fields[idx];
      resList.add(
          '''    ${insertChar(CsvTool.toCamelCase(key))}("$val"), // $desc''');
    }
    final last = resList.removeLast().replaceAll(",", ";");
    resList.add(last);
    resList.add('''
}
    ''');
    return resList;
  }
}
