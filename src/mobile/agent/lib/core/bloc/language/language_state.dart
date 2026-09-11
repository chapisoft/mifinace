import 'package:equatable/equatable.dart';
import '../../enums/app_language.dart';

/// State representing the currently active application language.
class LanguageState extends Equatable {
  final AppLanguage currentLanguage;

  const LanguageState({required this.currentLanguage});

  @override
  List<Object?> get props => [currentLanguage];
}
