import 'customer_localizations.dart';

/// Myanmar (`my`) translations using Pyidaungsu Unicode font.
class CustomerLocalizationsMy extends CustomerLocalizations {
  CustomerLocalizationsMy([super.locale = 'my']);

  @override
  String get appTitle => 'BMF အသေးစားငွေရေး';
  @override
  String get home => 'ပင်မစာမျက်နှာ';
  @override
  String get loans => 'ချေးငွေများ';
  @override
  String get savings => 'စုဆောင်းငွေ';
  @override
  String get insurance => 'အာမခံ';
  @override
  String get notifications => 'အသိပေးချက်များ';
  @override
  String get navHome => 'ပင်မ';
  @override
  String get navLoans => 'ချေးငွေ';
  @override
  String get navScanQr => 'MMQR ပေးချေ';
  @override
  String get navHistory => 'မှတ်တမ်း';
  @override
  String get navAccount => 'အကောင့်';

  // Common Actions & Dialogs
  @override
  String get close => 'ပိတ်မည်';
  @override
  String get cancel => 'မလုပ်တော့ပါ';
  @override
  String get confirm => 'အတည်ပြုသည်';
  @override
  String get done => 'ပြီးပါပြီ';
  @override
  String get save => 'သိမ်းမည်';
  @override
  String get retry => 'ထပ်ကြိုးစားမည်';
  @override
  String get selectLanguage => 'ဘာသာစကား ရွေးချယ်ပါ';
  @override
  String get version => 'ဗားရှင်း';
  @override
  String get viewAll => 'အားလုံးကြည့်မည်';
  @override
  String get customize => 'ပြင်ဆင်မည်';
  @override
  String get quickActions => 'အမြန်လုပ်ဆောင်ချက်များ';
  @override
  String get customizeQuickActions => 'အမြန်လုပ်ဆောင်ချက်များ ပြင်ဆင်မည်';
  @override
  String get customizeQuickActionsDesc => 'ပင်မစာမျက်နှာတွင် ဖော်ပြရန် မကြာခဏ အသုံးပြုသော လုပ်ဆောင်ချက်များကို ရွေးချယ်ပါ:';
  @override
  String get saveChanges => 'အပြောင်းအလဲများကို သိမ်းမည်';
  @override
  String get maxShortcutsReached => 'အများဆုံး ၄ ခုသာ ရွေးချယ်နိုင်ပါသည်';
  @override
  String get minShortcutsRequired => 'အနည်းဆုံး ၁ ခု ရွေးချယ်ပါ';

  // Authentication
  @override
  String get loginTitle => 'အသင်းဝင်အကောင့်ဝင်ရန်';
  @override
  String get phoneLabel => 'ဖုန်းနံပါတ်';
  @override
  String get nrcLabel => 'မှတ်ပုံတင်အမှတ်';
  @override
  String get memberIdOrPhoneOrNrc => 'အသင်းဝင်အမှတ် / ဖုန်း / မှတ်ပုံတင်';
  @override
  String get continueButton => 'ဆက်လက်လုပ်ဆောင်ရန်';
  @override
  String get switchAccount => 'အကောင့်ပြောင်းရန်';
  @override
  String get forgotPin => 'PIN မေ့နေပါသလား?';
  @override
  String get enter6DigitPin => 'လုံခြုံရေး PIN ၆ လုံး ရိုက်ထည့်ပါ';
  @override
  String get notActivatedPrompt => 'အကောင့်ကို မဖွင့်ရသေးပါ။ ယခု OTP ဖြင့် စတင်ဖွင့်လှစ်လိုပါသလား?';
  @override
  String get activateNow => 'ယခုစတင်ဖွင့်ပါ';
  @override
  String get welcomeBack => 'ပြန်လည်ကြိုဆိုပါသည်';
  @override
  String get firstTimeUsingApp => 'အကောင့်ဖွင့်ရန် လိုအပ်ပါသလား?';
  @override
  String get activateWithInfo => 'အသင်းဝင်အမှတ် သို့မဟုတ် မှတ်ပုံတင်ဖြင့် ဖွင့်လှစ်ပါ';
  @override
  String get splashTagline => 'ဒစ်ဂျစ်တယ် အသေးစားချေးငွေနှင့် ငွေစုဝန်ဆောင်မှု';
  @override
  String get savedMemberAccount => 'မှတ်သားထားသော အသင်းဝင်အကောင့်';
  @override
  String get requestOtp => 'OTP ရယူရန်';
  @override
  String get otpTitle => 'SMS ကုဒ်အတည်ပြုရန်';
  @override
  String get verifyOtp => 'အတည်ပြုပါ';
  @override
  String get setPinTitle => 'PIN နံပါတ် ၆ လုံးသတ်မှတ်ပါ';
  @override
  String get confirmPinTitle => 'PIN နံပါတ်ထပ်မံရိုက်ထည့်ပါ';
  @override
  String get enterPinTitle => 'PIN နံပါတ်ရိုက်ထည့်ပါ';
  @override
  String get biometricLogin => 'လက်ဗွေဖြင့်အကောင့်ဝင်ရန်';
  @override
  String get pinMismatch => 'PIN နံပါတ်မကိုက်ညီပါ';
  @override
  String get pinSuccess => 'PIN နံပါတ်သတ်မှတ်ပြီးပါပြီ';
  @override
  String get inputIdentifierRequired => 'ကျေးဇူးပြု၍ အသင်းဝင်အမှတ်၊ ဖုန်း သို့မဟုတ် မှတ်ပုံတင် ရိုက်ထည့်ပါ။';

