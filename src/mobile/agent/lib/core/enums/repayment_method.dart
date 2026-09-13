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

extension RepaymentMethodExtension on RepaymentMethod {
  String localizedName(dynamic l10n) {
    switch (this) {
      case RepaymentMethod.cash:
        return l10n.methodCash;
      case RepaymentMethod.mmqr:
        return l10n.methodMmqr;
      case RepaymentMethod.kbzPay:
        return l10n.methodKbzPay;
      case RepaymentMethod.wavePay:
        return l10n.methodWavePay;
      case RepaymentMethod.ayaPay:
        return l10n.methodAyaPay;
      case RepaymentMethod.mytelPay:
        return l10n.methodMytelPay;
      case RepaymentMethod.bankTransfer:
        return l10n.methodBankTransfer;
    }
  }
}

