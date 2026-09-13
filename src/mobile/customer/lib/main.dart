import 'package:flutter/material.dart';
import 'package:bmf_customer/app/app.dart';
import 'package:bmf_customer/core/network/api_client.dart';
import 'package:bmf_customer/core/security/biometric_service.dart';
import 'package:bmf_customer/core/security/secure_storage_service.dart';
import 'package:bmf_customer/core/utils/app_logger.dart';
import 'package:bmf_customer/features/auth/data/repositories/customer_auth_repository_impl.dart';
import 'package:bmf_customer/features/loans/data/repositories/customer_loan_repository_impl.dart';
import 'package:bmf_customer/features/payments/data/repositories/payment_repository_impl.dart';
import 'package:bmf_customer/features/savings/data/repositories/savings_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.info('Initializing BMF Customer Mobile Application...', tag: 'Main');

  final secureStorage = SecureStorageService();
  final biometricService = BiometricService();
  final apiClient = ApiClient(secureStorage: secureStorage);

  final authRepository = CustomerAuthRepositoryImpl(
    storage: secureStorage,
    biometricService: biometricService,
    apiClient: apiClient,
  );
  final loanRepository = CustomerLoanRepositoryImpl(apiClient: apiClient);
  final paymentRepository = PaymentRepositoryImpl(apiClient: apiClient);
  final savingsRepository = SavingsRepositoryImpl(apiClient: apiClient);

  runApp(
    BmfCustomerApp(
      secureStorageService: secureStorage,
      biometricService: biometricService,
      authRepository: authRepository,
      loanRepository: loanRepository,
      paymentRepository: paymentRepository,
      savingsRepository: savingsRepository,
    ),
  );
}
