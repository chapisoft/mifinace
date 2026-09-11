/// Types of physical cash movements handled by field credit officers.
enum CashTransactionType {
  loanRepayment(code: 'LOAN_REPAYMENT', label: 'Loan Installment Collection', myanmarLabel: 'ချေးငွေအရစ်ကျ ကောက်ခံငွေ'),
  savingDeposit(code: 'SAVING_DEPOSIT', label: 'Village Saving Deposit', myanmarLabel: 'စုဆောင်းငွေ ထည့်သွင်းငွေ'),
  savingOpen(code: 'SAVING_OPEN', label: 'Passbook Opening Initial Deposit', myanmarLabel: 'စာအုပ်ဖွင့် မတည်ငွေ'),
  handoverToCashier(code: 'HANDOVER', label: 'Branch Cashier Handover', myanmarLabel: 'ရုံးငွေကိုင်ထံ အပ်နှံငွေ');

  final String code;
  final String label;
  final String myanmarLabel;

  const CashTransactionType({
    required this.code,
    required this.label,
    required this.myanmarLabel,
  });

  static CashTransactionType fromCode(String? code) {
    if (code == null) return CashTransactionType.loanRepayment;
    for (final type in CashTransactionType.values) {
      if (type.code == code || type.name.toUpperCase() == code.toUpperCase()) {
        return type;
      }
    }
    return CashTransactionType.loanRepayment;
  }
}
