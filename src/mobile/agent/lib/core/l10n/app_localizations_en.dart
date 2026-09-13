// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BMF Agent';

  @override
  String get loginTitle => 'BMF Agent Login';

  @override
  String get loginSubtitle => 'BMF Authorized Agent & Point of Service';

  @override
  String get agentAuthHeader => 'Agent Account Authentication';

  @override
  String get agentAuthDesc =>
      'Enter agent credentials to access collections & field transactions.';

  @override
  String get usernameLabel => 'Agent Username / Code';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get biometricLogin => 'Log In with Biometrics';

  @override
  String get loginValidationEmpty =>
      'Please enter agent username and password.';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get securityBadgeFooter =>
      'Protected by BMF SSL Pinning & Hardware Keystore';

  @override
  String get dashboardTitle => 'Agent Operations Dashboard';

  @override
  String get centersTitle => 'Centers & Groups';

  @override
  String get collectionSheetTitle => 'Collection Sheet';

  @override
  String get offlineSyncTitle => 'Offline Sync';

  @override
  String get todayTarget => 'Today\'s Target';

  @override
  String get progressCompleted => 'Completed';

  @override
  String get collectedAmount => 'Collected Amount';

  @override
  String get remainingAmount => 'Remaining Amount';

  @override
  String get memberCount => 'Member Count';

  @override
  String get collectPayment => 'Collect Payment';

  @override
  String get printReceipt => 'Print Receipt';

  @override
  String get syncNow => 'Sync Now';

  @override
  String get syncPending => 'Pending Sync';

  @override
  String get syncSuccess => 'Sync Completed Successfully';

  @override
  String get networkOnline => 'Online';

  @override
  String get networkOffline => 'Offline (Local Storage)';

  @override
  String get languageMyanmar => 'မြန်မာ (Myanmar)';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageChinese => '中文';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageKorean => '한국어';

  @override
  String get searchCenterHint => 'Search center name or code';

  @override
  String get meetingDayLabel => 'Meeting Day';

  @override
  String get meetingTimeLabel => 'Meeting Time';

  @override
  String get townshipLabel => 'Township';

  @override
  String get groupCountLabel => 'Groups';

  @override
  String get selectCenterPrompt => 'Select a center to view collection sheets';

  @override
  String get noCentersMatch => 'No centers match this search';

  @override
  String get filterAll => 'All';

  @override
  String get filterDueToday => 'Due Today';

  @override
  String get filterOverdue => 'Overdue';

  @override
  String get filterPaid => 'Paid';

  @override
  String get contractCodeLabel => 'Contract Code';

  @override
  String get customerNameLabel => 'Customer Name';

  @override
  String get periodNumberLabel => 'Period';

  @override
  String get principalLabel => 'Principal';

  @override
  String get interestLabel => 'Interest';

  @override
  String get insuranceLabel => 'Insurance Fee';

  @override
  String get savingLabel => 'Compulsory Saving';

  @override
  String get totalDueLabel => 'Total Due Amount';

  @override
  String get paymentMethodLabel => 'Payment Method';

  @override
  String get methodCash => 'Cash MMK';

  @override
  String get methodMmqr => 'MMQR Dynamic Code';

  @override
  String get methodKbzPay => 'KBZPay Wallet';

  @override
  String get methodWavePay => 'WavePay Wallet';

  @override
  String get confirmCollectionButton => 'Confirm & Record';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get collectionSuccessMessage => 'Repayment recorded successfully';

  @override
  String get collectionFailedMessage => 'Failed to record collection';

  @override
  String get noRepaymentsFound => 'No repayments found for current filter';

  @override
  String get dueLabel => 'Due';

  @override
  String get paidOfflineBadge => 'Paid (Offline Queue)';

  @override
  String get paidSyncedBadge => 'Paid (Synced)';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusPending => 'Pending';

  @override
  String get retryButton => 'Retry';

  @override
  String get bluetoothPrinterTitle => 'Bluetooth Printer';

  @override
  String get printerConnected => 'Connected';

  @override
  String get printerDisconnected => 'Disconnected';

  @override
  String get connectPrinter => 'Connect Printer';

  @override
  String get disconnectPrinter => 'Disconnect';

  @override
  String get printingReceipt => 'Printing receipt...';

  @override
  String get printSuccess => 'Receipt printed successfully';

  @override
  String get printFailed => 'Failed to print receipt';

  @override
  String get noPrintersFound => 'No Bluetooth printers found';

  @override
  String get scanPrinters => 'Scan for Printers';

  @override
  String get printTestReceipt => 'Print Test Receipt';

  @override
  String get availableBluetoothDevices => 'Available Bluetooth Devices';

  @override
  String get noActiveBluetoothLink => 'No active Bluetooth link established';

  @override
  String get syncStatusTitle => 'Offline Sync Engine';

  @override
  String get pendingUploadsCount => 'Pending Records to Upload';

  @override
  String get lastSyncTime => 'Last Sync';

  @override
  String get syncInProgress => 'Syncing data with server...';

  @override
  String get pullingCatalog => 'Downloading updated centers & schedules...';

  @override
  String get pushingBatch => 'Uploading offline repayments...';

  @override
  String get offlineGuidelinesTitle => 'Offline-First Operating Guidelines';

  @override
  String get offlineGuidelinesText =>
      '1. Repayments collected in remote villages are encrypted in SQLCipher AES-256 local database with UUIDv4 idempotency keys.\n2. Once cellular data/Wi-Fi is detected, the engine automatically pushes offline transactions in batches of 50.\n3. Printed receipts with local transaction IDs are legally binding and reconcilable upon server sync.';

  @override
  String get statSynced => 'Synced';

  @override
  String get statFailed => 'Failed';

  @override
  String get navHome => 'Home';

  @override
  String get navCenters => 'Collections';

  @override
  String get navNewLoan => 'New Loan';

  @override
  String get navSavingsCash => 'Savings';

  @override
  String get navAccount => 'Account';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get customize => 'Customize';

  @override
  String get viewAll => 'View All';

  @override
  String get accountSettings => 'Account & Settings';

  @override
  String get officerProfile => 'Agent Profile';

  @override
  String get agentAuthorizedRole => 'Authorized Agent';

  @override
  String get agentBranchLocation => 'Yangon Transaction Point (BR001)';

  @override
  String get cashInHand => 'Agent Cash Balance';

  @override
  String get handoverQr => 'Cash Settlement / Handover QR';

  @override
  String get signOut => 'Sign Out';

  @override
  String get confirmSignOut =>
      'Are you sure you want to sign out from BMF Agent?';

  @override
  String get deviceSecurity => 'Biometrics & Security';

  @override
  String get appVersion => 'App Version';

  @override
  String get appVersionSubtitle => 'Version v2.6.0 (Build 2026.09 - Staging)';

  @override
  String get todayCenterMeeting => 'Today Center Meetings';

  @override
  String get completed => 'Completed';

  @override
  String get itemsCount => 'items';

  @override
  String get membersCount => 'members';

  @override
  String get collectedLabel => 'Collected';

  @override
  String get pendingLabel => 'Pending';

  @override
  String get expectedLabel => 'Expected';

  @override
  String get handoverButton => 'Handover';

  @override
  String get saveCustomization => 'Save Customization';

  @override
  String get customizeAgentShortcuts => 'Customize Agent Shortcuts';

  @override
  String get customizeAgentShortcutsDesc =>
      'Select primary operations to pin on your quick action bar:';

  @override
  String get actionCollectRepayment => 'Collections';

  @override
  String get actionNewLoan => 'New Loan KYC';

  @override
  String get actionSavings => 'Savings Deposit';

  @override
  String get actionCenters => 'Center Meetings';

  @override
  String get actionManageCash => 'Agent Cash Vault';

  @override
  String get actionInsurance => 'Micro-Insurance';

  @override
  String get actionPrinter => 'Thermal Printer';

  @override
  String get actionSync => 'Offline Data Sync';

  @override
  String get agentOperationsSection => 'AGENT OPERATIONS';

  @override
  String get devicesSyncSection => 'DEVICES & SYNC';

  @override
  String get systemSettingsSection => 'SYSTEM & SETTINGS';

  @override
  String get hardwarePrinterSection => 'HARDWARE & PRINTER SETTINGS';

  @override
  String get offlineDataSection => 'OFFLINE DATA & SYNCHRONIZATION';

  @override
  String get securitySection => 'SECURITY & SESSION AUTHENTICATION';

  @override
  String get systemSupportSection => 'SYSTEM & SUPPORT';

  @override
  String get biometricFingerprint => 'Fingerprint Biometric Authentication';

  @override
  String get biometricFingerprintDesc =>
      'Fast and secure login for agent staff';

  @override
  String get itHotline => 'Agent 24/7 Support Hotline';

  @override
  String get itHotlineDesc => 'Hotline: 09450011223 (Ext 2 - Agent Desk)';

  @override
  String get thermalPrinterDesc => 'Handheld thermal printer 58mm/80mm ESC/POS';

  @override
  String get offlineSyncDesc => 'Two-way SQLite & central ERP synchronization';

  @override
  String get manageAgentCashDesc =>
      'Audit physical cash and generate settlement QR code';

  @override
  String get manageAgentCashTitle => 'Agent Cash Vault Management';

  @override
  String get sqliteEncryptionDesc =>
      'SQLite AES-256 database encryption & Hardware KeyStore';

  @override
  String get languageDisplay => 'Display Language';

  @override
  String get latestVersionBadge => 'Latest';

  @override
  String get secureBadge => 'Secure';

  @override
  String get connectedBadge => 'Connected';

  @override
  String get pendingUploadsBadge => 'pending';

  @override
  String get cashManagementTitle => 'Mobile Cash Management';

  @override
  String get currentCashInHand => 'Current Physical Cash in Hand';

  @override
  String get loanRepayments => 'Loan Repayments';

  @override
  String get savingsDeposits => 'Savings Deposits';

  @override
  String get handoverToBranch => 'Hand Over Cash to Branch (QR Code)';

  @override
  String get todayCashTransactions => 'Today Cash Transactions Breakdown';

  @override
  String get noCashTransactions => 'No cash transactions recorded today.';

  @override
  String get safetyLimitExceeded => 'Safety Cash Limit Exceeded!';

  @override
  String get safetyLimitWarning =>
      'Physical cash held exceeds safe limit. Please hand over to branch cashier or bank immediately.';

  @override
  String get cashHandoverSuccess => 'Cash handover confirmed successfully!';

  @override
  String get branchCashierHandoverTitle => 'Branch Cashier Handover';

  @override
  String get transactionsCollectedToday => 'transactions collected today';

  @override
  String get confirmCashierDeposit => 'Confirm Cashier Deposit';

  @override
  String get closeButton => 'Close';

  @override
  String get newLoanApplication => 'New Loan Application';

  @override
  String get originationGuide => 'Field Origination Guide';

  @override
  String get originationGuideText =>
      '1. Verify customer identity via NRC card.\n2. Record GPS coordinates at borrower residence.\n3. Complete biometric e-Signature on screen.\n4. Application is encrypted locally & queued for server approval.';

  @override
  String get gotItButton => 'Got it';

  @override
  String get borrowerDetails => 'Borrower & Loan Details';

  @override
  String get borrowerFullName => 'Borrower Full Name *';

  @override
  String get borrowerFullNameHint => 'e.g. Daw Khin Khin Win';

  @override
  String get borrowerFullNameRequired => 'Full Name is required';

  @override
  String get phoneNumber => 'Contact Phone Number *';

  @override
  String get phoneNumberHint => 'e.g. 09123456789';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get requestedLoanAmount => 'Requested Loan Amount (MMK) *';

  @override
  String get requestedLoanAmountRequired => 'Loan amount is required';

  @override
  String get minLoanAmountValidation => 'Minimum loan amount is 100,000 MMK';

  @override
  String get loanTerm => 'Loan Term';

  @override
  String get purpose => 'Purpose';

  @override
  String get stepIdentityNrc => 'Myanmar NRC Card Verification';

  @override
  String get stepGpsSurvey => 'Field Residence GPS Survey';

  @override
  String get stepSignature => 'Borrower e-Signature (လက်မှတ်)';

  @override
  String get nrcRequiredValidation =>
      'Please scan or enter a valid Myanmar NRC card.';

  @override
  String get gpsRequiredValidation =>
      'Borrower residence GPS coordinates are required before submission.';

  @override
  String get signatureRequiredValidation =>
      'Borrower e-Signature is required before submission.';

  @override
  String get submitApplication => 'Submit Loan Application';

  @override
  String get savingApplication => 'Encrypting & Saving...';

  @override
  String get applicationSaved => 'Application Saved';

  @override
  String get applicationSavedSuccessMsg =>
      'Loan application has been encrypted in local database and queued for sync.';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get positionNrcInFrame =>
      'Position NRC in frame\n(မှတ်ပုံတင် ကတ်ပြားအား ထားပါ)';

  @override
  String get nrcInputLabel => 'Myanmar NRC Number';

  @override
  String get nrcInputHint => 'e.g. 12/DAGANA(N)123456 or ၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆';

  @override
  String get invalidNrcFormat =>
      'Invalid Myanmar NRC format. Example: 12/DAGANA(N)123456';

  @override
  String get signHerePrompt =>
      'Sign here with finger / stylus (လက်မှတ်ရေးထိုးပါ)';

  @override
  String get clearSignature => 'Clear Signature';

  @override
  String get gpsRecordedSuccess =>
      'Field GPS coordinates recorded successfully.';

  @override
  String get gpsPendingLabel => 'GPS Coordinates Pending';

  @override
  String get gpsRecordedLabel => 'Village Geolocation Recorded';

  @override
  String get gpsPromptTap =>
      'Tap the location icon to record field coordinates';

  @override
  String get savingsTitle => 'Village Savings Accounts';

  @override
  String get searchSavingHint => 'Search by member name, NRC, or account...';

  @override
  String get depositSavingButton => 'Deposit Saving';

  @override
  String get reloadAccounts => 'Reload Accounts';

  @override
  String get noSavingsFound => 'No savings accounts found.';

  @override
  String get openFirstAccount => 'Open First Account';

  @override
  String get openPassbookButton => 'Open New Passbook';

  @override
  String get openSavingsPassbookTitle => 'Open Savings Passbook';

  @override
  String get memberAccountHolder => 'Member Account Holder';

  @override
  String get savingsProductPackage => 'Savings Product Package';

  @override
  String get initialCashDeposit => 'Initial Cash Deposit (MMK)';

  @override
  String get initialDepositHint => '0 if opening without deposit';

  @override
  String get legalNominee => 'Legal Nominee / Beneficiary';

  @override
  String get nomineeFullName => 'Nominee Full Name';

  @override
  String get nomineeNrc => 'Nominee NRC Card';

  @override
  String get nomineeRelation => 'Relationship with Member';

  @override
  String get confirmOpenPassbook => 'Confirm & Open Passbook';

  @override
  String get passbookCreatedTitle => 'Passbook Created';

  @override
  String get passbookCreatedDesc =>
      'Savings Passbook has been opened successfully and queued for synchronization.';

  @override
  String get doneButton => 'Done';

  @override
  String get accumulatedBalance => 'Accumulated Balance';

  @override
  String get depositTitle => 'Deposit';

  @override
  String get currentBalanceLabel => 'Current Balance:';

  @override
  String get depositAmountLabel => 'Deposit Amount (MMK) *';

  @override
  String get depositAmountHint => 'Enter amount to deposit';

  @override
  String get depositAmountRequired => 'Deposit amount is required';

  @override
  String get minDepositValidation => 'Minimum deposit amount is 1,000 MMK';

  @override
  String get printReceiptCheckbox => 'Print receipt via Bluetooth printer';

  @override
  String get confirmDeposit => 'Confirm Deposit';

  @override
  String get navSavingsTitle => 'Savings Management';

  @override
  String get navCashTitle => 'Cash Management';

  @override
  String get navInsuranceTitle => 'Micro-Insurance Claims';

  @override
  String get insuranceClaimTitle => 'Mutual Insurance Claim';

  @override
  String get claimSubmittedTitle => 'Claim Submitted';

  @override
  String get claimSubmittedDesc =>
      'Emergency assistance claim has been enqueued locally and forwarded to Township branch for payout approval.';

  @override
  String get claimReferenceCode => 'Claim Reference Code';

  @override
  String get beneficiaryIncidentDetails => 'Beneficiary & Incident Details';

  @override
  String get coveredRiskCategory => 'Covered Risk Category';

  @override
  String get requestedAssistanceAmount => 'Requested Assistance Amount (MMK) *';

  @override
  String get incidentDescription => 'Incident Description & Circumstances *';

  @override
  String get incidentDescriptionHint =>
      'Describe medical diagnosis, hospitalization dates, or loss details...';

  @override
  String get incidentDescriptionRequired => 'Description is required';

  @override
  String get evidentiaryDocuments => 'Evidentiary Documents & Photos';

  @override
  String get villageHeadLetter => 'Village Head Verification Letter';

  @override
  String get letterAttached => 'Letter attached';

  @override
  String get tapToAttachLetter => 'Tap to attach or take photo';

  @override
  String get medicalReceipt => 'Hospital Bill / Medical Receipt';

  @override
  String get receiptAttached => 'Receipt attached';

  @override
  String get tapToAttachReceipt => 'Tap to attach or take photo';

  @override
  String get submitEmergencyClaim => 'Submit Emergency Claim';

  @override
  String get submittingClaim => 'Submitting Claim...';

  @override
  String get letterAttachedToast => 'Village Head verification photo attached.';

  @override
  String get receiptAttachedToast => 'Medical invoice photo attached.';

  @override
  String get savingProductCompulsory => 'Compulsory Micro Saving';

  @override
  String get savingProductVoluntary => 'Voluntary Open Saving';

  @override
  String get savingProductFixedTerm => 'Fixed Term Deposit';

  @override
  String get cashTxLoanRepayment => 'Loan Installment Collection';

  @override
  String get cashTxSavingDeposit => 'Village Saving Deposit';

  @override
  String get cashTxSavingOpen => 'Passbook Opening Initial Deposit';

  @override
  String get cashTxHandover => 'Branch Cashier Handover';

  @override
  String get claimRiskIllness => 'Inpatient Hospitalization';

  @override
  String get claimRiskAccident => 'Work / Traffic Accident';

  @override
  String get claimRiskNaturalDisaster => 'Flood / Cyclone / Fire';

  @override
  String get claimRiskDeath => 'Member / Spouse Bereavement';

  @override
  String get claimRiskCropFailure => 'Severe Crop Pest / Drought';

  @override
  String get claimAmountRequired => 'Claim assistance amount is required';

  @override
  String get invalidAmountValidation =>
      'Please enter a valid amount greater than 0';

  @override
  String get methodAyaPay => 'AYA Pay Wallet';

  @override
  String get methodMytelPay => 'MytelPay Wallet';

  @override
  String get methodBankTransfer => 'Bank Transfer';
}
