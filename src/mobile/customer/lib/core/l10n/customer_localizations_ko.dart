import 'customer_localizations.dart';

/// Korean (`ko`) translations.
class CustomerLocalizationsKo extends CustomerLocalizations {
  CustomerLocalizationsKo([super.locale = 'ko']);

  @override
  String get appTitle => 'BMF 마이크로파이낸스';
  @override
  String get home => '홈';
  @override
  String get loans => '대출';
  @override
  String get savings => '저축';
  @override
  String get insurance => '공제';
  @override
  String get notifications => '알림';
  @override
  String get navHome => '홈';
  @override
  String get navLoans => '대출';
  @override
  String get navScanQr => 'MMQR 결제';
  @override
  String get navHistory => '내역';
  @override
  String get navAccount => '계정';

  // Common Actions & Dialogs
  @override
  String get close => '닫기';
  @override
  String get cancel => '취소';
  @override
  String get confirm => '확인';
  @override
  String get done => '완료';
  @override
  String get save => '저장';
  @override
  String get retry => '다시 시도';
  @override
  String get selectLanguage => '언어 선택';
  @override
  String get version => '버전';
  @override
  String get viewAll => '전체보기';
  @override
  String get customize => '사용자 설정';
  @override
  String get quickActions => '빠른 실행';
  @override
  String get customizeQuickActions => '빠른 실행 사용자 설정';
  @override
  String get customizeQuickActionsDesc => '홈 화면에 표시할 자주 사용하는 기능을 선택하세요:';
  @override
  String get saveChanges => '변경 사항 저장';
  @override
  String get maxShortcutsReached => '최대 4개의 바로가기만 선택할 수 있습니다';
  @override
  String get minShortcutsRequired => '최소 1개의 바로가기를 선택하세요';

  // Authentication
  @override
  String get loginTitle => '회원 로그인';
  @override
  String get phoneLabel => '전화번호';
  @override
  String get nrcLabel => 'NRC 신분증 번호';
  @override
  String get memberIdOrPhoneOrNrc => '회원번호 / 전화번호 / NRC';
  @override
  String get continueButton => '다음';
  @override
  String get switchAccount => '계정 전환';
  @override
  String get forgotPin => 'PIN을 잊으셨나요?';
  @override
  String get enter6DigitPin => '6자리 보안 PIN 번호 입력';
  @override
  String get notActivatedPrompt => '계정이 활성화되지 않았습니다. 지금 OTP를 전송하여 활성화하시겠습니까?';
  @override
  String get activateNow => '지금 활성화';
  @override
  String get welcomeBack => '다시 오신 것을 환영합니다';
  @override
  String get firstTimeUsingApp => '처음 이용하시나요?';
  @override
  String get activateWithInfo => '회원번호, 전화번호 또는 NRC로 활성화';
  @override
  String get splashTagline => '디지털 연대 소액금융 및 회원 금융 서비스';
  @override
  String get savedMemberAccount => '저장된 회원 계정';
  @override
  String get requestOtp => 'OTP 요청';
  @override
  String get otpTitle => 'SMS 인증코드 확인';
  @override
  String get verifyOtp => '인증하기';
  @override
  String get setPinTitle => '6자리 PIN 번호 설정';
  @override
  String get confirmPinTitle => '6자리 PIN 번호 재입력';
  @override
  String get enterPinTitle => '보안 PIN 번호 입력';
  @override
  String get biometricLogin => '생체인식 로그인';
  @override
  String get pinMismatch => 'PIN 번호가 일치하지 않습니다';
  @override
  String get pinSuccess => 'PIN 번호 설정 완료';
  @override
  String get inputIdentifierRequired => '회원번호, 전화번호 또는 NRC를 입력해 주세요.';

