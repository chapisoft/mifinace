/// Base API Endpoints for BMF Customer Mobile App communication.
class ApiEndpoints {
  ApiEndpoints._();

  static const String defaultBaseUrl = 'https://mbmfina.microtec.vn';

  // Health
  static const String health = '/api/v1/health';

  // Authentication & Session
  static const String checkAccount = '/api/v1/auth/check-account';
  static const String activationSendOtp = '/api/v1/auth/activation/send-otp';
  static const String activationVerifyOtp = '/api/v1/auth/activation/verify-otp';
  static const String activationSetPin = '/api/v1/auth/activation/set-pin';
  static const String forgotPinSendOtp = '/api/v1/auth/forgot-pin/send-otp';
  static const String forgotPinVerifyOtp = '/api/v1/auth/forgot-pin/verify-otp';
  static const String forgotPinResetPin = '/api/v1/auth/forgot-pin/reset-pin';
  static const String loginCustomer = '/api/v1/auth/customer-login';
  static const String refreshToken = '/api/v1/auth/refresh-token';
  static const String logout = '/api/v1/auth/logout';
  static const String registerDevice = '/api/v1/devices/register';
  static const String profile = '/api/v1/auth/profile';

  // Loans & Repayments
  static const String getMyLoans = '/api/v1/loans/my-loans';
  static String getLoanSchedule(String loanId) => '/api/v1/customer/loans/$loanId/schedule';

  // Payments & MMQR
  static const String generateMmqr = '/api/v1/payments/mmqr';
  static String getPaymentStatus(String paymentId) => '/api/v1/payments/$paymentId/status';
  static const String getTransactions = '/api/v1/payments/transactions';

  // Savings & Insurance
  static const String getMySavings = '/api/v1/customer/savings';
  static const String openSavings = '/api/v1/customer/savings/open';
  static const String submitClaim = '/api/v1/customer/insurance/claim';

  // Branches & Network
  static const String branches = '/api/v1/branches';
}
