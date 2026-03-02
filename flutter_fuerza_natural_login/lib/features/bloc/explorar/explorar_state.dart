part of 'explorar_bloc.dart';

abstract class ExplorarState {
  const ExplorarState();
}

class ExplorarInitial extends ExplorarState {
  const ExplorarInitial();
}

class ExplorarLoading extends ExplorarState {
  const ExplorarLoading();
}

class ExplorarLoaded extends ExplorarState {
  final List<FincaModel> destacadas;
  final List<FincaModel> todas;
  final List<FincaModel> resultadosBusqueda;
  final String searchQuery;

  const ExplorarLoaded({
    required this.destacadas,
    required this.todas,
    this.resultadosBusqueda = const [],
    this.searchQuery = '',
  });

  bool get enBusqueda => searchQuery.isNotEmpty;
}

class ExplorarError extends ExplorarState {
  final String mensaje;
  const ExplorarError(this.mensaje);
}
