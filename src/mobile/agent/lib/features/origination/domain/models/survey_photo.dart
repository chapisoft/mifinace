import 'package:equatable/equatable.dart';
import '../../../../core/enums/survey_photo_type.dart';
import 'gps_location.dart';

/// Entity representing a field survey photograph taken during loan origination.
class SurveyPhoto extends Equatable {
  final String photoId;
  final SurveyPhotoType photoType;
  final String filePath;
  final String? base64Thumbnail;
  final GpsLocation? gpsLocation;
  final DateTime capturedAt;
  final int fileSizeBytes;

  const SurveyPhoto({
    required this.photoId,
    required this.photoType,
    required this.filePath,
    this.base64Thumbnail,
    this.gpsLocation,
    required this.capturedAt,
    required this.fileSizeBytes,
  });

  Map<String, dynamic> toJson() {
    return {
      'photoId': photoId,
      'photoType': photoType.code,
      'filePath': filePath,
      'base64Thumbnail': base64Thumbnail,
      'gpsLocation': gpsLocation?.toJson(),
      'capturedAt': capturedAt.toIso8601String(),
      'fileSizeBytes': fileSizeBytes,
    };
  }

  @override
  List<Object?> get props => [
        photoId,
        photoType,
        filePath,
        base64Thumbnail,
        gpsLocation,
        capturedAt,
        fileSizeBytes,
      ];
}
