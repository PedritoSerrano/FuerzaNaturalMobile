import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/fincas_repository.dart';

part 'mis_fincas_event.dart';
part 'mis_fincas_state.dart';

class MisFincasBloc extends Bloc<MisFincasEvent, MisFincasState> {
  final FincasRepository _repo;

  MisFincasBloc({FincasRepository? repo})
      : _repo = repo ?? FincasRepository(),
        super(const MisFincasInitial()) {
    on<MisFincasLoadRequested>(_onLoadRequested);
    on<MisFincasPausarFinca>(_onPausar);
    on<MisFincasActivarFinca>(_onActivar);
    on<MisFincasEliminarFinca>(_onEliminar);
    on<MisFincasAgregarFinca>(_onAgregar);
    on<MisFincasActualizarFotos>(_onActualizarFotos);
    on<MisFincasInactivarFinca>(_onInactivar);
  }

  Future<void> _onLoadRequested(
      MisFincasLoadRequested event, Emitter<MisFincasState> emit) async {
    emit(const MisFincasLoading());
    try {
      final fincas = await _repo.getMisFincas();
      emit(MisFincasLoaded(fincas));
    } catch (e) {
      emit(MisFincasError(e.toString()));
    }
  }

  Future<void> _onPausar(MisFincasPausarFinca event, Emitter<MisFincasState> emit) async {
    final current = state;
    if (current is! MisFincasLoaded) return;
    
    final updated = current.fincas
        .map((f) => f.id == event.fincaId ? f.copyWith(estado: EstadoFinca.pausada) : f)
        .toList();
    emit(MisFincasLoaded(updated));
    try {
      await _repo.cambiarEstado(event.fincaId, 'pausada');
    } catch (_) {
      
      emit(MisFincasLoaded(current.fincas));
    }
  }

  Future<void> _onActivar(MisFincasActivarFinca event, Emitter<MisFincasState> emit) async {
    final current = state;
    if (current is! MisFincasLoaded) return;
    final updated = current.fincas
        .map((f) => f.id == event.fincaId ? f.copyWith(estado: EstadoFinca.activa) : f)
        .toList();
    emit(MisFincasLoaded(updated));
    try {
      await _repo.cambiarEstado(event.fincaId, 'activa');
    } catch (_) {
      emit(MisFincasLoaded(current.fincas));
    }
  }

  Future<void> _onEliminar(
      MisFincasEliminarFinca event, Emitter<MisFincasState> emit) async {
    final current = state;
    if (current is! MisFincasLoaded) return;
    final updated = current.fincas.where((f) => f.id != event.fincaId).toList();
    emit(MisFincasLoaded(updated));
    try {
      await _repo.eliminarFinca(event.fincaId);
    } catch (_) {
      emit(MisFincasLoaded(current.fincas));
    }
  }

  void _onAgregar(MisFincasAgregarFinca event, Emitter<MisFincasState> emit) {
    final current = state;
    if (current is! MisFincasLoaded) return;
    emit(MisFincasLoaded([...current.fincas, event.finca]));
  }

  Future<void> _onActualizarFotos(
      MisFincasActualizarFotos event, Emitter<MisFincasState> emit) async {
    try {
      final updated = await _repo.agregarFotosFinca(event.fincaId, event.nuevasFotos);
      final current = state;
      if (current is MisFincasLoaded) {
        final list = current.fincas
            .map((f) => f.id == event.fincaId ? updated : f)
            .toList();
        emit(MisFincasLoaded(list));
      }
    } catch (_) {
      
    }
  }

  Future<void> _onInactivar(
      MisFincasInactivarFinca event, Emitter<MisFincasState> emit) async {
    final current = state;
    if (current is! MisFincasLoaded) return;
    final updated = current.fincas
        .map((f) => f.id == event.fincaId ? f.copyWith(estado: EstadoFinca.inactiva) : f)
        .toList();
    emit(MisFincasLoaded(updated));
    try {
      await _repo.cambiarEstado(event.fincaId, 'inactiva');
    } catch (_) {
      emit(MisFincasLoaded(current.fincas));
    }
  }
}
