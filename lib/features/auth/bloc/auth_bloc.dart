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
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final user = await _repo.login(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );
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
        emit(PhoneVerificationOtpSent(
          otpId: response.data.otpId,
          phoneNumber: event.phoneNumber,
          expiresAt: DateTime.parse(response.data.expiresAt),
        ));
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
        emit(PhoneVerificationOtpVerified(
          phoneNumber: event.phoneNumber,
          isValid: response.data.isValid,
        ));
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
        emit(PhoneVerificationOtpResent(
          otpId: response.data.otpId,
          phoneNumber: event.phoneNumber,
          expiresAt: DateTime.parse(response.data.expiresAt),
        ));
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
}
