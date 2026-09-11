/// Review and payout status of field insurance claims.
enum ClaimStatus {
  submitted(code: 'SUBMITTED', label: 'Submitted from Field', myanmarLabel: 'လျှောက်ထားပြီး'),
  underReview(code: 'UNDER_REVIEW', label: 'Under Township Review', myanmarLabel: 'စိစစ်ဆဲ'),
  approved(code: 'APPROVED', label: 'Approved for Payout', myanmarLabel: 'ခွင့်ပြုပြီး'),
  rejected(code: 'REJECTED', label: 'Claim Rejected', myanmarLabel: 'ပယ်ချခံရ');

  final String code;
  final String label;
  final String myanmarLabel;

  const ClaimStatus({
    required this.code,
    required this.label,
    required this.myanmarLabel,
  });

  static ClaimStatus fromCode(String? code) {
    if (code == null) return ClaimStatus.submitted;
    for (final s in ClaimStatus.values) {
      if (s.code == code || s.name.toUpperCase() == code.toUpperCase()) {
        return s;
      }
    }
    return ClaimStatus.submitted;
  }
}
