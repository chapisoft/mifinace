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
  /// **'BMF Credit Officer Login'**
  String get loginTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Officer Username'**
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

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Field Operations Dashboard'**
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
