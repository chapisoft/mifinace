import 'package:equatable/equatable.dart';
import '../../domain/models/check_account_result.dart';
import '../../domain/models/member_profile.dart';

abstract class CustomerAuthState extends Equatable {
  const CustomerAuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends CustomerAuthState {
  const AuthInitial();
}

class AuthLoading extends CustomerAuthState {
  const AuthLoading();
}

class AuthAccountCheckedState extends CustomerAuthState {
  final CheckAccountResult account;

  const AuthAccountCheckedState(this.account);

  @override
  List<Object?> get props => [account];
}

class AuthActivationOtpSentState extends CustomerAuthState {
  final String identifier;
  final String maskedPhone;
  final int expiresIn;
  final int cooldownSeconds;

  const AuthActivationOtpSentState({
    required this.identifier,
    required this.maskedPhone,
    required this.expiresIn,
    required this.cooldownSeconds,
  });

  @override
  List<Object?> get props => [identifier, maskedPhone, expiresIn, cooldownSeconds];
}

class AuthActivationOtpVerifiedState extends CustomerAuthState {
  final String identifier;
  final String stepUpToken;

  const AuthActivationOtpVerifiedState({
    required this.identifier,
    required this.stepUpToken,
  });

  @override
  List<Object?> get props => [identifier, stepUpToken];
}

class AuthForgotPinOtpSentState extends CustomerAuthState {
  final String identifier;
  final String maskedPhone;
  final int expiresIn;
  final int cooldownSeconds;

  const AuthForgotPinOtpSentState({
    required this.identifier,
    required this.maskedPhone,
    required this.expiresIn,
    required this.cooldownSeconds,
  });

  @override
  List<Object?> get props => [identifier, maskedPhone, expiresIn, cooldownSeconds];
}

class AuthForgotPinOtpVerifiedState extends CustomerAuthState {
  final String identifier;
  final String resetPinToken;

  const AuthForgotPinOtpVerifiedState({
    required this.identifier,
    required this.resetPinToken,
  });

  @override
  List<Object?> get props => [identifier, resetPinToken];
}

class AuthAuthenticated extends CustomerAuthState {
  final MemberProfile profile;

  const AuthAuthenticated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class AuthUnauthenticated extends CustomerAuthState {
  final bool hasPinConfigured;

  const AuthUnauthenticated({this.hasPinConfigured = false});

  @override
  List<Object?> get props => [hasPinConfigured];
}

class AuthError extends CustomerAuthState {
  final String errorMessage;

  const AuthError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
