part of 'mis_fincas_bloc.dart';

abstract class MisFincasEvent {
  const MisFincasEvent();
}

class MisFincasLoadRequested extends MisFincasEvent {
  const MisFincasLoadRequested();
}

class MisFincasPausarFinca extends MisFincasEvent {
  final String fincaId;
  const MisFincasPausarFinca(this.fincaId);
}

class MisFincasActivarFinca extends MisFincasEvent {
  final String fincaId;
  const MisFincasActivarFinca(this.fincaId);
}

class MisFincasEliminarFinca extends MisFincasEvent {
  final String fincaId;
  const MisFincasEliminarFinca(this.fincaId);
}

class MisFincasAgregarFinca extends MisFincasEvent {
  final FincaModel finca;
  const MisFincasAgregarFinca(this.finca);
}

class MisFincasActualizarFotos extends MisFincasEvent {
  final String fincaId;
  final List<String> nuevasFotos;
  const MisFincasActualizarFotos(this.fincaId, this.nuevasFotos);
}

class MisFincasInactivarFinca extends MisFincasEvent {
  final String fincaId;
  const MisFincasInactivarFinca(this.fincaId);
}
