import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../collection/domain/entities/repayment_receipt.dart';
import '../models/bluetooth_printer_device.dart';
import 'esc_pos_raster_encoder.dart';

/// Service rendering high-fidelity Myanmar Unicode & English Receipts to printable ESC/POS Raster Bitmaps.
class MyanmarReceiptRenderer {
  MyanmarReceiptRenderer._();

  /// Renders a [RepaymentReceipt] into raw ESC/POS Raster image bytes.
  static Future<Uint8List> renderReceiptToEscPosBytes({
    required RepaymentReceipt receipt,
    PrinterPaperWidth paperWidth = PrinterPaperWidth.mm58,
  }) async {
    final int widthInDots = paperWidth.dotsPerLine;
    final double estimatedHeight = paperWidth == PrinterPaperWidth.mm58 ? 620.0 : 680.0;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, widthInDots.toDouble(), estimatedHeight),
    );

    // 1. Draw white background
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, widthInDots.toDouble(), estimatedHeight), bgPaint);

    // 2. Draw Content Elements
    double currentY = 16.0;

    // Company Header
    currentY = _drawCenteredText(
      canvas: canvas,
      text: 'BMF MICROFINANCE MYANMAR',
      fontSize: 16,
      isBold: true,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY += 4;

    currentY = _drawCenteredText(
      canvas: canvas,
      text: 'ငွေရပြေစာ (OFFICIAL RECEIPT)',
      fontSize: 14,
      isBold: true,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY += 8;

    currentY = _drawDivider(canvas: canvas, y: currentY, width: widthInDots.toDouble());
    currentY += 8;

    // Receipt Meta Info
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'ပြေစာအမှတ် (Receipt No):',
      value: receipt.receiptNumber,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'ရက်စွဲ (Date & Time):',
      value: receipt.collectedAt.toIso8601String().replaceAll('T', ' ').substring(0, 19),
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'ကောက်ခံသူ (Officer):',
      value: receipt.collectorId,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY += 4;

    currentY = _drawDivider(canvas: canvas, y: currentY, width: widthInDots.toDouble(), isDashed: true);
    currentY += 8;

    // Customer & Loan Details
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'ဖောက်သည်အမည် (Customer):',
      value: receipt.customerName,
      y: currentY,
      width: widthInDots.toDouble(),
      isBold: true,
    );
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'ဖောက်သည်ကုဒ် (Code):',
      value: receipt.customerCode,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'စာချုပ်အမှတ် (Contract):',
      value: receipt.contractCode,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'အရစ်အမှတ် (Period):',
      value: '${receipt.periodNumber}',
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY += 4;

    currentY = _drawDivider(canvas: canvas, y: currentY, width: widthInDots.toDouble(), isDashed: true);
    currentY += 8;

    // Financial Breakdown
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'အရင်းငွေ (Principal):',
      value: CurrencyFormatter.formatMmk(receipt.principalAmount),
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'အတိုးငွေ (Interest):',
      value: CurrencyFormatter.formatMmk(receipt.interestAmount),
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'အာမခံကြေး (Insurance):',
      value: CurrencyFormatter.formatMmk(receipt.insuranceFee),
      y: currentY,
      width: widthInDots.toDouble(),
    );
    if (receipt.compulsorySaving > 0) {
      currentY = _drawKeyValue(
        canvas: canvas,
        key: 'မဖြစ်မနေစုငွေ (Saving):',
        value: CurrencyFormatter.formatMmk(receipt.compulsorySaving),
        y: currentY,
        width: widthInDots.toDouble(),
      );
    }
    currentY += 4;

    currentY = _drawDivider(canvas: canvas, y: currentY, width: widthInDots.toDouble());
    currentY += 8;

    // Total Amount Box
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'စုစုပေါင်းပေးသွင်းငွေ (TOTAL):',
      value: CurrencyFormatter.formatMmk(receipt.totalAmount),
      y: currentY,
      width: widthInDots.toDouble(),
      isBold: true,
      fontSize: 14,
    );
    currentY = _drawKeyValue(
      canvas: canvas,
      key: 'ပေးချေမှု (Method):',
      value: receipt.paymentMethod.code,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY += 8;

    currentY = _drawDivider(canvas: canvas, y: currentY, width: widthInDots.toDouble());
    currentY += 12;

    // Footer Messages
    currentY = _drawCenteredText(
      canvas: canvas,
      text: 'ကျေးဇူးတင်ပါသည် (Thank you)',
      fontSize: 13,
      isBold: true,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY += 4;

    currentY = _drawCenteredText(
      canvas: canvas,
      text: 'ပြေစာအား သိမ်းဆည်းထားပါရန်',
      fontSize: 11,
      isBold: false,
      y: currentY,
      width: widthInDots.toDouble(),
    );
    currentY += 16;

    final int actualHeight = currentY.ceil();
    final picture = recorder.endRecording();
    final image = await picture.toImage(widthInDots, actualHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

    if (byteData == null) {
      throw Exception('Failed to obtain RGBA image bytes from rendered receipt canvas.');
    }

    // Convert RGBA to 1-bit monochrome bitmap
    final monochromeBytes = EscPosRasterEncoder.convertRgbaToMonochrome1Bit(
      rgbaBytes: byteData.buffer.asUint8List(),
      width: widthInDots,
      height: actualHeight,
    );

    // Encode to ESC/POS Raster command
    return EscPosRasterEncoder.encodeRasterImage(
      monochromeBytes: monochromeBytes,
      widthInDots: widthInDots,
      heightInDots: actualHeight,
      feedAfterPrint: 4,
    );
  }

  static double _drawCenteredText({
    required Canvas canvas,
    required String text,
    required double fontSize,
    required bool isBold,
    required double y,
    required double width,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Pyidaungsu',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width);

    final double x = (width - textPainter.width) / 2;
    textPainter.paint(canvas, Offset(x, y));
    return y + textPainter.height;
  }

  static double _drawKeyValue({
    required Canvas canvas,
    required String key,
    required String value,
    required double y,
    required double width,
    bool isBold = false,
    double fontSize = 12,
  }) {
    final keySpan = TextSpan(
      text: key,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Pyidaungsu',
      ),
    );
    final keyPainter = TextPainter(
      text: keySpan,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width * 0.55);

    final valueSpan = TextSpan(
      text: value,
      style: TextStyle(
        color: Colors.black,
        fontSize: fontSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        fontFamily: 'Pyidaungsu',
      ),
    );
    final valuePainter = TextPainter(
      text: valueSpan,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width * 0.45);

    keyPainter.paint(canvas, Offset(8, y));
    valuePainter.paint(canvas, Offset(width - valuePainter.width - 8, y));

    final double rowHeight = (keyPainter.height > valuePainter.height ? keyPainter.height : valuePainter.height) + 4;
    return y + rowHeight;
  }

  static double _drawDivider({
    required Canvas canvas,
    required double y,
    required double width,
    bool isDashed = false,
  }) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0;

    if (!isDashed) {
      canvas.drawLine(Offset(8, y), Offset(width - 8, y), paint);
    } else {
      double startX = 8.0;
      while (startX < width - 8) {
        canvas.drawLine(Offset(startX, y), Offset(startX + 4, y), paint);
        startX += 8;
      }
    }
    return y + 2;
  }
}
