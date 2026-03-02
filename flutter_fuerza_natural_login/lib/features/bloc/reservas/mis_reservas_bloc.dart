import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/reserva_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/reservas_repository.dart';

part 'mis_reservas_event.dart';
part 'mis_reservas_state.dart';

class MisReservasBloc extends Bloc<MisReservasEvent, MisReservasState> {
  final ReservasRepository _repo;

  MisReservasBloc({ReservasRepository? repo})
      : _repo = repo ?? ReservasRepository(),
        super(const MisReservasInitial()) {
    on<MisReservasLoadRequested>(_onLoadRequested);
    on<MisReservasFiltrarPorEstado>(_onFiltrar);
  }

  Future<void> _onLoadRequested(
      MisReservasLoadRequested event, Emitter<MisReservasState> emit) async {
    emit(const MisReservasLoading());
    try {
      final todas = await _repo.getMisReservas();
      emit(MisReservasLoaded(todas: todas, mostradas: todas));
    } catch (e) {
      emit(MisReservasError(e.toString()));
    }
  }

  void _onFiltrar(
      MisReservasFiltrarPorEstado event, Emitter<MisReservasState> emit) {
    final current = state;
    if (current is! MisReservasLoaded) return;

    List<ReservaModel> filtradas;
    switch (event.filtro) {
      case 'activas':
        filtradas = current.todas
            .where((r) =>
                r.estado == EstadoReserva.confirmada ||
                r.estado == EstadoReserva.pendiente ||
                r.estado == EstadoReserva.enCurso)
            .toList();
        break;
      case 'pasadas':
        filtradas = current.todas
            .where((r) =>
                r.estado == EstadoReserva.completada ||
                r.estado == EstadoReserva.cancelada)
            .toList();
        break;
      default:
        filtradas = current.todas;
    }

    emit(MisReservasLoaded(
      todas: current.todas,
      mostradas: filtradas,
      filtroActivo: event.filtro,
    ));
  }
}