  // Dashboard & Member Profile
  @override
  String get welcomeMember => '환영합니다';
  @override
  String get memberCode => '회원 코드';
  @override
  String get groupCode => '그룹 코드';
  @override
  String get totalOutstanding => '총 잔여 대출금액';
  @override
  String get activeLoans => '이용 중인 대출';
  @override
  String get dueAlertTitle => '상환 기일 도래 알림';
  @override
  String get payNow => '지금 상환하기';
  @override
  String get quickServices => '빠른 서비스';
  @override
  String get digitalMemberCard => '디지털 회원카드';
  @override
  String get memberQrTitle => 'BMF 디지털 회원증';
  @override
  String get centerLabel => '센터명';
  @override
  String get groupLabel => '연대 그룹';
  @override
  String get meetingScheduleLabel => '정기 모임 일정';
  @override
  String get weeklyMeetingTime => '매주 금요일 • 오전 09:00';
  @override
  String get assignedOfficerLabel => '담당 대출 심사역';
  @override
  String get noRecentTransactions => '최근 거래 내역이 없습니다.';
  @override
  String get periodNumberLabel => '회차';

  // Overview Metrics & Status
  @override
  String get outstandingLoanMetric => '잔여 대출원금';
  @override
  String get dueMetric => '다음 납부금액';
  @override
  String get totalSavingsMetric => '총 저축 잔액';
  @override
  String get loyaltyPointsMetric => '회원 포인트';
  @override
  String get memberActiveStatus => '우수 회원 상태';

  // Home Menu Items
  @override
  String get menuMmqrTitle => 'MMQR 상환';
  @override
  String get menuMmqrSubtitle => '국가 결제 게이트웨이';
  @override
  String get menuLoansTitle => '대출 목록';
  @override
  String get menuLoansSubtitle => '상환 일정 및 세부내역';
  @override
  String get menuSavingsTitle => '저축 계좌';
  @override
  String get menuSavingsSubtitle => '통장 및 이자 수익';
  @override
  String get menuInsuranceTitle => '상조 공제';
  @override
  String get menuInsuranceSubtitle => '의료비 및 재해 구호';
  @override
  String get menuApplyLoanTitle => '스피드 대출';
  @override
  String get menuApplyLoanSubtitle => '온라인 간편 신청';
  @override
  String get menuHistoryTitle => '거래 내역';
  @override
  String get menuHistorySubtitle => '전자 영수증 조회';
  @override
  String get menuBranchesTitle => '영업점 안내';
  @override
  String get menuBranchesSubtitle => '가까운 서비스 지점';
  @override
  String get menuNotificationsTitle => '알림';
  @override
  String get menuNotificationsSubtitle => '상환 일정 알림';

  // Loans & Schedule
  @override
  String get loansTitle => '대출 목록';
  @override
  String get loanDetails => '계약 상세정보';
  @override
  String get scheduleTitle => '정기 상환 스케줄';
  @override
  String get period => '회차';
  @override
  String get dueDate => '납부기일';
  @override
  String get principal => '원금';
  @override
  String get interest => '이자';
  @override
  String get insuranceFee => '공제료';
  @override
  String get totalDue => '총 납부액';
  @override
  String get statusPaid => '수납완료';
  @override
  String get statusPending => '미납';
  @override
  String get statusOverdue => '연체';

  // 5 FRD Debt Groups
  @override
  String get debtGroupCurrent => '그룹 1 - 정상 (Current)';
  @override
  String get debtGroupSpecialMention => '그룹 2 - 요주의 (Special Mention)';
  @override
  String get debtGroupSubstandard => '그룹 3 - 고정 (Substandard)';
  @override
  String get debtGroupDoubtful => '그룹 4 - 회수의문 (Doubtful)';
  @override
  String get debtGroupLoss => '그룹 5 - 추정손실 (Loss)';

