// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'BMF Agent';

  @override
  String get loginTitle => 'Đăng nhập Điểm Đại lý BMF';

  @override
  String get loginSubtitle => 'Hệ sinh thái Tác nghiệp Điểm Đại lý BMF';

  @override
  String get agentAuthHeader => 'Xác thực Tài khoản Đại lý';

  @override
  String get agentAuthDesc =>
      'Nhập thông tin tài khoản đại lý để truy cập hệ thống thu hộ & giao dịch.';

  @override
  String get usernameLabel => 'Tên đăng nhập / Mã đại lý';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get biometricLogin => 'Đăng nhập bằng Sinh trắc học';

  @override
  String get loginValidationEmpty =>
      'Vui lòng nhập tên tài khoản đại lý và mật khẩu.';

  @override
  String get selectLanguageTitle => 'Chọn ngôn ngữ hiển thị';

  @override
  String get securityBadgeFooter =>
      'Bảo mật bởi BMF SSL Pinning & Hardware Keystore';

  @override
  String get dashboardTitle => 'Bảng điều hành Điểm Đại lý';

  @override
  String get centersTitle => 'Danh sách Cụm và Tổ';

  @override
  String get collectionSheetTitle => 'Bảng kê Thu nợ';

  @override
  String get offlineSyncTitle => 'Đồng bộ Ngoại tuyến';

  @override
  String get todayTarget => 'Chỉ tiêu thu hôm nay';

  @override
  String get progressCompleted => 'Hoàn thành';

  @override
  String get collectedAmount => 'Số tiền đã thu';

  @override
  String get remainingAmount => 'Số tiền còn lại';

  @override
  String get memberCount => 'Tổng số thành viên';

  @override
  String get collectPayment => 'Thu nợ';

  @override
  String get printReceipt => 'In biên lai';

  @override
  String get syncNow => 'Đồng bộ ngay';

  @override
  String get syncPending => 'Chờ đồng bộ';

  @override
  String get syncSuccess => 'Đồng bộ dữ liệu thành công';

  @override
  String get networkOnline => 'Trực tuyến';

  @override
  String get networkOffline => 'Ngoại tuyến (Lưu trữ nội bộ)';

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
  String get searchCenterHint => 'Tìm kiếm theo tên hoặc mã cụm';

  @override
  String get meetingDayLabel => 'Ngày sinh hoạt';

  @override
  String get meetingTimeLabel => 'Giờ sinh hoạt';

  @override
  String get townshipLabel => 'Khu vực';

  @override
  String get groupCountLabel => 'Số tổ vay vốn';

  @override
  String get selectCenterPrompt => 'Chọn một cụm để xem bảng kê thu nợ';

  @override
  String get noCentersMatch => 'Không có cụm nào khớp với từ khóa tìm kiếm';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterDueToday => 'Đến hạn hôm nay';

  @override
  String get filterOverdue => 'Quá hạn';

  @override
  String get filterPaid => 'Đã thanh toán';

  @override
  String get contractCodeLabel => 'Mã hợp đồng';

  @override
  String get customerNameLabel => 'Tên khách hàng';

  @override
  String get periodNumberLabel => 'Kỳ trả nợ';

  @override
  String get principalLabel => 'Tiền gốc';

  @override
  String get interestLabel => 'Tiền lãi';

  @override
  String get insuranceLabel => 'Phí bảo hiểm';

  @override
  String get savingLabel => 'Tiết kiệm bắt buộc';

  @override
  String get totalDueLabel => 'Tổng số tiền phải thu';

  @override
  String get paymentMethodLabel => 'Phương thức thanh toán';

  @override
  String get methodCash => 'Tiền mặt MMK';

  @override
  String get methodMmqr => 'Mã QR MMQR';

  @override
  String get methodKbzPay => 'Ví điện tử KBZPay';

  @override
  String get methodWavePay => 'Ví điện tử WavePay';

  @override
  String get confirmCollectionButton => 'Xác nhận và Ghi nhận';

  @override
  String get cancelButton => 'Hủy bỏ';

  @override
  String get collectionSuccessMessage => 'Ghi nhận thu nợ thành công';

  @override
  String get collectionFailedMessage => 'Ghi nhận thu nợ thất bại';

  @override
  String get noRepaymentsFound => 'Không tìm thấy khoản thu nào theo bộ lọc';

  @override
  String get dueLabel => 'Hạn trả';

  @override
  String get paidOfflineBadge => 'Đã thu (Hàng đợi ngoại tuyến)';

  @override
  String get paidSyncedBadge => 'Đã thu (Đã đồng bộ)';

  @override
  String get statusOverdue => 'Quá hạn';

  @override
  String get statusPending => 'Chờ thu';

  @override
  String get retryButton => 'Thử lại';

  @override
  String get bluetoothPrinterTitle => 'Máy in nhiệt Bluetooth';

  @override
  String get printerConnected => 'Đã kết nối';

  @override
  String get printerDisconnected => 'Chưa kết nối';

  @override
  String get connectPrinter => 'Kết nối máy in';

  @override
  String get disconnectPrinter => 'Ngắt kết nối';

  @override
  String get printingReceipt => 'Đang in biên lai...';

  @override
  String get printSuccess => 'In biên lai thành công';

  @override
  String get printFailed => 'In biên lai thất bại';

  @override
  String get noPrintersFound => 'Không tìm thấy máy in Bluetooth';

  @override
  String get scanPrinters => 'Tìm kiếm máy in';

  @override
  String get printTestReceipt => 'In thử biên lai kiểm tra';

  @override
  String get availableBluetoothDevices =>
      'Danh sách thiết bị Bluetooth khả dụng';

  @override
  String get noActiveBluetoothLink => 'Chưa thiết lập liên kết Bluetooth';

  @override
  String get syncStatusTitle => 'Sync Engine Ngoại tuyến';

  @override
  String get pendingUploadsCount => 'Giao dịch chờ tải lên máy chủ';

  @override
  String get lastSyncTime => 'Lần đồng bộ gần nhất';

  @override
  String get syncInProgress => 'Đang đồng bộ dữ liệu với máy chủ...';

  @override
  String get pullingCatalog =>
      'Đang tải danh mục cụm và lịch thu nợ mới nhất...';

  @override
  String get pushingBatch => 'Đang gửi danh sách giao dịch thu nợ...';

  @override
  String get offlineGuidelinesTitle => 'Quy tắc vận hành Ngoại tuyến';

  @override
  String get offlineGuidelinesText =>
      '1. Các giao dịch thu nợ thực hiện tại bản làng vùng sâu được mã hóa trong CSDL cục bộ SQLCipher AES-256 với khóa Idempotency UUIDv4.\n2. Khi phát hiện có kết nối mạng di động/Wi-Fi, hệ thống sẽ tự động gửi dữ liệu theo lô 50 giao dịch.\n3. Biên lai in nhiệt cầm tay có giá trị pháp lý và được đối soát tức thì khi đồng bộ lên máy chủ.';

  @override
  String get statSynced => 'Đã đồng bộ';

  @override
  String get statFailed => 'Lỗi';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navCenters => 'Thu hộ & Cụm';

  @override
  String get navNewLoan => 'Vay mới KYC';

  @override
  String get navSavingsCash => 'Tiết kiệm';

  @override
  String get navAccount => 'Tài khoản';

  @override
  String get quickActions => 'Tác nghiệp nhanh';

  @override
  String get customize => 'Tùy chỉnh';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get accountSettings => 'Tài khoản & Thiết lập';

  @override
  String get officerProfile => 'Hồ sơ Điểm Đại lý';

  @override
  String get agentAuthorizedRole => 'Đại lý Ủy quyền';

  @override
  String get agentBranchLocation => 'Điểm giao dịch Yangon (BR001)';

  @override
  String get cashInHand => 'Số dư quỹ tiền mặt đại lý';

  @override
  String get handoverQr => 'QR Nộp quỹ & Quyết toán';

  @override
  String get signOut => 'Đăng xuất';

  @override
  String get confirmSignOut =>
      'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng Đại lý BMF?';

  @override
  String get deviceSecurity => 'Sinh trắc học & Bảo mật';

  @override
  String get appVersion => 'Phiên bản ứng dụng';

  @override
  String get appVersionSubtitle => 'Phiên bản v2.6.0 (Build 2026.09 - Staging)';

  @override
  String get todayCenterMeeting => 'Lịch họp cụm hôm nay';

  @override
  String get completed => 'Hoàn thành';

  @override
  String get itemsCount => 'mục';

  @override
  String get membersCount => 'thành viên';

  @override
  String get collectedLabel => 'Đã thu';

  @override
  String get pendingLabel => 'Chưa thu';

  @override
  String get expectedLabel => 'Dự kiến';

  @override
  String get handoverButton => 'Bàn giao';

  @override
  String get saveCustomization => 'Lưu tùy chỉnh';

  @override
  String get customizeAgentShortcuts => 'Tùy chỉnh Tiện ích Đại lý';

  @override
  String get customizeAgentShortcutsDesc =>
      'Chọn các chức năng tác nghiệp thường xuyên sử dụng để ghim lên thanh tiện ích nhanh:';

  @override
  String get actionCollectRepayment => 'Thu nợ cụm';

  @override
  String get actionNewLoan => 'Vay mới KYC';

  @override
  String get actionSavings => 'Gửi tiết kiệm';

  @override
  String get actionCenters => 'Lịch cụm GD';

  @override
  String get actionManageCash => 'Quỹ tiền mặt đại lý';

  @override
  String get actionInsurance => 'Bảo hiểm tương trợ';

  @override
  String get actionPrinter => 'Máy in nhiệt Bluetooth';

  @override
  String get actionSync => 'Đồng bộ dữ liệu Offline';

  @override
  String get agentOperationsSection => 'TÁC NGHIỆP ĐẠI LÝ';

  @override
  String get devicesSyncSection => 'THIẾT BỊ & ĐỒNG BỘ';

  @override
  String get systemSettingsSection => 'HỆ THỐNG & CÀI ĐẶT';

  @override
  String get hardwarePrinterSection => 'THIẾT BỊ NGOẠI VI & IN ẤN';

  @override
  String get offlineDataSection => 'DỮ LIỆU NGOẠI TUYẾN & ĐỒNG BỘ';

  @override
  String get securitySection => 'BẢO MẬT & XÁC THỰC PHIÊN';

  @override
  String get systemSupportSection => 'HỆ THỐNG & HỖ TRỢ';

  @override
  String get biometricFingerprint => 'Xác thực sinh trắc học vân tay';

  @override
  String get biometricFingerprintDesc =>
      'Đăng nhập nhanh an toàn cho nhân viên đại lý';

  @override
  String get itHotline => 'Tổng đài Hỗ trợ Đại lý 24/7';

  @override
  String get itHotlineDesc => 'Hotline: 09450011223 (Nhánh 2 - Kênh Đại lý)';

  @override
  String get thermalPrinterDesc => 'Máy in nhiệt cầm tay 58mm/80mm ESC/POS';

  @override
  String get offlineSyncDesc => 'Đồng bộ 2 chiều SQLite và máy chủ trung tâm';

  @override
  String get manageAgentCashDesc =>
      'Kiểm đếm tiền mặt và tạo QR nộp quỹ quyết toán';

  @override
  String get manageAgentCashTitle => 'Quản lý Quỹ tiền mặt đại lý';

  @override
  String get sqliteEncryptionDesc =>
      'Mã hóa cơ sở dữ liệu SQLite AES-256 & Khóa phần cứng';

  @override
  String get languageDisplay => 'Ngôn ngữ hiển thị';

  @override
  String get latestVersionBadge => 'Mới nhất';

  @override
  String get secureBadge => 'An toàn';

  @override
  String get connectedBadge => 'Đã kết nối';

  @override
  String get pendingUploadsBadge => 'chờ tải';

  @override
  String get cashManagementTitle => 'Quản lý Quỹ tiền mặt Đại lý';

  @override
  String get currentCashInHand => 'Số dư tiền mặt thực tế tại điểm';

  @override
  String get loanRepayments => 'Thu hồi nợ vay';

  @override
  String get savingsDeposits => 'Tiền gửi tiết kiệm';

  @override
  String get handoverToBranch => 'Tạo mã QR nộp quỹ quyết toán';

  @override
  String get todayCashTransactions => 'Bảng kê giao dịch tiền mặt hôm nay';

  @override
  String get noCashTransactions =>
      'Chưa có giao dịch tiền mặt nào được ghi nhận hôm nay.';

  @override
  String get safetyLimitExceeded => 'Vượt hạn mức tiền mặt an toàn!';

  @override
  String get safetyLimitWarning =>
      'Số tiền mặt giữ tại điểm vượt quá hạn mức cho phép. Vui lòng nộp quỹ về chi nhánh hoặc ngân hàng ngay lập tức.';

  @override
  String get cashHandoverSuccess => 'Xác nhận nộp quỹ quyết toán thành công!';

  @override
  String get branchCashierHandoverTitle => 'Bàn giao Quỹ Tiền mặt Chi nhánh';

  @override
  String get transactionsCollectedToday => 'giao dịch đã thu hôm nay';

  @override
  String get confirmCashierDeposit => 'Xác nhận Nộp quỹ Thủ quỹ';

  @override
  String get closeButton => 'Đóng';

  @override
  String get newLoanApplication => 'Tiếp nhận Khoản vay mới';

  @override
  String get originationGuide => 'Hướng dẫn Thẩm định Vay';

  @override
  String get originationGuideText =>
      '1. Xác thực danh tính khách hàng qua thẻ NRC.\n2. Ghi nhận tọa độ GPS tại nơi cư trú của người vay.\n3. Hoàn tất chữ ký điện tử sinh trắc học trên màn hình.\n4. Hồ sơ được mã hóa lưu cục bộ và xếp hàng chờ duyệt.';

  @override
  String get gotItButton => 'Đã hiểu';

  @override
  String get borrowerDetails => 'Thông tin Khách hàng & Khoản vay';

  @override
  String get borrowerFullName => 'Họ và tên khách hàng *';

  @override
  String get borrowerFullNameHint => 'Ví dụ: Daw Khin Khin Win';

  @override
  String get borrowerFullNameRequired => 'Họ và tên khách hàng là bắt buộc';

  @override
  String get phoneNumber => 'Số điện thoại liên hệ *';

  @override
  String get phoneNumberHint => 'Ví dụ: 09123456789';

  @override
  String get phoneNumberRequired => 'Số điện thoại liên hệ là bắt buộc';

  @override
  String get requestedLoanAmount => 'Số tiền đề nghị vay (MMK) *';

  @override
  String get requestedLoanAmountRequired => 'Số tiền vay là bắt buộc';

  @override
  String get minLoanAmountValidation => 'Số tiền vay tối thiểu là 100,000 MMK';

  @override
  String get loanTerm => 'Kỳ hạn vay';

  @override
  String get purpose => 'Mục đích vay';

  @override
  String get stepIdentityNrc => 'Xác minh Thẻ Căn cước Myanmar NRC';

  @override
  String get stepGpsSurvey => 'Khảo sát Tọa độ Nơi ở (GPS)';

  @override
  String get stepSignature => 'Chữ ký Điện tử Khách hàng (လက်မှတ်)';

  @override
  String get nrcRequiredValidation =>
      'Vui lòng quét hoặc nhập thẻ căn cước NRC hợp lệ.';

  @override
  String get gpsRequiredValidation =>
      'Tọa độ GPS nơi ở của người vay là bắt buộc trước khi gửi hồ sơ.';

  @override
  String get signatureRequiredValidation =>
      'Chữ ký điện tử của người vay là bắt buộc trước khi gửi hồ sơ.';

  @override
  String get submitApplication => 'Gửi hồ sơ vay vốn';

  @override
  String get savingApplication => 'Đang mã hóa & lưu trữ...';

  @override
  String get applicationSaved => 'Đã lưu hồ sơ thành công';

  @override
  String get applicationSavedSuccessMsg =>
      'Hồ sơ vay đã được mã hóa vào CSDL cục bộ và xếp hàng chờ đồng bộ.';

  @override
  String get backToDashboard => 'Quay lại Trang chủ';

  @override
  String get positionNrcInFrame =>
      'Đặt thẻ NRC vào trong khung hình\n(မှတ်ပုံတင် ကတ်ပြားအား ထားပါ)';

  @override
  String get nrcInputLabel => 'Số Căn cước Myanmar NRC';

  @override
  String get nrcInputHint =>
      'Ví dụ: 12/DAGANA(N)123456 hoặc ၁၂/ဒဂန(နိုင်)၁၂၃၄၅၆';

  @override
  String get invalidNrcFormat =>
      'Định dạng NRC Myanmar không hợp lệ. Ví dụ: 12/DAGANA(N)123456';

  @override
  String get signHerePrompt =>
      'Ký tên vào đây bằng ngón tay hoặc bút cảm ứng (လက်မှတ်ရေးထိုးပါ)';

  @override
  String get clearSignature => 'Xóa chữ ký';

  @override
  String get gpsRecordedSuccess =>
      'Đã ghi nhận tọa độ GPS thực địa thành công.';

  @override
  String get gpsPendingLabel => 'Chưa ghi nhận tọa độ GPS';

  @override
  String get gpsRecordedLabel => 'Đã ghi nhận tọa độ nơi cư trú';

  @override
  String get gpsPromptTap => 'Nhấn biểu tượng định vị để lấy tọa độ thực tế';

  @override
  String get savingsTitle => 'Danh sách Sổ Tiết kiệm';

  @override
  String get searchSavingHint => 'Tìm kiếm theo tên, NRC hoặc số tài khoản...';

  @override
  String get depositSavingButton => 'Nộp tiền tiết kiệm';

  @override
  String get reloadAccounts => 'Tải lại danh sách';

  @override
  String get noSavingsFound => 'Không tìm thấy sổ tiết kiệm nào.';

  @override
  String get openFirstAccount => 'Mở sổ tiết kiệm đầu tiên';

  @override
  String get openPassbookButton => 'Mở Sổ Tiết kiệm Mới';

  @override
  String get openSavingsPassbookTitle => 'Mở Sổ Tiết kiệm Bản làng';

  @override
  String get memberAccountHolder => 'Chủ sở hữu Sổ Tiết kiệm';

  @override
  String get savingsProductPackage => 'Gói sản phẩm Tiết kiệm';

  @override
  String get initialCashDeposit => 'Số tiền gửi ban đầu (MMK)';

  @override
  String get initialDepositHint => 'Nhập 0 nếu mở sổ chưa nộp tiền';

  @override
  String get legalNominee => 'Người thụ hưởng hợp pháp';

  @override
  String get nomineeFullName => 'Họ và tên người thụ hưởng';

  @override
  String get nomineeNrc => 'Số thẻ NRC người thụ hưởng';

  @override
  String get nomineeRelation => 'Mối quan hệ với thành viên';

  @override
  String get confirmOpenPassbook => 'Xác nhận & Mở sổ tiết kiệm';

  @override
  String get passbookCreatedTitle => 'Đã tạo Sổ Tiết kiệm';

  @override
  String get passbookCreatedDesc =>
      'Sổ tiết kiệm đã được mở thành công và xếp hàng chờ đồng bộ máy chủ.';

  @override
  String get doneButton => 'Hoàn tất';

  @override
  String get accumulatedBalance => 'Số dư tích lũy';

  @override
  String get depositTitle => 'Nộp tiền';

  @override
  String get currentBalanceLabel => 'Số dư hiện tại:';

  @override
  String get depositAmountLabel => 'Số tiền gửi (MMK) *';

  @override
  String get depositAmountHint => 'Nhập số tiền muốn nộp';

  @override
  String get depositAmountRequired => 'Số tiền nộp là bắt buộc';

  @override
  String get minDepositValidation => 'Số tiền nộp tối thiểu là 1,000 MMK';

  @override
  String get printReceiptCheckbox => 'In biên lai qua máy in Bluetooth';

  @override
  String get confirmDeposit => 'Xác nhận Nộp tiền';

  @override
  String get navSavingsTitle => 'Quản lý Tiết kiệm';

  @override
  String get navCashTitle => 'Quản lý Quỹ tiền mặt';

  @override
  String get navInsuranceTitle => 'Bảo hiểm tương trợ';

  @override
  String get insuranceClaimTitle => 'Bảo hiểm Tương trợ Vi mô';

  @override
  String get claimSubmittedTitle => 'Đã gửi yêu cầu bồi thường';

  @override
  String get claimSubmittedDesc =>
      'Yêu cầu trợ cấp khẩn cấp đã được ghi nhận cục bộ và chuyển lên Chi nhánh phê duyệt chi trả.';

  @override
  String get claimReferenceCode => 'Mã tham chiếu hồ sơ';

  @override
  String get beneficiaryIncidentDetails => 'Thông tin Người thụ hưởng & Sự cố';

  @override
  String get coveredRiskCategory => 'Danh mục rủi ro được bảo hiểm';

  @override
  String get requestedAssistanceAmount => 'Số tiền đề nghị trợ cấp (MMK) *';

  @override
  String get incidentDescription => 'Mô tả sự cố & hoàn cảnh xảy ra *';

  @override
  String get incidentDescriptionHint =>
      'Mô tả chẩn đoán bệnh án, ngày nhập viện hoặc thiệt hại phát sinh...';

  @override
  String get incidentDescriptionRequired => 'Mô tả sự cố là bắt buộc';

  @override
  String get evidentiaryDocuments => 'Hồ sơ & Hình ảnh Chứng minh';

  @override
  String get villageHeadLetter => 'Giấy xác nhận của Trưởng thôn';

  @override
  String get letterAttached => 'Đã đính kèm giấy xác nhận';

  @override
  String get tapToAttachLetter => 'Chạm để đính kèm hoặc chụp ảnh';

  @override
  String get medicalReceipt => 'Hóa đơn viện phí / Biên lai y tế';

  @override
  String get receiptAttached => 'Đã đính kèm hóa đơn y tế';

  @override
  String get tapToAttachReceipt => 'Chạm để đính kèm hoặc chụp ảnh';

  @override
  String get submitEmergencyClaim => 'Gửi yêu cầu Trợ cấp Khẩn cấp';

  @override
  String get submittingClaim => 'Đang gửi hồ sơ yêu cầu...';

  @override
  String get letterAttachedToast =>
      'Đã đính kèm ảnh giấy xác nhận của Trưởng thôn.';

  @override
  String get receiptAttachedToast =>
      'Đã đính kèm ảnh hóa đơn / chứng từ viện phí.';

  @override
  String get savingProductCompulsory => 'Tiết kiệm vi mô bắt buộc';

  @override
  String get savingProductVoluntary => 'Tiết kiệm tự nguyện linh hoạt';

  @override
  String get savingProductFixedTerm => 'Tiết kiệm có kỳ hạn';

  @override
  String get cashTxLoanRepayment => 'Thu nợ gốc & lãi định kỳ';

  @override
  String get cashTxSavingDeposit => 'Gửi tiền tiết kiệm định kỳ';

  @override
  String get cashTxSavingOpen => 'Nộp tiền mở sổ tiết kiệm';

  @override
  String get cashTxHandover => 'Nộp quỹ về thủ quỹ chi nhánh';

  @override
  String get claimRiskIllness => 'Ốm đau nằm viện nội trú';

  @override
  String get claimRiskAccident => 'Tai nạn lao động / Giao thông';

  @override
  String get claimRiskNaturalDisaster => 'Thiên tai lũ lụt / Hỏa hoạn';

  @override
  String get claimRiskDeath => 'Tử tuất thành viên / Vợ chồng';

  @override
  String get claimRiskCropFailure => 'Thiệt hại mùa màng / Hạn hán';

  @override
  String get claimAmountRequired => 'Vui lòng nhập số tiền yêu cầu trợ cấp';

  @override
  String get invalidAmountValidation =>
      'Vui lòng nhập số tiền hợp lệ lớn hơn 0';

  @override
  String get methodAyaPay => 'Ví điện tử AYA Pay';

  @override
  String get methodMytelPay => 'Ví điện tử MytelPay';

  @override
  String get methodBankTransfer => 'Chuyển khoản ngân hàng';
}
