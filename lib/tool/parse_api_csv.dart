import 'dart:io';

import 'csv_tool.dart';

Future<void> main() async {
  // 映射表
  final currentPath = Directory.current.path;
  final userDir = Directory.current.path.split("Desktop").first;
  print("userDir = $userDir");
  final path = "${userDir}Downloads/api.csv";
  // api id 表
  final idPath = "${userDir}Downloads/apiId.csv";
  // 目标路径文件
  final apiPath = "${currentPath}/test/_api.dart";
  final tool = CsvTool(path);
  await tool.parse(isApi: true);
  await tool.parseApiIdObs(idPath);
  // tool.createApiEnum(apiPath); // or tool.parseApiEnum(apiPath)

  // 目标路径
  final modelPath = "${currentPath}/test/_model.dart";
  // 接口地址
  final apiModelPath = "/v1/app/recommend";
  tool.createModel(apiPath: apiModelPath, modelPath: modelPath);
}
