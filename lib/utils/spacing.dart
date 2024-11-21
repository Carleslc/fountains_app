import 'package:flutter/material.dart';

extension ListWidgetSpacing on List<Widget> {
  List<Widget> withSpacing([double spacing = 8]) {
    final List<Widget> childrenWithSpacing = List.from([]);

    if (isNotEmpty) {
      final EdgeInsets padding = EdgeInsets.only(bottom: spacing);

      // Add bottom padding for all elements except the last
      for (int i = 0; i < length - 1; i++) {
        childrenWithSpacing.add(Padding(padding: padding, child: elementAt(i)));
      }

      // Add last element without bottom padding
      childrenWithSpacing.add(last);
    }

    return childrenWithSpacing;
  }
}
