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
  String get insurance => '공제보험';
  @override
  String get notifications => '알림';

  @override
  String get loginTitle => '회원 로그인';
  @override
  String get phoneLabel => '전화번호';
  @override
  String get nrcLabel => '신분증 번호 (NRC)';
  @override
  String get requestOtp => 'SMS 인증번호 받기';
  @override
  String get otpTitle => 'SMS 인증번호 확인';
  @override
  String get verifyOtp => '인증하기';
  @override
  String get setPinTitle => '6자리 비밀번호 설정';
  @override
  String get confirmPinTitle => '6자리 비밀번호 재입력';
  @override
  String get enterPinTitle => '비밀번호를 입력하세요';
  @override
  String get biometricLogin => '생체인식으로 로그인';
  @override
  String get pinMismatch => '비밀번호가 일치하지 않습니다';
  @override
  String get pinSuccess => '보안 비밀번호 설정이 완료되었습니다';

  @override
  String get welcomeMember => '환영합니다';
  @override
  String get memberCode => '회원번호';
  @override
  String get groupCode => '연대조 번호';
  @override
  String get totalOutstanding => '총 잔여 대출금';
  @override
  String get activeLoans => '이용 중인 대출';
  @override
  String get dueAlertTitle => '상환일 도래 알림';
  @override
  String get payNow => '지금 상환하기';
  @override
  String get quickServices => '빠른 서비스';

  @override
  String get loansTitle => '대출 내역';
  @override
  String get loanDetails => '대출 상세 정보';
  @override
  String get scheduleTitle => '상환 일정 계획';
  @override
  String get period => '회차';
  @override
  String get dueDate => '상환 기한';
  @override
  String get principal => '원금';
  @override
  String get interest => '이자';
  @override
  String get insuranceFee => '공제보험료';
  @override
  String get totalDue => '상환 합계액';
  @override
  String get statusPaid => '상환 완료';
  @override
  String get statusPending => '미상환';
  @override
  String get statusOverdue => '연체';

  @override
  String get debtGroupCurrent => '정상 (1단계)';
  @override
  String get debtGroupSpecialMention => '요주의 (2단계)';
  @override
  String get debtGroupSubstandard => '고정 (3단계)';
  @override
  String get debtGroupDoubtful => '회수의문 (4단계)';
  @override
  String get debtGroupLoss => '추정손실 (5단계)';

  @override
  String get paymentTitle => 'MMQR 전자결제';
  @override
  String get scanMmqr => '은행 또는 지갑 앱으로 QR 스캔';
  @override
  String get openWallet => '전자지갑 열기';
  @override
  String get launchKbzPay => 'KBZPay 로 결제';
  @override
  String get launchWavePay => 'WavePay 로 결제';
  @override
  String get launchAyaPay => 'AYA Pay 로 결제';
  @override
  String get launchMytelPay => 'MytelPay 로 결제';
  @override
  String get saveQrImage => 'QR 코드 이미지 저장';
  @override
  String get paymentSuccess => '대출 상환 결제 완료';
  @override
  String get electronicReceipt => '공식 전자 영수증';
  @override
  String get referenceNo => '거래 참조 번호';
  @override
  String get returnHome => '홈으로 돌아가기';

  @override
  String get savingsTitle => '저축 계좌';
  @override
  String get accruedInterest => '누적 발생 이자';
  @override
  String get openSavingOnline => '온라인 저축 통장 개설';
  @override
  String get compulsorySaving => '의무 저축';
  @override
  String get voluntarySaving => '자율 저축';
  @override
  String get fixedTermSaving => '정기 예금';
  @override
  String get interestRatePerAnnum => '연이율';

  @override
  String get insuranceTitle => '회원 상호부조 기금';
  @override
  String get medicalBenefitTitle => '의료 입원 보조금 (일 10,000 MMK)';
  @override
  String get medicalBenefitDesc => '질병 및 사고에 대한 포괄적 상호 복지 지원';
  @override
  String get submitClaim => '보험금 지급 신청';
  @override
  String get illnessRisk => '질병 입원';
  @override
  String get accidentRisk => '불의의 사고';
  @override
  String get naturalDisasterRisk => '자연재해';
  @override
  String get uploadInvoices => '병원 영수증 및 확인서 첨부';
  @override
  String get claimSubmitted => '보험금 지급 신청이 성공적으로 접수되었습니다';

  @override
  String get notificationsTitle => '알림 센터';
  @override
  String get markAllRead => '모두 읽음으로 표시';
  @override
  String get noNotifications => '새로운 알림이 없습니다';
}
