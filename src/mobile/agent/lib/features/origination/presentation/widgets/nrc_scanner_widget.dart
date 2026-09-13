import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../domain/models/nrc_data.dart';
import '../../domain/services/nrc_parser.dart';

/// Interactive Camera Overlay & OCR Form Scanner for Myanmar NRC Cards.
class NrcScannerWidget extends StatefulWidget {
  final Function(NrcData nrcData) onNrcCaptured;

  const NrcScannerWidget({
    super.key,
    required this.onNrcCaptured,
  });

  @override
  State<NrcScannerWidget> createState() => _NrcScannerWidgetState();
}

class _NrcScannerWidgetState extends State<NrcScannerWidget> {
  final TextEditingController _nrcController = TextEditingController();
  NrcData? _parsedNrc;
  bool _hasInvalidFormat = false;

  @override
  void initState() {
    super.initState();
    _nrcController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _nrcController.removeListener(_onTextChanged);
    _nrcController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _nrcController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedNrc = null;
        _hasInvalidFormat = false;
      });
      return;
    }

    final parsed = NrcParser.parseNrc(text);
    setState(() {
      if (parsed != null) {
        _parsedNrc = parsed;
        _hasInvalidFormat = false;
        widget.onNrcCaptured(parsed);
      } else {
        _parsedNrc = null;
        _hasInvalidFormat = text.length >= 8;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Camera Viewfinder Box Mock
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _parsedNrc != null ? AppTheme.accentTeal : AppTheme.primaryNavy,
              width: 2.0,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Card Target Frame
              Container(
                width: 250,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _parsedNrc != null ? AppTheme.accentTeal : Colors.white70,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _parsedNrc != null ? Icons.check_circle : Icons.credit_card,
                        size: 32,
                        color: _parsedNrc != null ? AppTheme.accentTeal : Colors.white70,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _parsedNrc != null
                            ? _parsedNrc!.fullNrcFormatted
                            : l10n.positionNrcInFrame,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _parsedNrc != null ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: _parsedNrc != null ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Manual / OCR Recognized Text Input
        TextField(
          controller: _nrcController,
          decoration: InputDecoration(
            labelText: l10n.nrcInputLabel,
            hintText: l10n.nrcInputHint,
            prefixIcon: const Icon(Icons.badge_outlined),
            suffixIcon: _parsedNrc != null
                ? const Icon(Icons.check_circle, color: AppTheme.accentTeal)
                : null,
            errorText: _hasInvalidFormat ? l10n.invalidNrcFormat : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),

        if (_parsedNrc != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.accentTeal.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppTheme.accentTeal, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verified NRC: ${_parsedNrc!.fullNrcFormatted} • Type: ${_parsedNrc!.citizenshipType.englishText} • State: ${_parsedNrc!.stateNumber}',
                    style: const TextStyle(color: AppTheme.accentTeal, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
