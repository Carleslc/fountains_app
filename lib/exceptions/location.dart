import 'package:geolocator/geolocator.dart';

import 'error.dart';

///
/// Exceptions related to geolocation services
///
abstract class LocationException extends AppException {}

/// User does not have location enabled on their device
class LocationServicesDisabledException extends LocationException {
  @override
  String get message => 'Location services are disabled';
}

/// User denied location permissions
class LocationPermissionDeniedException extends LocationException {
  final LocationPermission permission;

  LocationPermissionDeniedException(this.permission) {
    assert(permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever);
  }

  @override
  String get message {
    String message = 'Location permissions are denied';

    if (permission == LocationPermission.deniedForever) {
      message += ' (forever)';
    }

    return message;
  }
}
