import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String username;
  final String password;
  final String deviceId;

  const LoginRequested({
    required this.username,
    required this.password,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [username, password, deviceId];
}

class BiometricLoginRequested extends AuthEvent {
  const BiometricLoginRequested();
}

class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
