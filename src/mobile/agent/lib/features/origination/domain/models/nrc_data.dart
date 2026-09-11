import 'package:equatable/equatable.dart';
import '../../../../core/enums/nrc_citizenship_type.dart';

/// Entity representing parsed and validated Myanmar National Registration Card (NRC) data.
class NrcData extends Equatable {
  final int stateNumber; // 1 - 14 (e.g., 12 = Yangon, 13 = Shan)
  final String townshipCode; // e.g. DAGANA, KAMAYU, TGY
  final NrcCitizenshipType citizenshipType; // (N), (P), (E)
  final String nrcNumber; // 6 digits, e.g. 123456
  final String fullNrcFormatted; // 12/DAGANA(N)123456
  final String myanmarFormatted; // ၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆

  const NrcData({
    required this.stateNumber,
    required this.townshipCode,
    required this.citizenshipType,
    required this.nrcNumber,
    required this.fullNrcFormatted,
    required this.myanmarFormatted,
  });

  @override
  List<Object?> get props => [
        stateNumber,
        townshipCode,
        citizenshipType,
        nrcNumber,
        fullNrcFormatted,
        myanmarFormatted,
      ];
}
