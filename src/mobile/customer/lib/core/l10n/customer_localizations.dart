import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'customer_localizations_my.dart';
import 'customer_localizations_en.dart';
import 'customer_localizations_vi.dart';
import 'customer_localizations_zh.dart';
import 'customer_localizations_ja.dart';
import 'customer_localizations_ko.dart';

/// Central Localizations contract for BMF Customer Mobile App.
/// Strictly supports 6 languages across the ERP platform: Myanmar, English, Vietnamese, Chinese, Japanese, Korean.
abstract class CustomerLocalizations {
  final String localeName;
  CustomerLocalizations(this.localeName);

  static CustomerLocalizations of(BuildContext context) {
    return Localizations.of<CustomerLocalizations>(context, CustomerLocalizations) ?? CustomerLocalizationsEn();
  }

  static const LocalizationsDelegate<CustomerLocalizations> delegate = _CustomerLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('my'),
    Locale('en'),
    Locale('vi'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
  ];

  // App & Navigation
  String get appTitle;
  String get home;
  String get loans;
  String get savings;
  String get insurance;
  String get notifications;
  String get navHome;
  String get navLoans;
  String get navScanQr;
  String get navHistory;
  String get navAccount;

  // Common Actions & Dialogs
  String get close;
  String get cancel;
  String get confirm;
  String get done;
  String get save;
  String get retry;
  String get selectLanguage;
  String get version;
  String get viewAll;
  String get customize;
  String get quickActions;
  String get customizeQuickActions;
  String get customizeQuickActionsDesc;
  String get saveChanges;
  String get maxShortcutsReached;
  String get minShortcutsRequired;

  // Authentication
  String get loginTitle;
  String get phoneLabel;
  String get nrcLabel;
  String get memberIdOrPhoneOrNrc;
  String get continueButton;
  String get switchAccount;
  String get forgotPin;
  String get enter6DigitPin;
  String get notActivatedPrompt;
  String get activateNow;
  String get welcomeBack;
  String get firstTimeUsingApp;
  String get activateWithInfo;
  String get splashTagline;
  String get savedMemberAccount;
  String get requestOtp;
  String get otpTitle;
  String get verifyOtp;
  String get setPinTitle;
  String get confirmPinTitle;
  String get enterPinTitle;
  String get biometricLogin;
  String get pinMismatch;
  String get pinSuccess;
  String get inputIdentifierRequired;

  // Dashboard & Member Profile
  String get welcomeMember;
  String get memberCode;
  String get groupCode;
  String get totalOutstanding;
  String get activeLoans;
  String get dueAlertTitle;
  String get payNow;
  String get quickServices;
  String get digitalMemberCard;
  String get memberQrTitle;
  String get centerLabel;
  String get groupLabel;
  String get meetingScheduleLabel;
  String get weeklyMeetingTime;
  String get assignedOfficerLabel;
  String get noRecentTransactions;
  String get periodNumberLabel;

  // Overview Metrics & Status
  String get outstandingLoanMetric;
  String get dueMetric;
  String get totalSavingsMetric;
  String get loyaltyPointsMetric;
  String get memberActiveStatus;

  // Home Menu Items
  String get menuMmqrTitle;
  String get menuMmqrSubtitle;
  String get menuLoansTitle;
  String get menuLoansSubtitle;
  String get menuSavingsTitle;
  String get menuSavingsSubtitle;
  String get menuInsuranceTitle;
  String get menuInsuranceSubtitle;
  String get menuApplyLoanTitle;
  String get menuApplyLoanSubtitle;
  String get menuHistoryTitle;
  String get menuHistorySubtitle;
  String get menuBranchesTitle;
  String get menuBranchesSubtitle;
  String get menuNotificationsTitle;
  String get menuNotificationsSubtitle;

  // Loans & Schedule
  String get loansTitle;
  String get loanDetails;
  String get scheduleTitle;
  String get period;
  String get dueDate;
  String get principal;
  String get interest;
  String get insuranceFee;
  String get totalDue;
  String get statusPaid;
  String get statusPending;
  String get statusOverdue;

  // 5 FRD Debt Groups
  String get debtGroupCurrent;
  String get debtGroupSpecialMention;
  String get debtGroupSubstandard;
  String get debtGroupDoubtful;
  String get debtGroupLoss;

