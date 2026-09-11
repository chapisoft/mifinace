/// 5 FRD (Financial Regulatory Department Myanmar) debt classification groups.
enum DebtGroup {
  standard(
    code: 'STANDARD',
    minDays: 0,
    maxDays: 30,
    provisionRate: 0.01,
  ),
  watch(
    code: 'WATCH',
    minDays: 31,
    maxDays: 60,
    provisionRate: 0.05,
  ),
  substandard(
    code: 'SUBSTANDARD',
    minDays: 61,
    maxDays: 90,
    provisionRate: 0.20,
  ),
  doubtful(
    code: 'DOUBTFUL',
    minDays: 91,
    maxDays: 180,
    provisionRate: 0.50,
  ),
  loss(
    code: 'LOSS',
    minDays: 181,
    maxDays: 99999,
    provisionRate: 1.00,
  );

  final String code;
  final int minDays;
  final int maxDays;
  final double provisionRate;

  const DebtGroup({
    required this.code,
    required this.minDays,
    required this.maxDays,
    required this.provisionRate,
  });

  static DebtGroup fromDays(int overdueDays) {
    if (overdueDays <= 30) return DebtGroup.standard;
    if (overdueDays <= 60) return DebtGroup.watch;
    if (overdueDays <= 90) return DebtGroup.substandard;
    if (overdueDays <= 180) return DebtGroup.doubtful;
    return DebtGroup.loss;
  }
}
