// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'BMF エージェント';

  @override
  String get loginTitle => 'BMF 融資担当者ログイン';

  @override
  String get usernameLabel => '担当者ユーザー名';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get loginButton => 'ログイン';

  @override
  String get biometricLogin => '生体認証でログイン';

  @override
  String get dashboardTitle => '現場業務ダッシュボード';

  @override
  String get centersTitle => 'センターとグループ';

  @override
  String get collectionSheetTitle => '回収シート';

  @override
  String get offlineSyncTitle => 'オフライン同期';

  @override
  String get todayTarget => '本日の目標';

  @override
  String get collectedAmount => '回収済金額';

  @override
  String get remainingAmount => '残高';

  @override
  String get memberCount => '会員数';

  @override
  String get collectPayment => '回収する';

  @override
  String get printReceipt => '領収書印刷';

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get syncPending => '同期待ち';

  @override
  String get syncSuccess => 'データ同期が完了しました';

  @override
  String get networkOnline => 'オンライン';

  @override
  String get networkOffline => 'オフライン（ローカル保存）';

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
  String get searchCenterHint => 'センター名またはコードで検索';

  @override
  String get meetingDayLabel => '開催日';

  @override
  String get meetingTimeLabel => '開催時間';

  @override
  String get townshipLabel => '地区';

  @override
  String get groupCountLabel => 'グループ数';

  @override
  String get selectCenterPrompt => '回収シートを表示するセンターを選択してください';

  @override
  String get filterAll => 'すべて';

  @override
  String get filterDueToday => '本日期日';

  @override
  String get filterOverdue => '延滞';

  @override
  String get filterPaid => '支払済';

  @override
  String get contractCodeLabel => '契約コード';

  @override
  String get customerNameLabel => '顧客名';

  @override
  String get periodNumberLabel => '期数';

  @override
  String get principalLabel => '元金';

  @override
  String get interestLabel => '利息';

  @override
  String get insuranceLabel => '保険料';

  @override
  String get savingLabel => '強制貯蓄';

  @override
  String get totalDueLabel => '請求合計額';

  @override
  String get paymentMethodLabel => '支払方法';

  @override
  String get methodCash => '現金 MMK';

  @override
  String get methodMmqr => 'MMQRコード';

  @override
  String get methodKbzPay => 'KBZPay ウォレット';

  @override
  String get methodWavePay => 'WavePay ウォレット';

  @override
  String get confirmCollectionButton => '確認して記録';

  @override
  String get cancelButton => 'キャンセル';

  @override
  String get collectionSuccessMessage => '回収を正常に記録しました';

  @override
  String get collectionFailedMessage => '回収の記録に失敗しました';

  @override
  String get bluetoothPrinterTitle => 'Bluetoothプリンター';

  @override
  String get printerConnected => '接続中';

  @override
  String get printerDisconnected => '未接続';

  @override
  String get connectPrinter => 'プリンター接続';

  @override
  String get disconnectPrinter => '切断';

  @override
  String get printingReceipt => '領収書を印刷中...';

  @override
  String get printSuccess => '領収書を印刷しました';

  @override
  String get printFailed => '領収書の印刷に失敗しました';

  @override
  String get noPrintersFound => 'Bluetoothプリンターが見つかりません';

  @override
  String get scanPrinters => 'プリンターを検索';

  @override
  String get syncStatusTitle => 'オフライン同期エンジン';

  @override
  String get pendingUploadsCount => 'サーバー送信待ち件数';

  @override
  String get lastSyncTime => '最終同期時刻';

  @override
  String get syncInProgress => 'サーバーとデータを同期中...';

  @override
  String get pullingCatalog => '最新のセンターと返済予定をダウンロード中...';

  @override
  String get pushingBatch => 'オフライン回収記録をアップロード中...';
}
