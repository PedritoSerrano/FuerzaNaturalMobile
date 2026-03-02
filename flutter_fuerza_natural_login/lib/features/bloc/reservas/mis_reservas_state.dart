part of 'mis_reservas_bloc.dart';

abstract class MisReservasState {
  const MisReservasState();
}

class MisReservasInitial extends MisReservasState {
  const MisReservasInitial();
}

class MisReservasLoading extends MisReservasState {
  const MisReservasLoading();
}

class MisReservasLoaded extends MisReservasState {
  final List<ReservaModel> todas;
  final List<ReservaModel> mostradas;
  final String filtroActivo; // 'todas', 'activas', 'pasadas'

  const MisReservasLoaded({
    required this.todas,
    required this.mostradas,
    this.filtroActivo = 'todas',
  });

  int get totalActivas => todas
      .where((r) =>
          r.estado == EstadoReserva.confirmada ||
          r.estado == EstadoReserva.pendiente ||
          r.estado == EstadoReserva.enCurso)
      .length;

  int get totalCompletadas =>
      todas.where((r) => r.estado == EstadoReserva.completada).length;
}

class MisReservasError extends MisReservasState {
  final String mensaje;
  const MisReservasError(this.mensaje);
}
