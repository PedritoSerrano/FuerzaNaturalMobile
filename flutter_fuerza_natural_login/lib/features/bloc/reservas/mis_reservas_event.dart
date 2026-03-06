part of 'mis_reservas_bloc.dart';

abstract class MisReservasEvent {
  const MisReservasEvent();
}

class MisReservasLoadRequested extends MisReservasEvent {
  const MisReservasLoadRequested();
}

class MisReservasFiltrarPorEstado extends MisReservasEvent {
  final String filtro; 
  const MisReservasFiltrarPorEstado(this.filtro);
}
