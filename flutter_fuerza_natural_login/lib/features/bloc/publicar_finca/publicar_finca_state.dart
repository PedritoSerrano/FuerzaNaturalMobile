part of 'publicar_finca_bloc.dart';

class PublicarFincaState {
  final int paso; // 0-5
  final String nombre;
  final String provincia;
  final String localidad;
  final String descripcion;
  final double superficie;
  final double precioDia;
  final int capacidad;
  final List<String> especies;
  final List<String> servicios;
  final String normas;
  final List<String> fotos; // local file paths
  final bool publicando;
  final bool publicada;
  final String? error;

  const PublicarFincaState({
    this.paso = 0,
    this.nombre = '',
    this.provincia = '',
    this.localidad = '',
    this.descripcion = '',
    this.superficie = 0,
    this.precioDia = 0,
    this.capacidad = 0,
    this.especies = const [],
    this.servicios = const [],
    this.normas = '',
    this.fotos = const [],
    this.publicando = false,
    this.publicada = false,
    this.error,
  });

  static const int totalPasos = 6;

  // Always allow advancing between steps; final validation on Publicar.
  bool get pasoValido => true;

  bool get datosCompletos =>
      nombre.trim().isNotEmpty &&
      provincia.isNotEmpty &&
      superficie > 0 &&
      precioDia > 0;

  PublicarFincaState copyWith({
    int? paso,
    String? nombre,
    String? provincia,
    String? localidad,
    String? descripcion,
    double? superficie,
    double? precioDia,
    int? capacidad,
    List<String>? especies,
    List<String>? servicios,
    String? normas,
    List<String>? fotos,
    bool? publicando,
    bool? publicada,
    String? error,
  }) {
    return PublicarFincaState(
      paso: paso ?? this.paso,
      nombre: nombre ?? this.nombre,
      provincia: provincia ?? this.provincia,
      localidad: localidad ?? this.localidad,
      descripcion: descripcion ?? this.descripcion,
      superficie: superficie ?? this.superficie,
      precioDia: precioDia ?? this.precioDia,
      capacidad: capacidad ?? this.capacidad,
      especies: especies ?? this.especies,
      servicios: servicios ?? this.servicios,
      normas: normas ?? this.normas,
      fotos: fotos ?? this.fotos,
      publicando: publicando ?? this.publicando,
      publicada: publicada ?? this.publicada,
      error: error,
    );
  }
}