  // Payments & MMQR
  String get paymentTitle;
  String get scanMmqr;
  String get mmqrRepaymentTitle;
  String get generatingMmqr;
  String get openWallet;
  String get launchKbzPay;
  String get launchWavePay;
  String get launchAyaPay;
  String get launchMytelPay;
  String get saveQrImage;
  String get paymentSuccess;
  String get electronicReceipt;
  String get referenceNo;
  String get returnHome;
  String get backToHome;
  String get contractCodeLabel;
  String get transactionRefLabel;
  String get paymentChannelLabel;
  String get settledDateLabel;
  String get totalPaidAmountLabel;
  String get totalTransactionAmount;
  String get noMatchingTransactions;
  String get tryDifferentFilter;
  String get details;
  String get savingReceiptPdf;
  String get savePdf;
  String get sharingReceipt;
  String get share;
  String get filterAll;
  String get filterRepayment;
  String get filterSavings;
  String get filterInsurance;
  String get searchPlaceholder;
  String get allTime;
  String get thisMonth;
  String get last3Months;
  String get filterModalTitle;

  // Savings
  String get savingsTitle;
  String get savingsAndPassbooks;
  String get accruedInterest;
  String get openSavingOnline;
  String get openSavingsPassbookTitle;
  String get passbookOpenedSuccess;
  String get viewPassbooks;
  String get expectedProfitAtMaturity;
  String get confirmAndSubscribe;
  String get depositPrincipal;
  String get accruedProfitYield;
  String get compulsorySaving;
  String get voluntarySaving;
  String get fixedTermSaving;
  String get interestRatePerAnnum;

  // Insurance
  String get insuranceTitle;
  String get medicalBenefitTitle;
  String get medicalBenefitDesc;
  String get submitClaim;
  String get mutualAidClaimTitle;
  String get illnessRisk;
  String get accidentRisk;
  String get naturalDisasterRisk;
  String get uploadInvoices;
  String get attachMedicalDocument;
  String get documentAttachedSimulated;
  String get submitInsuranceClaim;
  String get claimFiledSuccess;
  String get claimSubmitted;

  // Notifications
  String get notificationsTitle;
  String get notificationCenterTitle;
  String get markAllRead;
  String get noNotifications;
  String get noNotificationsFound;

  // Fast Loan & Application
  String get applyLoanTitle;
  String get tabApplyLoan;
  String get tabTrackApplications;
  String get selectLoanPackage;
  String get loanAmountToBorrow;
  String get minAmountLabel;
  String get maxAmountLabel;
  String get loanTerm;
  String get repaymentFrequency;
  String get monthly;
  String get biweekly;
  String get weekly;
  String get estimatedMonthlyRepayment;
  String get monthlyPrincipal;
  String get monthlyInterest;
  String get welfareInsuranceFee;
  String get disbursementMethod;
  String get loanPurpose;
  String get loanPurposeHint;
  String get submitLoanApplication;
  String get applicationSubmittedSuccess;
  String get viewProgress;
  String get searchApplicationPlaceholder;
  String get appStatusUnderReview;
  String get appStatusApproved;
  String get appStatusDisbursed;
  String get appStatusRejected;
  String get noActiveLoansToRepay;
  String get selectLoanToRepay;
  String get monthsTerm;
  String get interestPerMonth;

  // Account Screen & Settings
  String get accountTitle;
  String get securityTitle;
  String get changePin;
  String get changePinSecurityTitle;
  String get currentPinLabel;
  String get newPinLabel;
  String get confirmNewPinLabel;
  String get pinChangedSuccess;
  String get biometricAuth;
  String get biometricSubtitle;
  String get deviceSecurity;
  String get deviceSecurityStatus;
  String get deviceSecurityPass;
  String get deviceSecurityDesc;
  String get utilitiesTitle;
  String get settingsAndPreferences;
  String get languageSettingTitle;
  String get dueReminderNotifications;
  String get dueReminderDesc;
  String get branchNetwork;
  String get supportHotline;
  String get termsAndPrivacy;
  String get appVersion;
  String get signOut;
  String get confirmSignOut;
  String get signOutConfirmTitle;
  String get signOutConfirmDesc;
}

class _CustomerLocalizationsDelegate extends LocalizationsDelegate<CustomerLocalizations> {
  const _CustomerLocalizationsDelegate();

  @override
  Future<CustomerLocalizations> load(Locale locale) {
    return SynchronousFuture<CustomerLocalizations>(lookupCustomerLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['my', 'en', 'vi', 'zh', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_CustomerLocalizationsDelegate old) => false;
}

CustomerLocalizations lookupCustomerLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'my':
      return CustomerLocalizationsMy();
    case 'en':
      return CustomerLocalizationsEn();
    case 'vi':
      return CustomerLocalizationsVi();
    case 'zh':
      return CustomerLocalizationsZh();
    case 'ja':
      return CustomerLocalizationsJa();
    case 'ko':
      return CustomerLocalizationsKo();
    default:
      return CustomerLocalizationsMy();
  }
}
