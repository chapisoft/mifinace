import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'gps_location.dart';

/// Service generating immutable watermarks (GPS coordinates, Timestamp, Officer ID) on field survey photos.
class PhotoWatermarkService {
  PhotoWatermarkService._();

  /// Applies a high-visibility text watermark banner onto an image buffer.
  static Future<Uint8List> applyWatermark({
    required Uint8List imageBytes,
    required GpsLocation gps,
    required String officerId,
    required String customerNrc,
  }) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final ui.Image baseImage = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, baseImage.width.toDouble(), baseImage.height.toDouble()));

    // 1. Draw base photo
    canvas.drawImage(baseImage, Offset.zero, Paint());

    // 2. Draw semi-transparent watermark footer banner
    const double bannerHeight = 70.0;
    final bannerRect = Rect.fromLTWH(
      0,
      baseImage.height.toDouble() - bannerHeight,
      baseImage.width.toDouble(),
      bannerHeight,
    );
    final bgPaint = Paint()..color = Colors.black.withAlpha(160);
    canvas.drawRect(bannerRect, bgPaint);

    // 3. Draw Watermark Metadata
    final timeStr = gps.timestamp.toIso8601String().replaceAll('T', ' ').substring(0, 19);
    final coordStr = 'LAT: ${gps.latitude.toStringAsFixed(6)}  LON: ${gps.longitude.toStringAsFixed(6)}  (±${gps.accuracy.toStringAsFixed(1)}m)';
    final metaStr = 'BMF MICROFINANCE • OFFICER: $officerId • NRC: $customerNrc • $timeStr';

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: '$metaStr\n',
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: coordStr,
          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: baseImage.width.toDouble() - 24);

    textPainter.paint(
      canvas,
      Offset(12, baseImage.height.toDouble() - bannerHeight + 14),
    );

    final picture = recorder.endRecording();
    final watermarkedImage = await picture.toImage(baseImage.width, baseImage.height);
    final byteData = await watermarkedImage.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to encode watermarked survey photo.');
    }

    return byteData.buffer.asUint8List();
  }
}
