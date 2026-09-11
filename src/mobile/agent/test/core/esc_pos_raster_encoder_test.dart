import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/features/printer/domain/services/esc_pos_raster_encoder.dart';

void main() {
  group('ESC/POS Raster Encoder Tests (TASK-AGENT-05.2 & 05.3)', () {
    test('encodeRasterImage generates valid ESC/POS GS v 0 binary command stream', () {
      const widthInDots = 384; // 58mm printer
      const heightInDots = 100;
      const widthInBytes = 384 ~/ 8; // 48 bytes per line

      final dummyMonochrome = Uint8List(widthInBytes * heightInDots);
      // Fill with test pattern
      for (int i = 0; i < dummyMonochrome.length; i++) {
        dummyMonochrome[i] = 0xAA; // 10101010 binary
      }

      final bytes = EscPosRasterEncoder.encodeRasterImage(
        monochromeBytes: dummyMonochrome,
        widthInDots: widthInDots,
        heightInDots: heightInDots,
        feedAfterPrint: 3,
      );

      // Verify Header: ESC @ (Initialize)
      expect(bytes[0], equals(0x1B));
      expect(bytes[1], equals(0x40));

      // Verify Align Center: ESC a 1
      expect(bytes[2], equals(0x1B));
      expect(bytes[3], equals(0x61));
      expect(bytes[4], equals(0x01));

      // Verify GS v 0 m xL xH yL yH
      expect(bytes[5], equals(0x1D)); // GS
      expect(bytes[6], equals(0x76)); // v
      expect(bytes[7], equals(0x30)); // 0
      expect(bytes[8], equals(0x00)); // m = 0 (Normal mode)

      // xL, xH: 48 bytes -> xL = 48, xH = 0
      expect(bytes[9], equals(48));
      expect(bytes[10], equals(0));

      // yL, yH: 100 lines -> yL = 100, yH = 0
      expect(bytes[11], equals(100));
      expect(bytes[12], equals(0));

      // Verify trailing feed lines: ESC d 3
      final len = bytes.length;
      expect(bytes[len - 3], equals(0x1B));
      expect(bytes[len - 2], equals(0x64));
      expect(bytes[len - 1], equals(3));
    });

    test('convertRgbaToMonochrome1Bit converts RGBA pixels into 1-bit packed bitmap', () {
      const width = 8;
      const height = 2;
      // 8 pixels per line, 2 lines = 16 pixels * 4 bytes = 64 bytes RGBA
      final rgba = Uint8List(width * height * 4);

      // Line 0: alternating Black (0,0,0,255) and White (255,255,255,255)
      for (int x = 0; x < width; x++) {
        final idx = x * 4;
        if (x % 2 == 0) {
          // Black pixel -> should be bit 1
          rgba[idx] = 0;
          rgba[idx + 1] = 0;
          rgba[idx + 2] = 0;
          rgba[idx + 3] = 255;
        } else {
          // White pixel -> should be bit 0
          rgba[idx] = 255;
          rgba[idx + 1] = 255;
          rgba[idx + 2] = 255;
          rgba[idx + 3] = 255;
        }
      }

      final monochrome = EscPosRasterEncoder.convertRgbaToMonochrome1Bit(
        rgbaBytes: rgba,
        width: width,
        height: height,
        luminanceThreshold: 128,
      );

      // 8 dots = 1 byte per line
      expect(monochrome.length, equals(2));
      // First byte: bits 7, 5, 3, 1 are 1 -> 10101010 in binary = 0xAA
      expect(monochrome[0], equals(0xAA));
    });
  });
}
