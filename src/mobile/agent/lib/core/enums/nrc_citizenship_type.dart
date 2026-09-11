/// Myanmar NRC Citizenship classification types.
enum NrcCitizenshipType {
  citizen(code: 'N', myanmarText: 'နိုင်', englishText: 'Citizen'),
  associate(code: 'P', myanmarText: 'ဧည့်', englishText: 'Associate Citizen'),
  naturalized(code: 'E', myanmarText: 'ပြု', englishText: 'Naturalized Citizen');

  final String code;
  final String myanmarText;
  final String englishText;

  const NrcCitizenshipType({
    required this.code,
    required this.myanmarText,
    required this.englishText,
  });

  static NrcCitizenshipType fromCode(String? code) {
    if (code == null) return NrcCitizenshipType.citizen;
    for (final type in NrcCitizenshipType.values) {
      if (type.code == code ||
          type.name.toUpperCase() == code.toUpperCase() ||
          type.myanmarText == code) {
        return type;
      }
    }
    return NrcCitizenshipType.citizen;
  }
}
