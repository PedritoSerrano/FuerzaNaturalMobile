// ignore_for_file: depend_on_referenced_packages
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';

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

  // ── Parsing helpers ────────────────────────────────────────────────────────
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

  /// Handles JSON arrays, comma-separated strings, newline-separated strings, or null.
  static List<String> _list(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String && v.isNotEmpty) {
      // Split by newline or comma (covers both normas typed in a textarea and CSV lists)
      return v.split(RegExp(r'[,\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  static EstadoFinca _parseEstado(dynamic v) {
    final s = v?.toString().toLowerCase() ?? '';
    if (s == 'activa' || s == 'activo' || s == 'active') return EstadoFinca.activa;
    if (s == 'pausada' || s == 'paused') return EstadoFinca.pausada;
    if (s == 'inactiva' || s == 'inactivo' || s == 'inactive') return EstadoFinca.inactiva;
    return EstadoFinca.activa;
  }

  /// Extracts provincia and pais from a combined 'ubicacion' string like "Sevilla, España"
  static _Ubicacion _parseUbicacion(dynamic ubicacion, dynamic provincia, dynamic pais) {
    final uStr = ubicacion?.toString() ?? '';
    final provStr = (provincia ?? '').toString();
    final paisStr = (pais ?? '').toString();
    if (provStr.isNotEmpty || paisStr.isNotEmpty) return _Ubicacion(provStr, paisStr);
    if (uStr.isEmpty) return _Ubicacion('', '');
    final parts = uStr.split(',').map((e) => e.trim()).toList();
    return _Ubicacion(parts.isNotEmpty ? parts[0] : uStr, parts.length > 1 ? parts[1] : 'España');
  }

  /// Builds the full list of image URLs from the backend 'imagenes' array.
  static List<String> _parseImagenes(dynamic imagenes) {
    final base = ApiConfig.baseUrl.replaceAll('/api', '');
    if (imagenes is! List) return [];
    return imagenes
        .map((e) {
          final s = e.toString();
          return s.startsWith('/') ? base + s : s;
        })
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Gets first image string from 'imagenes' array or any image field.
  /// Prepends the backend host URL if the path is relative (starts with '/').
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
    return raw;
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
      // Backend uses 'extension'; fallback to 'superficie'
      superficie: _d(json['extension'] ?? json['superficie']),
      // Backend uses 'precio_base'; fallback to 'precio_dia'
      precioDia: _d(json['precio_base'] ?? json['precio_dia'] ?? json['precioDia']),
      valoracion: _d(json['valoracion_avg'] ?? json['valoracion']),
      numeroResenas: _i(json['valoracion_count'] ?? json['numeroResenas'] ?? json['numero_resenas']),
      especies: _list(json['especies']),
      servicios: _list(json['servicios']),
      normas: _list(json['normas']),
      // Backend uses 'imagenes' (array); fallback to imageUrl fields
      imagenes: _parseImagenes(json['imagenes']),
      imageUrl: _firstImage(json['imagenes'], json['imageUrl'], json['image_url']),
      destacada: _b(json['destacada']),
      estado: _parseEstado(json['estado']),
      // Backend uses 'id_propietario'
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

/// Internal helper for parsing combined ubicacion strings.
class _Ubicacion {
  final String provincia;
  final String pais;
  const _Ubicacion(this.provincia, this.pais);
}
