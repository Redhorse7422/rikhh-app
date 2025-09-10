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

class PhoneVerificationOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String? deviceId;

  const PhoneVerificationOtpRequested({
    required this.phoneNumber,
    this.deviceId,
  });

  @override
  List<Object?> get props => [phoneNumber, deviceId];
}

class PhoneOtpVerificationRequested extends AuthEvent {
  final String phoneNumber;
  final String otpCode;

  const PhoneOtpVerificationRequested({
    required this.phoneNumber,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [phoneNumber, otpCode];
}

class PhoneOtpResendRequested extends AuthEvent {
  final String phoneNumber;
  final String? deviceId;

  const PhoneOtpResendRequested({
    required this.phoneNumber,
    this.deviceId,
  });

  @override
  List<Object?> get props => [phoneNumber, deviceId];
}

class PhoneVerificationResetRequested extends AuthEvent {}