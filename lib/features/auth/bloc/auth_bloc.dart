import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc({required AuthRepository repo})
    : _repo = repo,
      super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckStatusRequested>(_onCheckStatusRequested);
    on<PhoneVerificationOtpRequested>(_onPhoneVerificationOtpRequested);
    on<PhoneOtpVerificationRequested>(_onPhoneOtpVerificationRequested);
    on<PhoneOtpResendRequested>(_onPhoneOtpResendRequested);
    on<PhoneVerificationResetRequested>(_onPhoneVerificationResetRequested);
    on<AuthRegistrationRequested>(_onRegistrationRequested);
    on<AuthRefreshUserDataRequested>(_onRefreshUserDataRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordResetConfirmRequested>(_onPasswordResetConfirmRequested);
    on<PasswordResetResetRequested>(_onPasswordResetResetRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      Map<String, dynamic> user;
      
      if (event.loginType == LoginType.email) {
        if (event.email == null) {
          throw Exception('Email is required for email login');
        }
        user = await _repo.login(
          email: event.email!,
          password: event.password,
          rememberMe: event.rememberMe,
        );
      } else {
        if (event.phone == null) {
          throw Exception('Phone number is required for phone login');
        }
        user = await _repo.loginWithPhone(
          phone: event.phone!,
          password: event.password,
          rememberMe: event.rememberMe,
        );
      }
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _repo.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckStatusRequested(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    final has = await _repo.hasToken();

    if (has) {
      final user = await _repo.getUser();

      emit(AuthAuthenticated(user: user ?? {}));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onPhoneVerificationOtpRequested(
    PhoneVerificationOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final response = await _repo.sendPhoneVerificationOtp(
        phoneNumber: event.phoneNumber,
        deviceId: event.deviceId,
      );


      if (response.code == 0) {
        emit(
          PhoneVerificationOtpSent(
            otpId: response.data.otpId,
            phoneNumber: event.phoneNumber,
            expiresAt: DateTime.parse(response.data.expiresAt),
          ),
        );
      } else {
        emit(AuthError(response.message));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPhoneOtpVerificationRequested(
    PhoneOtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final response = await _repo.verifyPhoneOtp(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
      );

      if (response.code == 0 && response.data.isValid) {
        emit(
          PhoneVerificationOtpVerified(
            phoneNumber: event.phoneNumber,
            isValid: response.data.isValid,
          ),
        );
      } else {
        emit(AuthError(response.message));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPhoneOtpResendRequested(
    PhoneOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final response = await _repo.resendPhoneVerificationOtp(
        phoneNumber: event.phoneNumber,
        deviceId: event.deviceId,
      );

      if (response.code == 0) {
        emit(
          PhoneVerificationOtpResent(
            otpId: response.data.otpId,
            phoneNumber: event.phoneNumber,
            expiresAt: DateTime.parse(response.data.expiresAt),
          ),
        );
      } else {
        emit(AuthError(response.message));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPhoneVerificationResetRequested(
    PhoneVerificationResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(PhoneVerificationReset());
  }

  Future<void> _onRegistrationRequested(
    AuthRegistrationRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final user = await _repo.register(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        phoneNumber: event.phoneNumber,
        password: event.password,
        referralCode: event.referralCode,
      );
      emit(AuthRegistrationSuccess(user: user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRefreshUserDataRequested(
    AuthRefreshUserDataRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _repo.getUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError('Failed to refresh user data: ${e.toString()}'));
    }
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final response = await _repo.requestPasswordReset(
        phoneNumber: event.phoneNumber,
        userType: event.userType,
        deviceId: event.deviceId,
      );


      if (response.code == 0) {
        emit(
          PasswordResetOtpSent(
            otpId: response.data.otpId,
            phoneNumber: event.phoneNumber,
            expiresAt: DateTime.parse(response.data.expiresAt),
          ),
        );
      } else {
        emit(AuthError(response.message));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetConfirmRequested(
    PasswordResetConfirmRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final response = await _repo.confirmPasswordReset(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
        newPassword: event.newPassword,
        userType: event.userType,
      );


      if (response.code == 0) {
        emit(PasswordResetSuccess(message: response.message));
      } else {
        emit(AuthError(response.message));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onPasswordResetResetRequested(
    PasswordResetResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(PasswordResetReset());
  }
}
