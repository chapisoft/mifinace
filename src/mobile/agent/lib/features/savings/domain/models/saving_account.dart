import 'package:equatable/equatable.dart';
import '../../../../core/enums/saving_product_type.dart';

/// Represents a microfinance savings passbook account held by a village borrower.
class SavingAccount extends Equatable {
  final String accountId;
  final String accountNumber;
  final String centerCode;
  final String groupCode;
  final String customerName;
  final String nrcFormatted;
  final String phone;
  final SavingProductType productType;
  final double balanceMmk;
  final double interestRateAnnual;
  final DateTime openedDate;
  final String? nomineeName;
  final String? nomineeNrc;
  final String? nomineeRelation;

  const SavingAccount({
    required this.accountId,
    required this.accountNumber,
    required this.centerCode,
    required this.groupCode,
    required this.customerName,
    required this.nrcFormatted,
    required this.phone,
    required this.productType,
    required this.balanceMmk,
    required this.interestRateAnnual,
    required this.openedDate,
    this.nomineeName,
    this.nomineeNrc,
    this.nomineeRelation,
  });

  SavingAccount copyWith({
    String? accountId,
    String? accountNumber,
    String? centerCode,
    String? groupCode,
    String? customerName,
    String? nrcFormatted,
    String? phone,
    SavingProductType? productType,
    double? balanceMmk,
    double? interestRateAnnual,
    DateTime? openedDate,
    String? nomineeName,
    String? nomineeNrc,
    String? nomineeRelation,
  }) {
    return SavingAccount(
      accountId: accountId ?? this.accountId,
      accountNumber: accountNumber ?? this.accountNumber,
      centerCode: centerCode ?? this.centerCode,
      groupCode: groupCode ?? this.groupCode,
      customerName: customerName ?? this.customerName,
      nrcFormatted: nrcFormatted ?? this.nrcFormatted,
      phone: phone ?? this.phone,
      productType: productType ?? this.productType,
      balanceMmk: balanceMmk ?? this.balanceMmk,
      interestRateAnnual: interestRateAnnual ?? this.interestRateAnnual,
      openedDate: openedDate ?? this.openedDate,
      nomineeName: nomineeName ?? this.nomineeName,
      nomineeNrc: nomineeNrc ?? this.nomineeNrc,
      nomineeRelation: nomineeRelation ?? this.nomineeRelation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountNumber': accountNumber,
      'centerCode': centerCode,
      'groupCode': groupCode,
      'customerName': customerName,
      'nrcFormatted': nrcFormatted,
      'phone': phone,
      'productType': productType.code,
      'balanceMmk': balanceMmk,
      'interestRateAnnual': interestRateAnnual,
      'openedDate': openedDate.toIso8601String(),
      'nomineeName': nomineeName,
      'nomineeNrc': nomineeNrc,
      'nomineeRelation': nomineeRelation,
    };
  }

  factory SavingAccount.fromJson(Map<String, dynamic> json) {
    return SavingAccount(
      accountId: json['accountId'] as String,
      accountNumber: json['accountNumber'] as String,
      centerCode: json['centerCode'] as String,
      groupCode: json['groupCode'] as String,
      customerName: json['customerName'] as String,
      nrcFormatted: json['nrcFormatted'] as String,
      phone: json['phone'] as String? ?? '',
      productType: SavingProductType.fromCode(json['productType'] as String?),
      balanceMmk: (json['balanceMmk'] as num).toDouble(),
      interestRateAnnual: (json['interestRateAnnual'] as num).toDouble(),
      openedDate: DateTime.parse(json['openedDate'] as String),
      nomineeName: json['nomineeName'] as String?,
      nomineeNrc: json['nomineeNrc'] as String?,
      nomineeRelation: json['nomineeRelation'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        accountId,
        accountNumber,
        centerCode,
        groupCode,
        customerName,
        nrcFormatted,
        phone,
        productType,
        balanceMmk,
        interestRateAnnual,
        openedDate,
        nomineeName,
        nomineeNrc,
        nomineeRelation,
      ];
}