  // Dashboard & Member Profile
  @override
  String get welcomeMember => 'ကြိုဆိုပါသည်';
  @override
  String get memberCode => 'အသင်းဝင်အမှတ်';
  @override
  String get groupCode => 'အဖွဲ့အမှတ်';
  @override
  String get totalOutstanding => 'စုစုပေါင်းလက်ကျန်ငွေ';
  @override
  String get activeLoans => 'လက်ရှိချေးငွေ';
  @override
  String get dueAlertTitle => 'ပေးသွင်းရန်ရက်နီးကပ်နေသောချေးငွေ';
  @override
  String get payNow => 'ယခုပေးချေမည်';
  @override
  String get quickServices => 'အမြန်ဝန်ဆောင်မှုများ';
  @override
  String get digitalMemberCard => 'ဒစ်ဂျစ်တယ် အသင်းဝင်ကတ်';
  @override
  String get memberQrTitle => 'BMF ဒစ်ဂျစ်တယ် အသင်းဝင်ကတ်';
  @override
  String get centerLabel => 'စင်တာ အမည်';
  @override
  String get groupLabel => 'စည်းလုံးညီညွတ်ရေး အဖွဲ့';
  @override
  String get meetingScheduleLabel => 'အစည်းအဝေး အချိန်ဇယား';
  @override
  String get weeklyMeetingTime => 'အပတ်စဉ် သောကြာနေ့ • နံနက် ၀၉:၀၀';
  @override
  String get assignedOfficerLabel => 'တာဝန်ခံ အရာရှိ';
  @override
  String get noRecentTransactions => 'လတ်တလော ငွေပေးငွေယူမှတ်တမ်း မရှိသေးပါ။';
  @override
  String get periodNumberLabel => 'အရစ်';

  // Overview Metrics & Status
  @override
  String get outstandingLoanMetric => 'လက်ကျန်ချေးငွေ စုစုပေါင်း';
  @override
  String get dueMetric => 'ပေးသွင်းရန်ငွေ';
  @override
  String get totalSavingsMetric => 'စုဆောင်းငွေ စုစုပေါင်း';
  @override
  String get loyaltyPointsMetric => 'ရမှတ်များ';
  @override
  String get memberActiveStatus => 'အသင်းဝင်အခြေအနေကောင်း';

  // Home Menu Items
  @override
  String get menuMmqrTitle => 'MMQR ပေးချေ';
  @override
  String get menuMmqrSubtitle => 'အမျိုးသားစနစ်ဖြင့် ပေးချေမည်';
  @override
  String get menuLoansTitle => 'ချေးငွေစာရင်း';
  @override
  String get menuLoansSubtitle => 'ဆပ်ရန်စာရင်း အသေးစိတ်';
  @override
  String get menuSavingsTitle => 'စုဆောင်းငွေ';
  @override
  String get menuSavingsSubtitle => 'အပ်ငွေစာအုပ်နှင့် အတိုး';
  @override
  String get menuInsuranceTitle => 'ရံပုံငွေ အာမခံ';
  @override
  String get menuInsuranceSubtitle => 'ကျန်းမာရေး အထောက်အပံ့';
  @override
  String get menuApplyLoanTitle => 'အမြန်ချေးငွေ';
  @override
  String get menuApplyLoanSubtitle => 'အွန်လိုင်းမှ လျှောက်ထားမည်';
  @override
  String get menuHistoryTitle => 'ငွေပေးချေမှတ်တမ်း';
  @override
  String get menuHistorySubtitle => 'ပြေစာအားလုံး ကြည့်မည်';
  @override
  String get menuBranchesTitle => 'ရုံးခွဲများ';
  @override
  String get menuBranchesSubtitle => 'အနီးဆုံး ဝန်ဆောင်မှုနေရာများ';
  @override
  String get menuNotificationsTitle => 'အသိပေးချက်များ';
  @override
  String get menuNotificationsSubtitle => 'အရစ်ကျပေးသွင်းရန် သတိပေးချက်';

