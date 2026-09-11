import 'package:flutter_bloc/flutter_bloc.dart';
import '../../enums/app_language.dart';
import '../../security/secure_storage_service.dart';
import '../../utils/app_logger.dart';
import 'language_state.dart';

/// Cubit managing immediate UI language toggling between Myanmar, English, and other supported locales.
class LanguageCubit extends Cubit<LanguageState> {
  final SecureStorageService _storageService;

  LanguageCubit(this._storageService)
      : super(const LanguageState(currentLanguage: AppLanguage.myanmar)) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final savedCode = await _storageService.getLanguage();
      if (savedCode != null) {
        final lang = AppLanguage.fromCode(savedCode);
        emit(LanguageState(currentLanguage: lang));
        AppLogger.info('Loaded saved language: ${lang.code}', tag: 'LanguageCubit');
      }
    } catch (e) {
      AppLogger.warn('Failed to load saved language: $e', tag: 'LanguageCubit');
    }
  }

  Future<void> changeLanguage(AppLanguage language) async {
    emit(LanguageState(currentLanguage: language));
    await _storageService.saveLanguage(language.code);
    AppLogger.info('Switched customer app language to: ${language.code}', tag: 'LanguageCubit');
  }
}
