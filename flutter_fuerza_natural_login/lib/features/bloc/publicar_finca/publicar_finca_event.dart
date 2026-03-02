part of 'publicar_finca_bloc.dart';

abstract class PublicarFincaEvent {
  const PublicarFincaEvent();
}

class PublicarFincaIniciar extends PublicarFincaEvent {
  const PublicarFincaIniciar();
}

class PublicarFincaSiguientePaso extends PublicarFincaEvent {
  const PublicarFincaSiguientePaso();
}

class PublicarFincaAnteriorPaso extends PublicarFincaEvent {
  const PublicarFincaAnteriorPaso();
}

class PublicarFincaActualizarBasico extends PublicarFincaEvent {
  final String? nombre;
  final String? provincia;
  final String? localidad;
  final String? descripcion;
  const PublicarFincaActualizarBasico({
    this.nombre,
    this.provincia,
    this.localidad,
    this.descripcion,
  });
}

class PublicarFincaActualizarDetalles extends PublicarFincaEvent {
  final double? superficie;
  final double? precioDia;
  final int? capacidad;
  const PublicarFincaActualizarDetalles({
    this.superficie,
    this.precioDia,
    this.capacidad,
  });
}

class PublicarFincaActualizarEspecies extends PublicarFincaEvent {
  final List<String> especies;
  const PublicarFincaActualizarEspecies(this.especies);
}

class PublicarFincaActualizarServicios extends PublicarFincaEvent {
  final List<String> servicios;
  const PublicarFincaActualizarServicios(this.servicios);
}

class PublicarFincaActualizarNormas extends PublicarFincaEvent {
  final String normas;
  const PublicarFincaActualizarNormas(this.normas);
}

class PublicarFincaPublicar extends PublicarFincaEvent {
  const PublicarFincaPublicar();
}

class PublicarFincaReset extends PublicarFincaEvent {
  const PublicarFincaReset();
}
