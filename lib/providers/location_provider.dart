import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';

import '../exceptions/location.dart';
import '../models/distance.dart';
import '../services/location_service.dart';
import '../utils/logger.dart';

/// Provider of user device position
class LocationProvider with ChangeNotifier {
  static const LocationMarkerDataStreamFactory locationMarkerFactory =
      LocationMarkerDataStreamFactory();

  final LocationService locationService;

  LocationProvider([LocationService? locationService])
      : locationService = locationService ??
            LocationService(
              accuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: const Distance.m(5), // minimum distance to update
            );

  /// Last user device position
  Position? get userPosition => _userPosition;
  Position? _userPosition;

  /// Whether [userPosition] is retrieved for the current location or is unsure.\
  /// It is false if it is the last known position or the position is still not retrieved.
  bool get isCurrentLocation => _isCurrentLocation;
  bool _isCurrentLocation = false;

  /// Set current user position and notify listeners
  void setUserPosition(Position? position, {bool isCurrent = true}) {
    assert(() {
      // Debug message (assert to avoid equality comparison in release mode)
      if (position != _userPosition) {
        debug('User position: $position');
      }
      return true;
    }());
    // Set user position
    _isCurrentLocation = isCurrent;
    _userPosition = position;
    notifyListeners();
  }

  /// Stream of user device position updates
  Stream<Position>? get positionStream => _positionStream;
  Stream<Position>? _positionStream;
  StreamController<Position>? _positionStreamController;

  /// Stream of user marker position updates
  Stream<LocationMarkerPosition?>? get markerPositionStream =>
      _markerPositionStream;
  Stream<LocationMarkerPosition?>? _markerPositionStream;

  /// Listener of user device position updates
  StreamSubscription<Position>? _positionListener;

  /// Stream of location status updates
  Stream<bool>? get locationServiceStatusStream => _locationServiceStatusStream;
  Stream<bool>? _locationServiceStatusStream;

  /// Listener of location status updates
  StreamSubscription<bool>? _locationServiceStatusListener;

  /// Whether location service status is enabled
  bool get isLocationServiceEnabled => _locationServiceEnabled ?? true;
  bool? _locationServiceEnabled;

  /// Update user device position to last known position.
  ///
  /// Throws [LocationPermissionDeniedException] if user denied permission.
  Future<void> updateInitialPosition() async {
    final Position? lastPosition =
        await locationService.getLastKnownPosition(request: false);

    if (lastPosition != null) {
      setUserPosition(lastPosition, isCurrent: false);
    }
  }

  /// Update current user device position.
  ///
  /// Throws [LocationPermissionDeniedException] if user denied permission.\
  /// Throws [LocationServicesDisabledException] if location services are disabled.
  Future<void> updateCurrentPosition() async {
    final Position currentPosition =
        await locationService.getCurrentPosition(request: false);

    setUserPosition(currentPosition);
  }

  /// Check if it is listening to user device position updates
  bool get isListeningLocationUpdates => _positionListener != null;

  /// Listen to user device position updates.
  ///
  /// Handle the following errors with [onError]:
  ///
  /// Throws [LocationPermissionDeniedException] if user denied permission.\
  /// Throws [LocationServicesDisabledException] if location services are disabled.
  Future<void> startLocationUpdates({
    required void Function(Object e, StackTrace? stackTrace) onError,
  }) async {
    if (isListeningLocationUpdates) {
      await stopLocationUpdates();
    }

    // Stream with new positions
    Stream<Position> newPositionStream =
        (await locationService.getPositionUpdates(request: false))
            .handleError(onError);

    // Stream with initial and new positions
    final positionStreamController = StreamController<Position>.broadcast();

    positionStreamController
      ..onListen = () {
        final Position? initialPosition = _userPosition;

        // Emit initial position
        if (initialPosition != null) {
          positionStreamController.sink.add(initialPosition);
        }
      };

    // Set position stream
    _positionStream = positionStreamController.stream;
    _positionStreamController = positionStreamController;

    // Set marker position stream
    _markerPositionStream = locationMarkerFactory.fromGeolocatorPositionStream(
      stream: _positionStream,
    );

    // Listen to new positions
    _positionListener = newPositionStream.listen((Position position) {
      if (position != _userPosition) {
        setUserPosition(position);
      }
      // Emit new positions
      if (!positionStreamController.isClosed) {
        positionStreamController.sink.add(position);
      }
    });
  }

  /// Stop listening to user device position updates
  Future<void> stopLocationUpdates() async {
    await _positionListener?.cancel();
    await _positionStreamController?.close();
    _positionListener = null;
    _positionStream = null;
    _positionStreamController = null;
    _markerPositionStream = null;
  }

  /// Check if it is listening to location service status updates
  bool get isListeningLocationServiceStatus =>
      _locationServiceStatusListener != null;

  /// Set listeners to location service status updates
  Future<void> startLocationServiceStatusUpdates({
    FutureOr<void> Function()? onLocationServiceEnabled,
    FutureOr<void> Function()? onLocationServiceDisabled,
  }) async {
    if (isListeningLocationServiceStatus) {
      await stopLocationServiceStatusUpdates();
    }

    // Set current location service status
    _locationServiceEnabled = await locationService.isLocationServiceEnabled();

    if (_locationServiceStatusStream == null) {
      // Set location service stream
      _locationServiceStatusStream = locationService.getLocationStatusStream();
    }

    _locationServiceStatusListener = _locationServiceStatusStream?.listen(
      (bool locationServiceEnabled) async {
        _locationServiceEnabled = locationServiceEnabled;

        if (locationServiceEnabled) {
          await onLocationServiceEnabled?.call();
        } else {
          await onLocationServiceDisabled?.call();
        }

        notifyListeners();
      },
    );
  }

  /// Stop listening to location service status updates
  Future<void> stopLocationServiceStatusUpdates() async {
    await _locationServiceStatusListener?.cancel();
  }

  /// Ensure permissions are granted.\
  /// Requests permissions if needed.
  ///
  /// Throws [LocationPermissionDeniedException] if user denies permission.\
  /// Throws [LocationServicesDisabledException] if location services are disabled.
  Future<void> ensurePermissions() async {
    await locationService.ensurePermissions(request: true);
  }

  @override
  void dispose() {
    stopLocationUpdates();
    stopLocationServiceStatusUpdates();
    super.dispose();
  }
}