  // Payments & MMQR
  @override
  String get paymentTitle => 'MMQR 디지털 결제';
  @override
  String get scanMmqr => 'MMQR 코드 스캔';
  @override
  String get mmqrRepaymentTitle => 'MMQR 디지털 대출상환';
  @override
  String get generatingMmqr => 'CBM 표준 dynamic MMQR 생성 중...';
  @override
  String get openWallet => '모바일 월렛으로 결제';
  @override
  String get launchKbzPay => 'KBZPay 열기';
  @override
  String get launchWavePay => 'WavePay 열기';
  @override
  String get launchAyaPay => 'AYA Pay 열기';
  @override
  String get launchMytelPay => 'MytelPay 열기';
  @override
  String get saveQrImage => 'QR 이미지 저장';
  @override
  String get paymentSuccess => '상환 완료!';
  @override
  String get electronicReceipt => '전자 영수증';
  @override
  String get referenceNo => '거래 참조번호';
  @override
  String get returnHome => '홈으로 이동';
  @override
  String get backToHome => '홈으로 이동';
  @override
  String get contractCodeLabel => '계약 번호';
  @override
  String get transactionRefLabel => '거래 번호';
  @override
  String get paymentChannelLabel => '결제 채널';
  @override
  String get settledDateLabel => '정산 일시';
  @override
  String get totalPaidAmountLabel => '실제 납부금액';
  @override
  String get totalTransactionAmount => '총 거래 금액';
  @override
  String get noMatchingTransactions => '해당 거래 내역이 없습니다';
  @override
  String get tryDifferentFilter => '다른 기간 또는 카테고리를 선택해 보세요';
  @override
  String get details => '상세보기';
  @override
  String get savingReceiptPdf => '영수증 PDF를 기기에 저장하는 중...';
  @override
  String get savePdf => 'PDF 저장';
  @override
  String get sharingReceipt => '영수증 공유 링크 생성 중...';
  @override
  String get share => '공유';
  @override
  String get filterAll => '전체';
  @override
  String get filterRepayment => '상환';
  @override
  String get filterSavings => '저축';
  @override
  String get filterInsurance => '보험료';
  @override
  String get searchPlaceholder => '거래번호, 계약번호로 검색...';
  @override
  String get allTime => '전체 기간';
  @override
  String get thisMonth => '이번 달';
  @override
  String get last3Months => '최근 3개월';
  @override
  String get filterModalTitle => '거래 내역 필터';

  // Savings
  @override
  String get savingsTitle => '저축 및 통장';
  @override
  String get savingsAndPassbooks => '저축 및 통장 내역';
  @override
  String get accruedInterest => '누적 이자 수익';
  @override
  String get openSavingOnline => '온라인 저축통장 개설';
  @override
  String get openSavingsPassbookTitle => '고수익 정기예금 가입';
  @override
  String get passbookOpenedSuccess => '통장이 개설되었습니다!';
  @override
  String get viewPassbooks => '통장 목록 확인';
  @override
  String get expectedProfitAtMaturity => '만기 예상 수익:';
  @override
  String get confirmAndSubscribe => '확인 및 가입';
  @override
  String get depositPrincipal => '예치 원금';
  @override
  String get accruedProfitYield => '이자 수익';
  @override
  String get compulsorySaving => '그룹 의무 저축';
  @override
  String get voluntarySaving => '자유 입출금 저축';
  @override
  String get fixedTermSaving => '고수익 정기적금';
  @override
  String get interestRatePerAnnum => '연간 수익률';

  // Insurance
  @override
  String get insuranceTitle => '회원 상호부조 공제';
  @override
  String get medicalBenefitTitle => '입원비 및 재난 구호금';
  @override
  String get medicalBenefitDesc => '긴급 입원비 지원 및 재해 보상금';
  @override
  String get submitClaim => '공제금 지급 신청';
  @override
  String get mutualAidClaimTitle => '상호부조금 청구서';
  @override
  String get illnessRisk => '질병 및 입원 치료';
  @override
  String get accidentRisk => '불의의 사고 및 상해';
  @override
  String get naturalDisasterRisk => '풍수해 및 자연재해';
  @override
  String get uploadInvoices => '퇴원확인서 또는 진료비 영수증 첨부';
  @override
  String get attachMedicalDocument => '의료 증빙서류 첨부';
  @override
  String get documentAttachedSimulated => '증빙서류 1건 첨부됨';
  @override
  String get submitInsuranceClaim => '공제금 청구서 제출';
  @override
  String get claimFiledSuccess => '신청이 정상적으로 접수되었습니다';
  @override
  String get claimSubmitted => '청구 완료';

  // Notifications
  @override
  String get notificationsTitle => '알림';
  @override
  String get notificationCenterTitle => '알림 센터';
  @override
  String get markAllRead => '모두 읽음으로 표시';
  @override
  String get noNotifications => '새로운 알림이 없습니다';
  @override
  String get noNotificationsFound => '알림 기록이 없습니다';

