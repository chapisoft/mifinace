import 'customer_localizations.dart';

/// Chinese (`zh`) translations.
class CustomerLocalizationsZh extends CustomerLocalizations {
  CustomerLocalizationsZh([super.locale = 'zh']);

  @override
  String get appTitle => 'BMF 小额信贷平台';
  @override
  String get home => '首页';
  @override
  String get loans => '贷款';
  @override
  String get savings => '储蓄';
  @override
  String get insurance => '互助基金';
  @override
  String get notifications => '通知';
  @override
  String get navHome => '首页';
  @override
  String get navLoans => '贷款';
  @override
  String get navScanQr => 'MMQR 支付';
  @override
  String get navHistory => '记录';
  @override
  String get navAccount => '账户';

  // Common Actions & Dialogs
  @override
  String get close => '关闭';
  @override
  String get cancel => '取消';
  @override
  String get confirm => '确认';
  @override
  String get done => '完成';
  @override
  String get save => '保存';
  @override
  String get retry => '重试';
  @override
  String get selectLanguage => '选择语言';
  @override
  String get version => '版本';
  @override
  String get viewAll => '查看全部';
  @override
  String get customize => '自定义';
  @override
  String get quickActions => '快捷功能';
  @override
  String get customizeQuickActions => '自定义快捷功能';
  @override
  String get customizeQuickActionsDesc => '选择常用功能以在首页显示：';
  @override
  String get saveChanges => '保存更改';
  @override
  String get maxShortcutsReached => '最多只能选择 4 个快捷功能';
  @override
  String get minShortcutsRequired => '请至少选择 1 个快捷功能';

  // Authentication
  @override
  String get loginTitle => '会员登录';
  @override
  String get phoneLabel => '手机号码';
  @override
  String get nrcLabel => '身份证号 (NRC)';
  @override
  String get memberIdOrPhoneOrNrc => '会员编号 / 手机 / NRC 证件号';
  @override
  String get continueButton => '继续';
  @override
  String get switchAccount => '切换账户';
  @override
  String get forgotPin => '忘记 PIN 码？';
  @override
  String get enter6DigitPin => '请输入 6 位安全 PIN 码';
  @override
  String get notActivatedPrompt => '账户尚未激活。是否立即发送 OTP 进行激活？';
  @override
  String get activateNow => '立即激活';
  @override
  String get welcomeBack => '欢迎回来';
  @override
  String get firstTimeUsingApp => '首次使用？';
  @override
  String get activateWithInfo => '使用会员编号、手机或 NRC 激活';
  @override
  String get splashTagline => '数字化普惠金融与会员银行服务';
  @override
  String get savedMemberAccount => '已保存的会员账户';
  @override
  String get requestOtp => '获取 OTP';
  @override
  String get otpTitle => '验证短信验证码';
  @override
  String get verifyOtp => '验证';
  @override
  String get setPinTitle => '设置 6 位 PIN 码';
  @override
  String get confirmPinTitle => '确认 6 位 PIN 码';
  @override
  String get enterPinTitle => '输入安全 PIN 码';
  @override
  String get biometricLogin => '生物识别登录';
  @override
  String get pinMismatch => '两次输入的 PIN 码不一致';
  @override
  String get pinSuccess => 'PIN 码设置成功';
  @override
  String get inputIdentifierRequired => '请输入会员编号、手机号码或 NRC。';

