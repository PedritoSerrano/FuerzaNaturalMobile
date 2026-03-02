enum EstadoReserva {
  pendiente,
  confirmada,
  cancelada,
  completada,
  enCurso,
}

class ReservaModel {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String fincaId;
  final String fincaNombre;
  final String fincaProvincia;
  final String fincaPais;
  final String? fincaImageUrl;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int numeroDias;
  final int numeroPersonas;
  final double precioTotal;
  final double? descuento;
  final EstadoReserva estado;
  final String? notas;
  final DateTime fechaReserva;
  final DateTime? fechaConfirmacion;
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;

  const ReservaModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.fincaId,
    required this.fincaNombre,
    this.fincaProvincia = '',
    this.fincaPais = '',
    this.fincaImageUrl,
    required this.fechaInicio,
    required this.fechaFin,
    required this.numeroDias,
    required this.numeroPersonas,
    required this.precioTotal,
    this.descuento,
    this.estado = EstadoReserva.pendiente,
    this.notas,
    required this.fechaReserva,
    this.fechaConfirmacion,
    this.fechaCancelacion,
    this.motivoCancelacion,
  });

  String get ubicacion => '$fincaProvincia, $fincaPais';

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    return ReservaModel(
      id: json['id'] as String,
      clienteId: json['clienteId'] as String,
      clienteNombre: json['clienteNombre'] as String,
      fincaId: json['fincaId'] as String,
      fincaNombre: json['fincaNombre'] as String,
      fincaProvincia: json['fincaProvincia'] as String? ?? '',
      fincaPais: json['fincaPais'] as String? ?? '',
      fincaImageUrl: json['fincaImageUrl'] as String?,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      numeroDias: json['numeroDias'] as int,
      numeroPersonas: json['numeroPersonas'] as int,
      precioTotal: (json['precioTotal'] as num).toDouble(),
      descuento: json['descuento'] != null
          ? (json['descuento'] as num).toDouble()
          : null,
      estado: EstadoReserva.values.firstWhere(
        (e) => e.toString() == 'EstadoReserva.${json['estado']}',
        orElse: () => EstadoReserva.pendiente,
      ),
      notas: json['notas'] as String?,
      fechaReserva: DateTime.parse(json['fechaReserva'] as String),
      fechaConfirmacion: json['fechaConfirmacion'] != null
          ? DateTime.parse(json['fechaConfirmacion'] as String)
          : null,
      fechaCancelacion: json['fechaCancelacion'] != null
          ? DateTime.parse(json['fechaCancelacion'] as String)
          : null,
      motivoCancelacion: json['motivoCancelacion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'fincaId': fincaId,
      'fincaNombre': fincaNombre,
      'fincaProvincia': fincaProvincia,
      'fincaPais': fincaPais,
      'fincaImageUrl': fincaImageUrl,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'numeroDias': numeroDias,
      'numeroPersonas': numeroPersonas,
      'precioTotal': precioTotal,
      'descuento': descuento,
      'estado': estado.toString().split('.').last,
      'notas': notas,
      'fechaReserva': fechaReserva.toIso8601String(),
      'fechaConfirmacion': fechaConfirmacion?.toIso8601String(),
      'fechaCancelacion': fechaCancelacion?.toIso8601String(),
      'motivoCancelacion': motivoCancelacion,
    };
  }

  ReservaModel copyWith({
    String? id,
    String? clienteId,
    String? clienteNombre,
    String? fincaId,
    String? fincaNombre,
    String? fincaProvincia,
    String? fincaPais,
    String? fincaImageUrl,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? numeroDias,
    int? numeroPersonas,
    double? precioTotal,
    double? descuento,
    EstadoReserva? estado,
    String? notas,
    DateTime? fechaReserva,
    DateTime? fechaConfirmacion,
    DateTime? fechaCancelacion,
    String? motivoCancelacion,
  }) {
    return ReservaModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNombre: clienteNombre ?? this.clienteNombre,
      fincaId: fincaId ?? this.fincaId,
      fincaNombre: fincaNombre ?? this.fincaNombre,
      fincaProvincia: fincaProvincia ?? this.fincaProvincia,
      fincaPais: fincaPais ?? this.fincaPais,
      fincaImageUrl: fincaImageUrl ?? this.fincaImageUrl,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      numeroDias: numeroDias ?? this.numeroDias,
      numeroPersonas: numeroPersonas ?? this.numeroPersonas,
      precioTotal: precioTotal ?? this.precioTotal,
      descuento: descuento ?? this.descuento,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
      fechaReserva: fechaReserva ?? this.fechaReserva,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      fechaCancelacion: fechaCancelacion ?? this.fechaCancelacion,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
    );
  }
}
