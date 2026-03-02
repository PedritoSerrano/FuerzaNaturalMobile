part of 'perfil_bloc.dart';

abstract class PerfilState {
  const PerfilState();
}

class PerfilInitial extends PerfilState {
  const PerfilInitial();
}

class PerfilLoading extends PerfilState {
  const PerfilLoading();
}

class PerfilLoaded extends PerfilState {
  final UserModel user;
  const PerfilLoaded({required this.user});
}

class PerfilError extends PerfilState {
  final String mensaje;
  const PerfilError(this.mensaje);
}

class PerfilSesionCerrada extends PerfilState {
  const PerfilSesionCerrada();
}
