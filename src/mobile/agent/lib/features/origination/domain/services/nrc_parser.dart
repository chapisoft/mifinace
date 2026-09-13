import '../../../../core/enums/nrc_citizenship_type.dart';
import '../models/nrc_data.dart';

/// Utility and Parsing Engine for Myanmar National Registration Card (NRC) formats.
class NrcParser {
  NrcParser._();

  static const Map<String, String> _myanmarToArabicDigits = {
    '၀': '0',
    '၁': '1',
    '၂': '2',
    '၃': '3',
    '၄': '4',
    '၅': '5',
    '၆': '6',
    '၇': '7',
    '၈': '8',
    '၉': '9',
  };

  static const Map<String, String> _arabicToMyanmarDigits = {
    '0': '၀',
    '1': '၁',
    '2': '၂',
    '3': '၃',
    '4': '၄',
    '5': '၅',
    '6': '၆',
    '7': '၇',
    '8': '၈',
    '9': '၉',
  };

  /// Converts any Myanmar numeral characters in [text] to standard Arabic digits.
  static String toArabicDigits(String text) {
    String result = text;
    _myanmarToArabicDigits.forEach((myanmar, arabic) {
      result = result.replaceAll(myanmar, arabic);
    });
    return result;
  }

  /// Converts any Arabic digit characters in [text] to Myanmar numerals.
  static String toMyanmarDigits(String text) {
    String result = text;
    _arabicToMyanmarDigits.forEach((arabic, myanmar) {
      result = result.replaceAll(arabic, myanmar);
    });
    return result;
  }

  /// English NRC regex pattern: e.g. 12/DAGANA(N)123456 or 12/DAGANA (N) 123456
  static final RegExp _englishNrcPattern = RegExp(
    r'^([0-9]{1,2})\s*\/\s*([A-Za-z]+)\s*\(\s*(N|P|E)\s*\)\s*([0-9]{6})$',
    caseSensitive: false,
  );

  /// Myanmar NRC regex pattern: e.g. ၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆
  static final RegExp _myanmarNrcPattern = RegExp(
    r'^([0-9]{1,2})\s*\/\s*([^\(]+?)\s*\(\s*(နိုင်|ဧည့်|ပြု|N|P|E)\s*\)\s*([0-9]{6})$',
  );

  /// Parses a raw OCR text string into structured [NrcData].
  /// Returns null if the text does not match valid Myanmar NRC syntax.
  static NrcData? parseNrc(String rawText) {
    if (rawText.trim().isEmpty) return null;

    // Clean whitespace and normalize brackets
    final String cleaned = rawText.trim().replaceAll('[', '(').replaceAll(']', ')');

    // 1. Check English Format directly
    final englishMatch = _englishNrcPattern.firstMatch(cleaned);
    if (englishMatch != null) {
      final stateNum = int.tryParse(englishMatch.group(1)!) ?? 0;
      if (stateNum < 1 || stateNum > 14) return null;

      final township = englishMatch.group(2)!.toUpperCase();
      final typeCode = englishMatch.group(3)!.toUpperCase();
      final nrcNum = englishMatch.group(4)!;
      final citizenshipType = NrcCitizenshipType.fromCode(typeCode);

      final fullFormatted = '$stateNum/$township(${citizenshipType.code})$nrcNum';
      final myanmarState = toMyanmarDigits('$stateNum');
      final myanmarNum = toMyanmarDigits(nrcNum);
      final myanmarFormatted = '$myanmarState/$township(${citizenshipType.myanmarText})$myanmarNum';

      return NrcData(
        stateNumber: stateNum,
        townshipCode: township,
        citizenshipType: citizenshipType,
        nrcNumber: nrcNum,
        fullNrcFormatted: fullFormatted,
        myanmarFormatted: myanmarFormatted,
      );
    }

    // 2. Convert Myanmar numbers to Arabic numbers and test Myanmar pattern
    final arabicConverted = toArabicDigits(cleaned);
    final myanmarMatch = _myanmarNrcPattern.firstMatch(arabicConverted);
    if (myanmarMatch != null) {
      final stateNum = int.tryParse(myanmarMatch.group(1)!) ?? 0;
      if (stateNum < 1 || stateNum > 14) return null;

      final township = myanmarMatch.group(2)!.trim();
      final typeStr = myanmarMatch.group(3)!.trim();
      final nrcNum = myanmarMatch.group(4)!;
      final citizenshipType = NrcCitizenshipType.fromCode(typeStr);

      final fullFormatted = '$stateNum/$township(${citizenshipType.code})$nrcNum';
      final myanmarState = toMyanmarDigits('$stateNum');
      final myanmarNum = toMyanmarDigits(nrcNum);
      final myanmarFormatted = '$myanmarState/$township(${citizenshipType.myanmarText})$myanmarNum';

      return NrcData(
        stateNumber: stateNum,
        townshipCode: township,
        citizenshipType: citizenshipType,
        nrcNumber: nrcNum,
        fullNrcFormatted: fullFormatted,
        myanmarFormatted: myanmarFormatted,
      );
    }

    return null;
  }

  /// Checks whether a given string is a strictly valid Myanmar NRC number.
  static bool isValidNrc(String text) {
    return parseNrc(text) != null;
  }
}
