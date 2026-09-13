import '../l10n/app_localizations.dart';

/// Risk types covered under BMF village mutual micro-insurance program.
enum ClaimRiskType {
  illness(code: 'ILLNESS', label: 'Inpatient Hospitalization', myanmarLabel: 'ဖျားနာဆေးရုံတက်'),
  accident(code: 'ACCIDENT', label: 'Work / Traffic Accident', myanmarLabel: 'မတော်တဆထိခိုက်မှု'),
  naturalDisaster(code: 'NATURAL_DISASTER', label: 'Flood / Cyclone / Fire', myanmarLabel: 'သဘာဝဘေးအန္တရာယ်'),
  death(code: 'DEATH', label: 'Member / Spouse Bereavement', myanmarLabel: 'သေဆုံးမှု ထောက်ပံ့ငွေ'),
  cropFailure(code: 'CROP_FAILURE', label: 'Severe Crop Pest / Drought', myanmarLabel: 'သီးနှံပျက်စီးမှု');

  final String code;
  final String label;
  final String myanmarLabel;

  const ClaimRiskType({
    required this.code,
    required this.label,
    required this.myanmarLabel,
  });

  static ClaimRiskType fromCode(String? code) {
    if (code == null) return ClaimRiskType.illness;
    for (final type in ClaimRiskType.values) {
      if (type.code == code || type.name.toUpperCase() == code.toUpperCase()) {
        return type;
      }
    }
    return ClaimRiskType.illness;
  }
}

extension ClaimRiskTypeL10n on ClaimRiskType {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case ClaimRiskType.illness:
        return l10n.claimRiskIllness;
      case ClaimRiskType.accident:
        return l10n.claimRiskAccident;
      case ClaimRiskType.naturalDisaster:
        return l10n.claimRiskNaturalDisaster;
      case ClaimRiskType.death:
        return l10n.claimRiskDeath;
      case ClaimRiskType.cropFailure:
        return l10n.claimRiskCropFailure;
    }
  }
}

