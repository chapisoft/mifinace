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
  String get insurance => '共済';
  @override
  String get notifications => '通知';
  @override
  String get navHome => 'ホーム';
  @override
  String get navLoans => '融資';
  @override
  String get navScanQr => 'MMQR 決済';
  @override
  String get navHistory => '履歴';
  @override
  String get navAccount => 'アカウント';

  // Common Actions & Dialogs
  @override
  String get close => '閉じる';
  @override
  String get cancel => 'キャンセル';
  @override
  String get confirm => '確認';
  @override
  String get done => '完了';
  @override
  String get save => '保存';
  @override
  String get retry => '再試行';
  @override
  String get selectLanguage => '言語を選択';
  @override
  String get version => 'バージョン';
  @override
  String get viewAll => 'すべて表示';
  @override
  String get customize => 'カスタマイズ';
  @override
  String get quickActions => 'クイックアクション';
  @override
  String get customizeQuickActions => 'クイックアクションのカスタマイズ';
  @override
  String get customizeQuickActionsDesc => 'ホーム画面に表示するよく使う機能を選択してください：';
  @override
  String get saveChanges => '変更を保存';
  @override
  String get maxShortcutsReached => '選択できるショートカットは最大 4 つまでです';
  @override
  String get minShortcutsRequired => '少なくとも 1 つのショートカットを選択してください';

  // Authentication
  @override
  String get loginTitle => '会員ログイン';
  @override
  String get phoneLabel => '電話番号';
  @override
  String get nrcLabel => 'NRC 身分証番号';
  @override
  String get memberIdOrPhoneOrNrc => '会員番号 / 電話番号 / NRC';
  @override
  String get continueButton => '次へ進む';
  @override
  String get switchAccount => 'アカウント切り替え';
  @override
  String get forgotPin => 'PINをお忘れですか？';
  @override
  String get enter6DigitPin => '6桁のセキュリティPINを入力';
  @override
  String get notActivatedPrompt => 'アカウントが有効化されていません。今すぐOTPで有効化しますか？';
  @override
  String get activateNow => '今すぐ有効化';
  @override
  String get welcomeBack => 'おかえりなさい';
  @override
  String get firstTimeUsingApp => '初めてご利用ですか？';
  @override
  String get activateWithInfo => '会員番号、電話番号またはNRCで有効化';
  @override
  String get splashTagline => 'デジタル連帯マイクロクレジット＆会員金融';
  @override
  String get savedMemberAccount => '保存済み会員アカウント';
  @override
  String get requestOtp => 'OTPを取得';
  @override
  String get otpTitle => 'SMSコード確認';
  @override
  String get verifyOtp => '確認';
  @override
  String get setPinTitle => '6桁のPINを設定';
  @override
  String get confirmPinTitle => '6桁のPINを再入力';
  @override
  String get enterPinTitle => 'PINを入力';
  @override
  String get biometricLogin => '生体認証ログイン';
  @override
  String get pinMismatch => 'PINが一致しません';
  @override
  String get pinSuccess => 'PINの設定が完了しました';
  @override
  String get inputIdentifierRequired => '会員番号、電話番号またはNRCを入力してください。';

  // Dashboard & Member Profile
  @override
  String get welcomeMember => 'ようこそ';
  @override
  String get memberCode => '会員コード';
  @override
  String get groupCode => 'グループコード';
  @override
  String get totalOutstanding => '借入残高合計';
  @override
  String get activeLoans => '現在のお借入';
  @override
  String get dueAlertTitle => 'まもなくご返済期日です';
  @override
  String get payNow => '今すぐ返済';
  @override
  String get quickServices => 'クイックサービス';
  @override
  String get digitalMemberCard => 'デジタル会員証';
  @override
  String get memberQrTitle => 'BMF デジタル会員証';
  @override
  String get centerLabel => 'センター名';
  @override
  String get groupLabel => '連帯グループ';
  @override
  String get meetingScheduleLabel => '定例ミーティング';
  @override
  String get weeklyMeetingTime => '毎週金曜日 • 午前 09:00';
  @override
  String get assignedOfficerLabel => '担当オフィサー';
  @override
  String get noRecentTransactions => '最近の取引履歴はありません。';
  @override
  String get periodNumberLabel => '回';

  // Overview Metrics & Status
  @override
  String get outstandingLoanMetric => '借入残高合計';
  @override
  String get dueMetric => '次回返済額';
  @override
  String get totalSavingsMetric => '貯蓄残高合計';
  @override
  String get loyaltyPointsMetric => '獲得ポイント';
  @override
  String get memberActiveStatus => '会員ステータス良好';

  // Home Menu Items
  @override
  String get menuMmqrTitle => 'MMQR 決済';
  @override
  String get menuMmqrSubtitle => '国家決済ゲートウェイ';
  @override
  String get menuLoansTitle => '融資一覧';
  @override
  String get menuLoansSubtitle => '返済スケジュール確認';
  @override
  String get menuSavingsTitle => '貯蓄口座';
  @override
  String get menuSavingsSubtitle => '通帳と利息';
  @override
  String get menuInsuranceTitle => '共済基金';
  @override
  String get menuInsuranceSubtitle => '医療と災害扶助';
  @override
  String get menuApplyLoanTitle => 'スピード融資';
  @override
  String get menuApplyLoanSubtitle => 'オンライン申込';
  @override
  String get menuHistoryTitle => '取引履歴';
  @override
  String get menuHistorySubtitle => '領収書の確認';
  @override
  String get menuBranchesTitle => '支店・拠点';
  @override
  String get menuBranchesSubtitle => '最寄りのサービス拠点';
  @override
  String get menuNotificationsTitle => 'お知らせ';
  @override
  String get menuNotificationsSubtitle => '返済期日の通知';

  // Loans & Schedule
  @override
  String get loansTitle => '融資一覧';
  @override
  String get loanDetails => '契約詳細';
  @override
  String get scheduleTitle => '返済スケジュール表';
  @override
  String get period => '回数';
  @override
  String get dueDate => '期日';
  @override
  String get principal => '元金';
  @override
  String get interest => '利息';
  @override
  String get insuranceFee => '共済費';
  @override
  String get totalDue => '返済合計';
  @override
  String get statusPaid => '返済済';
  @override
  String get statusPending => '未返済';
  @override
  String get statusOverdue => '延滞中';

  // 5 FRD Debt Groups
  @override
  String get debtGroupCurrent => 'グループ1 - 正常先 (Current)';
  @override
  String get debtGroupSpecialMention => 'グループ2 - 要注意先 (Special Mention)';
  @override
  String get debtGroupSubstandard => 'グループ3 - 要管理先 (Substandard)';
  @override
  String get debtGroupDoubtful => 'グループ4 - 破綻懸念先 (Doubtful)';
  @override
  String get debtGroupLoss => 'グループ5 - 破綻先 (Loss)';

  // Payments & MMQR
  @override
  String get paymentTitle => 'MMQR デジタル決済';
  @override
  String get scanMmqr => 'MMQR をスキャン';
  @override
  String get mmqrRepaymentTitle => 'MMQR デジタル返済';
  @override
  String get generatingMmqr => 'CBM 標準 dynamic MMQR を生成中...';
  @override
  String get openWallet => 'モバイルウォレットで支払う';
  @override
  String get launchKbzPay => 'KBZPay を開く';
  @override
  String get launchWavePay => 'WavePay を開く';
  @override
  String get launchAyaPay => 'AYA Pay を開く';
  @override
  String get launchMytelPay => 'MytelPay を開く';
  @override
  String get saveQrImage => 'QRコード画像を保存';
  @override
  String get paymentSuccess => 'お支払い完了！';
  @override
  String get electronicReceipt => '電子領収書';
  @override
  String get referenceNo => '取引番号';
  @override
  String get returnHome => 'ホームに戻る';
  @override
  String get backToHome => 'ホームに戻る';
  @override
  String get contractCodeLabel => '契約コード';
  @override
  String get transactionRefLabel => '取引参照番号';
  @override
  String get paymentChannelLabel => '決済チャネル';
  @override
  String get settledDateLabel => '決済日時';
  @override
  String get totalPaidAmountLabel => '支払合計額';
  @override
  String get totalTransactionAmount => '総取引金額';
  @override
  String get noMatchingTransactions => '該当する取引履歴がありません';
  @override
  String get tryDifferentFilter => '期間やカテゴリを変更してお試しください';
  @override
  String get details => '詳細';
  @override
  String get savingReceiptPdf => '領収書PDFを端末に保存中...';
  @override
  String get savePdf => 'PDF保存';
  @override
  String get sharingReceipt => '領収書共有リンクを生成中...';
  @override
  String get share => '共有';
  @override
  String get filterAll => 'すべて';
  @override
  String get filterRepayment => '返済';
  @override
  String get filterSavings => '貯蓄';
  @override
  String get filterInsurance => '保険料';
  @override
  String get searchPlaceholder => '取引番号・契約番号で検索...';
  @override
  String get allTime => '全期間';
  @override
  String get thisMonth => '今月';
  @override
  String get last3Months => '過去3ヶ月';
  @override
  String get filterModalTitle => '取引絞り込み';

  // Savings
  @override
  String get savingsTitle => '貯蓄・通帳';
  @override
  String get savingsAndPassbooks => '貯蓄・通帳一覧';
  @override
  String get accruedInterest => '累計獲得利息';
  @override
  String get openSavingOnline => 'オンライン貯蓄口座開設';
  @override
  String get openSavingsPassbookTitle => '高利回り貯蓄口座の申込';
  @override
  String get passbookOpenedSuccess => '通帳の開設が完了しました！';
  @override
  String get viewPassbooks => '通帳一覧を確認';
  @override
  String get expectedProfitAtMaturity => '満期時予想収益:';
  @override
  String get confirmAndSubscribe => '内容を確認して口座開設';
  @override
  String get depositPrincipal => '預入元金';
  @override
  String get accruedProfitYield => '獲得利息';
  @override
  String get compulsorySaving => 'グループ強制貯蓄';
  @override
  String get voluntarySaving => '自由積立貯蓄';
  @override
  String get fixedTermSaving => '高利回り定期預金';
  @override
  String get interestRatePerAnnum => '年利回り';

  // Insurance
  @override
  String get insuranceTitle => '会員相互扶助共済';
  @override
  String get medicalBenefitTitle => '医療費・災害見舞金';
  @override
  String get medicalBenefitDesc => '緊急入院費および自然災害見舞金支援';
  @override
  String get submitClaim => '共済金請求を申請';
  @override
  String get mutualAidClaimTitle => '相互扶助給付金請求書';
  @override
  String get illnessRisk => '病気入院・通院治療';
  @override
  String get accidentRisk => '突発事故・怪我';
  @override
  String get naturalDisasterRisk => '風水害・自然災害';
  @override
  String get uploadInvoices => '退院証明書または医療費領収書を添付';
  @override
  String get attachMedicalDocument => '医療証明書類を添付';
  @override
  String get documentAttachedSimulated => '証明書類1件を添付済';
  @override
  String get submitInsuranceClaim => '共済請求書を送信';
  @override
  String get claimFiledSuccess => '申請が正常に受理されました';
  @override
  String get claimSubmitted => '申請完了';

  // Notifications
  @override
  String get notificationsTitle => 'お知らせ';
  @override
  String get notificationCenterTitle => '通知センター';
  @override
  String get markAllRead => 'すべて既読にする';
  @override
  String get noNotifications => '新しい通知はありません';
  @override
  String get noNotificationsFound => '通知履歴はありません';

  // Fast Loan & Application
  @override
  String get applyLoanTitle => 'スピード融資申込';
  @override
  String get tabApplyLoan => '融資を申し込む';
  @override
  String get tabTrackApplications => '申請履歴';
  @override
  String get selectLoanPackage => '融資プランを選択';
  @override
  String get loanAmountToBorrow => '借入希望額';
  @override
  String get minAmountLabel => '最小';
  @override
  String get maxAmountLabel => '最大';
  @override
  String get loanTerm => '借入期間';
  @override
  String get repaymentFrequency => '返済周期';
  @override
  String get monthly => '毎月';
  @override
  String get biweekly => '隔週';
  @override
  String get weekly => '毎週';
  @override
  String get estimatedMonthlyRepayment => '毎月の概算返済額';
  @override
  String get monthlyPrincipal => '毎月元金';
  @override
  String get monthlyInterest => '毎月利息';
  @override
  String get welfareInsuranceFee => '共済保険料 (0.5%)';
  @override
  String get disbursementMethod => '受取方法';
  @override
  String get loanPurpose => '借入目的';
  @override
  String get loanPurposeHint => '例：肥料の購入、仕入れ資金...';
  @override
  String get submitLoanApplication => '融資申請を送信';
  @override
  String get applicationSubmittedSuccess => '申請が完了しました';
  @override
  String get viewProgress => '進捗を確認';
  @override
  String get searchApplicationPlaceholder => '申請番号またはプランで検索...';
  @override
  String get appStatusUnderReview => '審査中';
  @override
  String get appStatusApproved => '承認済み';
  @override
  String get appStatusDisbursed => '融資実行済み';
  @override
  String get appStatusRejected => '却下';
  @override
  String get noActiveLoansToRepay => '返済対象の融資はありません';
  @override
  String get selectLoanToRepay => '返済する融資を選択';
  @override
  String get monthsTerm => 'ヶ月';
  @override
  String get interestPerMonth => '月';

  // Account Screen & Settings
  @override
  String get accountTitle => 'アカウント・セキュリティ';
  @override
  String get securityTitle => 'セキュリティと本人認証';
  @override
  String get changePin => 'PINを変更';
  @override
  String get changePinSecurityTitle => 'セキュリティPINの変更';
  @override
  String get currentPinLabel => '現在のPIN';
  @override
  String get newPinLabel => '新しい6桁のPIN';
  @override
  String get confirmNewPinLabel => '新しいPINを再入力';
  @override
  String get pinChangedSuccess => 'PINが正常に変更されました';
  @override
  String get biometricAuth => '生体認証';
  @override
  String get biometricSubtitle => 'FaceID / 指紋でのクイックログイン';
  @override
  String get deviceSecurity => '端末セキュリティ状態';
  @override
  String get deviceSecurityStatus => '端末セキュリティ診断';
  @override
  String get deviceSecurityPass => '合格';
  @override
  String get deviceSecurityDesc => 'SSL Pinning、耐タンパー性：基準を満たしています';
  @override
  String get utilitiesTitle => 'サポート・各種サービス';
  @override
  String get settingsAndPreferences => '設定と環境設定';
  @override
  String get languageSettingTitle => '表示言語';
  @override
  String get dueReminderNotifications => '返済期日リマインダー';
  @override
  String get dueReminderDesc => '期日の3日前に事前通知';
  @override
  String get branchNetwork => '支店・拠点案内';
  @override
  String get supportHotline => '会員サポート専用窓口';
  @override
  String get termsAndPrivacy => '融資約款および個人情報保護方針';
  @override
  String get appVersion => 'アプリバージョン';
  @override
  String get signOut => 'ログアウト';
  @override
  String get confirmSignOut => 'ログアウトしてもよろしいですか？';
  @override
  String get signOutConfirmTitle => 'アカウントからログアウト';
  @override
  String get signOutConfirmDesc => 'BMF 会員ポータルからログアウトしますか？';
}
