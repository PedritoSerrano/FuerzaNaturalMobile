import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/services/fincas_repository.dart';

part 'publicar_finca_event.dart';
part 'publicar_finca_state.dart';

class PublicarFincaBloc extends Bloc<PublicarFincaEvent, PublicarFincaState> {
  final FincasRepository _repo;

  PublicarFincaBloc({FincasRepository? repo})
      : _repo = repo ?? FincasRepository(),
        super(const PublicarFincaState()) {
    on<PublicarFincaIniciar>(_onIniciar);
    on<PublicarFincaSiguientePaso>(_onSiguientePaso);
    on<PublicarFincaAnteriorPaso>(_onAnteriorPaso);
    on<PublicarFincaActualizarBasico>(_onActualizarBasico);
    on<PublicarFincaActualizarDetalles>(_onActualizarDetalles);
    on<PublicarFincaActualizarEspecies>(_onActualizarEspecies);
    on<PublicarFincaActualizarServicios>(_onActualizarServicios);
    on<PublicarFincaActualizarNormas>(_onActualizarNormas);
    on<PublicarFincaPublicar>(_onPublicar);
    on<PublicarFincaReset>(_onReset);
  }

  void _onIniciar(PublicarFincaIniciar e, Emitter<PublicarFincaState> emit) =>
      emit(const PublicarFincaState());

  void _onSiguientePaso(
      PublicarFincaSiguientePaso e, Emitter<PublicarFincaState> emit) {
    if (state.paso < PublicarFincaState.totalPasos - 1) {
      emit(state.copyWith(paso: state.paso + 1));
    }
  }

  void _onAnteriorPaso(
      PublicarFincaAnteriorPaso e, Emitter<PublicarFincaState> emit) {
    if (state.paso > 0) {
      emit(state.copyWith(paso: state.paso - 1));
    }
  }

  void _onActualizarBasico(
      PublicarFincaActualizarBasico e, Emitter<PublicarFincaState> emit) {
    emit(state.copyWith(
      nombre: e.nombre,
      provincia: e.provincia,
      localidad: e.localidad,
      descripcion: e.descripcion,
    ));
  }

  void _onActualizarDetalles(
      PublicarFincaActualizarDetalles e, Emitter<PublicarFincaState> emit) {
    emit(state.copyWith(
      superficie: e.superficie,
      precioDia: e.precioDia,
      capacidad: e.capacidad,
    ));
  }

  void _onActualizarEspecies(
      PublicarFincaActualizarEspecies e, Emitter<PublicarFincaState> emit) {
    emit(state.copyWith(especies: e.especies));
  }

  void _onActualizarServicios(
      PublicarFincaActualizarServicios e, Emitter<PublicarFincaState> emit) {
    emit(state.copyWith(servicios: e.servicios));
  }

  void _onActualizarNormas(
      PublicarFincaActualizarNormas e, Emitter<PublicarFincaState> emit) {
    emit(state.copyWith(normas: e.normas));
  }

  Future<void> _onPublicar(
      PublicarFincaPublicar e, Emitter<PublicarFincaState> emit) async {
    if (!state.datosCompletos) {
      emit(state.copyWith(
          error: 'Completa al menos el nombre, provincia, superficie y precio.'));
      return;
    }
    emit(state.copyWith(publicando: true, error: null));
    try {
      await _repo.crearFinca({
        'nombre': state.nombre,
        'provincia': state.provincia,
        'localidad': state.localidad,
        'descripcion': state.descripcion,
        'superficie': state.superficie,
        'precio_dia': state.precioDia,
        'capacidad': state.capacidad,
        'especies': state.especies,
        'servicios': state.servicios,
        'normas': state.normas,
      });
      emit(state.copyWith(publicando: false, publicada: true));
    } catch (err) {
      emit(state.copyWith(publicando: false, error: err.toString()));
    }
  }

  void _onReset(PublicarFincaReset e, Emitter<PublicarFincaState> emit) {
    emit(const PublicarFincaState());
  }
}
