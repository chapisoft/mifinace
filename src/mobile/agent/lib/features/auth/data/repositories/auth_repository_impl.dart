import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/officer_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/officer_login_request.dart';
import '../models/officer_login_response.dart';

/// Implementation of AuthRepository communicating with Mobile BFF Gateway.
class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  @override
  Future<OfficerProfile> login({
    required String username,
    required String password,
    required String deviceId,
    required String platform,
    required String appVersion,
    String? pushToken,
  }) async {
    final request = OfficerLoginRequest(
      username: username,
      password: password,
      deviceId: deviceId,
      platform: platform,
      appVersion: appVersion,
      pushToken: pushToken,
    );

    AppLogger.info('Initiating officer login to BFF Gateway for username: $username', tag: 'AuthRepository');

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.loginOfficer,
      data: request.toJson(),
    );

    if (response.data == null) {
      throw Exception('Empty login response received from gateway.');
    }

    final loginResponse = OfficerLoginResponse.fromJson(response.data!);

    // Persist JWT Tokens & Profile securely
    await _secureStorage.saveAccessToken(loginResponse.accessToken);
    await _secureStorage.saveRefreshToken(loginResponse.refreshToken);
    await _secureStorage.write(AppConstants.loggedInUserKey, jsonEncode(loginResponse.profile.toJson()));

    AppLogger.info('Officer login successful: userId=${loginResponse.profile.userId}, name=${loginResponse.profile.fullName}',
        tag: 'AuthRepository');

    return loginResponse.profile;
  }

  @override
  Future<void> logout() async {
    try {
      AppLogger.info('Calling logout API on gateway', tag: 'AuthRepository');
      await _apiClient.post<void>(ApiEndpoints.logout);
    } catch (e) {
      AppLogger.warn('Gateway logout API call failed (proceeding with local cleanup): $e', tag: 'AuthRepository');
    } finally {
      await _secureStorage.clearAuthTokens();
    }
  }

  @override
  Future<OfficerProfile?> getCachedProfile() async {
    try {
      final userJson = await _secureStorage.read(AppConstants.loggedInUserKey);
      if (userJson != null && userJson.isNotEmpty) {
        final map = jsonDecode(userJson) as Map<String, dynamic>;
        return OfficerProfile.fromJson(map);
      }
    } catch (e) {
      AppLogger.warn('Failed to parse cached user profile: $e', tag: 'AuthRepository');
    }
    return null;
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
