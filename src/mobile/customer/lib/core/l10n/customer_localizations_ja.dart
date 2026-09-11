import 'customer_localizations.dart';

/// Japanese (`ja`) translations.
class CustomerLocalizationsJa extends CustomerLocalizations {
  CustomerLocalizationsJa([super.locale = 'ja']);

  @override
  String get appTitle => 'BMF マイクロファイナンス';
  @override
  String get home => 'ホーム';
  @override
  String get loans => '融資';
  @override
  String get savings => '貯蓄';
  @override
  String get insurance => '共済保険';
  @override
  String get notifications => 'お知らせ';

  @override
  String get loginTitle => '会員ログイン';
  @override
  String get phoneLabel => '電話番号';
  @override
  String get nrcLabel => '身分証番号 (NRC)';
  @override
  String get requestOtp => 'SMS認証コード取得';
  @override
  String get otpTitle => 'SMS認証コードの入力';
  @override
  String get verifyOtp => '認証';
  @override
  String get setPinTitle => '6桁の暗証番号を設定';
  @override
  String get confirmPinTitle => '暗証番号の再確認';
  @override
  String get enterPinTitle => '暗証番号を入力してください';
  @override
  String get biometricLogin => '生体認証でログイン';
  @override
  String get pinMismatch => '暗証番号が一致しません';
  @override
  String get pinSuccess => '暗証番号の設定が完了しました';

  @override
  String get welcomeMember => 'おかえりなさい';
  @override
  String get memberCode => '会員番号';
  @override
  String get groupCode => 'グループ番号';
  @override
  String get totalOutstanding => '借入残高合計';
  @override
  String get activeLoans => '利用中の融資';
  @override
  String get dueAlertTitle => '返済期日のご案内';
  @override
  String get payNow => '今すぐ返済';
  @override
  String get quickServices => 'クイック機能';

  @override
  String get loansTitle => '融資一覧';
  @override
  String get loanDetails => '融資詳細';
  @override
  String get scheduleTitle => '返済スケジュール';
  @override
  String get period => '回数';
  @override
  String get dueDate => '返済期日';
  @override
  String get principal => '元金';
  @override
  String get interest => '利息';
  @override
  String get insuranceFee => '保険料';
  @override
  String get totalDue => '返済合計額';
  @override
  String get statusPaid => '返済完了';
  @override
  String get statusPending => '未返済';
  @override
  String get statusOverdue => '延滞';

  @override
  String get debtGroupCurrent => '正常先 (第1区分)';
  @override
  String get debtGroupSpecialMention => '要管理先 (第2区分)';
  @override
  String get debtGroupSubstandard => '破綻懸念先 (第3区分)';
  @override
  String get debtGroupDoubtful => '実質破綻先 (第4区分)';
  @override
  String get debtGroupLoss => '破綻先 (第5区分)';

  @override
  String get paymentTitle => 'MMQR 決済';
  @override
  String get scanMmqr => '銀行またはウォレットでスキャン';
  @override
  String get openWallet => '電子ウォレットを開く';
  @override
  String get launchKbzPay => 'KBZPay で支払う';
  @override
  String get launchWavePay => 'WavePay で支払う';
  @override
  String get launchAyaPay => 'AYA Pay で支払う';
  @override
  String get launchMytelPay => 'MytelPay で支払う';
  @override
  String get saveQrImage => 'QRコード画像を保存';
  @override
  String get paymentSuccess => '返済決済が完了しました';
  @override
  String get electronicReceipt => '電子領収書';
  @override
  String get referenceNo => '取引参照番号';
  @override
  String get returnHome => 'ホームに戻る';

  @override
  String get savingsTitle => '貯蓄口座';
  @override
  String get accruedInterest => '累積利息';
  @override
  String get openSavingOnline => 'オンライン貯蓄口座開設';
  @override
  String get compulsorySaving => '強制貯蓄';
  @override
  String get voluntarySaving => '任意貯蓄';
  @override
  String get fixedTermSaving => '定期預金';
  @override
  String get interestRatePerAnnum => '年利率';

  @override
  String get insuranceTitle => '会員相互扶助基金';
  @override
  String get medicalBenefitTitle => '入院見舞金 (10,000 MMK/日)';
  @override
  String get medicalBenefitDesc => '病気や事故に対する手厚い福祉保障制度';
  @override
  String get submitClaim => '保険金請求を行う';
  @override
  String get illnessRisk => '病気・入院';
  @override
  String get accidentRisk => '事故・怪我';
  @override
  String get naturalDisasterRisk => '自然災害';
  @override
  String get uploadInvoices => '病院領収書と証明書の添付';
  @override
  String get claimSubmitted => '保険金請求の受付が完了しました';

  @override
  String get notificationsTitle => 'お知らせ一覧';
  @override
  String get markAllRead => 'すべて既読にする';
  @override
  String get noNotifications => '新しい通知はありません';
}
