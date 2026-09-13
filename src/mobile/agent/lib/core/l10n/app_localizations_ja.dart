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
  String get loginTitle => 'BMF 代理店ログイン';

  @override
  String get loginSubtitle => 'BMF 公認代理店・営業拠点システム';

  @override
  String get agentAuthHeader => '代理店アカウント認証';

  @override
  String get agentAuthDesc => '回収および現地取引業務を行うにはアカウント情報を入力してください。';

  @override
  String get usernameLabel => '代理店ユーザー名 / コード';

  @override
  String get passwordLabel => 'パスワード';

  @override
  String get loginButton => 'ログイン';

  @override
  String get biometricLogin => '生体認証でログイン';

  @override
  String get loginValidationEmpty => '代理店ユーザー名とパスワードを入力してください。';

  @override
  String get selectLanguageTitle => '表示言語の選択';

  @override
  String get securityBadgeFooter =>
      'BMF SSL Pinning およびハードウェア KeyStore で保護されています';

  @override
  String get dashboardTitle => '代理店ダッシュボード';

  @override
  String get centersTitle => 'センターとグループ';

  @override
  String get collectionSheetTitle => '回収シート';

  @override
  String get offlineSyncTitle => 'オフライン同期';

  @override
  String get todayTarget => '本日の目標';

  @override
  String get progressCompleted => '完了';

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
  String get noCentersMatch => '一致するセンターが見つかりません';

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
  String get noRepaymentsFound => '現在の条件に一致する回収記録はありません';

  @override
  String get dueLabel => '期日';

  @override
  String get paidOfflineBadge => '支払済（オフライン）';

  @override
  String get paidSyncedBadge => '支払済（同期済）';

  @override
  String get statusOverdue => '延滞';

  @override
  String get statusPending => '保留中';

  @override
  String get retryButton => '再試行';

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
  String get printTestReceipt => 'テスト印刷';

  @override
  String get availableBluetoothDevices => '利用可能なBluetoothデバイス';

  @override
  String get noActiveBluetoothLink => 'Bluetooth接続が確立されていません';

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

  @override
  String get offlineGuidelinesTitle => 'オフライン運用ガイドライン';

  @override
  String get offlineGuidelinesText =>
      '1. 現地で収集された取引は SQLCipher AES-256 で安全にローカル暗号化保存されます。\n2. 通信環境が回復すると、自動的にサーバーへバッチ送信されます。\n3. モバイルプリンターで出力された領収書は正式な受領証として有効です。';

  @override
  String get statSynced => '同期済';

  @override
  String get statFailed => '失敗';

  @override
  String get navHome => 'ホーム';

  @override
  String get navCenters => '回収';

  @override
  String get navNewLoan => '新規融資';

  @override
  String get navSavingsCash => '貯蓄管理';

  @override
  String get navAccount => 'アカウント';

  @override
  String get quickActions => 'クイック操作';

  @override
  String get customize => 'カスタマイズ';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get accountSettings => 'アカウントと設定';

  @override
  String get officerProfile => '代理店プロフィール';

  @override
  String get agentAuthorizedRole => '公認代理店';

  @override
  String get agentBranchLocation => 'ヤンゴン営業拠点 (BR001)';

  @override
  String get cashInHand => '代理店手元現金残高';

  @override
  String get handoverQr => '現金精算・引き渡しQR';

  @override
  String get signOut => 'ログアウト';

  @override
  String get confirmSignOut => 'BMF 代理店アプリからログアウトしますか？';

  @override
  String get deviceSecurity => '生体認証とセキュリティ';

  @override
  String get appVersion => 'アプリバージョン';

  @override
  String get appVersionSubtitle => 'バージョン v2.6.0 (Build 2026.09 - Staging)';

  @override
  String get todayCenterMeeting => '本日のセンター集会';

  @override
  String get completed => '完了';

  @override
  String get itemsCount => '件';

  @override
  String get membersCount => '名';

  @override
  String get collectedLabel => '回収済';

  @override
  String get pendingLabel => '未回収';

  @override
  String get expectedLabel => '予定';

  @override
  String get handoverButton => '引き渡し';

  @override
  String get saveCustomization => '設定を保存';

  @override
  String get customizeAgentShortcuts => 'ショートカットのカスタマイズ';

  @override
  String get customizeAgentShortcutsDesc => 'よく使う業務機能を選択してクイックバーに固定します：';

  @override
  String get actionCollectRepayment => '集団回収';

  @override
  String get actionNewLoan => '新規融資 KYC';

  @override
  String get actionSavings => '貯蓄預入';

  @override
  String get actionCenters => 'センター集会';

  @override
  String get actionManageCash => '手元現金管理';

  @override
  String get actionInsurance => '相互保険';

  @override
  String get actionPrinter => 'プリンター接続';

  @override
  String get actionSync => 'オフライン同期';

  @override
  String get agentOperationsSection => '代理店業務';

  @override
  String get devicesSyncSection => '端末とデータ同期';

  @override
  String get systemSettingsSection => 'システムと設定';

  @override
  String get hardwarePrinterSection => 'プリンター・外部機器設定';

  @override
  String get offlineDataSection => 'オフラインデータと同期';

  @override
  String get securitySection => 'セキュリティと認証';

  @override
  String get systemSupportSection => 'サポートとヘルプ';

  @override
  String get biometricFingerprint => '指紋生体認証';

  @override
  String get biometricFingerprintDesc => '代理店スタッフ向けの高速かつ安全なログイン';

  @override
  String get itHotline => '代理店サポートホットライン';

  @override
  String get itHotlineDesc => 'ホットライン：09450011223（内線 2）';

  @override
  String get thermalPrinterDesc => 'ポータブル熱転写プリンター 58mm/80mm ESC/POS';

  @override
  String get offlineSyncDesc => 'ローカル SQLite と中央サーバー間の双方向同期';

  @override
  String get manageAgentCashDesc => '手元現金監査および精算用 QR コード発行';

  @override
  String get manageAgentCashTitle => '代理店現金管理';

  @override
  String get sqliteEncryptionDesc => 'SQLite AES-256 データベース暗号化とハードウェア鍵';

  @override
  String get languageDisplay => '表示言語';

  @override
  String get latestVersionBadge => '最新';

  @override
  String get secureBadge => '安全';

  @override
  String get connectedBadge => '接続中';

  @override
  String get pendingUploadsBadge => '送信待ち';

  @override
  String get cashManagementTitle => 'モバイル現金管理';

  @override
  String get currentCashInHand => '現在の手元現金残高';

  @override
  String get loanRepayments => '融資返済金';

  @override
  String get savingsDeposits => '貯蓄預入金';

  @override
  String get handoverToBranch => '支店への現金引き渡し（QRコード）';

  @override
  String get todayCashTransactions => '本日の現金取引内訳';

  @override
  String get noCashTransactions => '本日の現金取引はまだありません。';

  @override
  String get safetyLimitExceeded => '安全保有現金限度額を超過しています！';

  @override
  String get safetyLimitWarning => '手元現金が安全限度額を超えています。速やかに支店出納係に引き渡してください。';

  @override
  String get cashHandoverSuccess => '現金の引き渡しを確認しました！';

  @override
  String get branchCashierHandoverTitle => '支店出納係への現金引き渡し';

  @override
  String get transactionsCollectedToday => '本日回収した取引件数';

  @override
  String get confirmCashierDeposit => '引き渡しを確認する';

  @override
  String get closeButton => '閉じる';

  @override
  String get newLoanApplication => '新規融資の申込み';

  @override
  String get originationGuide => '融資受付ガイド';

  @override
  String get originationGuideText =>
      '1. NRC カードで本人確認を実施します。\n2. 借入人の居住地 GPS 座標を記録します。\n3. 画面上で電子署名を取得します。\n4. 申込み内容は暗号化され同期キューに入ります。';

  @override
  String get gotItButton => '了解しました';

  @override
  String get borrowerDetails => '借入人および融資情報';

  @override
  String get borrowerFullName => '借入人氏名 *';

  @override
  String get borrowerFullNameHint => '例：Daw Khin Khin Win';

  @override
  String get borrowerFullNameRequired => '氏名は必須項目です';

  @override
  String get phoneNumber => '連絡先電話番号 *';

  @override
  String get phoneNumberHint => '例：09123456789';

  @override
  String get phoneNumberRequired => '電話番号は必須項目です';

  @override
  String get requestedLoanAmount => '希望融資額 (MMK) *';

  @override
  String get requestedLoanAmountRequired => '融資額は必須項目です';

  @override
  String get minLoanAmountValidation => '最低融資額は 100,000 MMK です';

  @override
  String get loanTerm => '融資期間';

  @override
  String get purpose => '資金使途';

  @override
  String get stepIdentityNrc => 'ミャンマー NRC 身分証の確認';

  @override
  String get stepGpsSurvey => '居住地 GPS 測位調査';

  @override
  String get stepSignature => '借入人電子署名 (လက်မှတ်)';

  @override
  String get nrcRequiredValidation => '有効な NRC 身分証をスキャンまたは入力してください';

  @override
  String get gpsRequiredValidation => '申請前に居住地 GPS 座標の記録が必要です';

  @override
  String get signatureRequiredValidation => '申請前に借入人の電子署名が必要です';

  @override
  String get submitApplication => '融資申込みを送信';

  @override
  String get savingApplication => '暗号化して保存中...';

  @override
  String get applicationSaved => '申込みを保存しました';

  @override
  String get applicationSavedSuccessMsg => '融資申込みはローカルに安全に保存され、同期待ちとなりました。';

  @override
  String get backToDashboard => 'ダッシュボードに戻る';

  @override
  String get positionNrcInFrame =>
      'NRC 身分証を枠内に合わせてください\n(မှတ်ပုံတင် ကတ်ပြားအား ထားပါ)';

  @override
  String get nrcInputLabel => 'ミャンマー NRC 番号';

  @override
  String get nrcInputHint => '例：12/DAGANA(N)123456 または ၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆';

  @override
  String get invalidNrcFormat => 'NRC の形式が正しくありません。例：12/DAGANA(N)123456';

  @override
  String get signHerePrompt => '指またはスタイラスで署名してください (လက်မှတ်ရေးထိုးပါ)';

  @override
  String get clearSignature => '署名を消去';

  @override
  String get gpsRecordedSuccess => '現地の GPS 座標を正常に記録しました。';

  @override
  String get gpsPendingLabel => 'GPS 座標未取得';

  @override
  String get gpsRecordedLabel => '居住地 GPS 座標記録済';

  @override
  String get gpsPromptTap => '位置情報アイコンをタップして測位してください';

  @override
  String get savingsTitle => '村落貯蓄口座一覧';

  @override
  String get searchSavingHint => '氏名、NRC、口座番号で検索...';

  @override
  String get depositSavingButton => '貯蓄預入';

  @override
  String get reloadAccounts => '再読み込み';

  @override
  String get noSavingsFound => '貯蓄口座が見つかりません。';

  @override
  String get openFirstAccount => '最初の通帳を開設する';

  @override
  String get openPassbookButton => '新規通帳開設';

  @override
  String get openSavingsPassbookTitle => '村落貯蓄通帳の開設';

  @override
  String get memberAccountHolder => '口座名義人情報';

  @override
  String get savingsProductPackage => '貯蓄商品タイプ';

  @override
  String get initialCashDeposit => '初回預入額 (MMK)';

  @override
  String get initialDepositHint => '預入なしで開設する場合は 0 を入力';

  @override
  String get legalNominee => '法定受取人情報';

  @override
  String get nomineeFullName => '受取人氏名';

  @override
  String get nomineeNrc => '受取人 NRC 番号';

  @override
  String get nomineeRelation => '本人との関係';

  @override
  String get confirmOpenPassbook => '確認して通帳を開設';

  @override
  String get passbookCreatedTitle => '通帳が開設されました';

  @override
  String get passbookCreatedDesc => '貯蓄通帳が正常に開設され、同期キューに追加されました。';

  @override
  String get doneButton => '完了';

  @override
  String get accumulatedBalance => '累積残高';

  @override
  String get depositTitle => '預入';

  @override
  String get currentBalanceLabel => '現在残高：';

  @override
  String get depositAmountLabel => '預入金額 (MMK) *';

  @override
  String get depositAmountHint => '預入金額を入力してください';

  @override
  String get depositAmountRequired => '預入金額は必須項目です';

  @override
  String get minDepositValidation => '最低預入額は 1,000 MMK です';

  @override
  String get printReceiptCheckbox => 'Bluetooth プリンターで領収書を印刷';

  @override
  String get confirmDeposit => '預入を確認';

  @override
  String get navSavingsTitle => '貯蓄管理';

  @override
  String get navCashTitle => '手元現金管理';

  @override
  String get navInsuranceTitle => '相互保険';

  @override
  String get insuranceClaimTitle => 'マイクロ相互保険金請求';

  @override
  String get claimSubmittedTitle => '請求を送信しました';

  @override
  String get claimSubmittedDesc => '緊急援助請求がローカルに記録され、承認のため支店に転送されました。';

  @override
  String get claimReferenceCode => '請求照会番号';

  @override
  String get beneficiaryIncidentDetails => '受取人および事故の詳細';

  @override
  String get coveredRiskCategory => '補償リスク分類';

  @override
  String get requestedAssistanceAmount => '請求援助金額 (MMK) *';

  @override
  String get incidentDescription => '事故状況・内容の説明 *';

  @override
  String get incidentDescriptionHint => '病名、入院日、損害状況などを入力してください...';

  @override
  String get incidentDescriptionRequired => '説明は必須項目です';

  @override
  String get evidentiaryDocuments => '証明書類および写真';

  @override
  String get villageHeadLetter => '村長証明書';

  @override
  String get letterAttached => '証明書添付済';

  @override
  String get tapToAttachLetter => 'タップして添付または撮影';

  @override
  String get medicalReceipt => '医療費領収書';

  @override
  String get receiptAttached => '領収書添付済';

  @override
  String get tapToAttachReceipt => 'タップして添付または撮影';

  @override
  String get submitEmergencyClaim => '緊急保険金を請求する';

  @override
  String get submittingClaim => '請求を送信中...';

  @override
  String get letterAttachedToast => '村長証明書写真が添付されました。';

  @override
  String get receiptAttachedToast => '医療機関領収書写真が添付されました。';

  @override
  String get savingProductCompulsory => '強制マイクロ貯蓄';

  @override
  String get savingProductVoluntary => '任意流動性貯蓄';

  @override
  String get savingProductFixedTerm => '定期貯蓄預金';

  @override
  String get cashTxLoanRepayment => '融資分割返済回収';

  @override
  String get cashTxSavingDeposit => '定期貯蓄預け入れ';

  @override
  String get cashTxSavingOpen => '通帳開設初期預金';

  @override
  String get cashTxHandover => '支店出納係への現金引渡';

  @override
  String get claimRiskIllness => '入院療養給付';

  @override
  String get claimRiskAccident => '労働・交通事故';

  @override
  String get claimRiskNaturalDisaster => '風水害・火災';

  @override
  String get claimRiskDeath => '組合員・配偶者死亡弔慰金';

  @override
  String get claimRiskCropFailure => '病虫害・干ばつ被害';

  @override
  String get claimAmountRequired => '請求支援金額を入力してください';

  @override
  String get invalidAmountValidation => '0より大きい有効な金額を入力してください';

  @override
  String get methodAyaPay => 'AYA Pay ウォレット';

  @override
  String get methodMytelPay => 'MytelPay ウォレット';

  @override
  String get methodBankTransfer => '銀行振込';
}
