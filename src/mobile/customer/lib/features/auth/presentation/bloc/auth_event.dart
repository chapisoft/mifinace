import 'package:equatable/equatable.dart';

abstract class CustomerAuthEvent extends Equatable {
  const CustomerAuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckSessionRequested extends CustomerAuthEvent {
  const CheckSessionRequested();
}

class CheckAccountRequested extends CustomerAuthEvent {
  final String identifier;
  final String userType;

  const CheckAccountRequested({required this.identifier, this.userType = 'CUSTOMER'});

  @override
  List<Object?> get props => [identifier, userType];
}

class SendActivationOtpRequested extends CustomerAuthEvent {
  final String identifier;
  final String userType;

  const SendActivationOtpRequested({required this.identifier, this.userType = 'CUSTOMER'});

  @override
  List<Object?> get props => [identifier, userType];
}

class VerifyActivationOtpRequested extends CustomerAuthEvent {
  final String identifier;
  final String otpCode;
  final String userType;

  const VerifyActivationOtpRequested({
    required this.identifier,
    required this.otpCode,
    this.userType = 'CUSTOMER',
  });

  @override
  List<Object?> get props => [identifier, otpCode, userType];
}

class ActivateAccountRequested extends CustomerAuthEvent {
  final String activationToken;
  final String pinCode;
  final bool enableBiometric;

  const ActivateAccountRequested({
    required this.activationToken,
    required this.pinCode,
    this.enableBiometric = true,
  });

  @override
  List<Object?> get props => [activationToken, pinCode, enableBiometric];
}

class SendForgotPinOtpRequested extends CustomerAuthEvent {
  final String identifier;
  final String userType;

  const SendForgotPinOtpRequested({required this.identifier, this.userType = 'CUSTOMER'});

  @override
  List<Object?> get props => [identifier, userType];
}

class VerifyForgotPinOtpRequested extends CustomerAuthEvent {
  final String identifier;
  final String otpCode;
  final String userType;

  const VerifyForgotPinOtpRequested({
    required this.identifier,
    required this.otpCode,
    this.userType = 'CUSTOMER',
  });

  @override
  List<Object?> get props => [identifier, otpCode, userType];
}

class ResetPinRequested extends CustomerAuthEvent {
  final String resetPinToken;
  final String newPinCode;

  const ResetPinRequested({
    required this.resetPinToken,
    required this.newPinCode,
  });

  @override
  List<Object?> get props => [resetPinToken, newPinCode];
}

class LoginWithNrcAndPinRequested extends CustomerAuthEvent {
  final String nrc;
  final String pin;

  const LoginWithNrcAndPinRequested({required this.nrc, required this.pin});

  @override
  List<Object?> get props => [nrc, pin];
}

class LoginWithPinRequested extends CustomerAuthEvent {
  final String pin;

  const LoginWithPinRequested({required this.pin});

  @override
  List<Object?> get props => [pin];
}

class LoginWithBiometricRequested extends CustomerAuthEvent {
  const LoginWithBiometricRequested();
}

class LogoutRequested extends CustomerAuthEvent {
  const LogoutRequested();
}
