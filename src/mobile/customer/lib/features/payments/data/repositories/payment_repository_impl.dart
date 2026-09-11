import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:bmf_customer/core/utils/app_logger.dart';
import '../../domain/models/mmqr_payment.dart';
import '../../domain/repositories/payment_repository.dart';

/// Implementation of [PaymentRepository] generating standard EMVCo MMQR strings and managing wallet deep links.
class PaymentRepositoryImpl implements PaymentRepository {
  final Map<String, bool> _settledTransactions = {};

  @override
  Future<MmqrPayment> generateLoanPaymentQr({
    required String contractCode,
    required double amountMmk,
  }) async {
    AppLogger.info('Generating dynamic MMQR for contract: $contractCode, amount: $amountMmk MMK', tag: 'PaymentRepo');

    final txRef = 'BMF-TX-${DateTime.now().millisecondsSinceEpoch}-${const Uuid().v4().substring(0, 6).toUpperCase()}';
    final now = DateTime.now();
    final expires = now.add(const Duration(minutes: 15));

    // EMVCo compliant MMQR string simulation (Merchant Category, Currency MMK 104, BMF Merchant)
    final formattedAmount = amountMmk.toStringAsFixed(0);
    final mmqr = '000201' // Payload Format Indicator
        '010212' // Dynamic QR
        '26360012mm.gov.cbm.mmqr0116BMF_MICROFINANCE' // Merchant Account Info
        '52046012' // Merchant Category Code
        '5303104' // MMK Currency Code
        '54${formattedAmount.length.toString().padLeft(2, '0')}$formattedAmount' // Amount
        '5802MM' // Country Code
        '5916BMF MICROFINANCE' // Merchant Name
        '6006YANGON' // City
        '62${(contractCode.length + txRef.length + 8).toString().padLeft(2, '0')}01${contractCode.length.toString().padLeft(2, '0')}$contractCode'
        '05${txRef.length.toString().padLeft(2, '0')}$txRef' // Additional Data
        '6304ABCD'; // CRC-16 Checksum

    return MmqrPayment(
      transactionReference: txRef,
      contractCode: contractCode,
      amountMmk: amountMmk,
      mmqrPayload: mmqr,
      generatedAt: now,
      expiresAt: expires,
      billerName: 'BMF Microfinance Myanmar',
    );
  }

  @override
  Future<bool> checkPaymentStatus(String transactionReference) async {
    AppLogger.info('Polling payment status for reference: $transactionReference', tag: 'PaymentRepo');
    // Simulated async check against Core Gateway
    return _settledTransactions[transactionReference] ?? false;
  }

  void markTransactionSettled(String transactionReference) {
    _settledTransactions[transactionReference] = true;
    AppLogger.info('Transaction marked settled manually/via webhook: $transactionReference', tag: 'PaymentRepo');
  }

  @override
  Future<bool> launchWalletApp({
    required String walletScheme,
    required String mmqrPayload,
  }) async {
    AppLogger.info('Attempting deep link launch for scheme: $walletScheme', tag: 'PaymentRepo');
    // Simulated deep link invocation
    return true;
  }
}
