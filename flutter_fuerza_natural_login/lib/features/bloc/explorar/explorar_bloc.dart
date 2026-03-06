import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/fincas_repository.dart';

part 'explorar_event.dart';
part 'explorar_state.dart';

class ExplorarBloc extends Bloc<ExplorarEvent, ExplorarState> {
  final FincasRepository _repo;
  final String? currentUserId;

  ExplorarBloc({FincasRepository? repo, this.currentUserId})
      : _repo = repo ?? FincasRepository(),
        super(const ExplorarInitial()) {
    on<ExplorarLoadRequested>(_onLoadRequested);
    on<ExplorarSearchChanged>(_onSearchChanged);
    on<ExplorarSearchCleared>(_onSearchCleared);
    on<ExplorarFiltrosChanged>(_onFiltrosChanged);
  }

  Future<void> _onLoadRequested(
    ExplorarLoadRequested event,
    Emitter<ExplorarState> emit,
  ) async {
    
    final previous = state is ExplorarLoaded ? state as ExplorarLoaded : null;
    emit(const ExplorarLoading());
    try {
      final raw = await _repo.getFincas();
      final todas = raw
          .where((f) => f.estado == EstadoFinca.activa)
          .where((f) => currentUserId == null || f.propietarioId != currentUserId)
          .toList();
      final provincia = previous?.filtroProvincias;
      final maxPrecio = previous?.filtroMaxPrecio;
      final minSuperficie = previous?.filtroMinSuperficie;
      final query = previous?.searchQuery ?? '';
      final resultados = _apply(
        todas,
        query: query,
        provincia: provincia,
        maxPrecio: maxPrecio,
        minSuperficie: minSuperficie,
      );
      emit(ExplorarLoaded(
        todas: todas,
        resultadosBusqueda: resultados,
        searchQuery: query,
        filtroProvincias: provincia,
        filtroMaxPrecio: maxPrecio,
        filtroMinSuperficie: minSuperficie,
      ));
    } catch (e) {
      emit(ExplorarError(e.toString()));
    }
  }

  
  List<FincaModel> _apply(
    List<FincaModel> base, {
    required String query,
    required String? provincia,
    required double? maxPrecio,
    required double? minSuperficie,
  }) {
    var result = base;
    if (provincia != null && provincia.isNotEmpty) {
      result = result
          .where((f) => f.provincia.toLowerCase().contains(provincia.toLowerCase()))
          .toList();
    }
    if (maxPrecio != null) {
      result = result.where((f) => f.precioDia <= maxPrecio).toList();
    }
    if (minSuperficie != null) {
      result = result.where((f) => f.superficie >= minSuperficie).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((f) =>
              f.nombre.toLowerCase().contains(q) ||
              f.provincia.toLowerCase().contains(q) ||
              f.pais.toLowerCase().contains(q) ||
              f.especies.any((e) => e.toLowerCase().contains(q)))
          .toList();
    }
    return result;
  }

  void _onSearchChanged(
    ExplorarSearchChanged event,
    Emitter<ExplorarState> emit,
  ) {
    final current = state;
    if (current is! ExplorarLoaded) return;
    final resultados = _apply(
      current.todas,
      query: event.query,
      provincia: current.filtroProvincias,
      maxPrecio: current.filtroMaxPrecio,
      minSuperficie: current.filtroMinSuperficie,
    );
    emit(ExplorarLoaded(
      todas: current.todas,
      resultadosBusqueda: resultados,
      searchQuery: event.query,
      filtroProvincias: current.filtroProvincias,
      filtroMaxPrecio: current.filtroMaxPrecio,
      filtroMinSuperficie: current.filtroMinSuperficie,
    ));
  }

  void _onSearchCleared(
    ExplorarSearchCleared event,
    Emitter<ExplorarState> emit,
  ) {
    final current = state;
    if (current is ExplorarLoaded) {
      final resultados = _apply(
        current.todas,
        query: '',
        provincia: current.filtroProvincias,
        maxPrecio: current.filtroMaxPrecio,
        minSuperficie: current.filtroMinSuperficie,
      );
      emit(ExplorarLoaded(
        todas: current.todas,
        resultadosBusqueda: resultados,
        searchQuery: '',
        filtroProvincias: current.filtroProvincias,
        filtroMaxPrecio: current.filtroMaxPrecio,
        filtroMinSuperficie: current.filtroMinSuperficie,
      ));
    }
  }

  void _onFiltrosChanged(
    ExplorarFiltrosChanged event,
    Emitter<ExplorarState> emit,
  ) {
    final current = state;
    if (current is! ExplorarLoaded) return;
    final resultados = _apply(
      current.todas,
      query: current.searchQuery,
      provincia: event.provincia,
      maxPrecio: event.maxPrecio,
      minSuperficie: event.minSuperficie,
    );
    emit(ExplorarLoaded(
      todas: current.todas,
      resultadosBusqueda: resultados,
      searchQuery: current.searchQuery,
      filtroProvincias: event.provincia,
      filtroMaxPrecio: event.maxPrecio,
      filtroMinSuperficie: event.minSuperficie,
    ));
  }
}
