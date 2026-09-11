import 'package:intl/intl.dart';

/// Formatter for Myanmar Kyat (MMK) currency amounts.
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat('#,##0', 'en_US');

  /// Format an amount into "150,000 MMK" or "0 MMK".
  static String formatMmk(num? amount) {
    if (amount == null) return '0 MMK';
    return '${_formatter.format(amount)} MMK';
  }

  /// Format without currency suffix (e.g. "150,000").
  static String formatNumber(num? amount) {
    if (amount == null) return '0';
    return _formatter.format(amount);
  }

  /// Parse a string formatted amount back to integer or double.
  static num parseMmk(String text) {
    final clean = text.replaceAll('MMK', '').replaceAll(',', '').trim();
    return num.tryParse(clean) ?? 0;
  }
}
