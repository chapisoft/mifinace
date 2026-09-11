import 'package:equatable/equatable.dart';

abstract class CustomerAuthEvent extends Equatable {
  const CustomerAuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckSessionRequested extends CustomerAuthEvent {
  const CheckSessionRequested();
}

class RequestOtpRequested extends CustomerAuthEvent {
  final String nrcFormatted;
  final String phone;

  const RequestOtpRequested({required this.nrcFormatted, required this.phone});

  @override
  List<Object?> get props => [nrcFormatted, phone];
}

class VerifyOtpRequested extends CustomerAuthEvent {
  final String nrcFormatted;
  final String phone;
  final String otpCode;

  const VerifyOtpRequested({
    required this.nrcFormatted,
    required this.phone,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [nrcFormatted, phone, otpCode];
}

class SetupPinRequested extends CustomerAuthEvent {
  final String pin;
  final bool enableBiometric;

  const SetupPinRequested({required this.pin, required this.enableBiometric});

  @override
  List<Object?> get props => [pin, enableBiometric];
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
