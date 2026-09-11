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
  String get loginTitle => 'BMF 信贷员登录';

  @override
  String get usernameLabel => '信贷员用户名';

  @override
  String get passwordLabel => '密码';

  @override
  String get loginButton => '登录';

  @override
  String get biometricLogin => '生物识别登录';

  @override
  String get dashboardTitle => '实地业务仪表板';

  @override
  String get centersTitle => '中心与组别';

  @override
  String get collectionSheetTitle => '收款清单';

  @override
  String get offlineSyncTitle => '离线同步';

  @override
  String get todayTarget => '今日目标';

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
}