  // Loans & Schedule
  @override
  String get loansTitle => 'ချေးငွေစာရင်း';
  @override
  String get loanDetails => 'ချေးငွေအသေးစိတ်';
  @override
  String get scheduleTitle => 'အရစ်ကျပေးဆပ်မှုအချိန်ဇယား';
  @override
  String get period => 'အရစ်';
  @override
  String get dueDate => 'ပေးသွင်းရန်ရက်စွဲ';
  @override
  String get principal => 'အရင်းငွေ';
  @override
  String get interest => 'အတိုးနှုန်း';
  @override
  String get insuranceFee => 'အာမခံကြေး';
  @override
  String get totalDue => 'စုစုပေါင်းပေးသွင်းငွေ';
  @override
  String get statusPaid => 'ပေးသွင်းပြီး';
  @override
  String get statusPending => 'ပေးရန်ကျန်';
  @override
  String get statusOverdue => 'ရက်လွန်နေသည်';

  // 5 FRD Debt Groups
  @override
  String get debtGroupCurrent => 'ပုံမှန် (Group 1 - Current)';
  @override
  String get debtGroupSpecialMention => 'စောင့်ကြည့် (Group 2 - Special Mention)';
  @override
  String get debtGroupSubstandard => 'အောက်အဆင့် (Group 3 - Substandard)';
  @override
  String get debtGroupDoubtful => 'သံသယဖြစ်ဖွယ် (Group 4 - Doubtful)';
  @override
  String get debtGroupLoss => 'ဆုံးရှုံးနိုင်ခြေ (Group 5 - Loss)';

