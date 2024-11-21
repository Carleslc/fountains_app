import 'package:flutter/material.dart';

/// Row with an icon and a text
class IconText extends StatelessWidget {
  final Icon icon;
  final Text text;

  final double space;

  final WrapAlignment alignment;

  const IconText({
    super.key,
    required this.icon,
    required this.text,
    this.space = 8,
    this.alignment = WrapAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: space,
      alignment: alignment,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        icon,
        text,
      ],
    );
  }
}
