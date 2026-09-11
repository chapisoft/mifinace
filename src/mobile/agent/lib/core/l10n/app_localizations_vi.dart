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
  String get loginTitle => 'Đăng nhập Cán bộ Tín dụng';

  @override
  String get usernameLabel => 'Tên tài khoản';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get biometricLogin => 'Đăng nhập bằng Sinh trắc học';

  @override
  String get dashboardTitle => 'Bảng điều hành Thực địa';

  @override
  String get centersTitle => 'Danh sách Cụm và Tổ';

  @override
  String get collectionSheetTitle => 'Bảng kê Thu nợ';

  @override
  String get offlineSyncTitle => 'Đồng bộ Ngoại tuyến';

  @override
  String get todayTarget => 'Chỉ tiêu thu hôm nay';

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
  String get syncStatusTitle => 'Động cơ Đồng bộ Ngoại tuyến';

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
}
