import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc managing Credit Officer Authentication, Biometrics, and Session Lifecycles.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final BiometricService _biometricService;

  AuthBloc({
    required AuthRepository authRepository,
    required BiometricService biometricService,
  })  : _authRepository = authRepository,
        _biometricService = biometricService,
        super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusRequested event, Emitter<AuthState> emit) async {
    final hasSession = await _authRepository.hasValidSession();
    if (hasSession) {
      final cachedProfile = await _authRepository.getCachedProfile();
      if (cachedProfile != null) {
        AppLogger.info('Found active authenticated session for user: ${cachedProfile.username}', tag: 'AuthBloc');
        emit(AuthAuthenticated(cachedProfile));
        return;
      }
    }
    emit(const AuthUnauthenticated());
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final profile = await _authRepository.login(
        username: event.username,
        password: event.password,
        deviceId: event.deviceId,
        platform: 'ANDROID',
        appVersion: AppConstants.appVersion,
      );
      emit(AuthAuthenticated(profile));
    } catch (e, stack) {
      AppLogger.error('Login failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthFailureState(e.toString().replaceAll('Exception:', '').trim()));
    }
  }

  Future<void> _onBiometricLoginRequested(BiometricLoginRequested event, Emitter<AuthState> emit) async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable) {
      emit(const AuthFailureState('Biometric authentication is not supported or enabled on this device.'));
      return;
    }

    final authenticated = await _biometricService.authenticate(
      localizedReason: 'Please scan your fingerprint to log into BMF Agent.',
    );

    if (authenticated) {
      final cachedProfile = await _authRepository.getCachedProfile();
      if (cachedProfile != null) {
        emit(AuthAuthenticated(cachedProfile));
      } else {
        emit(const AuthFailureState('No active officer profile found. Please log in with password first.'));
      }
    } else {
      emit(const AuthFailureState('Biometric authentication was cancelled or not recognized.'));
    }
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
