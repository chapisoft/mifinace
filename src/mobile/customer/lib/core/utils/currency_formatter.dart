import 'package:intl/intl.dart';

/// Formatter for Myanmar Kyats (MMK) currency values.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _mmkFormat = NumberFormat('#,##0', 'en_US');

  /// Formats an amount into formatted MMK string e.g. "1,250,000 MMK".
  static String formatMmk(num amount) {
    return '${_mmkFormat.format(amount)} MMK';
  }

  /// Parses a string representation into a numeric double.
  static double parseMmk(String text) {
    if (text.trim().isEmpty) return 0.0;
    final cleaned = text.replaceAll(',', '').replaceAll('MMK', '').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }
}
