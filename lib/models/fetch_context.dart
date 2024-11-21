import 'dart:ui';

import '../utils/location.dart';
import 'bounding_box.dart';
import 'distance.dart';

/// Context parameters when fetching fountains
class FetchContext {
  /// Avoid fetching again if the last fetched center location is less than this distance away
  static const Distance _fetchDistanceThreshold = Distance.m(50);

  /// Avoid fetching again if the last fetched zoom difference is less than this threshold
  static const double _fetchZoomThreshold = 0.5;

  /// Screen size at the moment of the request
  final Size screenSize;

  /// Map zoom level at the moment of the request
  final double zoom;

  /// Map center location at the moment of the request
  final Location location;

  /// Map bounding box at the moment of the request
  final BoundingBox boundingBox;

  FetchContext({
    required this.screenSize,
    required this.zoom,
    required this.location,
    required this.boundingBox,
  });

  /// Check if this fetch context is similar to the other fetched context
  bool isSimilarTo(final FetchContext other) =>
      screenSize == other.screenSize &&
      _zoomIsSimilar(other.zoom) &&
      _distanceIsSimilar(other.location);

  /// Check if the fetch zoom is similar to the other fetch zoom
  bool _zoomIsSimilar(double otherFetchZoom) =>
      (otherFetchZoom - zoom) < _fetchZoomThreshold;

  /// Check if the fetch location is similar to the other fetch location
  bool _distanceIsSimilar(Location otherFetchLocation) {
    double distanceFromCenter =
        DistanceCalculatorAccuracy.low.distanceCalculator.distance(
      otherFetchLocation,
      location,
    );
    return distanceFromCenter < _fetchDistanceThreshold.meters;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FetchContext &&
        other.screenSize == screenSize &&
        other.zoom == zoom &&
        other.location == location &&
        other.boundingBox == boundingBox;
  }

  @override
  int get hashCode {
    return Object.hash(
      screenSize,
      zoom,
      location,
      boundingBox,
    );
  }
}
