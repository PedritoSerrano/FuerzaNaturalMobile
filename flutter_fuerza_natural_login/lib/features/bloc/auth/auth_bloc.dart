import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/user_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repo;

  AuthBloc({AuthRepository? repo})
      : _repo = repo ?? AuthRepository(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthForceLogout>(_onForceLogout);
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    debugPrint('[AuthBloc] _onCheck iniciado');
    emit(const AuthLoading());
    try {
      final loggedIn = await _repo.isLoggedIn();
      debugPrint('[AuthBloc] token guardado: $loggedIn');
      if (loggedIn) {
        try {
          final user = await _repo.getMe();
          debugPrint('[AuthBloc] getMe OK → ${user.email}');
          emit(AuthAuthenticated(user));
        } catch (e) {
          
          debugPrint('[AuthBloc] getMe FALLÓ → $e → limpiando token');
          await _repo.deleteToken();
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      debugPrint('[AuthBloc] _onCheck error inesperado → $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested e, Emitter<AuthState> emit) async {
    debugPrint('[AuthBloc] _onLogin → ${e.email}');
    emit(const AuthLoading());
    try {
      final user = await _repo.login(e.email, e.password);
      debugPrint('[AuthBloc] login OK → ${user.email} rol=${user.rol}');
      emit(AuthAuthenticated(user));
    } catch (err, stack) {
      debugPrint('[AuthBloc] login FALLÓ → $err');
      debugPrint('[AuthBloc] stacktrace → $stack');
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested e, Emitter<AuthState> emit) async {
    debugPrint('[AuthBloc] _onRegister → ${e.email}');
    emit(const AuthLoading());
    try {
      final user = await _repo.register(
        nombre: e.nombre,
        apellidos: e.apellidos,
        email: e.email,
        password: e.password,
      );
      debugPrint('[AuthBloc] register OK → ${user.email}');
      emit(AuthAuthenticated(user));
    } catch (err) {
      debugPrint('[AuthBloc] register FALLÓ → $err');
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested e, Emitter<AuthState> emit) async {
    debugPrint('[AuthBloc] _onLogout');
    await _repo.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onForceLogout(AuthForceLogout e, Emitter<AuthState> emit) async {
    debugPrint('[AuthBloc] _onForceLogout → usuario eliminado externamente');
    await _repo.deleteToken();
    emit(const AuthUnauthenticated());
  }
}
