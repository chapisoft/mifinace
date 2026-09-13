import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bmf_customer/core/security/secure_storage_service.dart';
import 'package:bmf_customer/features/auth/domain/models/check_account_result.dart';
import 'package:bmf_customer/features/auth/domain/models/member_profile.dart';
import 'package:bmf_customer/features/auth/domain/repositories/customer_auth_repository.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_event.dart';
import 'package:bmf_customer/features/auth/presentation/bloc/auth_state.dart';

class MockCustomerAuthRepository extends Mock implements CustomerAuthRepository {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockCustomerAuthRepository mockAuthRepository;
  late MockSecureStorageService mockSecureStorage;
  late CustomerAuthBloc authBloc;

  const testProfile = MemberProfile(
    memberId: 'MBR-999',
    nrcFormatted: '12/DAGAMA(N)098765',
    fullName: 'Daw Khin Khin',
    phone: '09791234567',
    centerName: 'Kyauktada Center 01',
    groupName: 'Solidarity Group A',
    totalSavingBalanceMmk: 50000.0,
    loyaltyPoints: 100,
    hasActiveLoans: true,
    isPinConfigured: true,
  );

  setUp(() {
    mockAuthRepository = MockCustomerAuthRepository();
    mockSecureStorage = MockSecureStorageService();

    authBloc = CustomerAuthBloc(
      authRepository: mockAuthRepository,
      storageService: mockSecureStorage,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('CustomerAuthBloc Tests', () {
    test('Initial state should be AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    test('CheckSessionRequested emits AuthUnauthenticated when no pin set', () async {
      when(() => mockSecureStorage.hasPinSet()).thenAnswer((_) async => false);
      when(() => mockSecureStorage.getAuthToken()).thenAnswer((_) async => null);

      authBloc.add(const CheckSessionRequested());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthUnauthenticated(hasPinConfigured: false),
        ]),
      );
    });

    test('CheckSessionRequested emits AuthUnauthenticated with hasPinConfigured=true when pin set', () async {
      when(() => mockSecureStorage.hasPinSet()).thenAnswer((_) async => true);
      when(() => mockSecureStorage.getAuthToken()).thenAnswer((_) async => null);

      authBloc.add(const CheckSessionRequested());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthUnauthenticated(hasPinConfigured: true),
        ]),
      );
    });

    test('CheckSessionRequested emits AuthAuthenticated when token exists and active profile retrieved', () async {
      when(() => mockSecureStorage.hasPinSet()).thenAnswer((_) async => true);
      when(() => mockSecureStorage.getAuthToken()).thenAnswer((_) async => 'valid_token');
      when(() => mockAuthRepository.getActiveProfile()).thenAnswer((_) async => testProfile);

      authBloc.add(const CheckSessionRequested());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthAuthenticated(testProfile),
        ]),
      );
    });

    test('CheckAccountRequested emits AuthAccountCheckedState on valid identifier', () async {
      const mockResult = CheckAccountResult(
        status: 'NOT_ACTIVATED',
        identifier: '09791234567',
        businessId: 'MBR-999',
        userType: 'CUSTOMER',
        fullName: 'Daw Khin Khin',
        maskedPhone: '09*****4567',
        nrcNumber: '12/DAGAMA(N)098765',
        activated: false,
        biometricEnabled: false,
        pinLocked: false,
      );

      when(() => mockAuthRepository.checkAccount(identifier: '09791234567'))
          .thenAnswer((_) async => mockResult);

      authBloc.add(const CheckAccountRequested(identifier: '09791234567'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const AuthAccountCheckedState(mockResult),
        ]),
      );
    });

    test('SendActivationOtpRequested emits AuthActivationOtpSentState on success', () async {
      when(() => mockAuthRepository.sendActivationOtp(identifier: '09791234567'))
          .thenAnswer((_) async => {
                'identifier': '09791234567',
                'maskedPhone': '09*****4567',
                'expiresIn': 300,
                'cooldownSeconds': 60,
              });

      authBloc.add(const SendActivationOtpRequested(identifier: '09791234567'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const AuthActivationOtpSentState(
            identifier: '09791234567',
            maskedPhone: '09*****4567',
            expiresIn: 300,
            cooldownSeconds: 60,
          ),
        ]),
      );
    });

    test('SendActivationOtpRequested emits AuthError when repository throws', () async {
      when(() => mockAuthRepository.sendActivationOtp(identifier: '09791234567'))
          .thenThrow(Exception('SMS Gateway timeout'));

      authBloc.add(const SendActivationOtpRequested(identifier: '09791234567'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          isA<AuthError>(),
        ]),
      );
    });

    test('VerifyActivationOtpRequested emits AuthActivationOtpVerifiedState on valid OTP', () async {
      when(() => mockAuthRepository.verifyActivationOtp(
            identifier: '09791234567',
            otpCode: '123456',
          )).thenAnswer((_) async => 'STEP-UP-TOKEN-123');

      authBloc.add(const VerifyActivationOtpRequested(
        identifier: '09791234567',
        otpCode: '123456',
      ));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const AuthActivationOtpVerifiedState(
            identifier: '09791234567',
            stepUpToken: 'STEP-UP-TOKEN-123',
          ),
        ]),
      );
    });

    test('LoginWithPinRequested emits AuthAuthenticated on valid PIN', () async {
      when(() => mockAuthRepository.loginWithPin(pin: '123456'))
          .thenAnswer((_) async => testProfile);

      authBloc.add(const LoginWithPinRequested(pin: '123456'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          const AuthAuthenticated(testProfile),
        ]),
      );
    });

    test('LoginWithPinRequested emits AuthError on incorrect PIN', () async {
      when(() => mockAuthRepository.loginWithPin(pin: '000000'))
          .thenThrow(Exception('Invalid PIN'));

      authBloc.add(const LoginWithPinRequested(pin: '000000'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthLoading(),
          isA<AuthError>(),
        ]),
      );
    });

    test('LogoutRequested clears session and emits AuthUnauthenticated', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
      when(() => mockSecureStorage.hasPinSet()).thenAnswer((_) async => true);

      authBloc.add(const LogoutRequested());

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          const AuthUnauthenticated(hasPinConfigured: true),
        ]),
      );
    });
  });
}