  // Payments & MMQR
  @override
  String get paymentTitle => 'ဒစ်ဂျစ်တယ် MMQR ဖြင့် ပေးချေရန်';
  @override
  String get scanMmqr => 'MMQR စကန်ဖတ်ပါ';
  @override
  String get mmqrRepaymentTitle => 'MMQR ဒစ်ဂျစ်တယ် ချေးငွေပေးဆပ်မှု';
  @override
  String get generatingMmqr => 'CBM စံသတ်မှတ်ချက် dynamic MMQR ဖန်တီးနေသည်...';
  @override
  String get openWallet => 'မိုဘိုင်းပိုက်ဆံအိတ်ဖြင့် ပေးချေမည်';
  @override
  String get launchKbzPay => 'KBZPay ဖွင့်မည်';
  @override
  String get launchWavePay => 'WavePay ဖွင့်မည်';
  @override
  String get launchAyaPay => 'AYA Pay ဖွင့်မည်';
  @override
  String get launchMytelPay => 'MytelPay ဖွင့်မည်';
  @override
  String get saveQrImage => 'QR ပုံကို သိမ်းဆည်းမည်';
  @override
  String get paymentSuccess => 'ငွေပေးချေမှု အောင်မြင်ပါသည်!';
  @override
  String get electronicReceipt => 'အီလက်ထရွန်းနစ် ပြေစာ';
  @override
  String get referenceNo => 'လုပ်ငန်းစဉ်အမှတ်';
  @override
  String get returnHome => 'ပင်မစာမျက်နှာသို့ ပြန်သွားမည်';
  @override
  String get backToHome => 'ပင်မစာမျက်နှာသို့ ပြန်သွားမည်';
  @override
  String get contractCodeLabel => 'စာချုပ်အမှတ်';
  @override
  String get transactionRefLabel => 'လုပ်ငန်းစဉ်အမှတ်';
  @override
  String get paymentChannelLabel => 'ပေးချေသည့်လမ်းကြောင်း';
  @override
  String get settledDateLabel => 'ပေးသွင်းသည့်ရက်စွဲ';
  @override
  String get totalPaidAmountLabel => 'စုစုပေါင်းပေးချေငွေ';
  @override
  String get totalTransactionAmount => 'စုစုပေါင်း ငွေပေးငွေယူပမာဏ';
  @override
  String get noMatchingTransactions => 'ကိုက်ညီသော ငွေပေးငွေယူမှတ်တမ်း မရှိပါ';
  @override
  String get tryDifferentFilter => 'အခြားအချိန်အပိုင်းအခြား သို့မဟုတ် အမျိုးအစားကို ရွေးချယ်ကြည့်ပါ';
  @override
  String get details => 'အသေးစိတ်';
  @override
  String get savingReceiptPdf => 'ပြေစာ PDF အား ဖုန်းထဲသို့ သိမ်းဆည်းနေပါသည်...';
  @override
  String get savePdf => 'PDF သိမ်းမည်';
  @override
  String get sharingReceipt => 'ပြေစာလင့်ခ် ဖန်တီးနေပါသည်...';
  @override
  String get share => 'မျှဝေမည်';
  @override
  String get filterAll => 'အားလုံး';
  @override
  String get filterRepayment => 'ချေးငွေဆပ်';
  @override
  String get filterSavings => 'စုငွေ';
  @override
  String get filterInsurance => 'အာမခံကြေး';
  @override
  String get searchPlaceholder => 'ငွေလွှဲအမှတ်၊ စာချုပ်နံပါတ်ဖြင့် ရှာဖွေပါ...';
  @override
  String get allTime => 'အချိန်အားလုံး';
  @override
  String get thisMonth => 'ယခုလ';
  @override
  String get last3Months => 'လွန်ခဲ့သော ၃ လ';
  @override
  String get filterModalTitle => 'ငွေပေးငွေယူ စစ်ထုတ်ရန်';

  // Savings
  @override
  String get savingsTitle => 'စုဆောင်းငွေနှင့် အပ်ငွေစာအုပ်';
  @override
  String get savingsAndPassbooks => 'စုဆောင်းငွေနှင့် အပ်ငွေစာအုပ်များ';
  @override
  String get accruedInterest => 'ရရှိပြီးအတိုးစုစုပေါင်း';
  @override
  String get openSavingOnline => 'အွန်လိုင်းမှ စုဆောင်းငွေစာအုပ် ဖွင့်မည်';
  @override
  String get openSavingsPassbookTitle => 'အတိုးနှုန်းမြင့် အပ်ငွေစာအုပ် ဖွင့်မည်';
  @override
  String get passbookOpenedSuccess => 'အပ်ငွေစာအုပ် ဖွင့်လှစ်ပြီးပါပြီ!';
  @override
  String get viewPassbooks => 'အပ်ငွေစာအုပ်များ ကြည့်မည်';
  @override
  String get expectedProfitAtMaturity => 'ကာလပြည့်မြောက်ချိန်တွင် ရရှိမည့် အမြတ်ငွေ:';
  @override
  String get confirmAndSubscribe => 'အတည်ပြု၍ စာအုပ်ဖွင့်မည်';
  @override
  String get depositPrincipal => 'အပ်နှံငွေအရင်း';
  @override
  String get accruedProfitYield => 'စုဆောင်းရရှိသော အမြတ်ငွေ';
  @override
  String get compulsorySaving => 'မဖြစ်မနေ စုဆောင်းငွေ';
  @override
  String get voluntarySaving => 'မိမိဆန္ဒအလျောက် စုဆောင်းငွေ';
  @override
  String get fixedTermSaving => 'ကာလသတ်မှတ် စုဆောင်းငွေ';
  @override
  String get interestRatePerAnnum => 'နှစ်စဉ်အတိုးနှုန်း';

