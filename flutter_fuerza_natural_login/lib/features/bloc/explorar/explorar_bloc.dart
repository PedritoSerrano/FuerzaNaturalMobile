import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/fincas_repository.dart';

part 'explorar_event.dart';
part 'explorar_state.dart';

class ExplorarBloc extends Bloc<ExplorarEvent, ExplorarState> {
  final FincasRepository _repo;

  ExplorarBloc({FincasRepository? repo})
      : _repo = repo ?? FincasRepository(),
        super(const ExplorarInitial()) {
    on<ExplorarLoadRequested>(_onLoadRequested);
    on<ExplorarSearchChanged>(_onSearchChanged);
    on<ExplorarSearchCleared>(_onSearchCleared);
  }

  Future<void> _onLoadRequested(
    ExplorarLoadRequested event,
    Emitter<ExplorarState> emit,
  ) async {
    emit(const ExplorarLoading());
    try {
      final destacadas = await _repo.getFincasDestacadas();
      final todas = await _repo.getFincas();
      emit(ExplorarLoaded(destacadas: destacadas, todas: todas));
    } catch (e) {
      emit(ExplorarError(e.toString()));
    }
  }

  void _onSearchChanged(
    ExplorarSearchChanged event,
    Emitter<ExplorarState> emit,
  ) {
    final current = state;
    if (current is! ExplorarLoaded) return;

    final q = event.query.toLowerCase().trim();
    if (q.isEmpty) {
      emit(ExplorarLoaded(
        destacadas: current.destacadas,
        todas: current.todas,
        searchQuery: '',
      ));
      return;
    }

    final resultados = current.todas.where((f) {
      return f.nombre.toLowerCase().contains(q) ||
          f.provincia.toLowerCase().contains(q) ||
          f.pais.toLowerCase().contains(q) ||
          f.especies.any((e) => e.toLowerCase().contains(q));
    }).toList();

    emit(ExplorarLoaded(
      destacadas: current.destacadas,
      todas: current.todas,
      resultadosBusqueda: resultados,
      searchQuery: event.query,
    ));
  }

  void _onSearchCleared(
    ExplorarSearchCleared event,
    Emitter<ExplorarState> emit,
  ) {
    final current = state;
    if (current is ExplorarLoaded) {
      emit(ExplorarLoaded(
        destacadas: current.destacadas,
        todas: current.todas,
        searchQuery: '',
      ));
    }
  }
}
