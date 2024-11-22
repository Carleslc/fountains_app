import 'package:flutter/material.dart';

/// Widget to display the app logo
class Logo extends StatelessWidget {
  static const String path = 'assets/icons/logo.png';

  final double? size;

  const Logo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
    );
  }
}
