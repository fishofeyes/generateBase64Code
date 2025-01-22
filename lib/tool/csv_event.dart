import 'dart:io';

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
      resList.add('''    ${CsvTool.toCamelCase(key)}("$val"), // $desc''');
    }
    resList.add('''
;
    final String value;
    const MyEnum(this.value);
}
    ''');
    return resList;
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
      resList.add('''    case ${CsvTool.toCamelCase(key)} = "$val" // $desc''');
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
      resList.add('''    ${CsvTool.toCamelCase(key)}("$val"), // $desc''');
    }
    final last = resList.removeLast().replaceAll(",", ";");
    resList.add(last);
    resList.add('''
}
    ''');
    return resList;
  }
}
