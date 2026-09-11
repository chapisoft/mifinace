import 'package:equatable/equatable.dart';

/// Geographical coordinates collected at the borrower village residence.
class GpsLocation extends Equatable {
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy; // Meters
  final DateTime timestamp;

  const GpsLocation({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
    this.accuracy = 5.0,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GpsLocation.fromJson(Map<String, dynamic> json) {
    return GpsLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, altitude, accuracy, timestamp];
}
