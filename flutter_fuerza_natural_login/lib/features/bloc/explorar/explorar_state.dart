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
  final List<FincaModel> todas;
  final List<FincaModel> resultadosBusqueda;
  final String searchQuery;
  final String? filtroProvincias;
  final double? filtroMaxPrecio;
  final double? filtroMinSuperficie;

  const ExplorarLoaded({
    required this.todas,
    this.resultadosBusqueda = const [],
    this.searchQuery = '',
    this.filtroProvincias,
    this.filtroMaxPrecio,
    this.filtroMinSuperficie,
  });

  bool get hayFiltros =>
      (filtroProvincias != null && filtroProvincias!.isNotEmpty) ||
      filtroMaxPrecio != null ||
      filtroMinSuperficie != null;

  bool get enBusqueda => searchQuery.isNotEmpty || hayFiltros;

  List<FincaModel> get mostradas =>
      enBusqueda ? resultadosBusqueda : todas;
}

class ExplorarError extends ExplorarState {
  final String mensaje;
  const ExplorarError(this.mensaje);
}
