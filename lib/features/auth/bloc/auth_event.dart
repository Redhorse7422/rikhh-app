part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}
