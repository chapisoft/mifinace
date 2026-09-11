import '../../../../core/enums/repayment_method.dart';
import '../entities/repayment_receipt.dart';
import '../entities/schedule_item.dart';

/// Repository interface for Field Repayment Collection and Offline Transaction Recording.
abstract class CollectionRepository {
  Future<List<ScheduleItem>> getSchedulesByGroup(String groupCode, {bool forceRefresh = false});

  Future<RepaymentReceipt> collectRepayment({
    required ScheduleItem schedule,
    required double collectedAmount,
    required RepaymentMethod paymentMethod,
    required String collectorId,
  });
}
