import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../styles/app_styles.dart';

/// Background container to use with loading screens
class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final Color? backgroundColor;
  final double colorOpacity;
  final PaintingEffect? effect;
  final Duration? pulseDuration;
  final bool reverseEffect;
  final Widget? child;
  final BorderRadiusGeometry? borderRadius;

  SkeletonContainer({
    super.key,
    required this.width,
    required this.height,
    this.color,
    this.backgroundColor,
    this.colorOpacity = 0.1,
    this.effect,
    this.pulseDuration,
    this.borderRadius,
    this.reverseEffect = false,
    this.child,
  });

  PaintingEffect _buildEffect() {
    Color from = backgroundColor ??
        AppStyles.color.lightGray.withOpacity(0.5); // const Color(0xFFf4f4f4);
    Color to = (color ?? AppStyles.color.gray)
        .withOpacity(colorOpacity); // const Color(0xFFe5e5e5)
    if (reverseEffect) {
      Color aux = from;
      from = to;
      to = aux;
    }
    return PulseEffect(
      from: from,
      to: to,
      duration: pulseDuration ?? Duration(seconds: color != null ? 2 : 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      effect: effect ?? _buildEffect(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: height,
            child: Bone.square(
              size: width,
              borderRadius: borderRadius,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
