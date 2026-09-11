import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/repositories/customer_auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc coordinating borrower authentication, SMS OTP, and PIN verification.
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
    on<RequestOtpRequested>(_onRequestOtp);
    on<VerifyOtpRequested>(_onVerifyOtp);
    on<SetupPinRequested>(_onSetupPin);
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

  Future<void> _onRequestOtp(RequestOtpRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Initiating SMS OTP request for ${event.nrcFormatted}', tag: 'AuthBloc');
      await _authRepository.requestRegistrationOtp(
        nrcFormatted: event.nrcFormatted,
        phone: event.phone,
      );
      emit(AuthOtpSentState(nrcFormatted: event.nrcFormatted, phone: event.phone));
    } catch (e, stack) {
      AppLogger.error('Failed to request SMS OTP: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Verifying OTP for member ${event.nrcFormatted}', tag: 'AuthBloc');
      final profile = await _authRepository.verifyRegistrationOtp(
        nrcFormatted: event.nrcFormatted,
        phone: event.phone,
        otpCode: event.otpCode,
      );
      emit(AuthNeedsPinSetupState(profile));
    } catch (e, stack) {
      AppLogger.error('OTP verification failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSetupPin(SetupPinRequested event, Emitter<CustomerAuthState> emit) async {
    emit(const AuthLoading());
    try {
      AppLogger.info('Configuring new security PIN', tag: 'AuthBloc');
      await _authRepository.setupSecurityPin(
        pin: event.pin,
        enableBiometric: event.enableBiometric,
      );
      final profile = await _authRepository.getActiveProfile();
      if (profile != null) {
        emit(AuthAuthenticated(profile));
      } else {
        emit(const AuthUnauthenticated(hasPinConfigured: true));
      }
    } catch (e, stack) {
      AppLogger.error('PIN setup failed: $e', tag: 'AuthBloc', stackTrace: stack);
      emit(AuthError(e.toString()));
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
