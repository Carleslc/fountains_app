import '../../models/bounding_box.dart';
import '../../utils/location.dart';

/// Attributes to check the current status of the map
/// and methods to programmatically control the map.
abstract interface class AbstractMapController {
  /// Default zoom of the map
  double get defaultZoom;

  /// Minimum zoom of the map
  double get minZoom;

  /// Maximum zoom of the map
  double get maxZoom;

  /// Minimum zoom to fetch fountains to avoid large requests
  double get minZoomFetch;

  /// Map current center position
  Location get currentPosition;

  /// Map current zoom level
  double get currentZoom;

  /// Map current rotation in radians
  double get currentRotation;

  /// Bounds for the box area limits of the four corners of the visible map
  BoundingBox get bounds;

  /// Center the map to [location] with optional [zoom] level
  void center(Location location, {double? zoom});

  /// Rotate the map [degrees]° around the [currentPosition], where 0° is north
  void rotate(double degrees);

  // Map event listeners

  /// Listener on map move start
  abstract void Function(bool byController)? onMapMoveStart;

  /// Listener on map move end
  abstract void Function(bool byController)? onMapMoveEnd;

  /// Listener on map move update
  abstract void Function(bool byController)? onMapMoveUpdate;
}
