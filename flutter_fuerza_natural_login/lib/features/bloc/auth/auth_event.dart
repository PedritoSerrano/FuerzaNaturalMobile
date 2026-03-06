part of 'auth_bloc.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String nombre;
  final String apellidos;
  final String email;
  final String password;
  const AuthRegisterRequested({
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.password,
  });
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthForceLogout extends AuthEvent {
  const AuthForceLogout();
}
