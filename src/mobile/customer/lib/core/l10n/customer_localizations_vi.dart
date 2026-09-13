import 'customer_localizations.dart';

/// Vietnamese (`vi`) translations.
class CustomerLocalizationsVi extends CustomerLocalizations {
  CustomerLocalizationsVi([super.locale = 'vi']);

  @override
  String get appTitle => 'BMF Tài chính Vi mô';
  @override
  String get home => 'Trang chủ';
  @override
  String get loans => 'Khoản vay';
  @override
  String get savings => 'Tiết kiệm';
  @override
  String get insurance => 'Tương trợ';
  @override
  String get notifications => 'Thông báo';
  @override
  String get navHome => 'Trang chủ';
  @override
  String get navLoans => 'Khoản vay';
  @override
  String get navScanQr => 'Quét MMQR';
  @override
  String get navHistory => 'Lịch sử';
  @override
  String get navAccount => 'Tài khoản';

  // Common Actions & Dialogs
  @override
  String get close => 'Đóng';
  @override
  String get cancel => 'Hủy';
  @override
  String get confirm => 'Xác nhận';
  @override
  String get done => 'Hoàn tất';
  @override
  String get save => 'Lưu';
  @override
  String get retry => 'Thử lại';
  @override
  String get selectLanguage => 'Chọn ngôn ngữ';
  @override
  String get version => 'Phiên bản';
  @override
  String get viewAll => 'Xem tất cả';
  @override
  String get customize => 'Tùy chỉnh';
  @override
  String get quickActions => 'Tiện ích nhanh';
  @override
  String get customizeQuickActions => 'Tùy chỉnh Tiện ích Nhanh';
  @override
  String get customizeQuickActionsDesc => 'Chọn các chức năng thường xuyên sử dụng để hiển thị ngay trên trang chủ:';
  @override
  String get saveChanges => 'Lưu thay đổi';
  @override
  String get maxShortcutsReached => 'Chỉ được chọn tối đa 4 tiện ích';
  @override
  String get minShortcutsRequired => 'Vui lòng chọn ít nhất 1 tiện ích';

  // Authentication
  @override
  String get loginTitle => 'Đăng nhập Hội viên';
  @override
  String get phoneLabel => 'Số điện thoại';
  @override
  String get nrcLabel => 'Số CCCD / NRC';
  @override
  String get memberIdOrPhoneOrNrc => 'Mã thành viên / SĐT / Số NRC';
  @override
  String get continueButton => 'Tiếp tục';
  @override
  String get switchAccount => 'Đổi tài khoản';
  @override
  String get forgotPin => 'Quên PIN?';
  @override
  String get enter6DigitPin => 'Nhập mã PIN bảo mật 6 số';
  @override
  String get notActivatedPrompt => 'Tài khoản chưa được kích hoạt. Gửi mã OTP để kích hoạt ngay?';
  @override
  String get activateNow => 'Kích hoạt ngay';
  @override
  String get welcomeBack => 'Chào mừng trở lại';
  @override
  String get firstTimeUsingApp => 'Chưa kích hoạt tài khoản?';
  @override
  String get activateWithInfo => 'Kích hoạt bằng Mã thành viên, NRC hoặc SĐT';
  @override
  String get splashTagline => 'Tín dụng Tương trợ & Dịch vụ Hội viên Số';
  @override
  String get savedMemberAccount => 'Tài khoản hội viên đã lưu';
  @override
  String get requestOtp => 'Nhận mã OTP';
  @override
  String get otpTitle => 'Xác nhận mã OTP';
  @override
  String get verifyOtp => 'Xác thực';
  @override
  String get setPinTitle => 'Tạo mã PIN 6 số';
  @override
  String get confirmPinTitle => 'Nhập lại mã PIN 6 số';
  @override
  String get enterPinTitle => 'Nhập mã PIN bảo mật';
  @override
  String get biometricLogin => 'Đăng nhập sinh trắc học';
  @override
  String get pinMismatch => 'Mã PIN không khớp. Vui lòng thử lại.';
  @override
  String get pinSuccess => 'Thiết lập mã PIN thành công.';
  @override
  String get inputIdentifierRequired => 'Vui lòng nhập Mã thành viên, Số điện thoại hoặc NRC.';