  // Dashboard & Member Profile
  @override
  String get welcomeMember => '欢迎';
  @override
  String get memberCode => '会员编号';
  @override
  String get groupCode => '组别代码';
  @override
  String get totalOutstanding => '剩余待还总额';
  @override
  String get activeLoans => '当前贷款';
  @override
  String get dueAlertTitle => '即将到期还款提示';
  @override
  String get payNow => '立即还款';
  @override
  String get quickServices => '快捷服务';
  @override
  String get digitalMemberCard => '电子会员卡';
  @override
  String get memberQrTitle => 'BMF 电子会员卡';
  @override
  String get centerLabel => '服务中心';
  @override
  String get groupLabel => '联保小组';
  @override
  String get meetingScheduleLabel => '例会时间';
  @override
  String get weeklyMeetingTime => '每周五 • 上午 09:00';
  @override
  String get assignedOfficerLabel => '信贷专员';
  @override
  String get noRecentTransactions => '暂无近期交易记录。';
  @override
  String get periodNumberLabel => '期数';

  // Overview Metrics & Status
  @override
  String get outstandingLoanMetric => '未还本金总额';
  @override
  String get dueMetric => '本期应还';
  @override
  String get totalSavingsMetric => '累计储蓄余额';
  @override
  String get loyaltyPointsMetric => '会员积分';
  @override
  String get memberActiveStatus => '正常履约中';

  // Home Menu Items
  @override
  String get menuMmqrTitle => 'MMQR 扫码还款';
  @override
  String get menuMmqrSubtitle => '国家级结算网关';
  @override
  String get menuLoansTitle => '贷款组合';
  @override
  String get menuLoansSubtitle => '还款计划明细';
  @override
  String get menuSavingsTitle => '储蓄账户';
  @override
  String get menuSavingsSubtitle => '存折与利息收益';
  @override
  String get menuInsuranceTitle => '互助基金';
  @override
  String get menuInsuranceSubtitle => '医疗与灾害救助';
  @override
  String get menuApplyLoanTitle => '快速贷款';
  @override
  String get menuApplyLoanSubtitle => '在线申请审核';
  @override
  String get menuHistoryTitle => '交易记录';
  @override
  String get menuHistorySubtitle => '查看电子回单';
  @override
  String get menuBranchesTitle => '服务网点';
  @override
  String get menuBranchesSubtitle => '查找最近营业点';
  @override
  String get menuNotificationsTitle => '系统通知';
  @override
  String get menuNotificationsSubtitle => '还款提醒通知';

  // Loans & Schedule
  @override
  String get loansTitle => '贷款列表';
  @override
  String get loanDetails => '贷款详情';
  @override
  String get scheduleTitle => '还款计划表';
  @override
  String get period => '期次';
  @override
  String get dueDate => '到期日';
  @override
  String get principal => '本金';
  @override
  String get interest => '利息';
  @override
  String get insuranceFee => '互助费';
  @override
  String get totalDue => '应还总额';
  @override
  String get statusPaid => '已还清';
  @override
  String get statusPending => '待还款';
  @override
  String get statusOverdue => '已逾期';

  // 5 FRD Debt Groups
  @override
  String get debtGroupCurrent => '第 1 类 - 正常类 (Current)';
  @override
  String get debtGroupSpecialMention => '第 2 类 - 关注类 (Special Mention)';
  @override
  String get debtGroupSubstandard => '第 3 类 - 次级类 (Substandard)';
  @override
  String get debtGroupDoubtful => '第 4 类 - 可疑类 (Doubtful)';
  @override
  String get debtGroupLoss => '第 5 类 - 损失类 (Loss)';

