// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

List<String> extractQuotedContent(String text) {
  return RegExp(r"""(["'])(.*?)\1""")
      .allMatches(text)
      .map((match) => match.group(2)!)
      .toList();
}

void main() {
  final res = extractQuotedContent('''FileDetail.fromJson(json["trina"]),''');
  print(res);
  const path = "/v1/app/download/file/{uid}/{fileId}";

  final cleanedPath = path.replaceAll(RegExp(r'\/\{[^}]*\}'), "");
  print(cleanedPath);
}
