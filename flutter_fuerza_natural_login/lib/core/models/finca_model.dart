import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';

enum EstadoFinca { activa, pausada, inactiva }

class FincaModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String provincia;
  final String pais;
  final String? localidad;
  final double superficie; 
  final double precioDia;
  final double valoracion;
  final int numeroResenas;
  final List<String> especies;
  final List<String> servicios;
  final List<String> normas;
  final String? imageUrl;
  final List<String> imagenes;
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
    this.imagenes = const [],
    this.destacada = false,
    this.estado = EstadoFinca.activa,
    required this.propietarioId,
    this.totalReservas = 0,
    this.reservasPendientes = 0,
  });

  String get ubicacion => '$provincia, $pais';

  
  static double _d(dynamic v) =>
      (num.tryParse(v?.toString() ?? '') ?? 0).toDouble();

  static int _i(dynamic v) =>
      (num.tryParse(v?.toString() ?? '') ?? 0).toInt();

  static bool _b(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  
  static List<String> _list(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String && v.isNotEmpty) {
      
      return v.split(RegExp(r'[,\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  static EstadoFinca _parseEstado(dynamic v) {
    if (v == null) return EstadoFinca.activa;
    final s = v.toString().toLowerCase().trim();
    if (s.isEmpty) return EstadoFinca.activa;
    if (s == 'activa' || s == 'activo' || s == 'active' || s == '1' || s == 'true')
      return EstadoFinca.activa;
    if (s == 'pausada' || s == 'pausado' || s == 'paused') return EstadoFinca.pausada;
    if (s == 'inactiva' || s == 'inactivo' || s == 'inactive' || s == '0' || s == 'false')
      return EstadoFinca.inactiva;
    return EstadoFinca.inactiva;
  }

  
  static _Ubicacion _parseUbicacion(dynamic ubicacion, dynamic provincia, dynamic pais) {
    final uStr = ubicacion?.toString() ?? '';
    final provStr = (provincia ?? '').toString();
    final paisStr = (pais ?? '').toString();
    if (provStr.isNotEmpty || paisStr.isNotEmpty) return _Ubicacion(provStr, paisStr);
    if (uStr.isEmpty) return _Ubicacion('', '');
    final parts = uStr.split(',').map((e) => e.trim()).toList();
    return _Ubicacion(parts.isNotEmpty ? parts[0] : uStr, parts.length > 1 ? parts[1] : 'España');
  }

  
  
  
  static String _fixImageUrl(String url) {
    if (url.isEmpty) return url;
    final base = ApiConfig.baseUrl.replaceAll('/api', ''); 
    return url
        .replaceFirst(RegExp(r'https?://localhost(:\d+)?'), base)
        .replaceFirst(RegExp(r'https?://127\.0\.0\.1(:\d+)?'), base);
  }

  
  static List<String> _parseImagenes(dynamic imagenes) {
    final base = ApiConfig.baseUrl.replaceAll('/api', '');
    if (imagenes is! List) return [];
    return imagenes
        .map((e) {
          final s = e.toString();
          if (s.isEmpty) return '';
          if (s.startsWith('/')) return base + s;
          return _fixImageUrl(s);
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  
  
  static String? _firstImage(dynamic imagenes, dynamic imageUrl, dynamic imageUrlAlt) {
    String? raw;
    if (imageUrl != null && imageUrl.toString().isNotEmpty) raw = imageUrl.toString();
    else if (imageUrlAlt != null && imageUrlAlt.toString().isNotEmpty) raw = imageUrlAlt.toString();
    else if (imagenes is List && imagenes.isNotEmpty) raw = imagenes[0].toString();
    else if (imagenes is String && imagenes.isNotEmpty) raw = imagenes;
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('/')) {
      return ApiConfig.baseUrl.replaceAll('/api', '') + raw;
    }
    return _fixImageUrl(raw);
  }

  factory FincaModel.fromJson(Map<String, dynamic> json) {
    final ub = _parseUbicacion(json['ubicacion'], json['provincia'], json['pais']);
    return FincaModel(
      id: json['id']?.toString() ?? '0',
      nombre: (json['nombre'] ?? json['name'] ?? '').toString(),
      descripcion: (json['descripcion'] ?? json['description'] ?? '').toString(),
      provincia: ub.provincia,
      pais: ub.pais,
      localidad: json['localidad']?.toString(),
      
      superficie: _d(json['extension'] ?? json['superficie']),
      
      precioDia: _d(json['precio_base'] ?? json['precio_dia'] ?? json['precioDia']),
      valoracion: _d(json['valoracion_avg'] ?? json['valoracion']),
      numeroResenas: _i(json['valoracion_count'] ?? json['numeroResenas'] ?? json['numero_resenas']),
      especies: _list(json['especies']),
      servicios: _list(json['servicios']),
      normas: _list(json['normas']),
      
      imagenes: _parseImagenes(json['imagenes']),
      imageUrl: _firstImage(json['imagenes'], json['imageUrl'], json['image_url']),
      destacada: _b(json['destacada']),
      estado: _parseEstado(json['estado'] ?? json['status']),
      propietarioId: (json['id_propietario'] ?? json['propietarioId'] ?? json['user_id'] ?? json['owner_id'] ?? '0').toString(),
      totalReservas: _i(json['total_eventos'] ?? json['totalReservas'] ?? json['total_reservas']),
      reservasPendientes: _i(json['reservasPendientes'] ?? json['reservas_pendientes']),
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
      'imagenes': imagenes,
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
    List<String>? imagenes,
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
      imagenes: imagenes ?? this.imagenes,
      destacada: destacada ?? this.destacada,
      estado: estado ?? this.estado,
      propietarioId: propietarioId,
      totalReservas: totalReservas ?? this.totalReservas,
      reservasPendientes: reservasPendientes ?? this.reservasPendientes,
    );
  }
}

class _Ubicacion {
  final String provincia;
  final String pais;
  const _Ubicacion(this.provincia, this.pais);
}