  // Insurance
  @override
  String get insuranceTitle => 'အပြန်အလှန် အထောက်အကူပြု ရံပုံငွေ';
  @override
  String get medicalBenefitTitle => 'ကျန်းမာရေးနှင့် သဘာဝဘေး အကျိုးခံစားခွင့်';
  @override
  String get medicalBenefitDesc => 'ဆေးရုံတက်စရိတ်နှင့် သဘာဝဘေးအန္တရာယ် ထောက်ပံ့ကြေး';
  @override
  String get submitClaim => 'တောင်းခံလွှာ တင်သွင်းမည်';
  @override
  String get mutualAidClaimTitle => 'အပြန်အလှန်ကူညီရေး ရံပုံငွေတောင်းခံလွှာ';
  @override
  String get illnessRisk => 'နာမကျန်းဖြစ်ခြင်းနှင့် ဆေးရုံတက်ခြင်း';
  @override
  String get accidentRisk => 'မတော်တဆ ထိခိုက်ဒဏ်ရာရခြင်း';
  @override
  String get naturalDisasterRisk => 'မုန်တိုင်း၊ ရေကြီးနှင့် သဘာဝဘေး';
  @override
  String get uploadInvoices => 'ဆေးရုံဆင်းလက်မှတ် သို့မဟုတ် ဆေးစာရွက် ပူးတွဲပါ';
  @override
  String get attachMedicalDocument => 'ဆေးရုံဆေးခန်း အထောက်အထား ပူးတွဲပါ';
  @override
  String get documentAttachedSimulated => 'အထောက်အထား ၁ စောင် ထည့်သွင်းပြီးပါပြီ';
  @override
  String get submitInsuranceClaim => 'အာမခံ တောင်းခံလွှာ ပေးပို့မည်';
  @override
  String get claimFiledSuccess => 'တောင်းခံလွှာ တင်သွင်းမှု အောင်မြင်ပါသည်';
  @override
  String get claimSubmitted => 'တောင်းခံလွှာ ပေးပို့ပြီးပါပြီ';

  // Notifications
  @override
  String get notificationsTitle => 'အသိပေးချက်များ';
  @override
  String get notificationCenterTitle => 'အသိပေးချက် စင်တာ';
  @override
  String get markAllRead => 'အားလုံး ဖတ်ပြီးအဖြစ် သတ်မှတ်မည်';
  @override
  String get noNotifications => 'အသိပေးချက် အသစ် မရှိပါ';
  @override
  String get noNotificationsFound => 'အသိပေးချက် မှတ်တမ်း မရှိသေးပါ';

  // Fast Loan & Application
  @override
  String get applyLoanTitle => 'အမြန်ချေးငွေ လျှောက်ထားခြင်း';
  @override
  String get tabApplyLoan => 'ချေးငွေလျှောက်ထားရန်';
  @override
  String get tabTrackApplications => 'လျှောက်ထားမှု မှတ်တမ်း';
  @override
  String get selectLoanPackage => 'ချေးငွေအမျိုးအစား ရွေးချယ်ပါ';
  @override
  String get loanAmountToBorrow => 'ချေးငွေပမာဏ';
  @override
  String get minAmountLabel => 'အနည်းဆုံး';
  @override
  String get maxAmountLabel => 'အများဆုံး';
  @override
  String get loanTerm => 'ချေးငွေကာလ';
  @override
  String get repaymentFrequency => 'ပြန်ဆပ်မည့် အကြိမ်ရေ';
  @override
  String get monthly => 'လစဉ်';
  @override
  String get biweekly => '၂ ပတ်တစ်ကြိမ်';
  @override
  String get weekly => 'အပတ်စဉ်';
  @override
  String get estimatedMonthlyRepayment => 'လစဉ် ခန့်မှန်းပေးဆပ်ငွေ';
  @override
  String get monthlyPrincipal => 'လစဉ်အရင်း';
  @override
  String get monthlyInterest => 'လစဉ်အတိုး';
  @override
  String get welfareInsuranceFee => 'လူမှုဖူလုံရေး အာမခံကြေး (၀.၅%)';
  @override
  String get disbursementMethod => 'ငွေထုတ်ယူမည့် နည်းလမ်း';
  @override
  String get loanPurpose => 'ချေးငွေအသုံးပြုမည့် ရည်ရွယ်ချက်';
  @override
  String get loanPurposeHint => 'ဥပမာ - မြေဩဇာဝယ်ယူရန်၊ ကုန်ပစ္စည်းဖြည့်ရန်...';
  @override
  String get submitLoanApplication => 'ချေးငွေလျှောက်လွှာ တင်သွင်းရန်';
  @override
  String get applicationSubmittedSuccess => 'လျှောက်ထားမှု အောင်မြင်ပါသည်';
  @override
  String get viewProgress => 'လုပ်ငန်းစဉ် ကြည့်ရန်';
  @override
  String get searchApplicationPlaceholder => 'လျှောက်လွှာနံပါတ်ဖြင့် ရှာဖွေပါ...';
  @override
  String get appStatusUnderReview => 'စိစစ်ဆဲ';
  @override
  String get appStatusApproved => 'အတည်ပြုပြီး';
  @override
  String get appStatusDisbursed => 'ထုတ်ပေးပြီး';
  @override
  String get appStatusRejected => 'ငြင်းပယ်သည်';
  @override
  String get noActiveLoansToRepay => 'ပေးဆပ်ရန် ချေးငွေမရှိသေးပါ';
  @override
  String get selectLoanToRepay => 'ပေးဆပ်မည့် ချေးငွေကို ရွေးချယ်ပါ';
  @override
  String get monthsTerm => 'လ';
  @override
  String get interestPerMonth => 'လ';

