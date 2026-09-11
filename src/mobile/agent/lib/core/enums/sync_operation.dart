/// Operation types in the offline synchronization queue.
enum SyncOperation {
  collectRepayment('COLLECT_REPAYMENT'),
  loanApplication('LOAN_APPLICATION'),
  openSaving('OPEN_SAVING'),
  depositSaving('DEPOSIT_SAVING'),
  insuranceClaim('INSURANCE_CLAIM'),
  cashHandover('CASH_HANDOVER');

  final String code;
  const SyncOperation(this.code);

  static SyncOperation fromCode(String? code) {
    if (code == null) return SyncOperation.collectRepayment;
    for (final op in SyncOperation.values) {
      if (op.code == code || op.name.toUpperCase() == code.toUpperCase()) {
        return op;
      }
    }
    return SyncOperation.collectRepayment;
  }
}
