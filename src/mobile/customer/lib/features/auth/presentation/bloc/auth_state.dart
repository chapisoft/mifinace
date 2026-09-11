import 'package:equatable/equatable.dart';
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

class AuthOtpSentState extends CustomerAuthState {
  final String nrcFormatted;
  final String phone;

  const AuthOtpSentState({required this.nrcFormatted, required this.phone});

  @override
  List<Object?> get props => [nrcFormatted, phone];
}

class AuthNeedsPinSetupState extends CustomerAuthState {
  final MemberProfile profile;

  const AuthNeedsPinSetupState(this.profile);

  @override
  List<Object?> get props => [profile];
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
