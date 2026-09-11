/// Base API Endpoints for BMF Mobile BFF Gateway communication.
class ApiEndpoints {
  ApiEndpoints._();

  static const String defaultBaseUrl = 'http://10.0.2.2:8080'; // Android Emulator localhost bridge or Gateway URL

  // Authentication & Device
  static const String loginOfficer = '/api/v1/auth/officer/login';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String registerDevice = '/api/v1/devices/register';

  // Agent Operations (Centers, Groups, Schedules, Collection)
  static const String getCenters = '/api/v1/agent/centers';
  static const String getGroups = '/api/v1/agent/centers/{centerId}/groups';
  static const String getDueSchedules = '/api/v1/repayments/schedule';
  static const String collectRepayment = '/api/v1/repayments/collect';
  static const String batchSyncRepayments = '/api/v1/repayments/batch-sync';

  // Field Operations (Applications, Savings, Insurance, Handover)
  static const String submitLoanApplication = '/api/v1/field/loans/apply';
  static const String depositSavings = '/api/v1/customer/savings/deposit';
  static const String openSavingsAccount = '/api/v1/customer/savings/open';
  static const String submitInsuranceClaim = '/api/v1/customer/insurance/claim';
  static const String handoverCash = '/api/v1/field/cash/handover';
}
