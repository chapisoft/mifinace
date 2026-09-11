import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/nrc_citizenship_type.dart';
import 'package:bmf_agent_app/features/origination/domain/services/nrc_parser.dart';

void main() {
  group('Myanmar NRC Parser & OCR Normalizer Tests (TASK-AGENT-07.1)', () {
    test('toArabicDigits converts Myanmar numerals ၀-၉ to 0-9', () {
      expect(NrcParser.toArabicDigits('၀၁၂၃၄၅၆၇၈၉'), '0123456789');
      expect(NrcParser.toArabicDigits('၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆'), '12/ဒဂန(နိုင်)123456');
    });

    test('toMyanmarDigits converts Arabic digits 0-9 to Myanmar numerals ၀-၉', () {
      expect(NrcParser.toMyanmarDigits('0123456789'), '၀၁၂၃၄၅၆၇၈၉');
      expect(NrcParser.toMyanmarDigits('123456'), '၁၂၃၄၅၆');
    });

    test('parseNrc parses valid English NRC format correctly', () {
      final nrc = NrcParser.parseNrc('12/DAGANA(N)123456');
      expect(nrc, isNotNull);
      expect(nrc!.stateNumber, 12);
      expect(nrc.townshipCode, 'DAGANA');
      expect(nrc.citizenshipType, NrcCitizenshipType.citizen);
      expect(nrc.nrcNumber, '123456');
      expect(nrc.fullNrcFormatted, '12/DAGANA(N)123456');
      expect(nrc.myanmarFormatted, '၁၂/DAGANA(နိုင်)၁၂၃၄၅၆');
    });

    test('parseNrc parses valid English NRC with spaces and lowercase codes', () {
      final nrc = NrcParser.parseNrc(' 9 / mahama (p) 654321 ');
      expect(nrc, isNotNull);
      expect(nrc!.stateNumber, 9);
      expect(nrc.townshipCode, 'MAHAMA');
      expect(nrc.citizenshipType, NrcCitizenshipType.associate);
      expect(nrc.nrcNumber, '654321');
      expect(nrc.fullNrcFormatted, '9/MAHAMA(P)654321');
    });

    test('parseNrc parses valid Myanmar NRC format correctly', () {
      final nrc = NrcParser.parseNrc('၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆');
      expect(nrc, isNotNull);
      expect(nrc!.stateNumber, 12);
      expect(nrc.townshipCode, 'ဒဂန');
      expect(nrc.citizenshipType, NrcCitizenshipType.citizen);
      expect(nrc.nrcNumber, '123456');
      expect(nrc.fullNrcFormatted, '12/ဒဂန(N)123456');
      expect(nrc.myanmarFormatted, '၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆');
    });

    test('parseNrc parses Myanmar naturalized and associate citizenship formats', () {
      final associateNrc = NrcParser.parseNrc('၉/မဟမ(ပြု)၆၅၄၃၂၁');
      expect(associateNrc, isNotNull);
      expect(associateNrc!.citizenshipType, NrcCitizenshipType.naturalized);

      final guestNrc = NrcParser.parseNrc('၁/ဗမန(ဧည့်)၉၈၇၆၅၄');
      expect(guestNrc, isNotNull);
      expect(guestNrc!.citizenshipType, NrcCitizenshipType.associate);
    });

    test('parseNrc rejects invalid state numbers outside 1-14', () {
      expect(NrcParser.parseNrc('0/DAGANA(N)123456'), isNull);
      expect(NrcParser.parseNrc('15/DAGANA(N)123456'), isNull);
      expect(NrcParser.parseNrc('၉၉/ဒဂန(နိုင်)၁၂၃၄၅၆'), isNull);
    });

    test('parseNrc rejects invalid length, missing brackets, or malformed types', () {
      expect(NrcParser.parseNrc(''), isNull);
      expect(NrcParser.parseNrc('12/DAGANA(X)123456'), isNull);
      expect(NrcParser.parseNrc('12/DAGANA(N)12345'), isNull); // 5 digits instead of 6
      expect(NrcParser.parseNrc('12/DAGANA(N)1234567'), isNull); // 7 digits
      expect(NrcParser.parseNrc('random text without slash'), isNull);
    });

    test('isValidNrc helper accurately validates string', () {
      expect(NrcParser.isValidNrc('12/DAGANA(N)123456'), isTrue);
      expect(NrcParser.isValidNrc('၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆'), isTrue);
      expect(NrcParser.isValidNrc('INVALID_NRC'), isFalse);
    });
  });
}
