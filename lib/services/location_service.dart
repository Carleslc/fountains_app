import 'package:geolocator/geolocator.dart';

import '../exceptions/location.dart';
import '../models/distance.dart';
import '../utils/location.dart';
import '../utils/logger.dart';
import '../utils/platform.dart';

/// Service to retrieve user device position
class LocationService {
  /// Location settings (accuracy, distance filter, timeout)
  final LocationSettings _locationSettings;

  LocationService({
    LocationAccuracy accuracy = LocationAccuracy.best,
    Distance? distanceFilter,
    Duration? timeLimit,
  }) : _locationSettings = LocationSettings(
          accuracy: accuracy,
          distanceFilter: distanceFilter?.meters.toInt() ?? 0,
          timeLimit: timeLimit,
        );

  /// Retrieve current user device position.
  ///
  /// Request permissions if needed when [request] is true.
  ///
  /// Throws [LocationPermissionDeniedException] if user denies permission.\
  /// Throws [LocationServicesDisabledException] if location services are disabled.
  Future<Position> getCurrentPosition({bool request = true}) async {
    if (request) await ensurePermissions();

    final Position position = await _wrapExceptions(
      Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      ),
    );

    return position;
  }

  /// Retrieve last known user device position.
  ///
  /// Request permissions if needed when [request] is true.
  ///
  /// Throws [LocationPermissionDeniedException] if user denies permission.\
  /// Throws [LocationServicesDisabledException] if location services are disabled.
  ///
  /// Not supported on the web platform (returns null).
  Future<Position?> getLastKnownPosition({bool request = true}) async {
    if (isWeb) return null; // not supported on the web platform

    if (request) await ensurePermissions();

    final Position? position = await _wrapExceptions(
      Geolocator.getLastKnownPosition(),
    );

    return position;
  }

  /// Get a stream to listen to user device position updates.
  ///
  /// Request permissions if needed when [request] is true.
  ///
  /// Throws [LocationPermissionDeniedException] if user denies permission.\
  /// Throws [LocationServicesDisabledException] if location services are disabled.
  Future<Stream<Position>> getPositionUpdates({bool request = true}) async {
    if (request) await ensurePermissions();

    final Stream<Position> stream = await _wrapExceptionsStream(
      () => Geolocator.getPositionStream(locationSettings: _locationSettings),
    );

    return stream;
  }

  /// Emits whenever the location services are disabled/enabled
  /// in the notification bar or in the device settings.
  ///
  /// Emits true when location services are enabled and false when location services are disabled.
  ///
  /// Not supported on the web platform (returns null).
  Stream<bool>? getLocationStatusStream() {
    if (isWeb) return null; // not supported on the web platform

    return Geolocator.getServiceStatusStream()
        .map<bool>((ServiceStatus locationStatus) =>
            locationStatus == ServiceStatus.enabled)
        .handleError((e, stackTrace) {
      error('Error while listening to location service status', e, stackTrace);
    });
  }

  /// Check whether location services are enabled
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  /// Request permissions if needed when [request] is true.
  ///
  /// Throws [LocationPermissionDeniedException] if user denies permission.\
  /// Throws [LocationServicesDisabledException] if location services are disabled.
  Future<void> ensurePermissions({bool request = true}) async {
    final bool serviceEnabled = await isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw LocationServicesDisabledException();
    }

    LocationPermission permission = await getLocationPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debug('Location permission not granted');

      if (!request || permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedException(permission);
      }

      debug('Requesting location permissions...');
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedException(permission);
      }
    }

    debug('Location permission: $permission');
  }

  /// Get the location permission status
  Future<LocationPermission> getLocationPermission() =>
      Geolocator.checkPermission();

  /// Check if the user has enabled location permissions
  Future<bool> hasPermissions() async {
    LocationPermission permission = await getLocationPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Open device configuration to enable location services
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  /// Open device configuration to enable permissions
  Future<bool> openAppSettings() => Geolocator.openAppSettings();

  /// Calculate the distance between two locations
  double distance(
    Location a,
    Location b, {
    DistanceCalculatorAccuracy accuracy = DistanceCalculatorAccuracy.high,
  }) =>
      accuracy.distanceCalculator.distance(a, b);

  /// Wrap [Geolocator] exceptions with app [LocationException]
  ///
  /// [PermissionDeniedException] -> [LocationPermissionDeniedException]\
  /// [LocationServiceDisabledException] -> [LocationServicesDisabledException]
  Future<T> _wrapExceptions<T>(Future<T> geolocatorHandle) {
    return geolocatorHandle
        .catchError(
          test: (e) => e is LocationServiceDisabledException,
          _throwLocationServicesDisabledException,
        )
        .catchError(
          test: (e) => e is PermissionDeniedException,
          _throwLocationPermissionDeniedException,
        );
  }

  /// Wrap [Geolocator] stream exceptions with app [LocationException]
  ///
  /// [PermissionDeniedException] -> [LocationPermissionDeniedException]\
  /// [LocationServiceDisabledException] -> [LocationServicesDisabledException]
  Future<Stream<T>> _wrapExceptionsStream<T>(
    Stream<T> Function() geolocatorStreamHandle,
  ) {
    return _wrapExceptions(
      Future.sync(
        () => geolocatorStreamHandle()
            .handleError(
              test: (e) => e is LocationServiceDisabledException,
              _throwLocationServicesDisabledException,
            )
            .handleError(
              test: (e) => e is PermissionDeniedException,
              _throwLocationPermissionDeniedException,
            ),
      ),
    );
  }

  void _throwLocationServicesDisabledException(
      Object e, StackTrace? stackTrace) {
    throw LocationServicesDisabledException();
  }

  Future<void> _throwLocationPermissionDeniedException(
      Object e, StackTrace? stackTrace) async {
    throw LocationPermissionDeniedException(await getLocationPermission());
  }
}
