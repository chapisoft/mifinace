import 'package:flutter/material.dart';
import 'package:bmf_customer/app/theme/customer_theme.dart';

/// Secure Numeric Keypad that randomizes key positions to prevent shoulder surfing and smudge attacks.
class RandomNumericKeypad extends StatefulWidget {
  final Function(String digit) onKeyPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometric;

  const RandomNumericKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometric = false,
  });

  @override
  State<RandomNumericKeypad> createState() => _RandomNumericKeypadState();
}

class _RandomNumericKeypadState extends State<RandomNumericKeypad> {
  late List<int> _digits;

  @override
  void initState() {
    super.initState();
    _randomizeDigits();
  }

  void _randomizeDigits() {
    _digits = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 0; col < 3; col++)
                  _buildKeyButton(_digits[row * 3 + col].toString()),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bottom Left: Biometric or empty
              if (widget.showBiometric && widget.onBiometricPressed != null)
                IconButton(
                  icon: const Icon(Icons.fingerprint, size: 36, color: CustomerTheme.primaryNavy),
                  onPressed: widget.onBiometricPressed,
                )
              else
                const SizedBox(width: 72, height: 72),

              // Bottom Center: 10th digit
              _buildKeyButton(_digits[9].toString()),

              // Bottom Right: Delete backspace
              SizedBox(
                width: 72,
                height: 72,
                child: IconButton(
                  icon: const Icon(Icons.backspace_outlined, size: 28, color: CustomerTheme.textSecondary),
                  onPressed: widget.onDeletePressed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton(String text) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: CustomerTheme.surfaceWhite,
        shape: BoxShape.circle,
        border: Border.all(color: CustomerTheme.borderSubtle, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(36),
        onTap: () => widget.onKeyPressed(text),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: CustomerTheme.primaryNavy,
            ),
          ),
        ),
      ),
    );
  }
}
