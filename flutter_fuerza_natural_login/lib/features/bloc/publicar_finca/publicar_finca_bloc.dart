import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/fincas_repository.dart';

part 'publicar_finca_event.dart';
part 'publicar_finca_state.dart';

class PublicarFincaBloc extends Bloc<PublicarFincaEvent, PublicarFincaState> {
  final FincasRepository _repo;

  PublicarFincaBloc({FincasRepository? repo})
      : _repo = repo ?? FincasRepository(),
        super(const PublicarFincaState()) {
    _registerHandlers();
  }

  /// Constructor for editing an existing finca — pre-populates state.
  PublicarFincaBloc.editar(FincaModel finca, {FincasRepository? repo})
      : _repo = repo ?? FincasRepository(),
        super(PublicarFincaState(
          fincaId: finca.id,
          nombre: finca.nombre,
          provincia: finca.provincia,
          localidad: finca.localidad ?? '',
          descripcion: finca.descripcion,
          superficie: finca.superficie,
          precioDia: finca.precioDia,
          capacidad: 0,
          especies: List.from(finca.especies),
          servicios: List.from(finca.servicios),
          normas: finca.normas.join('\n'),
        )) {
    _registerHandlers();
  }

  void _registerHandlers() {
    on<PublicarFincaIniciar>(_onIniciar);
    on<PublicarFincaSiguientePaso>(_onSiguientePaso);
    on<PublicarFincaAnteriorPaso>(_onAnteriorPaso);
    on<PublicarFincaActualizarBasico>(_onActualizarBasico);
    on<PublicarFincaActualizarDetalles>(_onActualizarDetalles);
    on<PublicarFincaActualizarEspecies>(_onActualizarEspecies);
    on<PublicarFincaActualizarServicios>(_onActualizarServicios);
    on<PublicarFincaActualizarNormas>(_onActualizarNormas);
    on<PublicarFincaActualizarFotos>(_onActualizarFotos);
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

  void _onActualizarFotos(
      PublicarFincaActualizarFotos e, Emitter<PublicarFincaState> emit) {
    emit(state.copyWith(fotos: e.fotos));
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
      // Build ubicacion string from province + locality
      final ubicacion = [state.localidad, state.provincia]
          .where((s) => s.isNotEmpty)
          .join(', ');

      // Build multipart form data so photos can be uploaded as files
      final formData = FormData.fromMap({
        'nombre': state.nombre,
        'ubicacion': ubicacion,
        'provincia': state.provincia,
        'localidad': state.localidad,
        'descripcion': state.descripcion,
        // Map Flutter field names → Laravel DB column names
        'extension': state.superficie,
        'superficie': state.superficie, // fallback
        'precio_base': state.precioDia,
        'precio_dia': state.precioDia, // fallback
        'capacidad': state.capacidad,
        'especies': state.especies.join(','),
        'servicios': state.servicios.join(','),
        'normas': state.normas,
        'estado': 'activa',
      });

      // Attach photo files (if any)
      for (int i = 0; i < state.fotos.length; i++) {
        final file = File(state.fotos[i]);
        if (await file.exists()) {
          formData.files.add(MapEntry(
            'imagenes[]',
            await MultipartFile.fromFile(
              file.path,
              filename: 'foto_$i.jpg',
            ),
          ));
        }
      }

      if (state.fincaId != null) {
        await _repo.actualizarFincaFormData(state.fincaId!, formData);
      } else {
        await _repo.crearFincaFormData(formData);
      }
      emit(state.copyWith(publicando: false, publicada: true));
    } catch (err) {
      emit(state.copyWith(publicando: false, error: err.toString()));
    }
  }

  void _onReset(PublicarFincaReset e, Emitter<PublicarFincaState> emit) {
    emit(const PublicarFincaState());
  }
}
