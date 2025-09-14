part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String? email;
  final String? phone;
  final String password;
  final bool rememberMe;
  final LoginType loginType;

  const AuthLoginRequested({
    this.email,
    this.phone,
    required this.password,
    this.rememberMe = true,
    this.loginType = LoginType.email,
  });

  @override
  List<Object?> get props => [email, phone, password, rememberMe, loginType];
}

enum LoginType {
  email,
  phone,
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

  const PhoneOtpResendRequested({required this.phoneNumber, this.deviceId});

  @override
  List<Object?> get props => [phoneNumber, deviceId];
}

class PhoneVerificationResetRequested extends AuthEvent {}

class AuthRegistrationRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String password;
  final String? referralCode;

  const AuthRegistrationRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    this.referralCode,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phoneNumber,
    password,
    referralCode,
  ];
}

class AuthRefreshUserDataRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String phoneNumber;
  final String userType;
  final String? deviceId;

  const PasswordResetRequested({
    required this.phoneNumber,
    required this.userType,
    this.deviceId,
  });

  @override
  List<Object?> get props => [phoneNumber, userType, deviceId];
}

class PasswordResetConfirmRequested extends AuthEvent {
  final String phoneNumber;
  final String otpCode;
  final String newPassword;
  final String userType;

  const PasswordResetConfirmRequested({
    required this.phoneNumber,
    required this.otpCode,
    required this.newPassword,
    required this.userType,
  });

  @override
  List<Object?> get props => [phoneNumber, otpCode, newPassword, userType];
}

class PasswordResetResetRequested extends AuthEvent {}