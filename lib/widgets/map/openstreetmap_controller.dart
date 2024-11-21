import 'package:flutter_map/flutter_map.dart';

import '../../models/bounding_box.dart';
import '../../utils/location.dart';
import 'map_controller.dart';

/// Controller for OpenStreetMap map implementation using `flutter_map` library
class OpenStreetMapController implements AbstractMapController {
  final MapController controller;

  final double defaultZoom;
  final double minZoom;
  final double minZoomFetch;
  final double maxZoom;

  void Function(bool byController)? onMapMoveStart;
  void Function(bool byController)? onMapMoveEnd;
  void Function(bool byController)? onMapMoveUpdate;

  OpenStreetMapController({
    MapController? controller,
    this.defaultZoom = 15,
    this.minZoom = 3,
    this.minZoomFetch = 12,
    this.maxZoom = 20,
    this.onMapMoveStart,
    this.onMapMoveUpdate,
    this.onMapMoveEnd,
  }) : controller = controller ?? MapController();

  @override
  Location get currentPosition => controller.camera.center;

  @override
  double get currentZoom => controller.camera.zoom;

  @override
  double get currentRotation => controller.camera.rotationRad;

  @override
  BoundingBox get bounds => BoundingBox.fromLatLngBounds(visibleBounds);

  /// Unwrapped [LatLngBounds] from `flutter_map` library
  LatLngBounds get visibleBounds => controller.camera.visibleBounds;

  @override
  void center(Location location, {double? zoom}) {
    controller.move(location, zoom ?? currentZoom);
  }

  @override
  void rotate(double degrees) {
    controller.rotate(degrees);
  }
}
