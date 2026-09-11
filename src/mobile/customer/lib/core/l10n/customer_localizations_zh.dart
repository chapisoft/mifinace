import 'customer_localizations.dart';

/// Chinese (`zh`) translations.
class CustomerLocalizationsZh extends CustomerLocalizations {
  CustomerLocalizationsZh([super.locale = 'zh']);

  @override
  String get appTitle => 'BMF 小额信贷';
  @override
  String get home => '首页';
  @override
  String get loans => '贷款';
  @override
  String get savings => '储蓄';
  @override
  String get insurance => '互助保险';
  @override
  String get notifications => '通知';

  @override
  String get loginTitle => '会员登录';
  @override
  String get phoneLabel => '手机号码';
  @override
  String get nrcLabel => '身份证号 (NRC)';
  @override
  String get requestOtp => '获取短信验证码';
  @override
  String get otpTitle => '验证短信验证码';
  @override
  String get verifyOtp => '验证';
  @override
  String get setPinTitle => '设置6位安全密码';
  @override
  String get confirmPinTitle => '再次确认6位密码';
  @override
  String get enterPinTitle => '输入您的安全密码';
  @override
  String get biometricLogin => '使用生物识别登录';
  @override
  String get pinMismatch => '两次输入的密码不一致';
  @override
  String get pinSuccess => '安全密码设置成功';

  @override
  String get welcomeMember => '欢迎光临';
  @override
  String get memberCode => '会员编号';
  @override
  String get groupCode => '联保小组编号';
  @override
  String get totalOutstanding => '待还本金总额';
  @override
  String get activeLoans => '当前借款';
  @override
  String get dueAlertTitle => '近期还款提醒';
  @override
  String get payNow => '立即还款';
  @override
  String get quickServices => '快捷服务';

  @override
  String get loansTitle => '贷款列表';
  @override
  String get loanDetails => '贷款详情';
  @override
  String get scheduleTitle => '分期还款计划';
  @override
  String get period => '期数';
  @override
  String get dueDate => '到期日';
  @override
  String get principal => '本金';
  @override
  String get interest => '利息';
  @override
  String get insuranceFee => '保险费';
  @override
  String get totalDue => '应还总额';
  @override
  String get statusPaid => '已结清';
  @override
  String get statusPending => '待还款';
  @override
  String get statusOverdue => '逾期';

  @override
  String get debtGroupCurrent => '正常类 (第1类)';
  @override
  String get debtGroupSpecialMention => '关注类 (第2类)';
  @override
  String get debtGroupSubstandard => '次级类 (第3类)';
  @override
  String get debtGroupDoubtful => '可疑类 (第4类)';
  @override
  String get debtGroupLoss => '损失类 (第5类)';

  @override
  String get paymentTitle => 'MMQR 数字支付';
  @override
  String get scanMmqr => '使用银行或钱包应用扫码';
  @override
  String get openWallet => '打开电子钱包';
  @override
  String get launchKbzPay => '使用 KBZPay 支付';
  @override
  String get launchWavePay => '使用 WavePay 支付';
  @override
  String get launchAyaPay => '使用 AYA Pay 支付';
  @override
  String get launchMytelPay => '使用 MytelPay 支付';
  @override
  String get saveQrImage => '保存二维码图片';
  @override
  String get paymentSuccess => '还款核销成功';
  @override
  String get electronicReceipt => '正式电子收据';
  @override
  String get referenceNo => '流水参考号';
  @override
  String get returnHome => '返回首页';

  @override
  String get savingsTitle => '储蓄账户';
  @override
  String get accruedInterest => '累计结息';
  @override
  String get openSavingOnline => '在线开设储蓄账户';
  @override
  String get compulsorySaving => '强制储蓄';
  @override
  String get voluntarySaving => '自愿储蓄';
  @override
  String get fixedTermSaving => '定期存款';
  @override
  String get interestRatePerAnnum => '年化利率';

  @override
  String get insuranceTitle => '会员互助互济基金';
  @override
  String get medicalBenefitTitle => '医疗住院津贴 (10,000 MMK/天)';
  @override
  String get medicalBenefitDesc => '全面的重大疾病和意外互助保障';
  @override
  String get submitClaim => '提交理赔申请';
  @override
  String get illnessRisk => '疾病住院';
  @override
  String get accidentRisk => '意外事故';
  @override
  String get naturalDisasterRisk => '自然灾害';
  @override
  String get uploadInvoices => '上传医疗发票和村长证明';
  @override
  String get claimSubmitted => '理赔申请已成功提交';

  @override
  String get notificationsTitle => '消息中心';
  @override
  String get markAllRead => '全部标为已读';
  @override
  String get noNotifications => '暂无新消息';
}
