import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:latlong2/latlong.dart' as latlong;

import '../utils/number_format.dart';

/// Distance in a specified unit (m, km)
@immutable
class Distance {
  /// Distance value
  final double distance;

  /// Unit of the [distance]
  final DistanceUnit unit;

  const Distance(this.distance, this.unit);

  /// Distance in meters
  const Distance.m([double meters = 0]) : this(meters, DistanceUnit.meters);

  /// Distance in kilometers
  const Distance.km([double kilometers = 0])
      : this(kilometers, DistanceUnit.kilometers);

  /// Get distance as meters
  double get meters {
    switch (unit) {
      case DistanceUnit.meters:
        return distance;
      case DistanceUnit.kilometers:
        return distance * 1000;
    }
  }

  /// Get distance in meters unit
  Distance toMeters() {
    switch (unit) {
      case DistanceUnit.meters:
        return this;
      case DistanceUnit.kilometers:
        return Distance.m(meters);
    }
  }

  /// Get distance as kilometers
  double get kilometers {
    switch (unit) {
      case DistanceUnit.meters:
        return distance / 1000;
      case DistanceUnit.kilometers:
        return distance;
    }
  }

  /// Get distance in kilometers unit
  Distance toKilometers() {
    switch (unit) {
      case DistanceUnit.meters:
        return Distance.km(kilometers);
      case DistanceUnit.kilometers:
        return this;
    }
  }

  /// Format this distance as a string.
  ///
  /// For the [distance], [NumberFormatter.format] is used, with 2 (km) or 3 (m) optional decimal digits.\
  /// For the [unit], the [DistanceUnit.suffix] is appended if [withSuffix] is true.
  String format({
    String? locale,
    NumberFormat? pattern,
    bool withSuffix = true,
  }) {
    if (pattern == null && unit == DistanceUnit.kilometers) {
      pattern ??= NumberFormat('#,##0.##', locale); // 2 optional decimal digits
    }
    String formatted = distance.format(locale: locale, pattern: pattern);
    return withSuffix ? '$formatted ${unit.suffix}' : formatted;
  }

  @override
  String toString() => format();
}

/// Unit of distance
enum DistanceUnit {
  meters('m'),
  kilometers('km');

  final String suffix;

  const DistanceUnit(this.suffix);
}

///
/// Distance Calculator
///

typedef DistanceCalculator = latlong.Distance;

/// Accuracy for distance computations
enum DistanceCalculatorAccuracy {
  /// 0.3% error
  low(latlong.DistanceHaversine()),

  /// 0.5mm accuracy
  high(latlong.DistanceVincenty());

  final DistanceCalculator distanceCalculator;

  const DistanceCalculatorAccuracy(this.distanceCalculator);
}
