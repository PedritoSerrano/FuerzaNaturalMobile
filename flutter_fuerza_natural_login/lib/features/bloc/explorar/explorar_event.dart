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
