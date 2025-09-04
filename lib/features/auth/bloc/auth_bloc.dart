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
    print('🔍 AuthBloc: Checking authentication status...');
    final has = await _repo.hasToken();
    print('🔍 AuthBloc: Has token: $has');
    if (has) {
      final user = await _repo.getUser();
      print('🔍 AuthBloc: User data: ${user != null ? 'Found' : 'Not found'}');
      emit(AuthAuthenticated(user: user ?? {}));
    } else {
      print('🔍 AuthBloc: No token, emitting unauthenticated');
      emit(AuthUnauthenticated());
    }
  }
}
