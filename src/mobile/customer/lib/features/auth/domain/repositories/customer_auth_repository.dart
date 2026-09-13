import '../models/check_account_result.dart';
import '../models/member_profile.dart';

/// Repository interface cho xác thực tài khoản khách hàng, kiểm tra Core Banking, kích hoạt qua OTP và quên PIN.
abstract class CustomerAuthRepository {
  /// Kiểm tra trạng thái tài khoản trong Core Banking và ứng dụng (Chưa kích hoạt / Đã kích hoạt)
  Future<CheckAccountResult> checkAccount({
    required String identifier,
    String userType = 'CUSTOMER',
  });

  /// Gửi mã OTP kích hoạt tài khoản lần đầu
  Future<Map<String, dynamic>> sendActivationOtp({
    required String identifier,
    String userType = 'CUSTOMER',
  });

  /// Xác thực mã OTP kích hoạt và nhận Step-Up Token
  Future<String> verifyActivationOtp({
    required String identifier,
    required String otpCode,
    String userType = 'CUSTOMER',
  });

  /// Thiết lập mã PIN 6 số, kích hoạt tài khoản và đăng nhập
  Future<MemberProfile> activateAccount({
    required String activationToken,
    required String pinCode,
    bool enableBiometric = true,
  });

  /// Gửi mã OTP quên PIN
  Future<Map<String, dynamic>> sendForgotPinOtp({
    required String identifier,
    String userType = 'CUSTOMER',
  });

  /// Xác thực mã OTP quên PIN và nhận Reset PIN Token
  Future<String> verifyForgotPinOtp({
    required String identifier,
    required String otpCode,
    String userType = 'CUSTOMER',
  });

  /// Đặt lại mã PIN mới sau khi xác thực OTP thành công
  Future<MemberProfile> resetPin({
    required String resetPinToken,
    required String newPinCode,
  });

  /// Đăng nhập bằng số NRC / SĐT và mã PIN 6 số
  Future<MemberProfile> loginWithNrcAndPin({required String nrc, required String pin});

  /// Đăng nhập bằng mã PIN 6 số trên thiết bị đã lưu
  Future<MemberProfile> loginWithPin({required String pin});

  /// Đăng nhập bằng sinh trắc học (Fingerprint / Face ID)
  Future<MemberProfile> loginWithBiometric();

  /// Lấy thông tin hồ sơ người dùng đang đăng nhập
  Future<MemberProfile?> getActiveProfile();

  /// Đăng xuất và xóa phiên làm việc
  Future<void> logout();
}
