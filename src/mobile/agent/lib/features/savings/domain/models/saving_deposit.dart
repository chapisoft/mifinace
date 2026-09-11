import 'package:equatable/equatable.dart';
import '../../../../core/enums/sync_status.dart';

/// Represents a field cash deposit into a member's savings passbook account.
class SavingDeposit extends Equatable {
  final String depositId;
  final String accountNumber;
  final String customerName;
  final double amountMmk;
  final double newBalanceMmk;
  final DateTime depositDate;
  final String officerId;
  final String idempotencyKey;
  final SyncStatus syncStatus;

  const SavingDeposit({
    required this.depositId,
    required this.accountNumber,
    required this.customerName,
    required this.amountMmk,
    required this.newBalanceMmk,
    required this.depositDate,
    required this.officerId,
    required this.idempotencyKey,
    required this.syncStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'depositId': depositId,
      'accountNumber': accountNumber,
      'customerName': customerName,
      'amountMmk': amountMmk,
      'newBalanceMmk': newBalanceMmk,
      'depositDate': depositDate.toIso8601String(),
      'officerId': officerId,
      'idempotencyKey': idempotencyKey,
      'syncStatus': syncStatus.code,
    };
  }

  factory SavingDeposit.fromJson(Map<String, dynamic> json) {
    return SavingDeposit(
      depositId: json['depositId'] as String,
      accountNumber: json['accountNumber'] as String,
      customerName: json['customerName'] as String,
      amountMmk: (json['amountMmk'] as num).toDouble(),
      newBalanceMmk: (json['newBalanceMmk'] as num).toDouble(),
      depositDate: DateTime.parse(json['depositDate'] as String),
      officerId: json['officerId'] as String,
      idempotencyKey: json['idempotencyKey'] as String,
      syncStatus: SyncStatus.fromCode(json['syncStatus'] as String?),
    );
  }

  @override
  List<Object?> get props => [
        depositId,
        accountNumber,
        customerName,
        amountMmk,
        newBalanceMmk,
        depositDate,
        officerId,
        idempotencyKey,
        syncStatus,
      ];
}
