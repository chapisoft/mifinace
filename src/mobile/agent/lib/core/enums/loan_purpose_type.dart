/// Microfinance Loan Purpose categories recognized by FRD Myanmar.
enum LoanPurposeType {
  agriculture(code: 'AGRI', name: 'Nông nghiệp (Trồng trọt)', myanmarName: 'စိုက်ပျိုးရေး'),
  livestock(code: 'LIVE', name: 'Chăn nuôi gia súc', myanmarName: 'မွေးမြူရေး'),
  smallTrade(code: 'TRADE', name: 'Thương mại & Buôn bán nhỏ', myanmarName: 'အသေးစားကုန်သွယ်မှု'),
  handicraft(code: 'CRAFT', name: 'Thủ công mỹ nghệ & Dệt vải', myanmarName: 'လက်မှုလုပ်ငန်း'),
  housing(code: 'HOUSE', name: 'Cải tạo nhà ở nông thôn', myanmarName: 'နေအိမ်ပြုပြင်ရေး'),
  education(code: 'EDU', name: 'Chi phí học tập con em', myanmarName: 'ပညာရေး');

  final String code;
  final String name;
  final String myanmarName;

  const LoanPurposeType({
    required this.code,
    required this.name,
    required this.myanmarName,
  });

  static LoanPurposeType fromCode(String? code) {
    if (code == null) return LoanPurposeType.agriculture;
    for (final purpose in LoanPurposeType.values) {
      if (purpose.code == code || purpose.name.toUpperCase() == code.toUpperCase()) {
        return purpose;
      }
    }
    return LoanPurposeType.agriculture;
  }
}
