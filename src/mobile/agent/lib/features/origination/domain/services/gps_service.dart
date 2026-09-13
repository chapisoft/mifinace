import '../models/gps_location.dart';

/// Service interface for retrieving accurate field GPS coordinates.
abstract class GpsService {
  /// Fetches the current location coordinates of the field officer.
  Future<GpsLocation> getCurrentLocation();

  /// Checks whether GPS location services are enabled on the device.
  Future<bool> isLocationServiceEnabled();
}