  // Account Screen & Settings
  @override
  String get accountTitle => 'အကောင့်နှင့် လုံခြုံရေး';
  @override
  String get securityTitle => 'လုံခြုံရေးနှင့် စစ်မှန်ကြောင်း အတည်ပြုခြင်း';
  @override
  String get changePin => 'လုံခြုံရေး PIN ပြောင်းမည်';
  @override
  String get changePinSecurityTitle => 'လုံခြုံရေး PIN နံပါတ် အသစ်ပြောင်းမည်';
  @override
  String get currentPinLabel => 'လက်ရှိ PIN နံပါတ်';
  @override
  String get newPinLabel => 'PIN နံပါတ် အသစ် ၆ လုံး';
  @override
  String get confirmNewPinLabel => 'PIN နံပါတ် အသစ် ထပ်မံရိုက်ထည့်ပါ';
  @override
  String get pinChangedSuccess => 'PIN နံပါတ် အောင်မြင်စွာ ပြောင်းလဲပြီးပါပြီ';
  @override
  String get biometricAuth => 'လက်ဗွေ / မျက်နှာဖြင့် စစ်ဆေးခြင်း';
  @override
  String get biometricSubtitle => 'FaceID နှင့် လက်ဗွေဖြင့် အမြန်ဝင်မည်';
  @override
  String get deviceSecurity => 'စက်ပစ္စည်း လုံခြုံရေး အခြေအနေ';
  @override
  String get deviceSecurityStatus => 'စက်ပစ္စည်း လုံခြုံရေး စစ်ဆေးချက်';
  @override
  String get deviceSecurityPass => 'အောင်မြင်';
  @override
  String get deviceSecurityDesc => 'SSL Pinning နှင့် Anti-Tamper: စံသတ်မှတ်ချက် ပြည့်မီပါသည်';
  @override
  String get utilitiesTitle => 'အထောက်အကူပြုနှင့် ဝန်ဆောင်မှုဌာနများ';
  @override
  String get settingsAndPreferences => 'ဆက်တင်များနှင့် စိတ်ကြိုက်ရွေးချယ်မှုများ';
  @override
  String get languageSettingTitle => 'ဘာသာစကား';
  @override
  String get dueReminderNotifications => 'အရစ်ကျပေးသွင်းရန် သတိပေးချက်များ';
  @override
  String get dueReminderDesc => 'ရက်မတိုင်မီ ၃ ရက် ကြိုတင်အသိပေးချက်';
  @override
  String get branchNetwork => 'ရုံးခွဲကွန်ရက်နှင့် အချက်အလက်များ';
  @override
  String get supportHotline => 'အသင်းဝင် ဝန်ဆောင်မှု ဟော့လိုင်း';
  @override
  String get termsAndPrivacy => 'ချေးငွေစည်းမျဉ်းနှင့် ကိုယ်ရေးကိုယ်တာ မူဝါဒ';
  @override
  String get appVersion => 'အက်ပ် ဗားရှင်း';
  @override
  String get signOut => 'အကောင့်မှ ထွက်မည်';
  @override
  String get confirmSignOut => 'အသင်းဝင် ပေါ်တယ်မှ ထွက်ရန် သေချာပါသလား?';
  @override
  String get signOutConfirmTitle => 'အကောင့်မှ ထွက်မည်';
  @override
  String get signOutConfirmDesc => 'BMF အသင်းဝင် ပေါ်တယ်မှ အကောင့်ထွက်ရန် သေချာပါသလား?';
}
