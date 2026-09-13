import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/models/check_account_result.dart';
import '../../domain/models/member_profile.dart';
import '../../domain/repositories/customer_auth_repository.dart';

/// Hiện thực [CustomerAuthRepository] xử lý kiểm tra tài khoản Core, gửi/nhận OTP băm, băm PIN BCrypt/SHA và quản lý phiên.
class CustomerAuthRepositoryImpl implements CustomerAuthRepository {
  final SecureStorageService _storage;
  final BiometricService _biometricService;
  final ApiClient _apiClient;

  MemberProfile? _cachedProfile;

  CustomerAuthRepositoryImpl({
    required SecureStorageService storage,
    required BiometricService biometricService,
    ApiClient? apiClient,
  })  : _storage = storage,
        _biometricService = biometricService,
        _apiClient = apiClient ?? ApiClient(secureStorage: storage);

  String _hashPin(String pin) {
    final bytes = utf8.encode('BMF_SALT_$pin');
    return sha256.convert(bytes).toString();
  }

  @override
  Future<CheckAccountResult> checkAccount({
    required String identifier,
    String userType = 'CUSTOMER',
  }) async {
    AppLogger.info('Checking account status in Core Banking: identifier=$identifier, userType=$userType', tag: 'AuthRepo');
    try {
      final response = await _apiClient.post(
        ApiEndpoints.checkAccount,
        data: {
          'identifier': identifier.trim(),
          'userType': userType,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        return CheckAccountResult.fromJson(Map<String, dynamic>.from(data));
      }
      throw Exception('Không thể kiểm tra tài khoản: Máy chủ trả về mã HTTP ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('Check account failed: ${e.message}', tag: 'AuthRepo');
      if (e.response?.statusCode == 404) {
        throw Exception('Số điện thoại hoặc số giấy tờ không tồn tại trong hệ thống tài chính.');
      }
      final errDetail = e.response?.data is Map ? (e.response?.data['detail'] ?? e.response?.data['message']) : null;
      throw Exception(errDetail ?? 'Không thể kết nối đến máy chủ kiểm tra tài khoản. Vui lòng thử lại.');
    }
  }

  @override
  Future<Map<String, dynamic>> sendActivationOtp({
    required String identifier,
    String userType = 'CUSTOMER',
  }) async {
    AppLogger.info('Requesting activation OTP: identifier=$identifier', tag: 'AuthRepo');
    try {
      final response = await _apiClient.post(
        ApiEndpoints.activationSendOtp,
        data: {
          'identifier': identifier.trim(),
          'userType': userType,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        return Map<String, dynamic>.from(data);
      }
      throw Exception('Gửi OTP kích hoạt thất bại (HTTP ${response.statusCode})');
    } on DioException catch (e) {
      AppLogger.error('Activation OTP request failed: ${e.message}', tag: 'AuthRepo');
      final errDetail = e.response?.data is Map ? (e.response?.data['detail'] ?? e.response?.data['message']) : null;
      if (e.response?.statusCode == 429) {
        throw Exception('Vui lòng đợi 60 giây trước khi yêu cầu gửi lại mã OTP.');
      }
      throw Exception(errDetail ?? 'Không thể gửi mã OTP kích hoạt: ${e.message}');
    }
  }

  @override
  Future<String> verifyActivationOtp({
    required String identifier,
    required String otpCode,
    String userType = 'CUSTOMER',
  }) async {
    AppLogger.info('Verifying activation OTP: identifier=$identifier', tag: 'AuthRepo');
    try {
      final response = await _apiClient.post(
        ApiEndpoints.activationVerifyOtp,
        data: {
          'identifier': identifier.trim(),
          'userType': userType,
          'otpCode': otpCode.trim(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        final stepUpToken = data['stepUpToken']?.toString() ?? '';
        if (stepUpToken.isNotEmpty) {
          return stepUpToken;
        }
      }
      throw Exception('Xác thực OTP thất bại: Không nhận được token kích hoạt.');
    } on DioException catch (e) {
      AppLogger.error('Verify activation OTP failed: ${e.message}', tag: 'AuthRepo');
      final errCode = e.response?.data is Map ? e.response?.data['errorCode'] : null;
      if (errCode == 'ERR_OTP_INVALID') {
        throw Exception('Mã OTP không chính xác. Vui lòng kiểm tra lại.');
      } else if (errCode == 'ERR_OTP_EXPIRED') {
        throw Exception('Mã OTP đã hết hạn hoặc bị hủy do nhập sai quá 3 lần. Vui lòng yêu cầu mã mới.');
      }
      throw Exception('Xác thực OTP không thành công: ${e.message}');
    }
  }

  @override
  Future<MemberProfile> activateAccount({
    required String activationToken,
    required String pinCode,
    bool enableBiometric = true,
  }) async {
    AppLogger.info('Activating account with PIN setup', tag: 'AuthRepo');
    try {
      final deviceId = await _storage.getDeviceId() ?? 'DEV-MOBILE-01';
      final response = await _apiClient.post(
        ApiEndpoints.activationSetPin,
        data: {
          'activationToken': activationToken.trim(),
          'pinCode': pinCode.trim(),
          'enableBiometric': enableBiometric,
          'deviceId': deviceId,
          'platform': 'ANDROID',
          'appVersion': '1.0.0',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        return await _processAuthResponse(data, pinCode, enableBiometric);
      }
      throw Exception('Kích hoạt tài khoản thất bại: Máy chủ từ chối thiết lập PIN.');
    } on DioException catch (e) {
      AppLogger.error('Account activation failed: ${e.message}', tag: 'AuthRepo');
      final errDetail = e.response?.data is Map ? (e.response?.data['detail'] ?? e.response?.data['message']) : null;
      throw Exception(errDetail ?? 'Không thể kích hoạt tài khoản: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> sendForgotPinOtp({
    required String identifier,
    String userType = 'CUSTOMER',
  }) async {
    AppLogger.info('Requesting forgot PIN OTP: identifier=$identifier', tag: 'AuthRepo');
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPinSendOtp,
        data: {
          'identifier': identifier.trim(),
          'userType': userType,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        return Map<String, dynamic>.from(data);
      }
      throw Exception('Gửi OTP quên PIN thất bại (HTTP ${response.statusCode})');
    } on DioException catch (e) {
      AppLogger.error('Forgot PIN OTP request failed: ${e.message}', tag: 'AuthRepo');
      if (e.response?.statusCode == 429) {
        throw Exception('Vui lòng đợi 60 giây trước khi yêu cầu gửi lại mã OTP.');
      }
      final errDetail = e.response?.data is Map ? (e.response?.data['detail'] ?? e.response?.data['message']) : null;
      throw Exception(errDetail ?? 'Không thể gửi mã OTP đặt lại PIN: ${e.message}');
    }
  }

  @override
  Future<String> verifyForgotPinOtp({
    required String identifier,
    required String otpCode,
    String userType = 'CUSTOMER',
  }) async {
    AppLogger.info('Verifying forgot PIN OTP: identifier=$identifier', tag: 'AuthRepo');
    try {
      final response = await _apiClient.post(
        ApiEndpoints.forgotPinVerifyOtp,
        data: {
          'identifier': identifier.trim(),
          'userType': userType,
          'otpCode': otpCode.trim(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        final resetToken = data['stepUpToken']?.toString() ?? '';
        if (resetToken.isNotEmpty) {
          return resetToken;
        }
      }
      throw Exception('Xác thực OTP quên PIN thất bại: Không nhận được token đặt lại PIN.');
    } on DioException catch (e) {
      AppLogger.error('Verify forgot PIN OTP failed: ${e.message}', tag: 'AuthRepo');
      final errCode = e.response?.data is Map ? e.response?.data['errorCode'] : null;
      if (errCode == 'ERR_OTP_INVALID') {
        throw Exception('Mã OTP không chính xác. Vui lòng kiểm tra lại.');
      } else if (errCode == 'ERR_OTP_EXPIRED') {
        throw Exception('Mã OTP đã hết hạn hoặc bị hủy do nhập sai quá 3 lần.');
      }
      throw Exception('Xác thực OTP không thành công: ${e.message}');
    }
  }

  @override
  Future<MemberProfile> resetPin({
    required String resetPinToken,
    required String newPinCode,
  }) async {
    AppLogger.info('Resetting PIN code on server', tag: 'AuthRepo');
    try {
      final deviceId = await _storage.getDeviceId() ?? 'DEV-MOBILE-01';
      final response = await _apiClient.post(
        ApiEndpoints.forgotPinResetPin,
        data: {
          'resetPinToken': resetPinToken.trim(),
          'newPinCode': newPinCode.trim(),
          'deviceId': deviceId,
          'platform': 'ANDROID',
          'appVersion': '1.0.0',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        return await _processAuthResponse(data, newPinCode, true);
      }
      throw Exception('Đặt lại mã PIN thất bại.');
    } on DioException catch (e) {
      AppLogger.error('Reset PIN failed: ${e.message}', tag: 'AuthRepo');
      final errDetail = e.response?.data is Map ? (e.response?.data['detail'] ?? e.response?.data['message']) : null;
      throw Exception(errDetail ?? 'Không thể đặt lại mã PIN: ${e.message}');
    }
  }

  @override
  Future<MemberProfile> loginWithNrcAndPin({required String nrc, required String pin}) async {
    AppLogger.info('Attempting login with phone/NRC and PIN', tag: 'AuthRepo');
    if (nrc.trim().isEmpty) {
      throw Exception('Vui lòng nhập số điện thoại hoặc số NRC đăng ký.');
    }
    if (pin.trim().isEmpty) {
      throw Exception('Vui lòng nhập mã PIN bảo mật 6 số.');
    }

    try {
      final deviceId = await _storage.getDeviceId() ?? 'DEV-MOBILE-01';
      final response = await _apiClient.post(
        ApiEndpoints.loginCustomer,
        data: {
          'nrcNumber': nrc.trim(),
          'pinCode': pin.trim(),
          'deviceId': deviceId,
          'platform': 'ANDROID',
          'appVersion': '1.0.0',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        return await _processAuthResponse(data, pin, true);
      }
      throw Exception('Đăng nhập thất bại: Thông tin tài khoản hoặc mã PIN không chính xác.');
    } on DioException catch (e) {
      AppLogger.error('Remote login failed: ${e.message}', tag: 'AuthRepo');
      final errCode = e.response?.data is Map ? e.response?.data['errorCode'] : null;
      if (errCode == 'ERR_ACCOUNT_NOT_ACTIVATED') {
        throw Exception('Tài khoản chưa được kích hoạt. Vui lòng kích hoạt tài khoản qua OTP.');
      }
      if (errCode == 'ERR_CREDENTIALS_INVALID') {
        throw Exception('Mã PIN hoặc thông tin tài khoản không chính xác.');
      }
      throw Exception('Không thể kết nối đến máy chủ đăng nhập: ${e.message}');
    }
  }

  @override
  Future<MemberProfile> loginWithPin({required String pin}) async {
    AppLogger.info('Attempting login with 6-digit security PIN', tag: 'AuthRepo');
    final incomingHash = _hashPin(pin);
    final savedHash = await _storage.getPinHash();
    final savedNrc = await _storage.getMemberNrc();

    if (savedNrc != null && savedNrc.isNotEmpty) {
      return loginWithNrcAndPin(nrc: savedNrc, pin: pin);
    }

    if (savedHash == null) {
      throw Exception('Chưa thiết lập mã PIN bảo mật trên thiết bị này. Vui lòng đăng nhập bằng SĐT/NRC.');
    } else if (savedHash != incomingHash) {
      throw Exception('Mã PIN không chính xác. Vui lòng thử lại.');
    }

    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
    }

    if (_cachedProfile != null) {
      return _cachedProfile!;
    }

    return (await getActiveProfile()) ??
        (throw Exception('Không thể tải thông tin hồ sơ hội viên từ máy chủ.'));
  }

  @override
  Future<MemberProfile> loginWithBiometric() async {
    AppLogger.info('Attempting login with Biometrics', tag: 'AuthRepo');
    final isEnabled = await _storage.isBiometricEnabled();
    if (!isEnabled) {
      throw Exception('Chức năng sinh trắc học chưa được kích hoạt cho tài khoản này.');
    }

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Xác thực sinh trắc học để truy cập tài khoản BMF',
    );

    if (!authenticated) {
      throw Exception('Xác thực sinh trắc học đã bị hủy hoặc không thành công.');
    }

    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập bằng mã PIN.');
    }

    if (_cachedProfile != null) {
      return _cachedProfile!;
    }

    return (await getActiveProfile()) ??
        (throw Exception('Không thể tải hồ sơ hội viên từ máy chủ.'));
  }

  @override
  Future<MemberProfile?> getActiveProfile() async {
    if (_cachedProfile != null) {
      return _cachedProfile;
    }
    final token = await _storage.getAccessToken();
    if (token == null || token.isEmpty) {
      return null;
    }
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map ? (response.data['data'] ?? response.data) : <String, dynamic>{};
        final profile = MemberProfile.fromJson(Map<String, dynamic>.from(data));
        _cachedProfile = profile;
        return profile;
      }
    } catch (e) {
      AppLogger.warn('Cannot fetch profile: $e', tag: 'AuthRepo');
    }
    return null;
  }

  @override
  Future<void> logout() async {
    AppLogger.info('Logging out member from device', tag: 'AuthRepo');
    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      AppLogger.warn('Remote logout failed: $e', tag: 'AuthRepo');
    } finally {
      _cachedProfile = null;
      await _storage.clearAllSession();
    }
  }

  Future<MemberProfile> _processAuthResponse(
    Map<String, dynamic> data,
    String pinCode,
    bool enableBiometric,
  ) async {
    final accessToken = data['accessToken']?.toString() ?? data['token']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString() ?? '';

    if (accessToken.isNotEmpty) {
      await _storage.saveAccessToken(accessToken);
      if (refreshToken.isNotEmpty) {
        await _storage.saveRefreshToken(refreshToken);
      }

      final profileJson = data['profile'] is Map ? data['profile'] : data;
      final profileMap = Map<String, dynamic>.from(profileJson);
      final profile = MemberProfile.fromJson(profileMap);
      _cachedProfile = profile;

      if (profile.nrcFormatted.isNotEmpty) {
        await _storage.saveMemberNrc(profile.nrcFormatted);
      }
      await _storage.savePinHash(_hashPin(pinCode));
      await _storage.setBiometricEnabled(enableBiometric);
      return profile;
    }
    throw Exception('Máy chủ không trả về token phiên làm việc hợp lệ.');
  }
}