  // Fast Loan & Application
  @override
  String get applyLoanTitle => '빠른 대출 신청';
  @override
  String get tabApplyLoan => '대출 신청';
  @override
  String get tabTrackApplications => '신청 내역';
  @override
  String get selectLoanPackage => '대출 상품 선택';
  @override
  String get loanAmountToBorrow => '대출 희망 금액';
  @override
  String get minAmountLabel => '최소';
  @override
  String get maxAmountLabel => '최대';
  @override
  String get loanTerm => '대출 기간';
  @override
  String get repaymentFrequency => '상환 주기';
  @override
  String get monthly => '매월';
  @override
  String get biweekly => '격주';
  @override
  String get weekly => '매주';
  @override
  String get estimatedMonthlyRepayment => '월 예상 상환액';
  @override
  String get monthlyPrincipal => '월 원금';
  @override
  String get monthlyInterest => '월 이자';
  @override
  String get welfareInsuranceFee => '공제 보험료 (0.5%)';
  @override
  String get disbursementMethod => '지급 방식';
  @override
  String get loanPurpose => '대출 목적';
  @override
  String get loanPurposeHint => '예: 비료 구매, 재고 확충...';
  @override
  String get submitLoanApplication => '대출 신청서 제출';
  @override
  String get applicationSubmittedSuccess => '신청이 완료되었습니다';
  @override
  String get viewProgress => '진행 상황 확인';
  @override
  String get searchApplicationPlaceholder => '신청 번호 또는 상품 검색...';
  @override
  String get appStatusUnderReview => '심사 중';
  @override
  String get appStatusApproved => '승인됨';
  @override
  String get appStatusDisbursed => '지급 완료';
  @override
  String get appStatusRejected => '거절됨';
  @override
  String get noActiveLoansToRepay => '상환할 대출이 없습니다';
  @override
  String get selectLoanToRepay => '상환할 대출 선택';
  @override
  String get monthsTerm => '개월';
  @override
  String get interestPerMonth => '월';

  // Account Screen & Settings
  @override
  String get accountTitle => '계정 및 보안';
  @override
  String get securityTitle => '보안 및 본인 인증';
  @override
  String get changePin => 'PIN 변경';
  @override
  String get changePinSecurityTitle => '보안 PIN 번호 변경';
  @override
  String get currentPinLabel => '현재 PIN 번호';
  @override
  String get newPinLabel => '새로운 6자리 PIN';
  @override
  String get confirmNewPinLabel => '새 PIN 번호 재입력';
  @override
  String get pinChangedSuccess => 'PIN 번호가 성공적으로 변경되었습니다';
  @override
  String get biometricAuth => '생체인식 인증';
  @override
  String get biometricSubtitle => 'FaceID / 지문 빠른 로그인';
  @override
  String get deviceSecurity => '기기 보안 상태';
  @override
  String get deviceSecurityStatus => '기기 보안 진단';
  @override
  String get deviceSecurityPass => '정상';
  @override
  String get deviceSecurityDesc => 'SSL Pinning 및 무단 변조 방지: 규정 준수';
  @override
  String get utilitiesTitle => '고객센터 및 편의기능';
  @override
  String get settingsAndPreferences => '설정 및 환경설정';
  @override
  String get languageSettingTitle => '표시 언어';
  @override
  String get dueReminderNotifications => '상환 기일 사전 알림';
  @override
  String get dueReminderDesc => '납부일 3일 전 자동 알림';
  @override
  String get branchNetwork => '지점 안내';
  @override
  String get supportHotline => '회원 전용 고객센터';
  @override
  String get termsAndPrivacy => '대출 약관 및 개인정보 처리방침';
  @override
  String get appVersion => '앱 버전';
  @override
  String get signOut => '로그아웃';
  @override
  String get confirmSignOut => '정말 로그아웃 하시겠습니까?';
  @override
  String get signOutConfirmTitle => '계정 로그아웃';
  @override
  String get signOutConfirmDesc => 'BMF 회원 포털에서 로그아웃 하시겠습니까?';
}