  // Dashboard & Member Profile
  @override
  String get welcomeMember => 'Xin chào';
  @override
  String get memberCode => 'Mã thành viên';
  @override
  String get groupCode => 'Mã nhóm';
  @override
  String get totalOutstanding => 'Tổng dư nợ còn lại';
  @override
  String get activeLoans => 'Khoản vay hiện hữu';
  @override
  String get dueAlertTitle => 'Khoản vay sắp đến hạn thanh toán';
  @override
  String get payNow => 'Thanh toán ngay';
  @override
  String get quickServices => 'Dịch vụ nhanh';
  @override
  String get digitalMemberCard => 'Thẻ Hội viên Số';
  @override
  String get memberQrTitle => 'Thẻ Hội viên Số BMF';
  @override
  String get centerLabel => 'Cụm sinh hoạt';
  @override
  String get groupLabel => 'Nhóm đoàn kết';
  @override
  String get meetingScheduleLabel => 'Lịch sinh hoạt';
  @override
  String get weeklyMeetingTime => 'Thứ 6 hàng tuần • 09:00 AM';
  @override
  String get assignedOfficerLabel => 'Cán bộ phụ trách';
  @override
  String get noRecentTransactions => 'Chưa có giao dịch gần đây.';
  @override
  String get periodNumberLabel => 'Kỳ';

  // Overview Metrics & Status
  @override
  String get outstandingLoanMetric => 'Dư nợ hiện tại';
  @override
  String get dueMetric => 'Kỳ đến hạn';
  @override
  String get totalSavingsMetric => 'Tiết kiệm tích lũy';
  @override
  String get loyaltyPointsMetric => 'Điểm thưởng';
  @override
  String get memberActiveStatus => 'Hội viên chuẩn';

  // Home Menu Items
  @override
  String get menuMmqrTitle => 'Quét MMQR';
  @override
  String get menuMmqrSubtitle => 'Cổng thanh toán';
  @override
  String get menuLoansTitle => 'Hợp đồng vay';
  @override
  String get menuLoansSubtitle => 'Lịch trả nợ';
  @override
  String get menuSavingsTitle => 'Tiết kiệm';
  @override
  String get menuSavingsSubtitle => 'Sổ tiền gửi & lãi';
  @override
  String get menuInsuranceTitle => 'Quỹ tương trợ';
  @override
  String get menuInsuranceSubtitle => 'Y tế & Trợ cấp';
  @override
  String get menuApplyLoanTitle => 'Vay nhanh';
  @override
  String get menuApplyLoanSubtitle => 'Đăng ký trực tuyến';
  @override
  String get menuHistoryTitle => 'Lịch sử';
  @override
  String get menuHistorySubtitle => 'Tra cứu biên lai';
  @override
  String get menuBranchesTitle => 'Điểm giao dịch';
  @override
  String get menuBranchesSubtitle => 'Chi nhánh gần nhất';
  @override
  String get menuNotificationsTitle => 'Thông báo';
  @override
  String get menuNotificationsSubtitle => 'Nhắc lịch thanh toán';

  // Loans & Schedule
  @override
  String get loansTitle => 'Danh sách khoản vay';
  @override
  String get loanDetails => 'Chi tiết hợp đồng';
  @override
  String get scheduleTitle => 'Lịch trả nợ định kỳ';
  @override
  String get period => 'Kỳ';
  @override
  String get dueDate => 'Ngày đến hạn';
  @override
  String get principal => 'Tiền gốc';
  @override
  String get interest => 'Tiền lãi';
  @override
  String get insuranceFee => 'Phí tương trợ';
  @override
  String get totalDue => 'Tổng thanh toán';
  @override
  String get statusPaid => 'Đã thu';
  @override
  String get statusPending => 'Chờ thu';
  @override
  String get statusOverdue => 'Quá hạn';

