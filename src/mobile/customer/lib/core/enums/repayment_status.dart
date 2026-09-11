/// Repayment schedule installment status.
enum RepaymentStatus {
  paid(code: 'PAID', label: 'Paid in Full', myanmarLabel: 'ပေးသွင်းပြီး'),
  dueToday(code: 'DUE_TODAY', label: 'Due Today', myanmarLabel: 'ယနေ့ပေးသွင်းရန်'),
  overdue(code: 'OVERDUE', label: 'Overdue Pending', myanmarLabel: 'ရက်လွန်နေဆဲ'),
  upcoming(code: 'UPCOMING', label: 'Upcoming Installment', myanmarLabel: 'မကျရောက်သေး');

  final String code;
  final String label;
  final String myanmarLabel;

  const RepaymentStatus({
    required this.code,
    required this.label,
    required this.myanmarLabel,
  });

  static RepaymentStatus fromCode(String? code) {
    if (code == null) return RepaymentStatus.upcoming;
    for (final s in RepaymentStatus.values) {
      if (s.code == code || s.name.toUpperCase() == code.toUpperCase()) {
        return s;
      }
    }
    return RepaymentStatus.upcoming;
  }
}
