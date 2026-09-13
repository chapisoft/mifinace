import 'dart:typed_data';

/// ESC/POS Command & Raster Bit Image Encoder for portable thermal printers.
class EscPosRasterEncoder {
  EscPosRasterEncoder._();

  // Common ESC/POS Commands
  static const List<int> cmdInit = [0x1B, 0x40]; // ESC @
  static const List<int> cmdAlignLeft = [0x1B, 0x61, 0x00]; // ESC a 0
  static const List<int> cmdAlignCenter = [0x1B, 0x61, 0x01]; // ESC a 1
  static const List<int> cmdAlignRight = [0x1B, 0x61, 0x02]; // ESC a 2
  static const List<int> cmdCutPaper = [0x1D, 0x56, 0x42, 0x00]; // GS V 'B' 0

  /// Generates feed lines command.
  static List<int> cmdFeedLines(int lines) {
    return [0x1B, 0x64, lines]; // ESC d n
  }

  /// Encodes a 1-bit monochrome bitmap buffer into ESC/POS Raster Bit Image format (GS v 0).
  ///
  /// [monochromeBytes]: 1-bit packed bitmap data (widthInDots * heightInDots / 8 bytes).
  /// [widthInDots]: Image width in pixels (e.g., 384 for 58mm, 576 for 80mm).
  /// [heightInDots]: Image height in pixels.
  static Uint8List encodeRasterImage({
    required Uint8List monochromeBytes,
    required int widthInDots,
    required int heightInDots,
    int feedAfterPrint = 3,
  }) {
    final int widthInBytes = (widthInDots + 7) ~/ 8;
    final int xL = widthInBytes % 256;
    final int xH = (widthInBytes ~/ 256) % 256;
    final int yL = heightInDots % 256;
    final int yH = (heightInDots ~/ 256) % 256;

    final BytesBuilder builder = BytesBuilder();

    // 1. Initialize printer
    builder.add(cmdInit);

    // 2. Align center
    builder.add(cmdAlignCenter);

    // 3. GS v 0 m xL xH yL yH
    builder.add([
      0x1D, // GS
      0x76, // v
      0x30, // 0 (Raster bit image)
      0x00, // m = 0 (Normal mode)
      xL,
      xH,
      yL,
      yH,
    ]);

    // 4. Append bitmap data
    builder.add(monochromeBytes);

    // 5. Feed lines and optional cut
    if (feedAfterPrint > 0) {
      builder.add(cmdFeedLines(feedAfterPrint));
    }

    return builder.toBytes();
  }

  /// Converts RGBA raw pixels (4 bytes per pixel) to 1-bit packed monochrome bitmap buffer.
  /// Uses Luminance Thresholding (0.299*R + 0.587*G + 0.114*B < 128 -> Black dot = 1).
  static Uint8List convertRgbaToMonochrome1Bit({
    required Uint8List rgbaBytes,
    required int width,
    required int height,
    int luminanceThreshold = 140,
  }) {
    final int widthInBytes = (width + 7) ~/ 8;
    final Uint8List result = Uint8List(widthInBytes * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int rgbaIndex = (y * width + x) * 4;
        if (rgbaIndex + 3 >= rgbaBytes.length) break;

        final int r = rgbaBytes[rgbaIndex];
        final int g = rgbaBytes[rgbaIndex + 1];
        final int b = rgbaBytes[rgbaIndex + 2];
        final int a = rgbaBytes[rgbaIndex + 3];

        // If pixel is semi-transparent, treat as white background
        final bool isBlack;
        if (a < 50) {
          isBlack = false;
        } else {
          final double luminance = 0.299 * r + 0.587 * g + 0.114 * b;
          isBlack = luminance < luminanceThreshold;
        }

        if (isBlack) {
          final int byteIndex = y * widthInBytes + (x ~/ 8);
          final int bitPosition = 7 - (x % 8);
          result[byteIndex] |= (1 << bitPosition);
        }
      }
    }

    return result;
  }
}