  // 5 FRD Debt Groups
  @override
  String get debtGroupCurrent => 'Nhóm 1 - Nợ đủ tiêu chuẩn';
  @override
  String get debtGroupSpecialMention => 'Nhóm 2 - Nợ cần chú ý';
  @override
  String get debtGroupSubstandard => 'Nhóm 3 - Nợ dưới tiêu chuẩn';
  @override
  String get debtGroupDoubtful => 'Nhóm 4 - Nợ nghi ngờ';
  @override
  String get debtGroupLoss => 'Nhóm 5 - Nợ có khả năng mất vốn';

  // Payments & MMQR
  @override
  String get paymentTitle => 'Thanh toán MMQR';
  @override
  String get scanMmqr => 'Quét mã MMQR';
  @override
  String get mmqrRepaymentTitle => 'Thanh toán Khoản vay qua MMQR';
  @override
  String get generatingMmqr => 'Đang tạo mã động MMQR chuẩn CBM...';
  @override
  String get openWallet => 'Thanh toán bằng ví điện tử';
  @override
  String get launchKbzPay => 'Mở KBZPay';
  @override
  String get launchWavePay => 'Mở WavePay';
  @override
  String get launchAyaPay => 'Mở AYA Pay';
  @override
  String get launchMytelPay => 'Mở MytelPay';
  @override
  String get saveQrImage => 'Lưu ảnh QR';
  @override
  String get paymentSuccess => 'Đã nhận thanh toán!';
  @override
  String get electronicReceipt => 'Biên lai điện tử';
  @override
  String get referenceNo => 'Mã giao dịch';
  @override
  String get returnHome => 'Về trang chủ';
  @override
  String get backToHome => 'Về trang chủ';
  @override
  String get contractCodeLabel => 'Mã hợp đồng';
  @override
  String get transactionRefLabel => 'Mã tham chiếu';
  @override
  String get paymentChannelLabel => 'Kênh thanh toán';
  @override
  String get settledDateLabel => 'Ngày thanh toán';
  @override
  String get totalPaidAmountLabel => 'Tổng tiền đã thanh toán';
  @override
  String get totalTransactionAmount => 'Tổng tiền giao dịch';
  @override
  String get noMatchingTransactions => 'Không có giao dịch phù hợp';
  @override
  String get tryDifferentFilter => 'Hãy thử chọn khoảng thời gian hoặc danh mục khác';
  @override
  String get details => 'Chi tiết';
  @override
  String get savingReceiptPdf => 'Đang lưu biên lai PDF vào thiết bị...';
  @override
  String get savePdf => 'Lưu PDF';
  @override
  String get sharingReceipt => 'Đang tạo liên kết chia sẻ biên lai...';
  @override
  String get share => 'Chia sẻ';
  @override
  String get filterAll => 'Tất cả';
  @override
  String get filterRepayment => 'Trả nợ vay';
  @override
  String get filterSavings => 'Tiết kiệm';
  @override
  String get filterInsurance => 'Bảo hiểm';
  @override
  String get searchPlaceholder => 'Tìm theo mã giao dịch, hợp đồng...';
  @override
  String get allTime => 'Mọi thời gian';
  @override
  String get thisMonth => 'Tháng này';
  @override
  String get last3Months => '3 tháng qua';
  @override
  String get filterModalTitle => 'Bộ lọc giao dịch';

