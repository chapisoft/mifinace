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
  String get loginTitle => 'BMF 대출 담당자 로그인';

  @override
  String get usernameLabel => '담당자 사용자 이름';

  @override
  String get passwordLabel => '비밀번호';

  @override
  String get loginButton => '로그인';

  @override
  String get biometricLogin => '생체 인증으로 로그인';

  @override
  String get dashboardTitle => '현장 운영 대시보드';

  @override
  String get centersTitle => '센터 및 그룹';

  @override
  String get collectionSheetTitle => '수납 명세서';

  @override
  String get offlineSyncTitle => '오프라인 동기화';

  @override
  String get todayTarget => '오늘의 목표';

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
}
