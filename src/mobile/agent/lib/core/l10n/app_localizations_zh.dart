// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'BMF 代理';

  @override
  String get loginTitle => 'BMF 代理商登录';

  @override
  String get loginSubtitle => 'BMF 授权代理与网点服务生态';

  @override
  String get agentAuthHeader => '代理商账户认证';

  @override
  String get agentAuthDesc => '请输入代理商账户信息以访问代收与业务系统。';

  @override
  String get usernameLabel => '代理商用户名 / 编号';

  @override
  String get passwordLabel => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get biometricLogin => '生物识别登录';

  @override
  String get loginValidationEmpty => '请输入代理商用户名和密码。';

  @override
  String get selectLanguageTitle => '选择显示语言';

  @override
  String get securityBadgeFooter => '受 BMF SSL Pinning 与硬件安全 KeyStore 保护';

  @override
  String get dashboardTitle => '代理商运营控制台';

  @override
  String get centersTitle => '中心与组别';

  @override
  String get collectionSheetTitle => '收款清单';

  @override
  String get offlineSyncTitle => '离线同步';

  @override
  String get todayTarget => '今日目标';

  @override
  String get progressCompleted => '已完成';

  @override
  String get collectedAmount => '已收金额';

  @override
  String get remainingAmount => '剩余金额';

  @override
  String get memberCount => '成员人数';

  @override
  String get collectPayment => '收款';

  @override
  String get printReceipt => '打印收据';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncPending => '等待同步';

  @override
  String get syncSuccess => '数据同步成功';

  @override
  String get networkOnline => '在线';

  @override
  String get networkOffline => '离线（本地存储）';

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
  String get searchCenterHint => '搜索中心名称或代码';

  @override
  String get meetingDayLabel => '会议日';

  @override
  String get meetingTimeLabel => '会议时间';

  @override
  String get townshipLabel => '镇区';

  @override
  String get groupCountLabel => '组数';

  @override
  String get selectCenterPrompt => '选择中心以查看收款清单';

  @override
  String get noCentersMatch => '未找到匹配的中心';

  @override
  String get filterAll => '全部';

  @override
  String get filterDueToday => '今日到期';

  @override
  String get filterOverdue => '逾期';

  @override
  String get filterPaid => '已付';

  @override
  String get contractCodeLabel => '合同代码';

  @override
  String get customerNameLabel => '客户名称';

  @override
  String get periodNumberLabel => '期数';

  @override
  String get principalLabel => '本金';

  @override
  String get interestLabel => '利息';

  @override
  String get insuranceLabel => '保险费';

  @override
  String get savingLabel => '强制储蓄';

  @override
  String get totalDueLabel => '应收总额';

  @override
  String get paymentMethodLabel => '支付方式';

  @override
  String get methodCash => '现金 MMK';

  @override
  String get methodMmqr => 'MMQR 动态二维码';

  @override
  String get methodKbzPay => 'KBZPay 钱包';

  @override
  String get methodWavePay => 'WavePay 钱包';

  @override
  String get confirmCollectionButton => '确认并记录';

  @override
  String get cancelButton => '取消';

  @override
  String get collectionSuccessMessage => '还款记录成功';

  @override
  String get collectionFailedMessage => '还款记录失败';

  @override
  String get noRepaymentsFound => '当前筛选条件下无还款记录';

  @override
  String get dueLabel => '到期日';

  @override
  String get paidOfflineBadge => '已付（离线队列）';

  @override
  String get paidSyncedBadge => '已付（已同步）';

  @override
  String get statusOverdue => '逾期';

  @override
  String get statusPending => '待收';

  @override
  String get retryButton => '重试';

  @override
  String get bluetoothPrinterTitle => '蓝牙打印机';

  @override
  String get printerConnected => '已连接';

  @override
  String get printerDisconnected => '未连接';

  @override
  String get connectPrinter => '连接打印机';

  @override
  String get disconnectPrinter => '断开连接';

  @override
  String get printingReceipt => '正在打印收据...';

  @override
  String get printSuccess => '收据打印成功';

  @override
  String get printFailed => '打印收据失败';

  @override
  String get noPrintersFound => '未找到蓝牙打印机';

  @override
  String get scanPrinters => '扫描打印机';

  @override
  String get printTestReceipt => '打印测试收据';

  @override
  String get availableBluetoothDevices => '可用蓝牙设备';

  @override
  String get noActiveBluetoothLink => '尚未建立蓝牙连接';

  @override
  String get syncStatusTitle => '离线同步引擎';

  @override
  String get pendingUploadsCount => '待上传记录数';

  @override
  String get lastSyncTime => '上次同步时间';

  @override
  String get syncInProgress => '正在与服务器同步数据...';

  @override
  String get pullingCatalog => '正在下载最新的中心和还款计划...';

  @override
  String get pushingBatch => '正在上传离线还款记录...';

  @override
  String get offlineGuidelinesTitle => '离线作业指南';

  @override
  String get offlineGuidelinesText =>
      '1. 偏远村庄收取的款项通过 SQLCipher AES-256 本地安全加密存储。\n2. 重新连接蜂窝网络/Wi-Fi 后，系统将自动批量上传离线数据。\n3. 手持热敏打印机出具的凭证具有法律效力并可在同步后核对。';

  @override
  String get statSynced => '已同步';

  @override
  String get statFailed => '失败';

  @override
  String get navHome => '首页';

  @override
  String get navCenters => '代收客群';

  @override
  String get navNewLoan => '新贷款';

  @override
  String get navSavingsCash => '储蓄资金';

  @override
  String get navAccount => '我的账户';

  @override
  String get quickActions => '快捷操作';

  @override
  String get customize => '自定义';

  @override
  String get viewAll => '查看全部';

  @override
  String get accountSettings => '账户与设置';

  @override
  String get officerProfile => '代理商资料';

  @override
  String get agentAuthorizedRole => '授权代理商';

  @override
  String get agentBranchLocation => '仰光交易网点 (BR001)';

  @override
  String get cashInHand => '代理商现金余额';

  @override
  String get handoverQr => '缴款结算二维码';

  @override
  String get signOut => '退出登录';

  @override
  String get confirmSignOut => '您确定要退出 BMF 代理商系统吗？';

  @override
  String get deviceSecurity => '生物识别与安全';

  @override
  String get appVersion => '应用版本';

  @override
  String get appVersionSubtitle => '版本 v2.6.0 (Build 2026.09 - Staging)';

  @override
  String get todayCenterMeeting => '今日中心会议';

  @override
  String get completed => '已完成';

  @override
  String get itemsCount => '项';

  @override
  String get membersCount => '人';

  @override
  String get collectedLabel => '已收';

  @override
  String get pendingLabel => '待收';

  @override
  String get expectedLabel => '预计';

  @override
  String get handoverButton => '缴款交接';

  @override
  String get saveCustomization => '保存自定义';

  @override
  String get customizeAgentShortcuts => '自定义常用功能';

  @override
  String get customizeAgentShortcutsDesc => '选择常用业务功能并固定到快捷工具栏：';

  @override
  String get actionCollectRepayment => '村组代收';

  @override
  String get actionNewLoan => '新贷 KYC';

  @override
  String get actionSavings => '储蓄存款';

  @override
  String get actionCenters => '中心会议';

  @override
  String get actionManageCash => '现金库存';

  @override
  String get actionInsurance => '互助保险';

  @override
  String get actionPrinter => '蓝牙打印机';

  @override
  String get actionSync => '离线同步';

  @override
  String get agentOperationsSection => '代理商日常业务';

  @override
  String get devicesSyncSection => '设备与数据同步';

  @override
  String get systemSettingsSection => '系统与设置';

  @override
  String get hardwarePrinterSection => '外设与打印机设置';

  @override
  String get offlineDataSection => '离线数据与同步';

  @override
  String get securitySection => '安全与会话认证';

  @override
  String get systemSupportSection => '系统与客服支持';

  @override
  String get biometricFingerprint => '指纹生物识别认证';

  @override
  String get biometricFingerprintDesc => '为代理人员提供快速安全的登录认证';

  @override
  String get itHotline => '代理商 24/7 客服热线';

  @override
  String get itHotlineDesc => '热线：09450011223（分机 2）';

  @override
  String get thermalPrinterDesc => '便携手持热敏打印机 58mm/80mm ESC/POS';

  @override
  String get offlineSyncDesc => '本地 SQLite 与中心系统双向同步';

  @override
  String get manageAgentCashDesc => '盘点手头现金并生成缴款结算二维码';

  @override
  String get manageAgentCashTitle => '代理商现金库房管理';

  @override
  String get sqliteEncryptionDesc => 'SQLite AES-256 数据库加密与硬件安全密钥';

  @override
  String get languageDisplay => '显示语言';

  @override
  String get latestVersionBadge => '最新版本';

  @override
  String get secureBadge => '安全';

  @override
  String get connectedBadge => '已连接';

  @override
  String get pendingUploadsBadge => '待上传';

  @override
  String get cashManagementTitle => '移动现金管理';

  @override
  String get currentCashInHand => '当前手头实际现金';

  @override
  String get loanRepayments => '贷款还款';

  @override
  String get savingsDeposits => '储蓄存款';

  @override
  String get handoverToBranch => '向网点缴交现金（二维码）';

  @override
  String get todayCashTransactions => '今日现金交易明细';

  @override
  String get noCashTransactions => '今日暂无现金交易记录。';

  @override
  String get safetyLimitExceeded => '超出安全持现额度！';

  @override
  String get safetyLimitWarning => '手头现金已超出安全限额，请立即交接至分行出纳或存入银行。';

  @override
  String get cashHandoverSuccess => '现金交接确认成功！';

  @override
  String get branchCashierHandoverTitle => '分行出纳交接';

  @override
  String get transactionsCollectedToday => '今日已收交易笔数';

  @override
  String get confirmCashierDeposit => '确认缴交出纳';

  @override
  String get closeButton => '关闭';

  @override
  String get newLoanApplication => '新贷款申请受理';

  @override
  String get originationGuide => '贷款业务指引';

  @override
  String get originationGuideText =>
      '1. 通过国民身份证 NRC 验证客户身份。\n2. 记录借款人居所 GPS 定位坐标。\n3. 在屏幕上完成借款人电子签名。\n4. 申请资料将在本地加密并排队同步。';

  @override
  String get gotItButton => '我知道了';

  @override
  String get borrowerDetails => '借款人与贷款信息';

  @override
  String get borrowerFullName => '借款人全名 *';

  @override
  String get borrowerFullNameHint => '例如：Daw Khin Khin Win';

  @override
  String get borrowerFullNameRequired => '借款人全名为必填项';

  @override
  String get phoneNumber => '联系电话 *';

  @override
  String get phoneNumberHint => '例如：09123456789';

  @override
  String get phoneNumberRequired => '联系电话为必填项';

  @override
  String get requestedLoanAmount => '申请贷款金额 (MMK) *';

  @override
  String get requestedLoanAmountRequired => '贷款金额为必填项';

  @override
  String get minLoanAmountValidation => '最低贷款金额为 100,000 MMK';

  @override
  String get loanTerm => '贷款期限';

  @override
  String get purpose => '贷款用途';

  @override
  String get stepIdentityNrc => '缅甸 NRC 身份证核验';

  @override
  String get stepGpsSurvey => '居住地 GPS 坐标勘测';

  @override
  String get stepSignature => '借款人电子签名 (လက်မှတ်)';

  @override
  String get nrcRequiredValidation => '请扫描或输入有效的缅甸 NRC 身份证';

  @override
  String get gpsRequiredValidation => '提交前必须记录借款人居所 GPS 坐标';

  @override
  String get signatureRequiredValidation => '提交前必须完成借款人电子签名';

  @override
  String get submitApplication => '提交贷款申请';

  @override
  String get savingApplication => '正在加密保存...';

  @override
  String get applicationSaved => '申请已保存';

  @override
  String get applicationSavedSuccessMsg => '贷款申请已加密保存至本地数据库并排队同步。';

  @override
  String get backToDashboard => '返回控制台';

  @override
  String get positionNrcInFrame => '请将身份证置于取景框内\n(မှတ်ပုံတင် ကတ်ပြားအား ထားပါ)';

  @override
  String get nrcInputLabel => '缅甸 NRC 身份证号码';

  @override
  String get nrcInputHint => '例如：12/DAGANA(N)123456 或 ၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆';

  @override
  String get invalidNrcFormat => 'NRC 格式不正确。例如：12/DAGANA(N)123456';

  @override
  String get signHerePrompt => '请在此处签名 (လက်မှတ်ရေးထိုးပါ)';

  @override
  String get clearSignature => '清除签名';

  @override
  String get gpsRecordedSuccess => '居所 GPS 定位记录成功。';

  @override
  String get gpsPendingLabel => '尚未获取 GPS 坐标';

  @override
  String get gpsRecordedLabel => '已记录居所坐标';

  @override
  String get gpsPromptTap => '点击定位图标以获取实地坐标';

  @override
  String get savingsTitle => '村庄储蓄账户列表';

  @override
  String get searchSavingHint => '按姓名、身份证或账号搜索...';

  @override
  String get depositSavingButton => '储蓄存款';

  @override
  String get reloadAccounts => '重新加载列表';

  @override
  String get noSavingsFound => '未找到储蓄账户。';

  @override
  String get openFirstAccount => '开立第一个储蓄账户';

  @override
  String get openPassbookButton => '开立新存折';

  @override
  String get openSavingsPassbookTitle => '开立村庄储蓄存折';

  @override
  String get memberAccountHolder => '存折持有人信息';

  @override
  String get savingsProductPackage => '储蓄产品类型';

  @override
  String get initialCashDeposit => '初始存入现金 (MMK)';

  @override
  String get initialDepositHint => '开户不存入现金请输入 0';

  @override
  String get legalNominee => '法定受益人信息';

  @override
  String get nomineeFullName => '受益人全名';

  @override
  String get nomineeNrc => '受益人身份证号码';

  @override
  String get nomineeRelation => '与借款人关系';

  @override
  String get confirmOpenPassbook => '确认并开立存折';

  @override
  String get passbookCreatedTitle => '存折已成功开立';

  @override
  String get passbookCreatedDesc => '储蓄存折开立成功，已排队等待同步至中心系统。';

  @override
  String get doneButton => '完成';

  @override
  String get accumulatedBalance => '累计余额';

  @override
  String get depositTitle => '存款';

  @override
  String get currentBalanceLabel => '当前余额：';

  @override
  String get depositAmountLabel => '存款金额 (MMK) *';

  @override
  String get depositAmountHint => '请输入存款金额';

  @override
  String get depositAmountRequired => '存款金额为必填项';

  @override
  String get minDepositValidation => '最低存款金额为 1,000 MMK';

  @override
  String get printReceiptCheckbox => '通过蓝牙打印机打印收据';

  @override
  String get confirmDeposit => '确认存款';

  @override
  String get navSavingsTitle => '储蓄管理';

  @override
  String get navCashTitle => '现金管理';

  @override
  String get navInsuranceTitle => '互助保险';

  @override
  String get insuranceClaimTitle => '微型互助保险理赔';

  @override
  String get claimSubmittedTitle => '理赔申请已提交';

  @override
  String get claimSubmittedDesc => '紧急援助理赔申请已在本地登记并转交网点审批出纳。';

  @override
  String get claimReferenceCode => '理赔申请单号';

  @override
  String get beneficiaryIncidentDetails => '受益人与事故详情';

  @override
  String get coveredRiskCategory => '受保风险类别';

  @override
  String get requestedAssistanceAmount => '申请援助金额 (MMK) *';

  @override
  String get incidentDescription => '事故详情与经过描述 *';

  @override
  String get incidentDescriptionHint => '请描述医疗诊断、住院日期或损失情况...';

  @override
  String get incidentDescriptionRequired => '事故描述为必填项';

  @override
  String get evidentiaryDocuments => '证明材料与照片';

  @override
  String get villageHeadLetter => '村长证明信';

  @override
  String get letterAttached => '证明信已附加';

  @override
  String get tapToAttachLetter => '点击附加或拍照';

  @override
  String get medicalReceipt => '医疗发票 / 收据';

  @override
  String get receiptAttached => '发票已附加';

  @override
  String get tapToAttachReceipt => '点击附加或拍照';

  @override
  String get submitEmergencyClaim => '提交紧急理赔申请';

  @override
  String get submittingClaim => '正在提交申请...';

  @override
  String get letterAttachedToast => '已附加村长证明信照片。';

  @override
  String get receiptAttachedToast => '已附加医疗发票照片。';

  @override
  String get savingProductCompulsory => '强制性微型储蓄';

  @override
  String get savingProductVoluntary => '自愿性活期储蓄';

  @override
  String get savingProductFixedTerm => '定期储蓄存款';

  @override
  String get cashTxLoanRepayment => '分期还款代收';

  @override
  String get cashTxSavingDeposit => '村民储蓄存款';

  @override
  String get cashTxSavingOpen => '开户初始存金';

  @override
  String get cashTxHandover => '上缴网点出纳资金';

  @override
  String get claimRiskIllness => '住院治疗救助';

  @override
  String get claimRiskAccident => '工伤与交通事故';

  @override
  String get claimRiskNaturalDisaster => '洪涝风暴火灾';

  @override
  String get claimRiskDeath => '社员及配偶丧葬抚恤';

  @override
  String get claimRiskCropFailure => '农作物受灾与旱灾';

  @override
  String get claimAmountRequired => '请输入申请救助金额';

  @override
  String get invalidAmountValidation => '请输入大于0的有效金额';

  @override
  String get methodAyaPay => 'AYA Pay 电子钱包';

  @override
  String get methodMytelPay => 'MytelPay 电子钱包';

  @override
  String get methodBankTransfer => '银行转账';
}
