import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('formatMmk formats numbers into MMK strings', () {
      expect(CurrencyFormatter.formatMmk(500000), '500,000 MMK');
      expect(CurrencyFormatter.formatMmk(0), '0 MMK');
      expect(CurrencyFormatter.formatMmk(null), '0 MMK');
      expect(CurrencyFormatter.formatMmk(1250000), '1,250,000 MMK');
    });

    test('parseMmk parses formatted MMK strings into numbers', () {
      expect(CurrencyFormatter.parseMmk('500,000 MMK'), 500000);
      expect(CurrencyFormatter.parseMmk('1,250,000 MMK'), 1250000);
      expect(CurrencyFormatter.parseMmk('0 MMK'), 0);
      expect(CurrencyFormatter.parseMmk('invalid'), 0);
    });
  });
}
