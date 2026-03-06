enum EstadoReserva {
  pendiente,
  confirmada,
  cancelada,
  completada,
  enCurso,
}

enum TipoReserva { monteria, rececho, visita }

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
  final TipoReserva? tipoReserva;
  final String? notas;
  final DateTime fechaReserva;
  final DateTime? fechaConfirmacion;
  final DateTime? fechaCancelacion;
  final String? motivoCancelacion;
  final bool tieneValoracion;

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
    this.tipoReserva,
    this.notas,
    required this.fechaReserva,
    this.fechaConfirmacion,
    this.fechaCancelacion,
    this.motivoCancelacion,
    this.tieneValoracion = false,
  });

  String get ubicacion => '$fincaProvincia, $fincaPais';

  
  static double _d(dynamic v) =>
      (num.tryParse(v?.toString() ?? '') ?? 0).toDouble();

  static int _i(dynamic v) =>
      (num.tryParse(v?.toString() ?? '') ?? 0).toInt();

  static DateTime _dt(dynamic v) {
    if (v == null) return DateTime.now();
    return DateTime.tryParse(v.toString()) ?? DateTime.now();
  }

  static DateTime? _dtOpt(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static EstadoReserva _parseEstado(dynamic v) {
    final s = v?.toString().toLowerCase() ?? '';
    if (s == 'confirmada' || s == 'confirmed') return EstadoReserva.confirmada;
    if (s == 'cancelada' || s == 'cancelled' || s == 'canceled') return EstadoReserva.cancelada;
    if (s == 'completada' || s == 'completed') return EstadoReserva.completada;
    if (s == 'encurso' || s == 'en_curso' || s == 'in_progress') return EstadoReserva.enCurso;
    return EstadoReserva.pendiente;
  }

  static TipoReserva? _parseTipo(dynamic v) {
    final s = v?.toString().toLowerCase() ?? '';
    if (s == 'monteria' || s == 'montería') return TipoReserva.monteria;
    if (s == 'rececho') return TipoReserva.rececho;
    if (s == 'visita') return TipoReserva.visita;
    return null;
  }

  static String tipoLabel(TipoReserva? t) {
    switch (t) {
      case TipoReserva.monteria: return 'Montería';
      case TipoReserva.rececho:  return 'Rececho';
      case TipoReserva.visita:   return 'Visita';
      default: return 'Sin tipo';
    }
  }

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    
    final evento = json['evento'] as Map<String, dynamic>?;
    final fincaMap = evento?['finca'] as Map<String, dynamic>?;

    
    String? _fincaImage(Map<String, dynamic>? f) {
      if (f == null) return null;
      final imgs = f['imagenes'];
      if (imgs is List && imgs.isNotEmpty) return imgs[0].toString();
      if (imgs is String && imgs.isNotEmpty) return imgs;
      return f['imageUrl']?.toString() ?? f['image_url']?.toString();
    }

    
    String _provFromUbicacion(Map<String, dynamic>? f) {
      if (f == null) return '';
      final prov = f['provincia']?.toString() ?? '';
      if (prov.isNotEmpty) return prov;
      final ub = f['ubicacion']?.toString() ?? '';
      return ub.split(',').first.trim();
    }

    return ReservaModel(
      id: json['id']?.toString() ?? '0',
      
      clienteId: (json['id_usuario'] ?? json['clienteId'] ?? json['cliente_id'] ?? json['user_id'] ?? '0').toString(),
      clienteNombre: (json['clienteNombre'] ?? json['cliente_nombre'] ?? json['user_name'] ?? '').toString(),
      
      fincaId: (fincaMap?['id'] ?? evento?['id_finca'] ?? json['fincaId'] ?? json['finca_id'] ?? '0').toString(),
      fincaNombre: (fincaMap?['nombre'] ?? json['fincaNombre'] ?? json['finca_nombre'] ?? json['finca']?['nombre'] ?? '').toString(),
      fincaProvincia: _provFromUbicacion(fincaMap),
      fincaPais: (fincaMap?['pais'] ?? '').toString(),
      fincaImageUrl: _fincaImage(fincaMap) ?? json['fincaImageUrl']?.toString() ?? json['finca_image_url']?.toString(),
      
      fechaInicio: _dt(evento?['fecha_inicio'] ?? json['fechaInicio'] ?? json['fecha_inicio']),
      fechaFin: _dt(evento?['fecha_fin'] ?? json['fechaFin'] ?? json['fecha_fin']),
      numeroDias: _i(json['numeroDias'] ?? json['numero_dias']),
      numeroPersonas: _i(json['numero_personas'] ?? json['numeroPersonas'] ?? json['numero_personas']) == 0
          ? 1
          : _i(json['numero_personas'] ?? json['numeroPersonas']),
      
      precioTotal: _d(evento?['precio'] ?? json['precioTotal'] ?? json['precio_total']),
      descuento: json['descuento'] != null ? _d(json['descuento']) : null,
      estado: _parseEstado(json['estado']),
      tipoReserva: _parseTipo(json['tipo_reserva'] ?? evento?['tipo']),
      notas: (json['notas'] ?? json['metodo_pago'])?.toString(),
      fechaReserva: _dt(json['fechaReserva'] ?? json['fecha_reserva'] ?? json['created_at']),
      fechaConfirmacion: _dtOpt(json['fechaConfirmacion'] ?? json['fecha_confirmacion']),
      fechaCancelacion: _dtOpt(json['fechaCancelacion'] ?? json['fecha_cancelacion']),
      motivoCancelacion: (json['motivoCancelacion'] ?? json['motivo_cancelacion'])?.toString(),
      tieneValoracion: (_i(json['valoraciones_count'])) > 0,
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
      'tipo_reserva': tipoReserva?.toString().split('.').last,
      'notas': notas,
      'fechaReserva': fechaReserva.toIso8601String(),
      'fechaConfirmacion': fechaConfirmacion?.toIso8601String(),
      'fechaCancelacion': fechaCancelacion?.toIso8601String(),
      'motivoCancelacion': motivoCancelacion,
      'tieneValoracion': tieneValoracion,
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
    TipoReserva? tipoReserva,
    String? notas,
    DateTime? fechaReserva,
    DateTime? fechaConfirmacion,
    DateTime? fechaCancelacion,
    String? motivoCancelacion,
    bool? tieneValoracion,
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
      tipoReserva: tipoReserva ?? this.tipoReserva,
      notas: notas ?? this.notas,
      fechaReserva: fechaReserva ?? this.fechaReserva,
      fechaConfirmacion: fechaConfirmacion ?? this.fechaConfirmacion,
      fechaCancelacion: fechaCancelacion ?? this.fechaCancelacion,
      motivoCancelacion: motivoCancelacion ?? this.motivoCancelacion,
      tieneValoracion: tieneValoracion ?? this.tieneValoracion,
    );
  }
}
