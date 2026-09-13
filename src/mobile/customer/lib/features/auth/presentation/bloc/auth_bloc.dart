import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc điều phối xác thực khách hàng, kiểm tra tài khoản Core Banking, gửi/xác thực OTP và kích hoạt/đặt lại mã PIN.
class CustomerAuthBloc extends Bloc<CustomerAuthEvent, CustomerAuthState> {
  final CustomerAuthRepository _authRepository;
  final SecureStorageService _storageService;

  CustomerAuthBloc({
    required CustomerAuthRepository authRepository,
    required SecureStorageService storageService,
  })  : _authRepository = authRepository,
        _storageService = storageService,
        super(const AuthInitial()) {
    on<CheckSessionRequested>(_onCheckSession);
    on<CheckAccountRequested>(_onCheckAccount);
    on<SendActivationOtpRequested>(_onSendActivationOtp);
    on<VerifyActivationOtpRequested>(_onVerifyActivationOtp);
    on<ActivateAccountRequested>(_onActivateAccount);
    on<SendForgotPinOtpRequested>(_onSendForgotPinOtp);
    on<VerifyForgotPinOtpRequested>(_onVerifyForgotPinOtp);
    on<ResetPinRequested>(_onResetPin);
    on<LoginWithNrcAndPinRequested>(_onLoginWithNrcAndPin);
    on<LoginWithPinRequested>(_onLoginWithPin);
    on<LoginWithBiometricRequested>(_onLoginWithBiometric);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onCheckSession(CheckSessionRequested event, Emitter<CustomerAuthState> emit) async {
    try {
      final hasPin = await _storageService.hasPinSet();
      final token = await _storageService.getAuthToken();

      if (token != null && hasPin) {
        final profile = await _authRepository.getActiveProfile();
        if (profile != null) {
          emit(AuthAuthenticated(profile));
          return;
        }
      }

      emit(AuthUnauthenticated(hasPinConfigured: hasPin));
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onCheckAccount(CheckAccountRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Checking account for ${event.identifier}', tag: 'AuthBloc');
      final result = await _authRepository.checkAccount(
        identifier: event.identifier,
        userType: event.userType,
      );
      emit(AuthAccountCheckedState(result));
    } catch (e, stack) {
      AppLogger.error('Failed to check account: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendActivationOtp(SendActivationOtpRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Sending activation OTP for ${event.identifier}', tag: 'AuthBloc');
      final res = await _authRepository.sendActivationOtp(
        identifier: event.identifier,
        userType: event.userType,
      );
      emit(AuthActivationOtpSentState(
        identifier: event.identifier,
        maskedPhone: res['maskedPhone']?.toString() ?? '',
        expiresIn: (res['expiresIn'] as num?)?.toInt() ?? 120,
        cooldownSeconds: (res['cooldownSeconds'] as num?)?.toInt() ?? 60,
      ));
    } catch (e, stack) {
      AppLogger.error('Failed to send activation OTP: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyActivationOtp(VerifyActivationOtpRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Verifying activation OTP for ${event.identifier}', tag: 'AuthBloc');
      final stepUpToken = await _authRepository.verifyActivationOtp(
        identifier: event.identifier,
        otpCode: event.otpCode,
        userType: event.userType,
      );
      emit(AuthActivationOtpVerifiedState(
        identifier: event.identifier,
        stepUpToken: stepUpToken,
      ));
    } catch (e, stack) {
      AppLogger.error('Activation OTP verification failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onActivateAccount(ActivateAccountRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Activating account with PIN', tag: 'AuthBloc');
      final profile = await _authRepository.activateAccount(
        activationToken: event.activationToken,
        pinCode: event.pinCode,
        enableBiometric: event.enableBiometric,
      );
      emit(AuthAuthenticated(profile));
    } catch (e, stack) {
      AppLogger.error('Account activation failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSendForgotPinOtp(SendForgotPinOtpRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Sending forgot PIN OTP for ${event.identifier}', tag: 'AuthBloc');
      final res = await _authRepository.sendForgotPinOtp(
        identifier: event.identifier,
        userType: event.userType,
      );
      emit(AuthForgotPinOtpSentState(
        identifier: event.identifier,
        maskedPhone: res['maskedPhone']?.toString() ?? '',
        expiresIn: (res['expiresIn'] as num?)?.toInt() ?? 120,
        cooldownSeconds: (res['cooldownSeconds'] as num?)?.toInt() ?? 60,
      ));
    } catch (e, stack) {
      AppLogger.error('Failed to send forgot PIN OTP: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyForgotPinOtp(VerifyForgotPinOtpRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Verifying forgot PIN OTP for ${event.identifier}', tag: 'AuthBloc');
      final resetPinToken = await _authRepository.verifyForgotPinOtp(
        identifier: event.identifier,
        otpCode: event.otpCode,
        userType: event.userType,
      );
      emit(AuthForgotPinOtpVerifiedState(
        identifier: event.identifier,
        resetPinToken: resetPinToken,
      ));
    } catch (e, stack) {
      AppLogger.error('Forgot PIN OTP verification failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResetPin(ResetPinRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Resetting PIN', tag: 'AuthBloc');
      final profile = await _authRepository.resetPin(
        resetPinToken: event.resetPinToken,
        newPinCode: event.newPinCode,
      );
      emit(AuthAuthenticated(profile));
    } catch (e, stack) {
      AppLogger.error('Reset PIN failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoginWithNrcAndPin(LoginWithNrcAndPinRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Logging in member with NRC/Phone and PIN: ${event.nrc}', tag: 'AuthBloc');
      final profile = await _authRepository.loginWithNrcAndPin(nrc: event.nrc, pin: event.pin);
      emit(AuthAuthenticated(profile));
    } catch (e, stack) {
      AppLogger.error('NRC/PIN login failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated(hasPinConfigured: true));
    }
  }

  Future<void> _onLoginWithPin(LoginWithPinRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Logging in member with security PIN', tag: 'AuthBloc');
      final profile = await _authRepository.loginWithPin(pin: event.pin);
      emit(AuthAuthenticated(profile));
    } catch (e, stack) {
      AppLogger.error('PIN login failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated(hasPinConfigured: true));
    }
  }

  Future<void> _onLoginWithBiometric(LoginWithBiometricRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Logging in with Biometrics', tag: 'AuthBloc');
      final profile = await _authRepository.loginWithBiometric();
      emit(AuthAuthenticated(profile));
    } catch (e, stack) {
      AppLogger.error('Biometric login failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
      emit(const AuthUnauthenticated(hasPinConfigured: true));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<CustomerAuthState> emit) async {
    await _authRepository.logout();
    final hasPin = await _storageService.hasPinSet();
    emit(AuthUnauthenticated(hasPinConfigured: hasPin));
  }
}