  // Savings
  @override
  String get savingsTitle => 'Tiết kiệm & Tiền gửi';
  @override
  String get savingsAndPassbooks => 'Tiết kiệm & Sổ tiền gửi';
  @override
  String get accruedInterest => 'Tổng lãi tích lũy';
  @override
  String get openSavingOnline => 'Mở sổ tiết kiệm trực tuyến';
  @override
  String get openSavingsPassbookTitle => 'Mở sổ tiền gửi lãi suất cao';
  @override
  String get passbookOpenedSuccess => 'Mở sổ tiền gửi thành công!';
  @override
  String get viewPassbooks => 'Xem danh sách sổ';
  @override
  String get expectedProfitAtMaturity => 'Dự tính tiền lãi khi đáo hạn:';
  @override
  String get confirmAndSubscribe => 'Xác nhận mở sổ';
  @override
  String get depositPrincipal => 'Gốc tiền gửi';
  @override
  String get accruedProfitYield => 'Lãi phát sinh';
  @override
  String get compulsorySaving => 'Tiết kiệm bắt buộc nhóm';
  @override
  String get voluntarySaving => 'Tiết kiệm tự nguyện';
  @override
  String get fixedTermSaving => 'Tiền gửi có kỳ hạn';
  @override
  String get interestRatePerAnnum => 'Lãi suất / năm';

  // Insurance
  @override
  String get insuranceTitle => 'Quỹ tương trợ Hội viên';
  @override
  String get medicalBenefitTitle => 'Trợ cấp viện phí & Thiên tai';
  @override
  String get medicalBenefitDesc => 'Hỗ trợ chi phí điều trị khẩn cấp và rủi ro thiên tai';
  @override
  String get submitClaim => 'Gửi yêu cầu bồi thường';
  @override
  String get mutualAidClaimTitle => 'Yêu cầu Trợ cấp Tương trợ';
  @override
  String get illnessRisk => 'Nằm viện & Điều trị bệnh';
  @override
  String get accidentRisk => 'Tai nạn rủi ro';
  @override
  String get naturalDisasterRisk => 'Bão lũ & Thiên tai';
  @override
  String get uploadInvoices => 'Đính kèm Giấy ra viện hoặc Hóa đơn viện phí';
  @override
  String get attachMedicalDocument => 'Đính kèm chứng từ y tế';
  @override
  String get documentAttachedSimulated => 'Đã đính kèm 1 chứng từ';
  @override
  String get submitInsuranceClaim => 'Gửi hồ sơ bồi thường';
  @override
  String get claimFiledSuccess => 'Nộp hồ sơ thành công';
  @override
  String get claimSubmitted => 'Đã gửi yêu cầu trợ cấp';

  // Notifications
  @override
  String get notificationsTitle => 'Thông báo';
  @override
  String get notificationCenterTitle => 'Trung tâm thông báo';
  @override
  String get markAllRead => 'Đã đọc tất cả';
  @override
  String get noNotifications => 'Không có thông báo mới';
  @override
  String get noNotificationsFound => 'Chưa có lịch sử thông báo';

