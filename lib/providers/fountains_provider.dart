import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../models/fountain.dart';
import '../models/fountains.dart';
import '../widgets/fountain_marker.dart';

/// Provider of fountains and markers
class FountainsProvider with ChangeNotifier {
  /// Latest fetched fountains
  Fountains? get fountains => _fountains;
  Fountains? _fountains;

  /// Fountains markers
  Iterable<FountainMarker> get markers => _markersCache.values;

  /// Fountains markers cache
  final Map<Fountain, FountainMarker> _markersCache = LinkedHashMap();

  /// All latest fetched fountains are stored in the cache, and
  /// previous markers are removed when the cache exceeds this limit.\
  /// So the cache size is at most `max(_maxCacheSize, _fountains.length)`
  static const int _maxCacheSize = 2000;

  /// Update fountains
  void setFountains(final Fountains fountains) {
    final previous = _fountains;

    if (fountains != previous) {
      _fountains = fountains;

      _updateFountainsMarkers(fountains);

      SchedulerBinding.instance.scheduleTask(
        notifyListeners,
        Priority.idle, // after loading animation
      );
    }
  }

  /// Update fountains markers cache
  void _updateFountainsMarkers(final Fountains fountains) {
    final int previousCacheSize = _markersCache.length;

    // Update or add new markers to the cache
    for (final fountain in fountains) {
      _markersCache[fountain] = FountainMarker(fountain);
    }

    // Remove older markers that are not in the latest fetched fountains
    if (previousCacheSize > 0 && _markersCache.length > _maxCacheSize) {
      final expired = _markersCache.keys
          .where((fountain) => !fountains.contains(fountain))
          .take(_markersCache.length - _maxCacheSize)
          .toList();

      for (final old in expired) {
        _markersCache.remove(old);
      }
    }
  }
}
