part of 'mis_fincas_bloc.dart';

abstract class MisFincasState {
  const MisFincasState();
}

class MisFincasInitial extends MisFincasState {
  const MisFincasInitial();
}

class MisFincasLoading extends MisFincasState {
  const MisFincasLoading();
}

class MisFincasLoaded extends MisFincasState {
  final List<FincaModel> fincas;
  const MisFincasLoaded(this.fincas);

  int get totalFincas => fincas.length;
  int get fincasActivas =>
      fincas.where((f) => f.estado == EstadoFinca.activa).length;
  int get totalReservas =>
      fincas.fold(0, (sum, f) => sum + f.totalReservas);
}

class MisFincasError extends MisFincasState {
  final String mensaje;
  const MisFincasError(this.mensaje);
}