  // Fast Loan & Application
  @override
  String get applyLoanTitle => 'Đăng ký Vay Nhanh';
  @override
  String get tabApplyLoan => 'Đăng ký vay';
  @override
  String get tabTrackApplications => 'Hồ sơ đã gửi';
  @override
  String get selectLoanPackage => 'Chọn gói vay phù hợp';
  @override
  String get loanAmountToBorrow => 'Số tiền muốn vay';
  @override
  String get minAmountLabel => 'Tối thiểu';
  @override
  String get maxAmountLabel => 'Tối đa';
  @override
  String get loanTerm => 'Thời hạn vay';
  @override
  String get repaymentFrequency => 'Kỳ hạn trả nợ';
  @override
  String get monthly => 'Hàng tháng';
  @override
  String get biweekly => 'Mỗi 2 tuần';
  @override
  String get weekly => 'Hàng tuần';
  @override
  String get estimatedMonthlyRepayment => 'Ước tính trả hàng tháng';
  @override
  String get monthlyPrincipal => 'Gốc trả hàng tháng';
  @override
  String get monthlyInterest => 'Lãi suất hàng tháng';
  @override
  String get welfareInsuranceFee => 'Phí bảo hiểm an sinh (0.5%)';
  @override
  String get disbursementMethod => 'Hình thức nhận giải ngân';
  @override
  String get loanPurpose => 'Mục đích vay vốn cụ thể';
  @override
  String get loanPurposeHint => 'Ví dụ: Mua phân bón lúa vụ mùa, nhập hàng hóa...';
  @override
  String get submitLoanApplication => 'Gửi Hồ Sơ Vay Ngay';
  @override
  String get applicationSubmittedSuccess => 'Gửi Hồ Sơ Thành Công';
  @override
  String get viewProgress => 'Xem Tiến Độ';
  @override
  String get searchApplicationPlaceholder => 'Tìm theo mã hồ sơ hoặc gói vay...';
  @override
  String get appStatusUnderReview => 'Đang thẩm định';
  @override
  String get appStatusApproved => 'Đã phê duyệt';
  @override
  String get appStatusDisbursed => 'Đã giải ngân';
  @override
  String get appStatusRejected => 'Từ chối';
  @override
  String get noActiveLoansToRepay => 'Không có khoản vay nào cần thanh toán';
  @override
  String get selectLoanToRepay => 'Chọn khoản vay cần thanh toán';
  @override
  String get monthsTerm => 'Tháng';
  @override
  String get interestPerMonth => 'tháng';

  // Account Screen & Settings
  @override
  String get accountTitle => 'Tài khoản & Bảo mật';
  @override
  String get securityTitle => 'Bảo mật & Xác thực';
  @override
  String get changePin => 'Đổi mã PIN';
  @override
  String get changePinSecurityTitle => 'Đổi mã PIN bảo mật';
  @override
  String get currentPinLabel => 'Mã PIN hiện tại';
  @override
  String get newPinLabel => 'Mã PIN mới 6 số';
  @override
  String get confirmNewPinLabel => 'Xác nhận mã PIN mới';
  @override
  String get pinChangedSuccess => 'Đổi mã PIN thành công';
  @override
  String get biometricAuth => 'Xác thực Sinh trắc học';
  @override
  String get biometricSubtitle => 'Đăng nhập nhanh bằng FaceID / Vân tay';
  @override
  String get deviceSecurity => 'Trạng thái An toàn Thiết bị';
  @override
  String get deviceSecurityStatus => 'Kiểm định An toàn Thiết bị';
  @override
  String get deviceSecurityPass => 'ĐẠT';
  @override
  String get deviceSecurityDesc => 'SSL Pinning, Chống can thiệp: Đạt chuẩn';
  @override
  String get utilitiesTitle => 'Tiện ích & Tổng đài Chăm sóc';
  @override
  String get settingsAndPreferences => 'Cài đặt & Tùy chọn';
  @override
  String get languageSettingTitle => 'Ngôn ngữ';
  @override
  String get dueReminderNotifications => 'Thông báo nhắc nợ định kỳ';
  @override
  String get dueReminderDesc => 'Nhắc trước 3 ngày đến hạn';
  @override
  String get branchNetwork => 'Mạng lưới Chi nhánh';
  @override
  String get supportHotline => 'Tổng đài Chăm sóc Hội viên';
  @override
  String get termsAndPrivacy => 'Quy chế Tín dụng & Quyền riêng tư';
  @override
  String get appVersion => 'Phiên bản';
  @override
  String get signOut => 'Đăng xuất';
  @override
  String get confirmSignOut => 'Bạn có chắc chắn muốn đăng xuất?';
  @override
  String get signOutConfirmTitle => 'Đăng xuất tài khoản';
  @override
  String get signOutConfirmDesc => 'Bạn có chắc chắn muốn đăng xuất khỏi Cổng thông tin Hội viên BMF?';
}
