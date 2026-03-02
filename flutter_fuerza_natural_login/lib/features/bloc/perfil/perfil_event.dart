part of 'perfil_bloc.dart';

abstract class PerfilEvent {
  const PerfilEvent();
}

class PerfilLoadRequested extends PerfilEvent {
  const PerfilLoadRequested();
}

class PerfilCerrarSesionRequested extends PerfilEvent {
  const PerfilCerrarSesionRequested();
}
