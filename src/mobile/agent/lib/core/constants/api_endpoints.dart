/// Base API Endpoints for BMF Mobile BFF Gateway communication.
class ApiEndpoints {
  ApiEndpoints._();

  static const String defaultBaseUrl = 'https://mbmfina.microtec.vn';

  // Health
  static const String health = '/api/v1/health';

  // Authentication & Device
  static const String loginOfficer = '/api/v1/auth/agent-login';
  static const String loginCustomer = '/api/v1/auth/customer-login';
  static const String refreshToken = '/api/v1/auth/refresh-token';
  static const String logout = '/api/v1/auth/logout';
  static const String registerDevice = '/api/v1/devices/register';

  // Agent Operations (Centers, Groups, Schedules, Collection)
  static const String getCenters = '/api/v1/agent/centers';
  static const String getGroups = '/api/v1/agent/centers/{centerId}/groups';
  static const String getDueSchedules = '/api/v1/loans/schedules/sync';
  static const String collectRepayment = '/api/v1/loans/repayments/collect';
  static const String batchSyncRepayments = '/api/v1/loans/repayments/batch-sync';
  static const String getCustomerLoans = '/api/v1/loans/my-loans';

  // Field Operations (Applications, Savings, Insurance, Handover)
  static const String submitLoanApplication = '/api/v1/field/loans/apply';
  static const String depositSavings = '/api/v1/customer/savings/deposit';
  static const String openSavingsAccount = '/api/v1/customer/savings/open';
  static const String submitInsuranceClaim = '/api/v1/customer/insurance/claim';
  static const String handoverCash = '/api/v1/field/cash/handover';
}
