import 'dart:ui';

/// Languages supported in the BMF mobile ecosystem.
enum AppLanguage {
  myanmar('my', 'မြန်မာ', 'Myanmar (Pyidaungsu Unicode)'),
  english('en', 'English', 'English'),
  vietnamese('vi', 'Tiếng Việt', 'Vietnamese'),
  chinese('zh', '中文', 'Simplified Chinese'),
  japanese('ja', '日本語', 'Japanese'),
  korean('ko', '한국어', 'Korean');

  final String languageCode;
  final String displayName;
  final String nativeName;

  const AppLanguage(this.languageCode, this.displayName, this.nativeName);

  String get code => languageCode;

  Locale get locale => Locale(languageCode);

  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.myanmar; // Default to Myanmar language for BMF
    for (final lang in AppLanguage.values) {
      if (lang.languageCode == code.toLowerCase()) {
        return lang;
      }
    }
    return AppLanguage.myanmar;
  }
}
