/// Savings deposit contribution frequency.
enum SavingFrequency {
  weekly(code: 'WEEKLY', label: 'Weekly Deposit', myanmarLabel: 'အပတ်စဉ် စုဆောင်း'),
  biweekly(code: 'BIWEEKLY', label: 'Bi-Weekly Deposit', myanmarLabel: 'နှစ်ပတ်တစ်ကြိမ် စုဆောင်း'),
  monthly(code: 'MONTHLY', label: 'Monthly Deposit', myanmarLabel: 'လစဉ် စုဆောင်း');

  final String code;
  final String label;
  final String myanmarLabel;

  const SavingFrequency({
    required this.code,
    required this.label,
    required this.myanmarLabel,
  });

  static SavingFrequency fromCode(String? code) {
    if (code == null) return SavingFrequency.weekly;
    for (final freq in SavingFrequency.values) {
      if (freq.code == code || freq.name.toUpperCase() == code.toUpperCase()) {
        return freq;
      }
    }
    return SavingFrequency.weekly;
  }
}
