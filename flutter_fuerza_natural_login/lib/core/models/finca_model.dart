enum EstadoFinca { activa, pausada, inactiva }

class FincaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String provincia;
  final String pais;
  final String? localidad;
  final double superficie; // hectáreas
  final double precioDia;
  final double valoracion;
  final int numeroResenas;
  final List<String> especies;
  final List<String> servicios;
  final List<String> normas;
  final String? imageUrl;
  final bool destacada;
  final EstadoFinca estado;
  final String propietarioId;
  final int totalReservas;
  final int reservasPendientes;

  const FincaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.provincia,
    required this.pais,
    this.localidad,
    required this.superficie,
    required this.precioDia,
    this.valoracion = 0.0,
    this.numeroResenas = 0,
    this.especies = const [],
    this.servicios = const [],
    this.normas = const [],
    this.imageUrl,
    this.destacada = false,
    this.estado = EstadoFinca.activa,
    required this.propietarioId,
    this.totalReservas = 0,
    this.reservasPendientes = 0,
  });

  String get ubicacion => '$provincia, $pais';

  factory FincaModel.fromJson(Map<String, dynamic> json) {
    return FincaModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      provincia: json['provincia'] as String? ?? '',
      pais: json['pais'] as String? ?? '',
      localidad: json['localidad'] as String?,
      superficie: (json['superficie'] as num).toDouble(),
      precioDia: (json['precioDia'] as num).toDouble(),
      valoracion: json['valoracion'] != null
          ? (json['valoracion'] as num).toDouble()
          : 0.0,
      numeroResenas: json['numeroResenas'] as int? ?? 0,
      especies: (json['especies'] as List<dynamic>?)?.cast<String>() ?? [],
      servicios: (json['servicios'] as List<dynamic>?)?.cast<String>() ?? [],
      normas: (json['normas'] as List<dynamic>?)?.cast<String>() ?? [],
      imageUrl: json['imageUrl'] as String?,
      destacada: json['destacada'] as bool? ?? false,
      estado: EstadoFinca.values.firstWhere(
        (e) => e.toString() == 'EstadoFinca.${json['estado']}',
        orElse: () => EstadoFinca.activa,
      ),
      propietarioId: json['propietarioId'] as String,
      totalReservas: json['totalReservas'] as int? ?? 0,
      reservasPendientes: json['reservasPendientes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'provincia': provincia,
      'pais': pais,
      'localidad': localidad,
      'superficie': superficie,
      'precioDia': precioDia,
      'valoracion': valoracion,
      'numeroResenas': numeroResenas,
      'especies': especies,
      'servicios': servicios,
      'normas': normas,
      'imageUrl': imageUrl,
      'destacada': destacada,
      'estado': estado.toString().split('.').last,
      'propietarioId': propietarioId,
      'totalReservas': totalReservas,
      'reservasPendientes': reservasPendientes,
    };
  }

  FincaModel copyWith({
    String? nombre,
    String? descripcion,
    String? provincia,
    String? pais,
    String? localidad,
    double? superficie,
    double? precioDia,
    double? valoracion,
    int? numeroResenas,
    List<String>? especies,
    List<String>? servicios,
    List<String>? normas,
    String? imageUrl,
    bool? destacada,
    EstadoFinca? estado,
    int? totalReservas,
    int? reservasPendientes,
  }) {
    return FincaModel(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      provincia: provincia ?? this.provincia,
      pais: pais ?? this.pais,
      localidad: localidad ?? this.localidad,
      superficie: superficie ?? this.superficie,
      precioDia: precioDia ?? this.precioDia,
      valoracion: valoracion ?? this.valoracion,
      numeroResenas: numeroResenas ?? this.numeroResenas,
      especies: especies ?? this.especies,
      servicios: servicios ?? this.servicios,
      normas: normas ?? this.normas,
      imageUrl: imageUrl ?? this.imageUrl,
      destacada: destacada ?? this.destacada,
      estado: estado ?? this.estado,
      propietarioId: propietarioId,
      totalReservas: totalReservas ?? this.totalReservas,
      reservasPendientes: reservasPendientes ?? this.reservasPendientes,
    );
  }
}
