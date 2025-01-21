import 'package:custom_base64/page/base64/base64_page.dart';
import 'package:flutter/material.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage>
    with SingleTickerProviderStateMixin {
  final List<String> text = ["base64混入字符", "埋点枚举生成"];
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: text.length, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 40,
              width: double.infinity,
              child: TabBar(
                controller: controller,
                tabs: text
                    .map((e) => Tab(
                          text: e,
                        ))
                    .toList(),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  Base64Page(),
                  Container(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
