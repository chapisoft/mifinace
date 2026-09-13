import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_constants.dart';
import '../../enums/app_language.dart';
import '../../security/secure_storage_service.dart';
import '../../utils/app_logger.dart';
import 'language_state.dart';

/// Cubit managing dynamic runtime language switching across 6 languages.
class LanguageCubit extends Cubit<LanguageState> {
  final SecureStorageService _secureStorage;

  LanguageCubit(this._secureStorage)
      : super(const LanguageState(currentLanguage: AppLanguage.english)) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final savedCode = await _secureStorage.read(AppConstants.selectedLanguageKey);
      if (savedCode != null) {
        final lang = AppLanguage.fromCode(savedCode);
        emit(LanguageState(currentLanguage: lang));
        AppLogger.info('Loaded saved language: ${lang.displayName} (${lang.languageCode})', tag: 'LanguageCubit');
      }
    } catch (e) {
      AppLogger.warn('Failed to load saved language, default to English: $e', tag: 'LanguageCubit');
    }
  }

  Future<void> changeLanguage(AppLanguage language) async {
    emit(LanguageState(currentLanguage: language));
    await _secureStorage.write(AppConstants.selectedLanguageKey, language.languageCode);
    AppLogger.info('Switched application language to: ${language.displayName}', tag: 'LanguageCubit');
  }
}
