import 'package:intl/intl.dart';

/// Formatter for Dates and Times in ISO-8601 & Myanmar Display formats.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');
  static final DateFormat _isoDateTime = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _displayDate = DateFormat('dd/MM/yyyy');
  static final DateFormat _displayDateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String formatIsoDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _isoDate.format(dateTime);
  }

  static String formatIsoDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _isoDateTime.format(dateTime);
  }

  static String formatDisplayDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _displayDate.format(dateTime);
  }

  static String formatDisplayDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return _displayDateTime.format(dateTime);
  }

  static DateTime? parseIsoDate(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }
}
