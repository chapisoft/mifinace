import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmf_customer/core/constants/api_endpoints.dart';
import 'package:bmf_customer/core/network/api_client.dart';
import 'package:bmf_customer/core/security/biometric_service.dart';
import 'package:bmf_customer/core/security/secure_storage_service.dart';
import 'package:bmf_customer/features/auth/data/repositories/customer_auth_repository_impl.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockSecureStorageService extends Mock implements SecureStorageService {}
class MockBiometricService extends Mock implements BiometricService {}

void main() {
  late MockApiClient mockApiClient;
  late MockSecureStorageService mockSecureStorage;
  late MockBiometricService mockBiometric;
  late CustomerAuthRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSecureStorage = MockSecureStorageService();
    mockBiometric = MockBiometricService();

    when(() => mockSecureStorage.getDeviceId()).thenAnswer((_) async => 'DEV-TEST-001');

    repository = CustomerAuthRepositoryImpl(
      storage: mockSecureStorage,
      biometricService: mockBiometric,
      apiClient: mockApiClient,
    );
  });

  group('CustomerAuthRepositoryImpl Default Deny & No-Mock Verification', () {
    test('checkAccount MUST THROW when API connection fails (no mock fallback)', () async {
      when(() => mockApiClient.post(
            ApiEndpoints.checkAccount,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.checkAccount),
          message: 'Connection refused / Server unreachable',
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => repository.checkAccount(
          identifier: '12/DAGAMA(N)123456',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('sendActivationOtp MUST THROW when API server is unreachable (zero fake profile)', () async {
      when(() => mockApiClient.post(
            ApiEndpoints.activationSendOtp,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.activationSendOtp),
          message: 'Connection refused / 404 Not Found',
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => repository.sendActivationOtp(
          identifier: '12/DAGAMA(N)123456',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('activateAccount MUST THROW when server rejects or cannot be reached', () async {
      when(() => mockApiClient.post(
            ApiEndpoints.activationSetPin,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.activationSetPin),
          message: 'Connection timeout',
          type: DioExceptionType.connectionTimeout,
        ),
      );

      expect(
        () => repository.activateAccount(
          activationToken: 'STEP-UP-TOKEN-123',
          pinCode: '123456',
          enableBiometric: false,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('loginWithNrcAndPin MUST THROW when API call fails (no fake fallback profile)', () async {
      when(() => mockApiClient.post(
            ApiEndpoints.loginCustomer,
            data: any(named: 'data'),
          )).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.loginCustomer),
          message: 'Failed host lookup',
          type: DioExceptionType.connectionError,
        ),
      );

      expect(
        () => repository.loginWithNrcAndPin(
          nrc: '12/DAGAMA(N)123456',
          pin: '123456',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
