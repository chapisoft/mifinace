import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_my.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('my'),
    Locale('vi'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BMF Agent'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'BMF Agent Login'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'BMF Authorized Agent & Point of Service'**
  String get loginSubtitle;

  /// No description provided for @agentAuthHeader.
  ///
  /// In en, this message translates to:
  /// **'Agent Account Authentication'**
  String get agentAuthHeader;

  /// No description provided for @agentAuthDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter agent credentials to access collections & field transactions.'**
  String get agentAuthDesc;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Agent Username / Code'**
  String get usernameLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In with Biometrics'**
  String get biometricLogin;

  /// No description provided for @loginValidationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter agent username and password.'**
  String get loginValidationEmpty;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @securityBadgeFooter.
  ///
  /// In en, this message translates to:
  /// **'Protected by BMF SSL Pinning & Hardware Keystore'**
  String get securityBadgeFooter;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Operations Dashboard'**
  String get dashboardTitle;

  /// No description provided for @centersTitle.
  ///
  /// In en, this message translates to:
  /// **'Centers & Groups'**
  String get centersTitle;

  /// No description provided for @collectionSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection Sheet'**
  String get collectionSheetTitle;

  /// No description provided for @offlineSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Sync'**
  String get offlineSyncTitle;

  /// No description provided for @todayTarget.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Target'**
  String get todayTarget;

  /// No description provided for @progressCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get progressCompleted;

  /// No description provided for @collectedAmount.
  ///
  /// In en, this message translates to:
  /// **'Collected Amount'**
  String get collectedAmount;

  /// No description provided for @remainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Remaining Amount'**
  String get remainingAmount;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'Member Count'**
  String get memberCount;

  /// No description provided for @collectPayment.
  ///
  /// In en, this message translates to:
  /// **'Collect Payment'**
  String get collectPayment;

  /// No description provided for @printReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Receipt'**
  String get printReceipt;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Sync'**
  String get syncPending;

  /// No description provided for @syncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sync Completed Successfully'**
  String get syncSuccess;

  /// No description provided for @networkOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get networkOnline;

  /// No description provided for @networkOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline (Local Storage)'**
  String get networkOffline;

  /// No description provided for @languageMyanmar.
  ///
  /// In en, this message translates to:
  /// **'မြန်မာ (Myanmar)'**
  String get languageMyanmar;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get languageKorean;

  /// No description provided for @searchCenterHint.
  ///
  /// In en, this message translates to:
  /// **'Search center name or code'**
  String get searchCenterHint;

  /// No description provided for @meetingDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Meeting Day'**
  String get meetingDayLabel;

  /// No description provided for @meetingTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Meeting Time'**
  String get meetingTimeLabel;

  /// No description provided for @townshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Township'**
  String get townshipLabel;

  /// No description provided for @groupCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupCountLabel;

  /// No description provided for @selectCenterPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a center to view collection sheets'**
  String get selectCenterPrompt;

  /// No description provided for @noCentersMatch.
  ///
  /// In en, this message translates to:
  /// **'No centers match this search'**
  String get noCentersMatch;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get filterDueToday;

  /// No description provided for @filterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get filterOverdue;

  /// No description provided for @filterPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get filterPaid;

  /// No description provided for @contractCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Contract Code'**
  String get contractCodeLabel;

  /// No description provided for @customerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerNameLabel;

  /// No description provided for @periodNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get periodNumberLabel;

  /// No description provided for @principalLabel.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get principalLabel;

  /// No description provided for @interestLabel.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interestLabel;

  /// No description provided for @insuranceLabel.
  ///
  /// In en, this message translates to:
  /// **'Insurance Fee'**
  String get insuranceLabel;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Compulsory Saving'**
  String get savingLabel;

  /// No description provided for @totalDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Due Amount'**
  String get totalDueLabel;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodLabel;

  /// No description provided for @methodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash MMK'**
  String get methodCash;

  /// No description provided for @methodMmqr.
  ///
  /// In en, this message translates to:
  /// **'MMQR Dynamic Code'**
  String get methodMmqr;

  /// No description provided for @methodKbzPay.
  ///
  /// In en, this message translates to:
  /// **'KBZPay Wallet'**
  String get methodKbzPay;

  /// No description provided for @methodWavePay.
  ///
  /// In en, this message translates to:
  /// **'WavePay Wallet'**
  String get methodWavePay;

  /// No description provided for @confirmCollectionButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Record'**
  String get confirmCollectionButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @collectionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Repayment recorded successfully'**
  String get collectionSuccessMessage;

  /// No description provided for @collectionFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to record collection'**
  String get collectionFailedMessage;

  /// No description provided for @noRepaymentsFound.
  ///
  /// In en, this message translates to:
  /// **'No repayments found for current filter'**
  String get noRepaymentsFound;

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueLabel;

  /// No description provided for @paidOfflineBadge.
  ///
  /// In en, this message translates to:
  /// **'Paid (Offline Queue)'**
  String get paidOfflineBadge;

  /// No description provided for @paidSyncedBadge.
  ///
  /// In en, this message translates to:
  /// **'Paid (Synced)'**
  String get paidSyncedBadge;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @bluetoothPrinterTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Printer'**
  String get bluetoothPrinterTitle;

  /// No description provided for @printerConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get printerConnected;

  /// No description provided for @printerDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get printerDisconnected;

  /// No description provided for @connectPrinter.
  ///
  /// In en, this message translates to:
  /// **'Connect Printer'**
  String get connectPrinter;

  /// No description provided for @disconnectPrinter.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnectPrinter;

  /// No description provided for @printingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Printing receipt...'**
  String get printingReceipt;

  /// No description provided for @printSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt printed successfully'**
  String get printSuccess;

  /// No description provided for @printFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to print receipt'**
  String get printFailed;

  /// No description provided for @noPrintersFound.
  ///
  /// In en, this message translates to:
  /// **'No Bluetooth printers found'**
  String get noPrintersFound;

  /// No description provided for @scanPrinters.
  ///
  /// In en, this message translates to:
  /// **'Scan for Printers'**
  String get scanPrinters;

  /// No description provided for @printTestReceipt.
  ///
  /// In en, this message translates to:
  /// **'Print Test Receipt'**
  String get printTestReceipt;

  /// No description provided for @availableBluetoothDevices.
  ///
  /// In en, this message translates to:
  /// **'Available Bluetooth Devices'**
  String get availableBluetoothDevices;

  /// No description provided for @noActiveBluetoothLink.
  ///
  /// In en, this message translates to:
  /// **'No active Bluetooth link established'**
  String get noActiveBluetoothLink;

  /// No description provided for @syncStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Sync Engine'**
  String get syncStatusTitle;

  /// No description provided for @pendingUploadsCount.
  ///
  /// In en, this message translates to:
  /// **'Pending Records to Upload'**
  String get pendingUploadsCount;

  /// No description provided for @lastSyncTime.
  ///
  /// In en, this message translates to:
  /// **'Last Sync'**
  String get lastSyncTime;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing data with server...'**
  String get syncInProgress;

  /// No description provided for @pullingCatalog.
  ///
  /// In en, this message translates to:
  /// **'Downloading updated centers & schedules...'**
  String get pullingCatalog;

  /// No description provided for @pushingBatch.
  ///
  /// In en, this message translates to:
  /// **'Uploading offline repayments...'**
  String get pushingBatch;

  /// No description provided for @offlineGuidelinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline-First Operating Guidelines'**
  String get offlineGuidelinesTitle;

  /// No description provided for @offlineGuidelinesText.
  ///
  /// In en, this message translates to:
  /// **'1. Repayments collected in remote villages are encrypted in SQLCipher AES-256 local database with UUIDv4 idempotency keys.\n2. Once cellular data/Wi-Fi is detected, the engine automatically pushes offline transactions in batches of 50.\n3. Printed receipts with local transaction IDs are legally binding and reconcilable upon server sync.'**
  String get offlineGuidelinesText;

  /// No description provided for @statSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get statSynced;

  /// No description provided for @statFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statFailed;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCenters.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get navCenters;

  /// No description provided for @navNewLoan.
  ///
  /// In en, this message translates to:
  /// **'New Loan'**
  String get navNewLoan;

  /// No description provided for @navSavingsCash.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get navSavingsCash;

  /// No description provided for @navAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get navAccount;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account & Settings'**
  String get accountSettings;

  /// No description provided for @officerProfile.
  ///
  /// In en, this message translates to:
  /// **'Agent Profile'**
  String get officerProfile;

  /// No description provided for @agentAuthorizedRole.
  ///
  /// In en, this message translates to:
  /// **'Authorized Agent'**
  String get agentAuthorizedRole;

  /// No description provided for @agentBranchLocation.
  ///
  /// In en, this message translates to:
  /// **'Yangon Transaction Point (BR001)'**
  String get agentBranchLocation;

  /// No description provided for @cashInHand.
  ///
  /// In en, this message translates to:
  /// **'Agent Cash Balance'**
  String get cashInHand;

  /// No description provided for @handoverQr.
  ///
  /// In en, this message translates to:
  /// **'Cash Settlement / Handover QR'**
  String get handoverQr;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out from BMF Agent?'**
  String get confirmSignOut;

  /// No description provided for @deviceSecurity.
  ///
  /// In en, this message translates to:
  /// **'Biometrics & Security'**
  String get deviceSecurity;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @appVersionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version v2.6.0 (Build 2026.09 - Staging)'**
  String get appVersionSubtitle;

  /// No description provided for @todayCenterMeeting.
  ///
  /// In en, this message translates to:
  /// **'Today Center Meetings'**
  String get todayCenterMeeting;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get itemsCount;

  /// No description provided for @membersCount.
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get membersCount;

  /// No description provided for @collectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collectedLabel;

  /// No description provided for @pendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingLabel;

  /// No description provided for @expectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get expectedLabel;

  /// No description provided for @handoverButton.
  ///
  /// In en, this message translates to:
  /// **'Handover'**
  String get handoverButton;

  /// No description provided for @saveCustomization.
  ///
  /// In en, this message translates to:
  /// **'Save Customization'**
  String get saveCustomization;

  /// No description provided for @customizeAgentShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Customize Agent Shortcuts'**
  String get customizeAgentShortcuts;

  /// No description provided for @customizeAgentShortcutsDesc.
  ///
  /// In en, this message translates to:
  /// **'Select primary operations to pin on your quick action bar:'**
  String get customizeAgentShortcutsDesc;

  /// No description provided for @actionCollectRepayment.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get actionCollectRepayment;

  /// No description provided for @actionNewLoan.
  ///
  /// In en, this message translates to:
  /// **'New Loan KYC'**
  String get actionNewLoan;

  /// No description provided for @actionSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings Deposit'**
  String get actionSavings;

  /// No description provided for @actionCenters.
  ///
  /// In en, this message translates to:
  /// **'Center Meetings'**
  String get actionCenters;

  /// No description provided for @actionManageCash.
  ///
  /// In en, this message translates to:
  /// **'Agent Cash Vault'**
  String get actionManageCash;

  /// No description provided for @actionInsurance.
  ///
  /// In en, this message translates to:
  /// **'Micro-Insurance'**
  String get actionInsurance;

  /// No description provided for @actionPrinter.
  ///
  /// In en, this message translates to:
  /// **'Thermal Printer'**
  String get actionPrinter;

  /// No description provided for @actionSync.
  ///
  /// In en, this message translates to:
  /// **'Offline Data Sync'**
  String get actionSync;

  /// No description provided for @agentOperationsSection.
  ///
  /// In en, this message translates to:
  /// **'AGENT OPERATIONS'**
  String get agentOperationsSection;

  /// No description provided for @devicesSyncSection.
  ///
  /// In en, this message translates to:
  /// **'DEVICES & SYNC'**
  String get devicesSyncSection;

  /// No description provided for @systemSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM & SETTINGS'**
  String get systemSettingsSection;

  /// No description provided for @hardwarePrinterSection.
  ///
  /// In en, this message translates to:
  /// **'HARDWARE & PRINTER SETTINGS'**
  String get hardwarePrinterSection;

  /// No description provided for @offlineDataSection.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE DATA & SYNCHRONIZATION'**
  String get offlineDataSection;

  /// No description provided for @securitySection.
  ///
  /// In en, this message translates to:
  /// **'SECURITY & SESSION AUTHENTICATION'**
  String get securitySection;

  /// No description provided for @systemSupportSection.
  ///
  /// In en, this message translates to:
  /// **'SYSTEM & SUPPORT'**
  String get systemSupportSection;

  /// No description provided for @biometricFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint Biometric Authentication'**
  String get biometricFingerprint;

  /// No description provided for @biometricFingerprintDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast and secure login for agent staff'**
  String get biometricFingerprintDesc;

  /// No description provided for @itHotline.
  ///
  /// In en, this message translates to:
  /// **'Agent 24/7 Support Hotline'**
  String get itHotline;

  /// No description provided for @itHotlineDesc.
  ///
  /// In en, this message translates to:
  /// **'Hotline: 09450011223 (Ext 2 - Agent Desk)'**
  String get itHotlineDesc;

  /// No description provided for @thermalPrinterDesc.
  ///
  /// In en, this message translates to:
  /// **'Handheld thermal printer 58mm/80mm ESC/POS'**
  String get thermalPrinterDesc;

  /// No description provided for @offlineSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Two-way SQLite & central ERP synchronization'**
  String get offlineSyncDesc;

  /// No description provided for @manageAgentCashDesc.
  ///
  /// In en, this message translates to:
  /// **'Audit physical cash and generate settlement QR code'**
  String get manageAgentCashDesc;

  /// No description provided for @manageAgentCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Cash Vault Management'**
  String get manageAgentCashTitle;

  /// No description provided for @sqliteEncryptionDesc.
  ///
  /// In en, this message translates to:
  /// **'SQLite AES-256 database encryption & Hardware KeyStore'**
  String get sqliteEncryptionDesc;

  /// No description provided for @languageDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display Language'**
  String get languageDisplay;

  /// No description provided for @latestVersionBadge.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latestVersionBadge;

  /// No description provided for @secureBadge.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get secureBadge;

  /// No description provided for @connectedBadge.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connectedBadge;

  /// No description provided for @pendingUploadsBadge.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get pendingUploadsBadge;

  /// No description provided for @cashManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile Cash Management'**
  String get cashManagementTitle;

  /// No description provided for @currentCashInHand.
  ///
  /// In en, this message translates to:
  /// **'Current Physical Cash in Hand'**
  String get currentCashInHand;

  /// No description provided for @loanRepayments.
  ///
  /// In en, this message translates to:
  /// **'Loan Repayments'**
  String get loanRepayments;

  /// No description provided for @savingsDeposits.
  ///
  /// In en, this message translates to:
  /// **'Savings Deposits'**
  String get savingsDeposits;

  /// No description provided for @handoverToBranch.
  ///
  /// In en, this message translates to:
  /// **'Hand Over Cash to Branch (QR Code)'**
  String get handoverToBranch;

  /// No description provided for @todayCashTransactions.
  ///
  /// In en, this message translates to:
  /// **'Today Cash Transactions Breakdown'**
  String get todayCashTransactions;

  /// No description provided for @noCashTransactions.
  ///
  /// In en, this message translates to:
  /// **'No cash transactions recorded today.'**
  String get noCashTransactions;

  /// No description provided for @safetyLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'Safety Cash Limit Exceeded!'**
  String get safetyLimitExceeded;

  /// No description provided for @safetyLimitWarning.
  ///
  /// In en, this message translates to:
  /// **'Physical cash held exceeds safe limit. Please hand over to branch cashier or bank immediately.'**
  String get safetyLimitWarning;

  /// No description provided for @cashHandoverSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cash handover confirmed successfully!'**
  String get cashHandoverSuccess;

  /// No description provided for @branchCashierHandoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch Cashier Handover'**
  String get branchCashierHandoverTitle;

  /// No description provided for @transactionsCollectedToday.
  ///
  /// In en, this message translates to:
  /// **'transactions collected today'**
  String get transactionsCollectedToday;

  /// No description provided for @confirmCashierDeposit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Cashier Deposit'**
  String get confirmCashierDeposit;

  /// No description provided for @closeButton.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButton;

  /// No description provided for @newLoanApplication.
  ///
  /// In en, this message translates to:
  /// **'New Loan Application'**
  String get newLoanApplication;

  /// No description provided for @originationGuide.
  ///
  /// In en, this message translates to:
  /// **'Field Origination Guide'**
  String get originationGuide;

  /// No description provided for @originationGuideText.
  ///
  /// In en, this message translates to:
  /// **'1. Verify customer identity via NRC card.\n2. Record GPS coordinates at borrower residence.\n3. Complete biometric e-Signature on screen.\n4. Application is encrypted locally & queued for server approval.'**
  String get originationGuideText;

  /// No description provided for @gotItButton.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotItButton;

  /// No description provided for @borrowerDetails.
  ///
  /// In en, this message translates to:
  /// **'Borrower & Loan Details'**
  String get borrowerDetails;

  /// No description provided for @borrowerFullName.
  ///
  /// In en, this message translates to:
  /// **'Borrower Full Name *'**
  String get borrowerFullName;

  /// No description provided for @borrowerFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Daw Khin Khin Win'**
  String get borrowerFullNameHint;

  /// No description provided for @borrowerFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full Name is required'**
  String get borrowerFullNameRequired;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone Number *'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 09123456789'**
  String get phoneNumberHint;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @requestedLoanAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested Loan Amount (MMK) *'**
  String get requestedLoanAmount;

  /// No description provided for @requestedLoanAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Loan amount is required'**
  String get requestedLoanAmountRequired;

  /// No description provided for @minLoanAmountValidation.
  ///
  /// In en, this message translates to:
  /// **'Minimum loan amount is 100,000 MMK'**
  String get minLoanAmountValidation;

  /// No description provided for @loanTerm.
  ///
  /// In en, this message translates to:
  /// **'Loan Term'**
  String get loanTerm;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @stepIdentityNrc.
  ///
  /// In en, this message translates to:
  /// **'Myanmar NRC Card Verification'**
  String get stepIdentityNrc;

  /// No description provided for @stepGpsSurvey.
  ///
  /// In en, this message translates to:
  /// **'Field Residence GPS Survey'**
  String get stepGpsSurvey;

  /// No description provided for @stepSignature.
  ///
  /// In en, this message translates to:
  /// **'Borrower e-Signature (လက်မှတ်)'**
  String get stepSignature;

  /// No description provided for @nrcRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Please scan or enter a valid Myanmar NRC card.'**
  String get nrcRequiredValidation;

  /// No description provided for @gpsRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Borrower residence GPS coordinates are required before submission.'**
  String get gpsRequiredValidation;

  /// No description provided for @signatureRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'Borrower e-Signature is required before submission.'**
  String get signatureRequiredValidation;

  /// No description provided for @submitApplication.
  ///
  /// In en, this message translates to:
  /// **'Submit Loan Application'**
  String get submitApplication;

  /// No description provided for @savingApplication.
  ///
  /// In en, this message translates to:
  /// **'Encrypting & Saving...'**
  String get savingApplication;

  /// No description provided for @applicationSaved.
  ///
  /// In en, this message translates to:
  /// **'Application Saved'**
  String get applicationSaved;

  /// No description provided for @applicationSavedSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Loan application has been encrypted in local database and queued for sync.'**
  String get applicationSavedSuccessMsg;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @positionNrcInFrame.
  ///
  /// In en, this message translates to:
  /// **'Position NRC in frame\n(မှတ်ပုံတင် ကတ်ပြားအား ထားပါ)'**
  String get positionNrcInFrame;

  /// No description provided for @nrcInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Myanmar NRC Number'**
  String get nrcInputLabel;

  /// No description provided for @nrcInputHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12/DAGANA(N)123456 or ၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆'**
  String get nrcInputHint;

  /// No description provided for @invalidNrcFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid Myanmar NRC format. Example: 12/DAGANA(N)123456'**
  String get invalidNrcFormat;

  /// No description provided for @signHerePrompt.
  ///
  /// In en, this message translates to:
  /// **'Sign here with finger / stylus (လက်မှတ်ရေးထိုးပါ)'**
  String get signHerePrompt;

  /// No description provided for @clearSignature.
  ///
  /// In en, this message translates to:
  /// **'Clear Signature'**
  String get clearSignature;

  /// No description provided for @gpsRecordedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Field GPS coordinates recorded successfully.'**
  String get gpsRecordedSuccess;

  /// No description provided for @gpsPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'GPS Coordinates Pending'**
  String get gpsPendingLabel;

  /// No description provided for @gpsRecordedLabel.
  ///
  /// In en, this message translates to:
  /// **'Village Geolocation Recorded'**
  String get gpsRecordedLabel;

  /// No description provided for @gpsPromptTap.
  ///
  /// In en, this message translates to:
  /// **'Tap the location icon to record field coordinates'**
  String get gpsPromptTap;

  /// No description provided for @savingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Village Savings Accounts'**
  String get savingsTitle;

  /// No description provided for @searchSavingHint.
  ///
  /// In en, this message translates to:
  /// **'Search by member name, NRC, or account...'**
  String get searchSavingHint;

  /// No description provided for @depositSavingButton.
  ///
  /// In en, this message translates to:
  /// **'Deposit Saving'**
  String get depositSavingButton;

  /// No description provided for @reloadAccounts.
  ///
  /// In en, this message translates to:
  /// **'Reload Accounts'**
  String get reloadAccounts;

  /// No description provided for @noSavingsFound.
  ///
  /// In en, this message translates to:
  /// **'No savings accounts found.'**
  String get noSavingsFound;

  /// No description provided for @openFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'Open First Account'**
  String get openFirstAccount;

  /// No description provided for @openPassbookButton.
  ///
  /// In en, this message translates to:
  /// **'Open New Passbook'**
  String get openPassbookButton;

  /// No description provided for @openSavingsPassbookTitle.
  ///
  /// In en, this message translates to:
  /// **'Open Savings Passbook'**
  String get openSavingsPassbookTitle;

  /// No description provided for @memberAccountHolder.
  ///
  /// In en, this message translates to:
  /// **'Member Account Holder'**
  String get memberAccountHolder;

  /// No description provided for @savingsProductPackage.
  ///
  /// In en, this message translates to:
  /// **'Savings Product Package'**
  String get savingsProductPackage;

  /// No description provided for @initialCashDeposit.
  ///
  /// In en, this message translates to:
  /// **'Initial Cash Deposit (MMK)'**
  String get initialCashDeposit;

  /// No description provided for @initialDepositHint.
  ///
  /// In en, this message translates to:
  /// **'0 if opening without deposit'**
  String get initialDepositHint;

  /// No description provided for @legalNominee.
  ///
  /// In en, this message translates to:
  /// **'Legal Nominee / Beneficiary'**
  String get legalNominee;

  /// No description provided for @nomineeFullName.
  ///
  /// In en, this message translates to:
  /// **'Nominee Full Name'**
  String get nomineeFullName;

  /// No description provided for @nomineeNrc.
  ///
  /// In en, this message translates to:
  /// **'Nominee NRC Card'**
  String get nomineeNrc;

  /// No description provided for @nomineeRelation.
  ///
  /// In en, this message translates to:
  /// **'Relationship with Member'**
  String get nomineeRelation;

  /// No description provided for @confirmOpenPassbook.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Open Passbook'**
  String get confirmOpenPassbook;

  /// No description provided for @passbookCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Passbook Created'**
  String get passbookCreatedTitle;

  /// No description provided for @passbookCreatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Savings Passbook has been opened successfully and queued for synchronization.'**
  String get passbookCreatedDesc;

  /// No description provided for @doneButton.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneButton;

  /// No description provided for @accumulatedBalance.
  ///
  /// In en, this message translates to:
  /// **'Accumulated Balance'**
  String get accumulatedBalance;

  /// No description provided for @depositTitle.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get depositTitle;

  /// No description provided for @currentBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Balance:'**
  String get currentBalanceLabel;

  /// No description provided for @depositAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Deposit Amount (MMK) *'**
  String get depositAmountLabel;

  /// No description provided for @depositAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to deposit'**
  String get depositAmountHint;

  /// No description provided for @depositAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Deposit amount is required'**
  String get depositAmountRequired;

  /// No description provided for @minDepositValidation.
  ///
  /// In en, this message translates to:
  /// **'Minimum deposit amount is 1,000 MMK'**
  String get minDepositValidation;

  /// No description provided for @printReceiptCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Print receipt via Bluetooth printer'**
  String get printReceiptCheckbox;

  /// No description provided for @confirmDeposit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deposit'**
  String get confirmDeposit;

  /// No description provided for @navSavingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Savings Management'**
  String get navSavingsTitle;

  /// No description provided for @navCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash Management'**
  String get navCashTitle;

  /// No description provided for @navInsuranceTitle.
  ///
  /// In en, this message translates to:
  /// **'Micro-Insurance Claims'**
  String get navInsuranceTitle;

  /// No description provided for @insuranceClaimTitle.
  ///
  /// In en, this message translates to:
  /// **'Mutual Insurance Claim'**
  String get insuranceClaimTitle;

  /// No description provided for @claimSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim Submitted'**
  String get claimSubmittedTitle;

  /// No description provided for @claimSubmittedDesc.
  ///
  /// In en, this message translates to:
  /// **'Emergency assistance claim has been enqueued locally and forwarded to Township branch for payout approval.'**
  String get claimSubmittedDesc;

  /// No description provided for @claimReferenceCode.
  ///
  /// In en, this message translates to:
  /// **'Claim Reference Code'**
  String get claimReferenceCode;

  /// No description provided for @beneficiaryIncidentDetails.
  ///
  /// In en, this message translates to:
  /// **'Beneficiary & Incident Details'**
  String get beneficiaryIncidentDetails;

  /// No description provided for @coveredRiskCategory.
  ///
  /// In en, this message translates to:
  /// **'Covered Risk Category'**
  String get coveredRiskCategory;

  /// No description provided for @requestedAssistanceAmount.
  ///
  /// In en, this message translates to:
  /// **'Requested Assistance Amount (MMK) *'**
  String get requestedAssistanceAmount;

  /// No description provided for @incidentDescription.
  ///
  /// In en, this message translates to:
  /// **'Incident Description & Circumstances *'**
  String get incidentDescription;

  /// No description provided for @incidentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe medical diagnosis, hospitalization dates, or loss details...'**
  String get incidentDescriptionHint;

  /// No description provided for @incidentDescriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get incidentDescriptionRequired;

  /// No description provided for @evidentiaryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Evidentiary Documents & Photos'**
  String get evidentiaryDocuments;

  /// No description provided for @villageHeadLetter.
  ///
  /// In en, this message translates to:
  /// **'Village Head Verification Letter'**
  String get villageHeadLetter;

  /// No description provided for @letterAttached.
  ///
  /// In en, this message translates to:
  /// **'Letter attached'**
  String get letterAttached;

  /// No description provided for @tapToAttachLetter.
  ///
  /// In en, this message translates to:
  /// **'Tap to attach or take photo'**
  String get tapToAttachLetter;

  /// No description provided for @medicalReceipt.
  ///
  /// In en, this message translates to:
  /// **'Hospital Bill / Medical Receipt'**
  String get medicalReceipt;

  /// No description provided for @receiptAttached.
  ///
  /// In en, this message translates to:
  /// **'Receipt attached'**
  String get receiptAttached;

  /// No description provided for @tapToAttachReceipt.
  ///
  /// In en, this message translates to:
  /// **'Tap to attach or take photo'**
  String get tapToAttachReceipt;

  /// No description provided for @submitEmergencyClaim.
  ///
  /// In en, this message translates to:
  /// **'Submit Emergency Claim'**
  String get submitEmergencyClaim;

  /// No description provided for @submittingClaim.
  ///
  /// In en, this message translates to:
  /// **'Submitting Claim...'**
  String get submittingClaim;

  /// No description provided for @letterAttachedToast.
  ///
  /// In en, this message translates to:
  /// **'Village Head verification photo attached.'**
  String get letterAttachedToast;

  /// No description provided for @receiptAttachedToast.
  ///
  /// In en, this message translates to:
  /// **'Medical invoice photo attached.'**
  String get receiptAttachedToast;

  /// No description provided for @savingProductCompulsory.
  ///
  /// In en, this message translates to:
  /// **'Compulsory Micro Saving'**
  String get savingProductCompulsory;

  /// No description provided for @savingProductVoluntary.
  ///
  /// In en, this message translates to:
  /// **'Voluntary Open Saving'**
  String get savingProductVoluntary;

  /// No description provided for @savingProductFixedTerm.
  ///
  /// In en, this message translates to:
  /// **'Fixed Term Deposit'**
  String get savingProductFixedTerm;

  /// No description provided for @cashTxLoanRepayment.
  ///
  /// In en, this message translates to:
  /// **'Loan Installment Collection'**
  String get cashTxLoanRepayment;

  /// No description provided for @cashTxSavingDeposit.
  ///
  /// In en, this message translates to:
  /// **'Village Saving Deposit'**
  String get cashTxSavingDeposit;

  /// No description provided for @cashTxSavingOpen.
  ///
  /// In en, this message translates to:
  /// **'Passbook Opening Initial Deposit'**
  String get cashTxSavingOpen;

  /// No description provided for @cashTxHandover.
  ///
  /// In en, this message translates to:
  /// **'Branch Cashier Handover'**
  String get cashTxHandover;

  /// No description provided for @claimRiskIllness.
  ///
  /// In en, this message translates to:
  /// **'Inpatient Hospitalization'**
  String get claimRiskIllness;

  /// No description provided for @claimRiskAccident.
  ///
  /// In en, this message translates to:
  /// **'Work / Traffic Accident'**
  String get claimRiskAccident;

  /// No description provided for @claimRiskNaturalDisaster.
  ///
  /// In en, this message translates to:
  /// **'Flood / Cyclone / Fire'**
  String get claimRiskNaturalDisaster;

  /// No description provided for @claimRiskDeath.
  ///
  /// In en, this message translates to:
  /// **'Member / Spouse Bereavement'**
  String get claimRiskDeath;

  /// No description provided for @claimRiskCropFailure.
  ///
  /// In en, this message translates to:
  /// **'Severe Crop Pest / Drought'**
  String get claimRiskCropFailure;

  /// No description provided for @claimAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Claim assistance amount is required'**
  String get claimAmountRequired;

  /// No description provided for @invalidAmountValidation.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0'**
  String get invalidAmountValidation;

  /// No description provided for @methodAyaPay.
  ///
  /// In en, this message translates to:
  /// **'AYA Pay Wallet'**
  String get methodAyaPay;

  /// No description provided for @methodMytelPay.
  ///
  /// In en, this message translates to:
  /// **'MytelPay Wallet'**
  String get methodMytelPay;

  /// No description provided for @methodBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get methodBankTransfer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'ja',
        'ko',
        'my',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'my':
      return AppLocalizationsMy();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
