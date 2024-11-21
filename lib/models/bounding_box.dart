import 'package:flutter_map/flutter_map.dart';

import '../utils/location.dart';

/// A region of the earth delimited by four coordinates:
///
/// (northLat, westLong)\
/// (northLat, eastLong)\
/// (southLat, westLong)\
/// (southLat, eastLong)
class BoundingBox {
  /// North (maximum latitude) of the bounding box
  final double northLat;

  /// West (minimum longitude) of the bounding box
  final double westLong;

  /// South (minimum latitude) of the bounding box
  final double southLat;

  /// East (maximum longitude) of the bounding box
  final double eastLong;

  const BoundingBox({
    required this.northLat,
    required this.westLong,
    required this.southLat,
    required this.eastLong,
  });

  BoundingBox.fromLatLngBounds(LatLngBounds bounds)
      : this(
          northLat: bounds.north,
          westLong: bounds.west,
          southLat: bounds.south,
          eastLong: bounds.east,
        );

  /// Check if [location] is inside this bounding box
  bool isWithinBounds(Location location) =>
      location.longitude >= westLong &&
      location.longitude <= eastLong &&
      location.latitude >= southLat &&
      location.latitude <= northLat;

  @override
  String toString() =>
      '${runtimeType}(northLat: $northLat, westLong: $westLong, southLat: $southLat, eastLong: $eastLong)';

  @override
  bool operator ==(Object other) =>
      other is BoundingBox &&
      other.northLat == northLat &&
      other.westLong == westLong &&
      other.southLat == southLat &&
      other.eastLong == eastLong;

  @override
  int get hashCode => Object.hash(northLat, westLong, southLat, eastLong);
}
