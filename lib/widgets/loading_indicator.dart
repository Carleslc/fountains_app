import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Color? color;
  final Color? backgroundColor;

  const LoadingIndicator({
    super.key,
    this.height = 2,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: LinearProgressIndicator(
        color: color,
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
