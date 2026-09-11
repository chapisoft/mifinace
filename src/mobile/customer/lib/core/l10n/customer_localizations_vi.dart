import 'customer_localizations.dart';

/// Vietnamese (`vi`) translations.
class CustomerLocalizationsVi extends CustomerLocalizations {
  CustomerLocalizationsVi([super.locale = 'vi']);

  @override
  String get appTitle => 'Tài chính vi mô BMF';
  @override
  String get home => 'Trang chủ';
  @override
  String get loans => 'Khoản vay';
  @override
  String get savings => 'Tiết kiệm';
  @override
  String get insurance => 'Bảo hiểm';
  @override
  String get notifications => 'Thông báo';

  @override
  String get loginTitle => 'Đăng nhập thành viên';
  @override
  String get phoneLabel => 'Số điện thoại';
  @override
  String get nrcLabel => 'Số thẻ căn cước NRC';
  @override
  String get requestOtp => 'Nhận mã OTP SMS';
  @override
  String get otpTitle => 'Xác thực mã OTP SMS';
  @override
  String get verifyOtp => 'Xác nhận';
  @override
  String get setPinTitle => 'Thiết lập mã PIN 6 số';
  @override
  String get confirmPinTitle => 'Xác nhận lại mã PIN 6 số';
  @override
  String get enterPinTitle => 'Nhập mã PIN của bạn';
  @override
  String get biometricLogin => 'Đăng nhập bằng sinh trắc học';
  @override
  String get pinMismatch => 'Mã PIN xác nhận không trùng khớp';
  @override
  String get pinSuccess => 'Thiết lập mã PIN bảo mật thành công';

  @override
  String get welcomeMember => 'Xin chào thành viên';
  @override
  String get memberCode => 'Mã thành viên';
  @override
  String get groupCode => 'Mã nhóm tổ';
  @override
  String get totalOutstanding => 'Tổng dư nợ hiện tại';
  @override
  String get activeLoans => 'Khoản vay đang hoạt động';
  @override
  String get dueAlertTitle => 'Cảnh báo khoản nợ sắp đến hạn';
  @override
  String get payNow => 'Thanh toán ngay';
  @override
  String get quickServices => 'Dịch vụ nhanh';

  @override
  String get loansTitle => 'Danh sách khoản vay';
  @override
  String get loanDetails => 'Chi tiết khoản vay';
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
  String get insuranceFee => 'Phí bảo hiểm';
  @override
  String get totalDue => 'Tổng số tiền đến hạn';
  @override
  String get statusPaid => 'Đã thanh toán';
  @override
  String get statusPending => 'Chưa thanh toán';
  @override
  String get statusOverdue => 'Quá hạn';

  @override
  String get debtGroupCurrent => 'Nợ tiêu chuẩn (Nhóm 1)';
  @override
  String get debtGroupSpecialMention => 'Nợ cần chú ý (Nhóm 2)';
  @override
  String get debtGroupSubstandard => 'Nợ dưới tiêu chuẩn (Nhóm 3)';
  @override
  String get debtGroupDoubtful => 'Nợ nghi ngờ (Nhóm 4)';
  @override
  String get debtGroupLoss => 'Nợ có khả năng mất vốn (Nhóm 5)';

  @override
  String get paymentTitle => 'Thanh toán số MMQR';
  @override
  String get scanMmqr => 'Quét mã bằng ứng dụng ngân hàng hoặc ví';
  @override
  String get openWallet => 'Mở ví điện tử liên kết';
  @override
  String get launchKbzPay => 'Thanh toán qua KBZPay';
  @override
  String get launchWavePay => 'Thanh toán qua WavePay';
  @override
  String get launchAyaPay => 'Thanh toán qua AYA Pay';
  @override
  String get launchMytelPay => 'Thanh toán qua MytelPay';
  @override
  String get saveQrImage => 'Lưu hình ảnh mã QR';
  @override
  String get paymentSuccess => 'Thanh toán gạch nợ thành công';
  @override
  String get electronicReceipt => 'Biên nhận điện tử hợp lệ';
  @override
  String get referenceNo => 'Mã tham chiếu giao dịch';
  @override
  String get returnHome => 'Quay về trang chủ';

  @override
  String get savingsTitle => 'Sổ tiết kiệm buôn làng';
  @override
  String get accruedInterest => 'Tiền lãi dồn tích thực tế';
  @override
  String get openSavingOnline => 'Mở sổ tiết kiệm trực tuyến';
  @override
  String get compulsorySaving => 'Tiết kiệm bắt buộc';
  @override
  String get voluntarySaving => 'Tiết kiệm tự nguyện';
  @override
  String get fixedTermSaving => 'Tiết kiệm có kỳ hạn';
  @override
  String get interestRatePerAnnum => 'Lãi suất một năm';

  @override
  String get insuranceTitle => 'Quỹ tương trợ thành viên';
  @override
  String get medicalBenefitTitle => 'Trợ cấp viện phí y tế (10.000 MMK/ngày)';
  @override
  String get medicalBenefitDesc => 'Chế độ bảo đảm an sinh xã hội toàn diện trước ốm đau và tai nạn';
  @override
  String get submitClaim => 'Nộp hồ sơ bồi thường bảo hiểm';
  @override
  String get illnessRisk => 'Ốm đau bệnh tật';
  @override
  String get accidentRisk => 'Tai nạn rủi ro';
  @override
  String get naturalDisasterRisk => 'Thiên tai lũ lụt';
  @override
  String get uploadInvoices => 'Tải lên hóa đơn viện phí và giấy xác nhận';
  @override
  String get claimSubmitted => 'Hồ sơ yêu cầu trợ cấp đã được tiếp nhận thành công';

  @override
  String get notificationsTitle => 'Trung tâm thông báo';
  @override
  String get markAllRead => 'Đánh dấu tất cả là đã đọc';
  @override
  String get noNotifications => 'Hiện không có thông báo mới nào';
}
