part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;
  
  const AuthAuthenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PhoneVerificationOtpSent extends AuthState {
  final String otpId;
  final String phoneNumber;
  final DateTime expiresAt;

  const PhoneVerificationOtpSent({
    required this.otpId,
    required this.phoneNumber,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [otpId, phoneNumber, expiresAt];
}

class PhoneVerificationOtpVerified extends AuthState {
  final String phoneNumber;
  final bool isValid;

  const PhoneVerificationOtpVerified({
    required this.phoneNumber,
    required this.isValid,
  });

  @override
  List<Object?> get props => [phoneNumber, isValid];
}

class PhoneVerificationOtpResent extends AuthState {
  final String otpId;
  final String phoneNumber;
  final DateTime expiresAt;

  const PhoneVerificationOtpResent({
    required this.otpId,
    required this.phoneNumber,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [otpId, phoneNumber, expiresAt];
}

class PhoneVerificationReset extends AuthState {}

class AuthRegistrationSuccess extends AuthState {
  final Map<String, dynamic> user;
  
  const AuthRegistrationSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class PasswordResetOtpSent extends AuthState {
  final String otpId;
  final String phoneNumber;
  final DateTime expiresAt;

  const PasswordResetOtpSent({
    required this.otpId,
    required this.phoneNumber,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [otpId, phoneNumber, expiresAt];
}

class PasswordResetSuccess extends AuthState {
  final String message;

  const PasswordResetSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class PasswordResetReset extends AuthState {}