// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'BMF 에이전트';

  @override
  String get loginTitle => 'BMF 에이전트 로그인';

  @override
  String get loginSubtitle => 'BMF 공인 에이전트 및 영업소 시스템';

  @override
  String get agentAuthHeader => '에이전트 계정 인증';

  @override
  String get agentAuthDesc => '수납 및 현장 거래 업무를 위해 에이전트 계정 정보를 입력하세요.';

  @override
  String get usernameLabel => '에이전트 사용자 이름 / 코드';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get loginButton => '로그인';

  @override
  String get biometricLogin => '생체 인증으로 로그인';

  @override
  String get loginValidationEmpty => '에이전트 사용자 이름과 비밀번호를 입력해 주세요.';

  @override
  String get selectLanguageTitle => '표시 언어 선택';

  @override
  String get securityBadgeFooter => 'BMF SSL Pinning 및 하드웨어 KeyStore 보안 적용';

  @override
  String get dashboardTitle => '에이전트 운영 대시보드';

  @override
  String get centersTitle => '센터 및 그룹';

  @override
  String get collectionSheetTitle => '수납 명세서';

  @override
  String get offlineSyncTitle => '오프라인 동기화';

  @override
  String get todayTarget => '오늘의 목표';

  @override
  String get progressCompleted => '완료';

  @override
  String get collectedAmount => '수납 완료 금액';

  @override
  String get remainingAmount => '잔여 금액';

  @override
  String get memberCount => '회원 수';

  @override
  String get collectPayment => '수납하기';

  @override
  String get printReceipt => '영수증 출력';

  @override
  String get syncNow => '지금 동기화';

  @override
  String get syncPending => '동기화 대기 중';

  @override
  String get syncSuccess => '데이터 동기화 완료';

  @override
  String get networkOnline => '온라인';

  @override
  String get networkOffline => '오프라인 (로컬 저장소)';

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
  String get searchCenterHint => '센터 이름 또는 코드로 검색';

  @override
  String get meetingDayLabel => '모임 요일';

  @override
  String get meetingTimeLabel => '모임 시간';

  @override
  String get townshipLabel => '지역';

  @override
  String get groupCountLabel => '그룹 수';

  @override
  String get selectCenterPrompt => '수납 명세서를 보려면 센터를 선택하세요';

  @override
  String get noCentersMatch => '일치하는 센터를 찾을 수 없습니다';

  @override
  String get filterAll => '전체';

  @override
  String get filterDueToday => '오늘 만기';

  @override
  String get filterOverdue => '연체';

  @override
  String get filterPaid => '납부 완료';

  @override
  String get contractCodeLabel => '계약 코드';

  @override
  String get customerNameLabel => '고객명';

  @override
  String get periodNumberLabel => '회차';

  @override
  String get principalLabel => '원금';

  @override
  String get interestLabel => '이자';

  @override
  String get insuranceLabel => '보험료';

  @override
  String get savingLabel => '의무 저축';

  @override
  String get totalDueLabel => '총 청구 금액';

  @override
  String get paymentMethodLabel => '결제 수단';

  @override
  String get methodCash => '현금 MMK';

  @override
  String get methodMmqr => 'MMQR 코드';

  @override
  String get methodKbzPay => 'KBZPay 전자지갑';

  @override
  String get methodWavePay => 'WavePay 전자지갑';

  @override
  String get confirmCollectionButton => '확인 및 기록';

  @override
  String get cancelButton => '취소';

  @override
  String get collectionSuccessMessage => '수납 내역이 성공적으로 기록되었습니다';

  @override
  String get collectionFailedMessage => '수납 내역 기록에 실패했습니다';

  @override
  String get noRepaymentsFound => '현재 조건에 일치하는 수납 내역이 없습니다';

  @override
  String get dueLabel => '만기일';

  @override
  String get paidOfflineBadge => '납부 완료 (오프라인)';

  @override
  String get paidSyncedBadge => '납부 완료 (동기화됨)';

  @override
  String get statusOverdue => '연체';

  @override
  String get statusPending => '대기 중';

  @override
  String get retryButton => '다시 시도';

  @override
  String get bluetoothPrinterTitle => '블루투스 프린터';

  @override
  String get printerConnected => '연결됨';

  @override
  String get printerDisconnected => '연결 안 됨';

  @override
  String get connectPrinter => '프린터 연결';

  @override
  String get disconnectPrinter => '연결 해제';

  @override
  String get printingReceipt => '영수증 출력 중...';

  @override
  String get printSuccess => '영수증이 출력되었습니다';

  @override
  String get printFailed => '영수증 출력에 실패했습니다';

  @override
  String get noPrintersFound => '블루투스 프린터를 찾을 수 없습니다';

  @override
  String get scanPrinters => '프린터 검색';

  @override
  String get printTestReceipt => '시험 인쇄';

  @override
  String get availableBluetoothDevices => '연결 가능한 블루투스 장치';

  @override
  String get noActiveBluetoothLink => '연결된 블루투스 장치가 없습니다';

  @override
  String get syncStatusTitle => '오프라인 동기화 엔진';

  @override
  String get pendingUploadsCount => '서버 전송 대기 건수';

  @override
  String get lastSyncTime => '최근 동기화 시간';

  @override
  String get syncInProgress => '서버와 데이터 동기화 중...';

  @override
  String get pullingCatalog => '최신 센터 및 상환 일정 다운로드 중...';

  @override
  String get pushingBatch => '오프라인 수납 기록 업로드 중...';

  @override
  String get offlineGuidelinesTitle => '오프라인 업무 가이드라인';

  @override
  String get offlineGuidelinesText =>
      '1. 현장에서 수납한 내역은 SQLCipher AES-256 로컬 데이터베이스에 안전하게 암호화 저장됩니다.\n2. 네트워크가 감지되면 자동으로 서버에 일괄 전송됩니다.\n3. 모바일 프린터로 출력된 영수증은 공식 효력을 가집니다.';

  @override
  String get statSynced => '동기화됨';

  @override
  String get statFailed => '실패';

  @override
  String get navHome => '홈';

  @override
  String get navCenters => '수납';

  @override
  String get navNewLoan => '신규 대출';

  @override
  String get navSavingsCash => '저축 관리';

  @override
  String get navAccount => '계정';

  @override
  String get quickActions => '빠른 작업';

  @override
  String get customize => '사용자 정의';

  @override
  String get viewAll => '전체 보기';

  @override
  String get accountSettings => '계정 및 설정';

  @override
  String get officerProfile => '에이전트 프로필';

  @override
  String get agentAuthorizedRole => '공인 에이전트';

  @override
  String get agentBranchLocation => '양곤 거래 영업소 (BR001)';

  @override
  String get cashInHand => '에이전트 보유 현금 잔액';

  @override
  String get handoverQr => '정산/인계 QR 코드';

  @override
  String get signOut => '로그아웃';

  @override
  String get confirmSignOut => 'BMF 에이전트 앱에서 로그아웃하시겠습니까?';

  @override
  String get deviceSecurity => '생체 인증 및 보안';

  @override
  String get appVersion => '앱 버전';

  @override
  String get appVersionSubtitle => '버전 v2.6.0 (Build 2026.09 - Staging)';

  @override
  String get todayCenterMeeting => '오늘 센터 모임';

  @override
  String get completed => '완료';

  @override
  String get itemsCount => '건';

  @override
  String get membersCount => '명';

  @override
  String get collectedLabel => '수납 완료';

  @override
  String get pendingLabel => '미수납';

  @override
  String get expectedLabel => '예정';

  @override
  String get handoverButton => '인계하기';

  @override
  String get saveCustomization => '설정 저장';

  @override
  String get customizeAgentShortcuts => '빠른 실행 메뉴 설정';

  @override
  String get customizeAgentShortcutsDesc => '자주 사용하는 업무 기능을 선택하여 빠른 메뉴에 고정하세요:';

  @override
  String get actionCollectRepayment => '집단 수납';

  @override
  String get actionNewLoan => '신규 대출 KYC';

  @override
  String get actionSavings => '저축 입금';

  @override
  String get actionCenters => '센터 모임';

  @override
  String get actionManageCash => '보유 현금 관리';

  @override
  String get actionInsurance => '공제 보험';

  @override
  String get actionPrinter => '블루투스 프린터';

  @override
  String get actionSync => '오프라인 동기화';

  @override
  String get agentOperationsSection => '에이전트 업무';

  @override
  String get devicesSyncSection => '기기 및 데이터 동기화';

  @override
  String get systemSettingsSection => '시스템 및 설정';

  @override
  String get hardwarePrinterSection => '프린터 및 외부 기기';

  @override
  String get offlineDataSection => '오프라인 데이터 및 동기화';

  @override
  String get securitySection => '보안 및 세션 인증';

  @override
  String get systemSupportSection => '시스템 및 지원';

  @override
  String get biometricFingerprint => '지문 생체 인증';

  @override
  String get biometricFingerprintDesc => '에이전트 직원을 위한 빠르고 안전한 로그인';

  @override
  String get itHotline => '에이전트 24/7 지원 핫라인';

  @override
  String get itHotlineDesc => '핫라인: 09450011223 (내선 2)';

  @override
  String get thermalPrinterDesc => '휴대용 열전사 프린터 58mm/80mm ESC/POS';

  @override
  String get offlineSyncDesc => '로컬 SQLite와 중앙 서버 간 양방향 동기화';

  @override
  String get manageAgentCashDesc => '보유 현금 실사 및 정산용 QR 코드 생성';

  @override
  String get manageAgentCashTitle => '에이전트 현금 금고 관리';

  @override
  String get sqliteEncryptionDesc =>
      'SQLite AES-256 데이터베이스 암호화 및 하드웨어 KeyStore';

  @override
  String get languageDisplay => '표시 언어';

  @override
  String get latestVersionBadge => '최신';

  @override
  String get secureBadge => '안전';

  @override
  String get connectedBadge => '연결됨';

  @override
  String get pendingUploadsBadge => '대기 중';

  @override
  String get cashManagementTitle => '모바일 현금 관리';

  @override
  String get currentCashInHand => '현재 실제 보유 현금';

  @override
  String get loanRepayments => '대출 상환금';

  @override
  String get savingsDeposits => '저축 예치금';

  @override
  String get handoverToBranch => '지점에 현금 인계 (QR 코드)';

  @override
  String get todayCashTransactions => '오늘 현금 거래 내역';

  @override
  String get noCashTransactions => '오늘 기록된 현금 거래가 없습니다.';

  @override
  String get safetyLimitExceeded => '안전 보유 현금 한도 초과!';

  @override
  String get safetyLimitWarning =>
      '보유 현금이 안전 한도를 초과했습니다. 즉시 지점 출납원에게 인계하거나 은행에 입금하세요.';

  @override
  String get cashHandoverSuccess => '현금 인계가 확인되었습니다!';

  @override
  String get branchCashierHandoverTitle => '지점 출납원 현금 인계';

  @override
  String get transactionsCollectedToday => '오늘 수납한 거래 건수';

  @override
  String get confirmCashierDeposit => '출납원 입금 확인';

  @override
  String get closeButton => '닫기';

  @override
  String get newLoanApplication => '신규 대출 신청 접수';

  @override
  String get originationGuide => '대출 접수 가이드';

  @override
  String get originationGuideText =>
      '1. NRC 신분증으로 본인 인증을 진행합니다.\n2. 차주 거주지의 GPS 좌표를 기록합니다.\n3. 화면에서 전자 서명을 완료합니다.\n4. 신청 내역은 로컬에 암호화 저장 후 대기합니다.';

  @override
  String get gotItButton => '확인';

  @override
  String get borrowerDetails => '차주 및 대출 정보';

  @override
  String get borrowerFullName => '차주 성명 *';

  @override
  String get borrowerFullNameHint => '예: Daw Khin Khin Win';

  @override
  String get borrowerFullNameRequired => '성명은 필수 입력 항목입니다';

  @override
  String get phoneNumber => '연락처 전화번호 *';

  @override
  String get phoneNumberHint => '예: 09123456789';

  @override
  String get phoneNumberRequired => '전화번호는 필수 입력 항목입니다';

  @override
  String get requestedLoanAmount => '신청 대출 금액 (MMK) *';

  @override
  String get requestedLoanAmountRequired => '대출 금액은 필수 입력 항목입니다';

  @override
  String get minLoanAmountValidation => '최소 대출 금액은 100,000 MMK입니다';

  @override
  String get loanTerm => '대출 기간';

  @override
  String get purpose => '자금 용도';

  @override
  String get stepIdentityNrc => '미얀마 NRC 신분증 인증';

  @override
  String get stepGpsSurvey => '거주지 GPS 좌표 실사';

  @override
  String get stepSignature => '차주 전자 서명 (လက်မှတ်)';

  @override
  String get nrcRequiredValidation => '유효한 NRC 카드를 스캔하거나 입력하세요';

  @override
  String get gpsRequiredValidation => '신청서 제출 전에 거주지 GPS 좌표를 기록해야 합니다';

  @override
  String get signatureRequiredValidation => '신청서 제출 전에 차주 전자 서명이 필요합니다';

  @override
  String get submitApplication => '대출 신청서 제출';

  @override
  String get savingApplication => '암호화 및 저장 중...';

  @override
  String get applicationSaved => '신청서가 저장되었습니다';

  @override
  String get applicationSavedSuccessMsg => '대출 신청서가 로컬에 안전하게 저장되어 동기화 대기 중입니다.';

  @override
  String get backToDashboard => '대시보드로 돌아가기';

  @override
  String get positionNrcInFrame =>
      '신분증을 프레임 안에 맞춰주세요\n(မှတ်ပုံတင် ကတ်ပြားအား ထားပါ)';

  @override
  String get nrcInputLabel => '미얀마 NRC 신분증 번호';

  @override
  String get nrcInputHint => '예: 12/DAGANA(N)123456 또는 ၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆';

  @override
  String get invalidNrcFormat => 'NRC 형식이 올바르지 않습니다. 예: 12/DAGANA(N)123456';

  @override
  String get signHerePrompt => '손가락 또는 터치펜으로 서명하세요 (လက်မှတ်ရေးထိုးပါ)';

  @override
  String get clearSignature => '서명 지우기';

  @override
  String get gpsRecordedSuccess => '현장 GPS 좌표가 성공적으로 기록되었습니다.';

  @override
  String get gpsPendingLabel => 'GPS 좌표 미취득';

  @override
  String get gpsRecordedLabel => '거주지 GPS 좌표 기록 완료';

  @override
  String get gpsPromptTap => '위치 아이콘을 탭하여 현장 좌표를 취득하세요';

  @override
  String get savingsTitle => '마을 저축 통장 목록';

  @override
  String get searchSavingHint => '성명, NRC 또는 계좌번호로 검색...';

  @override
  String get depositSavingButton => '저축 입금';

  @override
  String get reloadAccounts => '목록 새로고침';

  @override
  String get noSavingsFound => '저축 계좌를 찾을 수 없습니다.';

  @override
  String get openFirstAccount => '첫 번째 저축 통장 개설';

  @override
  String get openPassbookButton => '신규 통장 개설';

  @override
  String get openSavingsPassbookTitle => '마을 저축 통장 개설';

  @override
  String get memberAccountHolder => '통장 명의인 정보';

  @override
  String get savingsProductPackage => '저축 상품 유형';

  @override
  String get initialCashDeposit => '최초 입금액 (MMK)';

  @override
  String get initialDepositHint => '입금 없이 개설할 경우 0 입력';

  @override
  String get legalNominee => '법정 수익자 정보';

  @override
  String get nomineeFullName => '수익자 성명';

  @override
  String get nomineeNrc => '수익자 NRC 번호';

  @override
  String get nomineeRelation => '차주와의 관계';

  @override
  String get confirmOpenPassbook => '확인 및 통장 개설';

  @override
  String get passbookCreatedTitle => '저축 통장이 개설되었습니다';

  @override
  String get passbookCreatedDesc => '저축 통장이 개설되었으며 서버 동기화 대기열에 추가되었습니다.';

  @override
  String get doneButton => '완료';

  @override
  String get accumulatedBalance => '누적 잔액';

  @override
  String get depositTitle => '입금';

  @override
  String get currentBalanceLabel => '현재 잔액:';

  @override
  String get depositAmountLabel => '입금 금액 (MMK) *';

  @override
  String get depositAmountHint => '입금할 금액을 입력하세요';

  @override
  String get depositAmountRequired => '입금 금액은 필수 입력 항목입니다';

  @override
  String get minDepositValidation => '최소 입금 금액은 1,000 MMK입니다';

  @override
  String get printReceiptCheckbox => '블루투스 프린터로 영수증 출력';

  @override
  String get confirmDeposit => '입금 확인';

  @override
  String get navSavingsTitle => '저축 관리';

  @override
  String get navCashTitle => '현금 관리';

  @override
  String get navInsuranceTitle => '공제 보험';

  @override
  String get insuranceClaimTitle => '소액 공제 보험금 청구';

  @override
  String get claimSubmittedTitle => '보험금 청구서 제출 완료';

  @override
  String get claimSubmittedDesc => '긴급 지원 보험금 청구서가 로컬에 접수되어 지점 승인을 위해 전송되었습니다.';

  @override
  String get claimReferenceCode => '청구 접수 번호';

  @override
  String get beneficiaryIncidentDetails => '수익자 및 사고 정보';

  @override
  String get coveredRiskCategory => '보장 위험 분류';

  @override
  String get requestedAssistanceAmount => '신청 지원금 (MMK) *';

  @override
  String get incidentDescription => '사고 경위 및 내용 설명 *';

  @override
  String get incidentDescriptionHint => '진단명, 입원 일자, 피해 상황 등을 작성해 주세요...';

  @override
  String get incidentDescriptionRequired => '사고 설명은 필수 입력 항목입니다';

  @override
  String get evidentiaryDocuments => '증빙 서류 및 사진';

  @override
  String get villageHeadLetter => '마을 이장 확인서';

  @override
  String get letterAttached => '확인서 첨부됨';

  @override
  String get tapToAttachLetter => '탭하여 사진 첨부 또는 촬영';

  @override
  String get medicalReceipt => '병원비 영수증 / 진료비 명세서';

  @override
  String get receiptAttached => '영수증 첨부됨';

  @override
  String get tapToAttachReceipt => '탭하여 사진 첨부 또는 촬영';

  @override
  String get submitEmergencyClaim => '긴급 지원금 청구서 제출';

  @override
  String get submittingClaim => '청구서 제출 중...';

  @override
  String get letterAttachedToast => '이장 확인서 사진이 첨부되었습니다.';

  @override
  String get receiptAttachedToast => '의료비 영수증 사진이 첨부되었습니다.';

  @override
  String get savingProductCompulsory => '의무 마이크로 저축';

  @override
  String get savingProductVoluntary => '자율 입출식 저축';

  @override
  String get savingProductFixedTerm => '정기 저축 예금';

  @override
  String get cashTxLoanRepayment => '대출 분할상환금 수납';

  @override
  String get cashTxSavingDeposit => '마을 저축 입금';

  @override
  String get cashTxSavingOpen => '통장 개설 최초 예치금';

  @override
  String get cashTxHandover => '지점 출납원 현금 인계';

  @override
  String get claimRiskIllness => '입원 치료 지원';

  @override
  String get claimRiskAccident => '산재 및 교통사고';

  @override
  String get claimRiskNaturalDisaster => '풍수해 및 화재 재난';

  @override
  String get claimRiskDeath => '조합원 및 배우자 사망 위로금';

  @override
  String get claimRiskCropFailure => '농작물 병충해 및 가뭄 피해';

  @override
  String get claimAmountRequired => '지원 요청 금액을 입력해주세요';

  @override
  String get invalidAmountValidation => '0보다 큰 유효한 금액을 입력해주세요';

  @override
  String get methodAyaPay => 'AYA Pay 전자지갑';

  @override
  String get methodMytelPay => 'MytelPay 전자지갑';

  @override
  String get methodBankTransfer => '계좌 이체';
}
