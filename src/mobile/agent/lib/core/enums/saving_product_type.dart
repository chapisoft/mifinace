import '../l10n/app_localizations.dart';

/// Microfinance savings product types in Myanmar.
enum SavingProductType {
  compulsory(code: 'COMPULSORY', label: 'Compulsory Micro Saving', myanmarLabel: 'မဖြစ်မနေ စုဆောင်းငွေ'),
  voluntary(code: 'VOLUNTARY', label: 'Voluntary Open Saving', myanmarLabel: 'ဆန္ဒအလျောက် စုဆောင်းငွေ'),
  fixedTerm(code: 'FIXED_TERM', label: 'Fixed Term Deposit', myanmarLabel: 'ကာလသတ်မှတ် စုဆောင်းငွေ');

  final String code;
  final String label;
  final String myanmarLabel;

  const SavingProductType({
    required this.code,
    required this.label,
    required this.myanmarLabel,
  });

  static SavingProductType fromCode(String? code) {
    if (code == null) return SavingProductType.voluntary;
    for (final type in SavingProductType.values) {
      if (type.code == code || type.name.toUpperCase() == code.toUpperCase()) {
        return type;
      }
    }
    return SavingProductType.voluntary;
  }
}

extension SavingProductTypeL10n on SavingProductType {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case SavingProductType.compulsory:
        return l10n.savingProductCompulsory;
      case SavingProductType.voluntary:
        return l10n.savingProductVoluntary;
      case SavingProductType.fixedTerm:
        return l10n.savingProductFixedTerm;
    }
  }
}

