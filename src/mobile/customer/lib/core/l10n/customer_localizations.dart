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

  // Authentication
  String get loginTitle;
  String get phoneLabel;
  String get nrcLabel;
  String get requestOtp;
  String get otpTitle;
  String get verifyOtp;
  String get setPinTitle;
  String get confirmPinTitle;
  String get enterPinTitle;
  String get biometricLogin;
  String get pinMismatch;
  String get pinSuccess;

  // Dashboard
  String get welcomeMember;
  String get memberCode;
  String get groupCode;
  String get totalOutstanding;
  String get activeLoans;
  String get dueAlertTitle;
  String get payNow;
  String get quickServices;

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

  // Savings
  String get savingsTitle;
  String get accruedInterest;
  String get openSavingOnline;
  String get compulsorySaving;
  String get voluntarySaving;
  String get fixedTermSaving;
  String get interestRatePerAnnum;

  // Insurance
  String get insuranceTitle;
  String get medicalBenefitTitle;
  String get medicalBenefitDesc;
  String get submitClaim;
  String get illnessRisk;
  String get accidentRisk;
  String get naturalDisasterRisk;
  String get uploadInvoices;
  String get claimSubmitted;

  // Notifications
  String get notificationsTitle;
  String get markAllRead;
  String get noNotifications;
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
