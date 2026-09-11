import 'package:flutter_test/flutter_test.dart';
import 'package:bmf_agent_app/core/enums/user_role.dart';
import 'package:bmf_agent_app/core/security/biometric_service.dart';
import 'package:bmf_agent_app/features/auth/domain/entities/officer_profile.dart';
import 'package:bmf_agent_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bmf_agent_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bmf_agent_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bmf_agent_app/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  bool isLoggedIn = false;
  OfficerProfile? mockProfile;
  bool shouldThrowError = false;

  @override
  Future<OfficerProfile> login({
    required String username,
    required String password,
    required String deviceId,
    required String platform,
    required String appVersion,
    String? pushToken,
  }) async {
    if (shouldThrowError) {
      throw Exception('Invalid username or password');
    }
    isLoggedIn = true;
    mockProfile = const OfficerProfile(
      userId: 'OFFICER001',
      username: 'thura_zaw',
      fullName: 'U Thura Zaw',
      role: UserRole.creditOfficer,
      branchCode: 'B001',
      townshipCode: 'TGY',
    );
    return mockProfile!;
  }

  @override
  Future<bool> hasValidSession() async => isLoggedIn;

  @override
  Future<OfficerProfile?> getCachedProfile() async => mockProfile;

  @override
  Future<void> logout() async {
    isLoggedIn = false;
    mockProfile = null;
  }
}

class MockBiometricService extends BiometricService {
  final bool available;
  final bool authResult;

  MockBiometricService({this.available = true, this.authResult = true});

  @override
  Future<bool> isBiometricAvailable() async => available;

  @override
  Future<bool> authenticate({required String localizedReason}) async => authResult;
}

void main() {
  group('AuthBloc & Field Officer Authentication Tests (TASK-AGENT-03)', () {
    late MockAuthRepository mockAuthRepository;
    late MockBiometricService mockBiometricService;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockBiometricService = MockBiometricService();
      authBloc = AuthBloc(
        authRepository: mockAuthRepository,
        biometricService: mockBiometricService,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('Initial state is AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    test('LoginRequested with valid credentials emits [AuthLoading, AuthAuthenticated]', () async {
      final expectedStates = [
        const AuthLoading(),
        isA<AuthAuthenticated>().having(
          (s) => s.profile.username,
          'username',
          'thura_zaw',
        ),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const LoginRequested(
        username: 'thura_zaw',
        password: 'SecurePassword123!',
        deviceId: 'DEV_TEST_001',
      ));
    });

    test('LoginRequested with invalid credentials emits [AuthLoading, AuthFailureState]', () async {
      mockAuthRepository.shouldThrowError = true;

      final expectedStates = [
        const AuthLoading(),
        isA<AuthFailureState>().having(
          (s) => s.message,
          'message',
          'Invalid username or password',
        ),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const LoginRequested(
        username: 'wrong_user',
        password: 'wrong_password',
        deviceId: 'DEV_TEST_001',
      ));
    });

    test('LogoutRequested emits [AuthLoading, AuthUnauthenticated]', () async {
      final expectedStates = [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const LogoutRequested());
    });
  });
}
