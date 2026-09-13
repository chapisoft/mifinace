import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';

/// Interactive Touch Signature Pad for field borrower e-Signature capture.
class SignaturePadWidget extends StatefulWidget {
  final Function(Uint8List signaturePngBytes) onSignatureCaptured;
  final VoidCallback? onCleared;

  const SignaturePadWidget({
    super.key,
    required this.onSignatureCaptured,
    this.onCleared,
  });

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];

  bool get hasSignature => _strokes.isNotEmpty;

  void _clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
    widget.onCleared?.call();
  }

  Future<void> _exportSignature() async {
    if (!hasSignature) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 350, 180));

    // Transparent background
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final stroke in _strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(350, 180);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null) {
      widget.onSignatureCaptured(byteData.buffer.asUint8List());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasSignature ? AppTheme.primaryNavy : AppTheme.borderSubtle,
              width: hasSignature ? 1.5 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                // Signature Canvas
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _currentStroke = [details.localPosition];
                      _strokes.add(_currentStroke);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentStroke.add(details.localPosition);
                    });
                  },
                  onPanEnd: (_) {
                    _exportSignature();
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(_strokes),
                    size: Size.infinite,
                  ),
                ),

                // Baseline guideline & hint text
                if (!hasSignature)
                  Center(
                    child: Text(
                      l10n.signHerePrompt,
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ),

                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 1,
                    color: AppTheme.borderSubtle,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.clear, size: 16),
              label: Text(l10n.clearSignature, style: const TextStyle(fontSize: 12)),
              onPressed: hasSignature ? _clear : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
