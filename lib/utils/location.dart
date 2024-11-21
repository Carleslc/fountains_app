import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Location coordinates
typedef Location = LatLng;

extension PositionExtension on Position {
  Location toLocation() => Location(latitude, longitude);
}
