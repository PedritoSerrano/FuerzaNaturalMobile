part of 'explorar_bloc.dart';

abstract class ExplorarEvent {
  const ExplorarEvent();
}

class ExplorarLoadRequested extends ExplorarEvent {
  const ExplorarLoadRequested();
}

class ExplorarSearchChanged extends ExplorarEvent {
  final String query;
  const ExplorarSearchChanged(this.query);
}

class ExplorarSearchCleared extends ExplorarEvent {
  const ExplorarSearchCleared();
}

class ExplorarFiltrosChanged extends ExplorarEvent {
  final String? provincia;
  final double? maxPrecio;
  final double? minSuperficie;
  const ExplorarFiltrosChanged({
    this.provincia,
    this.maxPrecio,
    this.minSuperficie,
  });
}
