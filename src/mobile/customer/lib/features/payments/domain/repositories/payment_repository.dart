import '../models/customer_transaction.dart';
import '../models/mmqr_payment.dart';

/// Repository interface handling dynamic MMQR generation and settlement verification.
abstract class PaymentRepository {
  /// Generates dynamic MMQR EMVCo string for a loan repayment.
  Future<MmqrPayment> generateLoanPaymentQr({
    required String contractCode,
    required double amountMmk,
  });

  /// Checks whether transaction has been settled by Core Gateway.
  Future<bool> checkPaymentStatus(String transactionReference);

  /// Launches local mobile wallet app via deep link URL schemes.
  Future<bool> launchWalletApp({
    required String walletScheme,
    required String mmqrPayload,
  });

  /// Tra cứu danh sách giao dịch trả nợ / thanh toán của khách hàng từ CSDL (bảng SYS_REPAYMENT_TRANSACTION).
  Future<List<CustomerTransaction>> getCustomerTransactions(String customerCode);

  /// Ghi nhận giao dịch thanh toán mới vào bộ nhớ / CSDL.
  Future<void> recordTransaction(CustomerTransaction transaction);
}
