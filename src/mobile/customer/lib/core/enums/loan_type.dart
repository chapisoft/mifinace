/// Microfinance loan product classifications.
enum LoanType {
  groupSolidarity(code: 'GROUP', label: 'Group Solidarity Loan', myanmarLabel: 'အုပ်စုအာမခံ ချေးငွေ'),
  individualMicro(code: 'INDIVIDUAL', label: 'Individual Micro Business', myanmarLabel: 'တစ်ဦးချင်း စီးပွားရေး ချေးငွေ'),
  agricultureSeasonal(code: 'AGRICULTURE', label: 'Seasonal Agriculture Loan', myanmarLabel: 'ရာသီပေါ် စိုက်ပျိုးစရိတ် ချေးငွေ'),
  emergencyRelief(code: 'EMERGENCY', label: 'Emergency Livelihood Relief', myanmarLabel: 'အရေးပေါ် ကူညီထောက်ပံ့ငွေ');

  final String code;
  final String label;
  final String myanmarLabel;

  const LoanType({
    required this.code,
    required this.label,
    required this.myanmarLabel,
  });

  static LoanType fromCode(String? code) {
    if (code == null) return LoanType.groupSolidarity;
    for (final t in LoanType.values) {
      if (t.code == code || t.name.toUpperCase() == code.toUpperCase()) {
        return t;
      }
    }
    return LoanType.groupSolidarity;
  }
}