  // Payments & MMQR
  @override
  String get paymentTitle => 'MMQR 数字还款';
  @override
  String get scanMmqr => '扫描 MMQR 码';
  @override
  String get mmqrRepaymentTitle => 'MMQR 数字化还款';
  @override
  String get generatingMmqr => '正在生成 CBM 标准动态 MMQR 码...';
  @override
  String get openWallet => '使用电子钱包付款';
  @override
  String get launchKbzPay => '打开 KBZPay';
  @override
  String get launchWavePay => '打开 WavePay';
  @override
  String get launchAyaPay => '打开 AYA Pay';
  @override
  String get launchMytelPay => '打开 MytelPay';
  @override
  String get saveQrImage => '保存二维码图片';
  @override
  String get paymentSuccess => '还款成功！';
  @override
  String get electronicReceipt => '电子回单';
  @override
  String get referenceNo => '交易参考号';
  @override
  String get returnHome => '返回首页';
  @override
  String get backToHome => '返回首页';
  @override
  String get contractCodeLabel => '合同编号';
  @override
  String get transactionRefLabel => '交易流水号';
  @override
  String get paymentChannelLabel => '支付渠道';
  @override
  String get settledDateLabel => '结算日期';
  @override
  String get totalPaidAmountLabel => '实付总金额';
  @override
  String get totalTransactionAmount => '交易总金额';
  @override
  String get noMatchingTransactions => '未找到符合条件的交易记录';
  @override
  String get tryDifferentFilter => '请尝试更换时间范围或筛选类别';
  @override
  String get details => '详情';
  @override
  String get savingReceiptPdf => '正在保存回单 PDF 至设备...';
  @override
  String get savePdf => '保存 PDF';
  @override
  String get sharingReceipt => '正在生成分享链接...';
  @override
  String get share => '分享';
  @override
  String get filterAll => '全部';
  @override
  String get filterRepayment => '还款';
  @override
  String get filterSavings => '储蓄';
  @override
  String get filterInsurance => '保险费';
  @override
  String get searchPlaceholder => '按交易流水号、合同号搜索...';
  @override
  String get allTime => '全部时间';
  @override
  String get thisMonth => '本月';
  @override
  String get last3Months => '近 3 个月';
  @override
  String get filterModalTitle => '交易筛选';

  // Savings
  @override
  String get savingsTitle => '储蓄与存折';
  @override
  String get savingsAndPassbooks => '储蓄与定活期存折';
  @override
  String get accruedInterest => '累计利息收益';
  @override
  String get openSavingOnline => '在线认购储蓄存折';
  @override
  String get openSavingsPassbookTitle => '认购高收益储蓄存折';
  @override
  String get passbookOpenedSuccess => '存折开户成功！';
  @override
  String get viewPassbooks => '查看存折列表';
  @override
  String get expectedProfitAtMaturity => '到期预期收益:';
  @override
  String get confirmAndSubscribe => '确认并开通存折';
  @override
  String get depositPrincipal => '存款本金';
  @override
  String get accruedProfitYield => '累计派息收益';
  @override
  String get compulsorySaving => '组别法定强制储蓄';
  @override
  String get voluntarySaving => '灵活自愿储蓄';
  @override
  String get fixedTermSaving => '定期高息存单';
  @override
  String get interestRatePerAnnum => '年化收益率';

  // Insurance
  @override
  String get insuranceTitle => '会员互助互济基金';
  @override
  String get medicalBenefitTitle => '医疗救助与防灾补偿';
  @override
  String get medicalBenefitDesc => '紧急住院与意外灾害纾困补偿金';
  @override
  String get submitClaim => '提交理赔申请';
  @override
  String get mutualAidClaimTitle => '互助理赔救助申请';
  @override
  String get illnessRisk => '疾病住院治疗';
  @override
  String get accidentRisk => '意外伤害事故';
  @override
  String get naturalDisasterRisk => '风暴洪涝灾害';
  @override
  String get uploadInvoices => '上传出院小结或医疗发票凭证';
  @override
  String get attachMedicalDocument => '附上医疗诊断证明';
  @override
  String get documentAttachedSimulated => '已附 1 份证明材料';
  @override
  String get submitInsuranceClaim => '提交理赔申请书';
  @override
  String get claimFiledSuccess => '理赔申请已成功受理';
  @override
  String get claimSubmitted => '申请已提交';

  // Notifications
  @override
  String get notificationsTitle => '消息通知';
  @override
  String get notificationCenterTitle => '消息中心';
  @override
  String get markAllRead => '全部标为已读';
  @override
  String get noNotifications => '暂无新通知';
  @override
  String get noNotificationsFound => '暂无历史通知记录';

