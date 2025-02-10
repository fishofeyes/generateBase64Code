import 'package:custom_base64/page/model_mix/model_mix_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RuleItem extends StatelessWidget {
  final String data;
  final CodeSwiftRuler ruler;
  final CodeSwiftRuler groupRuler;
  final Function()? onTap;
  const RuleItem({
    super.key,
    required this.data,
    required this.ruler,
    required this.groupRuler,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10, top: 5, bottom: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoRadio(
              value: ruler,
              groupValue: groupRuler,
              onChanged: (e) => onTap?.call(),
            ),
            Text(
              data,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}
