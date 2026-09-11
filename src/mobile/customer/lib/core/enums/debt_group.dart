import 'package:flutter/material.dart';
import '../../app/theme/customer_theme.dart';

/// 5 Debt Classification Groups mandated by Financial Regulatory Department (FRD) Myanmar.
enum DebtGroup {
  current(code: 'CURRENT', label: 'Standard Current', myanmarLabel: 'ပုံမှန်ချေးငွေ', minOverdueDays: 0, maxOverdueDays: 0),
  specialMention(code: 'SPECIAL_MENTION', label: 'Special Mention', myanmarLabel: 'အထူးစောင့်ကြည့်', minOverdueDays: 1, maxOverdueDays: 30),
  substandard(code: 'SUBSTANDARD', label: 'Substandard', myanmarLabel: 'စံချိန်မမီ', minOverdueDays: 31, maxOverdueDays: 60),
  doubtful(code: 'DOUBTFUL', label: 'Doubtful', myanmarLabel: 'သံသယဖြစ်ဖွယ်', minOverdueDays: 61, maxOverdueDays: 90),
  loss(code: 'LOSS', label: 'Loss / Bad Debt', myanmarLabel: 'ဆုံးရှုံးချေးငွေ', minOverdueDays: 91, maxOverdueDays: 999999);

  final String code;
  final String label;
  final String myanmarLabel;
  final int minOverdueDays;
  final int maxOverdueDays;

  const DebtGroup({
    required this.code,
    required this.label,
    required this.myanmarLabel,
    required this.minOverdueDays,
    required this.maxOverdueDays,
  });

  static DebtGroup fromOverdueDays(int days) {
    if (days <= 0) return DebtGroup.current;
    if (days <= 30) return DebtGroup.specialMention;
    if (days <= 60) return DebtGroup.substandard;
    if (days <= 90) return DebtGroup.doubtful;
    return DebtGroup.loss;
  }

  static DebtGroup fromCode(String? code) {
    if (code == null) return DebtGroup.current;
    for (final g in DebtGroup.values) {
      if (g.code == code || g.name.toUpperCase() == code.toUpperCase()) {
        return g;
      }
    }
    return DebtGroup.current;
  }

  bool get isNonPerforming =>
      this == DebtGroup.substandard || this == DebtGroup.doubtful || this == DebtGroup.loss;

  Color get badgeColor {
    switch (this) {
      case DebtGroup.current:
        return CustomerTheme.statusCurrent;
      case DebtGroup.specialMention:
        return CustomerTheme.statusSpecialMention;
      case DebtGroup.substandard:
        return CustomerTheme.statusSubstandard;
      case DebtGroup.doubtful:
        return CustomerTheme.statusDoubtful;
      case DebtGroup.loss:
        return CustomerTheme.statusLoss;
    }
  }
}
