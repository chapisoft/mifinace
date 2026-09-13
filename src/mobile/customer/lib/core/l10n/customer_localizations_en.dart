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
  String get insurance => 'Mutual Aid';
  @override
  String get notifications => 'Notifications';
  @override
  String get navHome => 'Home';
  @override
  String get navLoans => 'Loans';
  @override
  String get navScanQr => 'Pay MMQR';
  @override
  String get navHistory => 'History';
  @override
  String get navAccount => 'Account';

  // Common Actions & Dialogs
  @override
  String get close => 'Close';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get done => 'Done';
  @override
  String get save => 'Save';
  @override
  String get retry => 'Retry';
  @override
  String get selectLanguage => 'Select Language';
  @override
  String get version => 'Version';
  @override
  String get viewAll => 'View All';
  @override
  String get customize => 'Customize';
  @override
  String get quickActions => 'Quick Actions';
  @override
  String get customizeQuickActions => 'Customize Quick Actions';
  @override
  String get customizeQuickActionsDesc => 'Select frequently used features to display on the home screen:';
  @override
  String get saveChanges => 'Save Changes';
  @override
  String get maxShortcutsReached => 'You can select up to 4 shortcuts';
  @override
  String get minShortcutsRequired => 'Please select at least 1 shortcut';

  // Authentication
  @override
  String get loginTitle => 'Member Sign In';
  @override
  String get phoneLabel => 'Phone Number';
  @override
  String get nrcLabel => 'NRC Card Number';
  @override
  String get memberIdOrPhoneOrNrc => 'Member ID / Phone / NRC Card';
  @override
  String get continueButton => 'Continue';
  @override
  String get switchAccount => 'Switch Account';
  @override
  String get forgotPin => 'Forgot PIN?';
  @override
  String get enter6DigitPin => 'Enter 6-Digit Security PIN';
  @override
  String get notActivatedPrompt => 'Account is not activated yet. Send OTP to activate now?';
  @override
  String get activateNow => 'Activate Now';
  @override
  String get welcomeBack => 'Welcome Back';
  @override
  String get firstTimeUsingApp => 'First time here?';
  @override
  String get activateWithInfo => 'Activate with Member ID, Phone or NRC';
  @override
  String get splashTagline => 'Digital Solidarity Credit & Member Banking';
  @override
  String get savedMemberAccount => 'Saved Member Account';
  @override
  String get requestOtp => 'Request OTP';
  @override
  String get otpTitle => 'Verify SMS OTP';
  @override
  String get verifyOtp => 'Verify Code';
  @override
  String get setPinTitle => 'Create 6-Digit PIN';
  @override
  String get confirmPinTitle => 'Confirm 6-Digit PIN';
  @override
  String get enterPinTitle => 'Enter Security PIN';
  @override
  String get biometricLogin => 'Biometric Sign In';
  @override
  String get pinMismatch => 'PIN code mismatch. Please re-enter.';
  @override
  String get pinSuccess => 'PIN configured successfully.';
  @override
  String get inputIdentifierRequired => 'Please enter Member ID, Phone Number or NRC Card.';

  // Dashboard & Member Profile
  @override
  String get welcomeMember => 'Welcome';
  @override
  String get memberCode => 'Member Code';
  @override
  String get groupCode => 'Group Code';
  @override
  String get totalOutstanding => 'Total Outstanding Debt';
  @override
  String get activeLoans => 'Active Loans';
  @override
  String get dueAlertTitle => 'Upcoming Installment Due';
  @override
  String get payNow => 'Pay Now';
  @override
  String get quickServices => 'Quick Services';
  @override
  String get digitalMemberCard => 'Digital Member Card';
  @override
  String get memberQrTitle => 'BMF Digital Member Card';
  @override
  String get centerLabel => 'Center Name';
  @override
  String get groupLabel => 'Solidarity Group';
  @override
  String get meetingScheduleLabel => 'Meeting Schedule';
  @override
  String get weeklyMeetingTime => 'Every Friday • 09:00 AM';
  @override
  String get assignedOfficerLabel => 'Assigned Credit Officer';
  @override
  String get noRecentTransactions => 'No recent transactions found.';
  @override
  String get periodNumberLabel => 'Period';

  // Overview Metrics & Status
  @override
  String get outstandingLoanMetric => 'Outstanding Balance';
  @override
  String get dueMetric => 'Next Due';
  @override
  String get totalSavingsMetric => 'Total Savings';
  @override
  String get loyaltyPointsMetric => 'Loyalty Points';
  @override
  String get memberActiveStatus => 'Active & Good Standing';

  // Home Menu Items
  @override
  String get menuMmqrTitle => 'Pay MMQR';
  @override
  String get menuMmqrSubtitle => 'National Gateway';
  @override
  String get menuLoansTitle => 'Loan Portfolio';
  @override
  String get menuLoansSubtitle => 'Schedule & Dues';
  @override
  String get menuSavingsTitle => 'Savings';
  @override
  String get menuSavingsSubtitle => 'Passbooks & Profit';
  @override
  String get menuInsuranceTitle => 'Mutual Aid';
  @override
  String get menuInsuranceSubtitle => 'Health & Hospitalization';
  @override
  String get menuApplyLoanTitle => 'Fast Loan';
  @override
  String get menuApplyLoanSubtitle => 'Apply Online';
  @override
  String get menuHistoryTitle => 'History';
  @override
  String get menuHistorySubtitle => 'All Receipts';
  @override
  String get menuBranchesTitle => 'Branches';
  @override
  String get menuBranchesSubtitle => 'Nearest Service Points';
  @override
  String get menuNotificationsTitle => 'Notifications';
  @override
  String get menuNotificationsSubtitle => 'Installment Reminders';

  // Loans & Schedule
  @override
  String get loansTitle => 'Active Loans';
  @override
  String get loanDetails => 'Loan Details';
  @override
  String get scheduleTitle => 'Repayment Schedule';
  @override
  String get period => 'Inst.';
  @override
  String get dueDate => 'Due Date';
  @override
  String get principal => 'Principal';
  @override
  String get interest => 'Interest';
  @override
  String get insuranceFee => 'Mutual Aid';
  @override
  String get totalDue => 'Total Installment';
  @override
  String get statusPaid => 'Settled';
  @override
  String get statusPending => 'Pending';
  @override
  String get statusOverdue => 'Overdue';

  // 5 FRD Debt Groups
  @override
  String get debtGroupCurrent => 'Group 1 - Standard Current';
  @override
  String get debtGroupSpecialMention => 'Group 2 - Special Mention';
  @override
  String get debtGroupSubstandard => 'Group 3 - Substandard';
  @override
  String get debtGroupDoubtful => 'Group 4 - Doubtful';
  @override
  String get debtGroupLoss => 'Group 5 - Impaired Loss';

  // Payments & MMQR
  @override
  String get paymentTitle => 'Digital MMQR Repayment';
  @override
  String get scanMmqr => 'Scan MMQR Code';
  @override
  String get mmqrRepaymentTitle => 'MMQR Digital Repayment';
  @override
  String get generatingMmqr => 'Generating CBM standard dynamic MMQR...';
  @override
  String get openWallet => 'Pay with Mobile Wallet';
  @override
  String get launchKbzPay => 'Open KBZPay';
  @override
  String get launchWavePay => 'Open WavePay';
  @override
  String get launchAyaPay => 'Open AYA Pay';
  @override
  String get launchMytelPay => 'Open MytelPay';
  @override
  String get saveQrImage => 'Save QR Code';
  @override
  String get paymentSuccess => 'Repayment Received!';
  @override
  String get electronicReceipt => 'Electronic Receipt';
  @override
  String get referenceNo => 'Transaction Reference';
  @override
  String get returnHome => 'Return to Home';
  @override
  String get backToHome => 'Back to Home';
  @override
  String get contractCodeLabel => 'Contract Code';
  @override
  String get transactionRefLabel => 'Transaction Ref';
  @override
  String get paymentChannelLabel => 'Payment Channel';
  @override
  String get settledDateLabel => 'Settled Date';
  @override
  String get totalPaidAmountLabel => 'Total Paid Amount';
  @override
  String get totalTransactionAmount => 'Total Transacted Amount';
  @override
  String get noMatchingTransactions => 'No matching transactions found';
  @override
  String get tryDifferentFilter => 'Try selecting a different time range or category';
  @override
  String get details => 'Details';
  @override
  String get savingReceiptPdf => 'Saving receipt PDF to device...';
  @override
  String get savePdf => 'Save PDF';
  @override
  String get sharingReceipt => 'Generating receipt link...';
  @override
  String get share => 'Share';
  @override
  String get filterAll => 'All';
  @override
  String get filterRepayment => 'Repayments';
  @override
  String get filterSavings => 'Savings';
  @override
  String get filterInsurance => 'Insurance';
  @override
  String get searchPlaceholder => 'Search by Ref ID, contract...';
  @override
  String get allTime => 'All Time';
  @override
  String get thisMonth => 'This Month';
  @override
  String get last3Months => 'Last 3 Months';
  @override
  String get filterModalTitle => 'Filter Transactions';

  // Savings
  @override
  String get savingsTitle => 'Savings & Passbooks';
  @override
  String get savingsAndPassbooks => 'Savings & Passbooks';
  @override
  String get accruedInterest => 'Total Accrued Profit';
  @override
  String get openSavingOnline => 'Subscribe Deposit Online';
  @override
  String get openSavingsPassbookTitle => 'Subscribe High-Yield Deposit';
  @override
  String get passbookOpenedSuccess => 'Deposit Passbook Created!';
  @override
  String get viewPassbooks => 'View Passbooks';
  @override
  String get expectedProfitAtMaturity => 'Expected Profit at Maturity:';
  @override
  String get confirmAndSubscribe => 'Confirm & Subscribe';
  @override
  String get depositPrincipal => 'Deposit Principal';
  @override
  String get accruedProfitYield => 'Accrued Profit Yield';
  @override
  String get compulsorySaving => 'Compulsory Group Deposit';
  @override
  String get voluntarySaving => 'Voluntary Flexi Deposit';
  @override
  String get fixedTermSaving => 'Fixed-Term High-Yield';
  @override
  String get interestRatePerAnnum => 'Annual Profit Rate';

  // Insurance
  @override
  String get insuranceTitle => 'Member Mutual Aid Fund';
  @override
  String get medicalBenefitTitle => 'Hospitalization & Disaster Aid';
  @override
  String get medicalBenefitDesc => 'Emergency medical and disaster relief assistance';
  @override
  String get submitClaim => 'Submit Aid Claim';
  @override
  String get mutualAidClaimTitle => 'Mutual Aid Claim';
  @override
  String get illnessRisk => 'Hospitalization & Illness';
  @override
  String get accidentRisk => 'Accidental Injury';
  @override
  String get naturalDisasterRisk => 'Cyclone & Flood Relief';
  @override
  String get uploadInvoices => 'Attach Medical Record or Discharge Slip';
  @override
  String get attachMedicalDocument => 'Attach Medical Record or Discharge Slip';
  @override
  String get documentAttachedSimulated => '1 document attached';
  @override
  String get submitInsuranceClaim => 'Submit Insurance Claim';
  @override
  String get claimFiledSuccess => 'Claim Filed Successfully';
  @override
  String get claimSubmitted => 'Claim Submitted';

  // Notifications
  @override
  String get notificationsTitle => 'Notifications';
  @override
  String get notificationCenterTitle => 'Notification Center';
  @override
  String get markAllRead => 'Mark All Read';
  @override
  String get noNotifications => 'No unread notifications';
  @override
  String get noNotificationsFound => 'No notification history';

  // Fast Loan & Application
  @override
  String get applyLoanTitle => 'Quick Loan Application';
  @override
  String get tabApplyLoan => 'Apply Loan';
  @override
  String get tabTrackApplications => 'My Applications';
  @override
  String get selectLoanPackage => 'Select Loan Package';
  @override
  String get loanAmountToBorrow => 'Loan Amount to Borrow';
  @override
  String get minAmountLabel => 'Min';
  @override
  String get maxAmountLabel => 'Max';
  @override
  String get loanTerm => 'Loan Term';
  @override
  String get repaymentFrequency => 'Repayment Frequency';
  @override
  String get monthly => 'Monthly';
  @override
  String get biweekly => 'Bi-weekly';
  @override
  String get weekly => 'Weekly';
  @override
  String get estimatedMonthlyRepayment => 'Estimated Monthly Payment';
  @override
  String get monthlyPrincipal => 'Monthly Principal';
  @override
  String get monthlyInterest => 'Monthly Interest';
  @override
  String get welfareInsuranceFee => 'Welfare Insurance (0.5%)';
  @override
  String get disbursementMethod => 'Disbursement Method';
  @override
  String get loanPurpose => 'Specific Loan Purpose';
  @override
  String get loanPurposeHint => 'e.g. Agricultural supplies, store inventory...';
  @override
  String get submitLoanApplication => 'Submit Loan Application';
  @override
  String get applicationSubmittedSuccess => 'Application Submitted';
  @override
  String get viewProgress => 'View Progress';
  @override
  String get searchApplicationPlaceholder => 'Search application code or package...';
  @override
  String get appStatusUnderReview => 'Under Review';
  @override
  String get appStatusApproved => 'Approved';
  @override
  String get appStatusDisbursed => 'Disbursed';
  @override
  String get appStatusRejected => 'Rejected';
  @override
  String get noActiveLoansToRepay => 'No active loans to repay';
  @override
  String get selectLoanToRepay => 'Select loan to repay';
  @override
  String get monthsTerm => 'Months';
  @override
  String get interestPerMonth => 'month';

  // Account Screen & Settings
  @override
  String get accountTitle => 'Account & Security';
  @override
  String get securityTitle => 'Security & Authentication';
  @override
  String get changePin => 'Change PIN';
  @override
  String get changePinSecurityTitle => 'Change Security PIN';
  @override
  String get currentPinLabel => 'Current PIN';
  @override
  String get newPinLabel => 'New 6-Digit PIN';
  @override
  String get confirmNewPinLabel => 'Confirm New PIN';
  @override
  String get pinChangedSuccess => 'PIN updated successfully';
  @override
  String get biometricAuth => 'Biometrics Authentication';
  @override
  String get biometricSubtitle => 'FaceID & Fingerprint Quick Sign In';
  @override
  String get deviceSecurity => 'Device Security Status';
  @override
  String get deviceSecurityStatus => 'Device Security Audit';
  @override
  String get deviceSecurityPass => 'PASS';
  @override
  String get deviceSecurityDesc => 'SSL Pinning & Anti-Tamper: Compliant';
  @override
  String get utilitiesTitle => 'Utilities & Customer Service';
  @override
  String get settingsAndPreferences => 'Settings & Preferences';
  @override
  String get languageSettingTitle => 'Language';
  @override
  String get dueReminderNotifications => 'Installment Due Reminders';
  @override
  String get dueReminderDesc => 'Notify 3 days prior to due date';
  @override
  String get branchNetwork => 'Branch Network & Contacts';
  @override
  String get supportHotline => 'Member Support Hotline';
  @override
  String get termsAndPrivacy => 'Loan Regulations & Privacy Policy';
  @override
  String get appVersion => 'App Version';
  @override
  String get signOut => 'Sign Out';
  @override
  String get confirmSignOut => 'Are you sure you want to sign out?';
  @override
  String get signOutConfirmTitle => 'Sign Out';
  @override
  String get signOutConfirmDesc => 'Are you sure you want to sign out from BMF Member Portal?';
}
