/// Repayment status of loan schedules in BMF.
enum RepaymentStatus {
  pending('PENDING'),
  paidLocal('PAID_LOCAL'),
  synced('SYNCED'),
  settled('SETTLED'),
  overdue('OVERDUE'),
  failed('FAILED');

  final String code;
  const RepaymentStatus(this.code);

  static RepaymentStatus fromCode(String? code) {
    if (code == null) return RepaymentStatus.pending;
    for (final status in RepaymentStatus.values) {
      if (status.code == code || status.name.toUpperCase() == code.toUpperCase()) {
        return status;
      }
    }
    return RepaymentStatus.pending;
  }
}
