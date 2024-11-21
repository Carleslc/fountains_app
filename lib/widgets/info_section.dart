import 'package:flutter/material.dart';

import '../styles/app_styles.dart';

/// Header and text section
class InfoSection extends StatelessWidget {
  final String? header;
  final Widget? headerWidget;
  final String? text;
  final Widget? child;
  final double padding;

  final TextAlign headerAlign;
  final TextAlign textAlign;

  const InfoSection({
    super.key,
    this.header,
    this.headerWidget,
    this.text,
    this.child,
    this.headerAlign = TextAlign.start,
    this.textAlign = TextAlign.justify,
    this.padding = 8,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      header != null || headerWidget != null,
      'Either header or headerWidget must be provided',
    );
    assert(
      text != null || child != null,
      'Either text or child must be provided',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: padding),
          child: headerWidget ??
              Text(
                header!,
                style: AppStyles.text.header,
                textAlign: headerAlign,
              ),
        ),
        if (text != null)
          Text(
            text!,
            textAlign: textAlign,
          ),
        if (child != null) child!,
      ],
    );
  }
}
