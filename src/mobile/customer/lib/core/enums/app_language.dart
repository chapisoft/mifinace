import 'package:flutter/material.dart';

/// 6 Supported Languages across BMF ERP Platform.
enum AppLanguage {
  myanmar(code: 'my', languageName: 'မြန်မာ', englishName: 'Myanmar', locale: Locale('my')),
  english(code: 'en', languageName: 'English', englishName: 'English', locale: Locale('en')),
  vietnamese(code: 'vi', languageName: 'Tiếng Việt', englishName: 'Vietnamese', locale: Locale('vi')),
  chinese(code: 'zh', languageName: '中文', englishName: 'Chinese', locale: Locale('zh')),
  japanese(code: 'ja', languageName: '日本語', englishName: 'Japanese', locale: Locale('ja')),
  korean(code: 'ko', languageName: '한국어', englishName: 'Korean', locale: Locale('ko'));

  final String code;
  final String languageName;
  final String englishName;
  final Locale locale;

  const AppLanguage({
    required this.code,
    required this.languageName,
    required this.englishName,
    required this.locale,
  });

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.myanmar; // Default Myanmar for borrower app
    for (final l in AppLanguage.values) {
      if (l.code.toLowerCase() == code.toLowerCase()) {
        return l;
      }
    }
    return AppLanguage.myanmar;
  }
}
