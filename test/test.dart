String buildNestedJsonString(String pathKey, String valueExpression) {
  // 1. 清理路径：移除开头和结尾的斜杠，并按斜杠分割
  List<String> keys = pathKey
      .replaceAll(RegExp(r'^/+|/+$'), '') // 移除开头和结尾的斜杠
      .split('/')
      .where((part) => part.isNotEmpty) // 过滤空的部分
      .toList();

  // 2. 检查路径是否有效
  if (keys.isEmpty) {
    throw ArgumentError('Invalid path key format: $pathKey');
  }

  // 3. 从最内层开始构建字符串
  String innerMost = '"${keys.last}": $valueExpression';

  // 4. 从内向外构建嵌套结构
  for (int i = keys.length - 2; i >= 0; i--) {
    innerMost = '"${keys[i]}": {$innerMost}';
  }

  return innerMost;
}

/// 使用示例
void main() {
  // 示例 1: 值是字符串常量
  String path1 = "/hautein/j2gak0m7fe/iw7t_vdqnu";
  String value1 = '"SM-A326K"'; // 注意这里值加了引号
  print(buildNestedJsonString(path1, value1));
  // 输出: "hautein": {"j2gak0m7fe": {"iw7t_vdqnu": "SM-A326K"}}

  // 示例 2: 值是从map中获取的
  String value2 = 'map["a"]'; // 注意这里值没有加引号
  print(buildNestedJsonString(path1, value2));
  // 输出: "hautein": {"j2gak0m7fe": {"iw7t_vdqnu": map["a"]}}

  // 示例 3: 值是变量
  String value3 = 'deviceModel';
  print(buildNestedJsonString(path1, value3));
  // 输出: "hautein": {"j2gak0m7fe": {"iw7t_vdqnu": deviceModel}}

  // 示例 4: 值是函数调用
  String value4 = 'getDeviceModel()';
  print(buildNestedJsonString(path1, value4));
  // 输出: "hautein": {"j2gak0m7fe": {"iw7t_vdqnu": getDeviceModel()}}

  // 示例 5: 值是数字
  String value5 = '123';
  print(buildNestedJsonString(path1, value5));
  // 输出: "hautein": {"j2gak0m7fe": {"iw7t_vdqnu": 123}}

  // 示例 6: 值是布尔值
  String value6 = 'true';
  print(buildNestedJsonString(path1, value6));
  // 输出: "hautein": {"j2gak0m7fe": {"iw7t_vdqnu": true}}
}