  // Fast Loan & Application
  @override
  String get applyLoanTitle => '快速贷款申请';
  @override
  String get tabApplyLoan => '申请贷款';
  @override
  String get tabTrackApplications => '我的申请';
  @override
  String get selectLoanPackage => '选择贷款方案';
  @override
  String get loanAmountToBorrow => '借款金额';
  @override
  String get minAmountLabel => '最低';
  @override
  String get maxAmountLabel => '最高';
  @override
  String get loanTerm => '贷款期限';
  @override
  String get repaymentFrequency => '还款频率';
  @override
  String get monthly => '每月';
  @override
  String get biweekly => '每两周';
  @override
  String get weekly => '每周';
  @override
  String get estimatedMonthlyRepayment => '预计每月还款';
  @override
  String get monthlyPrincipal => '每月本金';
  @override
  String get monthlyInterest => '每月利息';
  @override
  String get welfareInsuranceFee => '福利保险费 (0.5%)';
  @override
  String get disbursementMethod => '放款方式';
  @override
  String get loanPurpose => '具体贷款用途';
  @override
  String get loanPurposeHint => '例如：采购化肥农资、补充商品库存...';
  @override
  String get submitLoanApplication => '立即提交贷款申请';
  @override
  String get applicationSubmittedSuccess => '申请提交成功';
  @override
  String get viewProgress => '查看进度';
  @override
  String get searchApplicationPlaceholder => '搜索申请编号或产品...';
  @override
  String get appStatusUnderReview => '审核中';
  @override
  String get appStatusApproved => '已批准';
  @override
  String get appStatusDisbursed => '已放款';
  @override
  String get appStatusRejected => '已拒绝';
  @override
  String get noActiveLoansToRepay => '当前无待还贷款';
  @override
  String get selectLoanToRepay => '选择需还款的贷款';
  @override
  String get monthsTerm => '个月';
  @override
  String get interestPerMonth => '月';

  // Account Screen & Settings
  @override
  String get accountTitle => '账户与安全';
  @override
  String get securityTitle => '安全设置与身份认证';
  @override
  String get changePin => '修改 PIN 码';
  @override
  String get changePinSecurityTitle => '修改安全交易 PIN 码';
  @override
  String get currentPinLabel => '当前 PIN 码';
  @override
  String get newPinLabel => '新 6 位 PIN 码';
  @override
  String get confirmNewPinLabel => '确认新 6 位 PIN 码';
  @override
  String get pinChangedSuccess => 'PIN 码修改成功';
  @override
  String get biometricAuth => '生物识别认证';
  @override
  String get biometricSubtitle => '开启面容/指纹快速登录';
  @override
  String get deviceSecurity => '设备安全状态';
  @override
  String get deviceSecurityStatus => '设备运行安全检测';
  @override
  String get deviceSecurityPass => '通过';
  @override
  String get deviceSecurityDesc => 'SSL Pinning 与防篡改机制已生效';
  @override
  String get utilitiesTitle => '服务与客户支持';
  @override
  String get settingsAndPreferences => '系统设置与首选项';
  @override
  String get languageSettingTitle => '显示语言';
  @override
  String get dueReminderNotifications => '还款到期提醒';
  @override
  String get dueReminderDesc => '还款日前 3 天自动推送提醒';
  @override
  String get branchNetwork => '服务网点分布';
  @override
  String get supportHotline => '会员专属服务热线';
  @override
  String get termsAndPrivacy => '信贷规程与隐私政策';
  @override
  String get appVersion => '应用版本';
  @override
  String get signOut => '退出登录';
  @override
  String get confirmSignOut => '确认退出会员平台？';
  @override
  String get signOutConfirmTitle => '退出当前账户';
  @override
  String get signOutConfirmDesc => '您确定要退出 BMF 会员门户平台吗？';
}
