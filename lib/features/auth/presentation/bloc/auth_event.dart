import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthGoogleLoginRequested extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthBiometricLoginRequested extends AuthEvent {}

class AuthUpdateProfileRequested extends AuthEvent {
  final String displayName;
  final String? photoUrl;

  const AuthUpdateProfileRequested({required this.displayName, this.photoUrl});

  @override
  List<Object> get props => [displayName, photoUrl ?? ''];
}

class AuthToggleOnlineStatus extends AuthEvent {
  final bool isOnline;
  const AuthToggleOnlineStatus(this.isOnline);

  @override
  List<Object> get props => [isOnline];
}
