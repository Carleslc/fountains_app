import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../styles/app_styles.dart';
import '../utils/logger.dart';
import 'localization.dart';
import 'skeleton_container.dart';

class ImageSkeleton extends StatefulWidget {
  final String imageUrl;
  final FilterQuality filterQuality;
  final Object? Function()? onErrorContext;

  const ImageSkeleton({
    required this.imageUrl,
    this.filterQuality = FilterQuality.medium,
    this.onErrorContext,
  });

  @override
  State<ImageSkeleton> createState() => _ImageSkeletonState();
}

class _ImageSkeletonState extends State<ImageSkeleton> with Localization {
  final _imageKey = GlobalKey();

  bool loadingImage = true;

  Size? _imageSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateImageSize();
  }

  void _loaded() {
    if (loadingImage) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          loadingImage = false;
        }),
      );
    }
  }

  void _updateImageSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final Size? imageSize = _imageKey.currentContext?.size;
      if (imageSize != null && _imageSize != imageSize) {
        setState(() {
          _imageSize = imageSize;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateImageSize();

    return Theme(
      data: AppStyles.theme.copyWith(
        tooltipTheme: AppStyles.theme.tooltipTheme.copyWith(
          triggerMode: TooltipTriggerMode.tap,
          margin: const EdgeInsets.symmetric(vertical: 4),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          key: _imageKey,
          widget.imageUrl,
          fit: BoxFit.contain,
          filterQuality: widget.filterQuality,
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              _loaded();
              return child;
            }
            final double? loadingPercent =
                loadingProgress.expectedTotalBytes != null &&
                        loadingProgress.expectedTotalBytes! > 0
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null;
            return Tooltip(
              message: l.imageLoading,
              child: SkeletonContainer(
                width: max(_imageSize?.width ?? 0, 256),
                height: max(_imageSize?.height ?? 0, 128),
                reverseEffect: true,
                child: Skeleton.shade(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.image,
                        size: 64,
                        color: AppStyles.color.gray,
                      ),
                      if (loadingPercent != null)
                        Positioned(
                          top: 12,
                          child: SizedBox(
                            width: 40,
                            child: Skeleton.keep(
                              child: LinearProgressIndicator(
                                value: loadingPercent,
                                semanticsLabel: l.imageLoading,
                                semanticsValue:
                                    '${(loadingPercent * 100).round()}%',
                                color: AppStyles.color.scheme.surfaceBright,
                                backgroundColor: AppStyles.color.gray,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
          errorBuilder: (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            _loaded();
            warningWithContext(
              'Cannot load image: ${widget.imageUrl}',
              errorObject: error,
              stackTrace: stackTrace,
              context: widget.onErrorContext?.call(),
            );
            return Tooltip(
              message: l.imageError,
              child: SizedBox(
                width: 64,
                height: 64,
                child: Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: AppStyles.color.gray,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
