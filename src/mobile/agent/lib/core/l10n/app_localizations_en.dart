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
  String get loginTitle => 'BMF Credit Officer Login';

  @override
  String get usernameLabel => 'Officer Username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get biometricLogin => 'Log In with Biometrics';

  @override
  String get dashboardTitle => 'Field Operations Dashboard';

  @override
  String get centersTitle => 'Centers & Groups';

  @override
  String get collectionSheetTitle => 'Collection Sheet';

  @override
  String get offlineSyncTitle => 'Offline Sync';

  @override
  String get todayTarget => 'Today\'s Target';

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
}
