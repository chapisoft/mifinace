import 'customer_localizations.dart';

/// English (`en`) translations.
class CustomerLocalizationsEn extends CustomerLocalizations {
  CustomerLocalizationsEn([super.locale = 'en']);

  @override
  String get appTitle => 'BMF Microfinance';
  @override
  String get home => 'Home';
  @override
  String get loans => 'Loans';
  @override
  String get savings => 'Savings';
  @override
  String get insurance => 'Insurance';
  @override
  String get notifications => 'Notifications';

  @override
  String get loginTitle => 'Member Sign In';
  @override
  String get phoneLabel => 'Phone Number';
  @override
  String get nrcLabel => 'NRC Card Number';
  @override
  String get requestOtp => 'Get SMS OTP';
  @override
  String get otpTitle => 'Verify SMS OTP';
  @override
  String get verifyOtp => 'Verify';
  @override
  String get setPinTitle => 'Set 6-Digit PIN';
  @override
  String get confirmPinTitle => 'Confirm 6-Digit PIN';
  @override
  String get enterPinTitle => 'Enter Your PIN';
  @override
  String get biometricLogin => 'Sign in with Biometrics';
  @override
  String get pinMismatch => 'PINs do not match';
  @override
  String get pinSuccess => 'Security PIN configured successfully';

  @override
  String get welcomeMember => 'Welcome back';
  @override
  String get memberCode => 'Member ID';
  @override
  String get groupCode => 'Group ID';
  @override
  String get totalOutstanding => 'Total Outstanding Balance';
  @override
  String get activeLoans => 'Active Loans';
  @override
  String get dueAlertTitle => 'Upcoming Loan Payment Alert';
  @override
  String get payNow => 'Pay Now';
  @override
  String get quickServices => 'Quick Services';

  @override
  String get loansTitle => 'My Loans';
  @override
  String get loanDetails => 'Loan Details';
  @override
  String get scheduleTitle => 'Repayment Schedule';
  @override
  String get period => 'Period';
  @override
  String get dueDate => 'Due Date';
  @override
  String get principal => 'Principal';
  @override
  String get interest => 'Interest';
  @override
  String get insuranceFee => 'Insurance Fee';
  @override
  String get totalDue => 'Total Due';
  @override
  String get statusPaid => 'Paid';
  @override
  String get statusPending => 'Pending';
  @override
  String get statusOverdue => 'Overdue';

  @override
  String get debtGroupCurrent => 'Standard (Group 1)';
  @override
  String get debtGroupSpecialMention => 'Special Mention (Group 2)';
  @override
  String get debtGroupSubstandard => 'Substandard (Group 3)';
  @override
  String get debtGroupDoubtful => 'Doubtful (Group 4)';
  @override
  String get debtGroupLoss => 'Loss (Group 5)';

  @override
  String get paymentTitle => 'MMQR Payment';
  @override
  String get scanMmqr => 'Scan with Bank or Wallet App';
  @override
  String get openWallet => 'Open Digital Wallet';
  @override
  String get launchKbzPay => 'Pay with KBZPay';
  @override
  String get launchWavePay => 'Pay with WavePay';
  @override
  String get launchAyaPay => 'Pay with AYA Pay';
  @override
  String get launchMytelPay => 'Pay with MytelPay';
  @override
  String get saveQrImage => 'Save QR Code';
  @override
  String get paymentSuccess => 'Payment Settled Successfully';
  @override
  String get electronicReceipt => 'Official Electronic Receipt';
  @override
  String get referenceNo => 'Reference Number';
  @override
  String get returnHome => 'Back to Home';

  @override
  String get savingsTitle => 'Savings Accounts';
  @override
  String get accruedInterest => 'Daily Accrued Interest';
  @override
  String get openSavingOnline => 'Open Online Savings Passbook';
  @override
  String get compulsorySaving => 'Compulsory Savings';
  @override
  String get voluntarySaving => 'Voluntary Savings';
  @override
  String get fixedTermSaving => 'Fixed Term Deposit';
  @override
  String get interestRatePerAnnum => 'Interest Rate (p.a.)';

  @override
  String get insuranceTitle => 'Member Mutual Aid Fund';
  @override
  String get medicalBenefitTitle => 'Medical Hospital Subsidy (10,000 MMK/day)';
  @override
  String get medicalBenefitDesc => 'Comprehensive health and accident mutual welfare coverage';
  @override
  String get submitClaim => 'File Insurance Claim';
  @override
  String get illnessRisk => 'Illness';
  @override
  String get accidentRisk => 'Accident';
  @override
  String get naturalDisasterRisk => 'Natural Disaster';
  @override
  String get uploadInvoices => 'Upload Hospital Invoices & Doctor Notes';
  @override
  String get claimSubmitted => 'Claim submitted successfully';

  @override
  String get notificationsTitle => 'Notification Center';
  @override
  String get markAllRead => 'Mark All as Read';
  @override
  String get noNotifications => 'No new notifications';
}
