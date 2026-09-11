/// Payment methods accepted in field collection and digital channels.
enum RepaymentMethod {
  cash('CASH'),
  mmqr('MMQR'),
  kbzPay('KBZ_PAY'),
  wavePay('WAVE_PAY'),
  ayaPay('AYA_PAY'),
  mytelPay('MYTEL_PAY'),
  bankTransfer('BANK_TRANSFER');

  final String code;
  const RepaymentMethod(this.code);

  static RepaymentMethod fromCode(String? code) {
    if (code == null) return RepaymentMethod.cash;
    for (final method in RepaymentMethod.values) {
      if (method.code == code || method.name.toUpperCase() == code.toUpperCase()) {
        return method;
      }
    }
    return RepaymentMethod.cash;
  }
}
