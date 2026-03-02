import 'package:dio/dio.dart';
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';

class FincasRepository {
  final _api = ApiService();

  /// GET /api/fincas?search=&provincia=
  Future<List<FincaModel>> getFincas({String? search, String? provincia}) async {
    try {
      final Map<String, dynamic> params = {};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (provincia != null && provincia.isNotEmpty) params['provincia'] = provincia;

      final response = await _api.get(ApiConfig.fincas, queryParameters: params.isEmpty ? null : params);
      final data = response.data;
      final List list = data is Map ? (data['data'] ?? data['fincas'] ?? []) : data;
      return list.map((e) => FincaModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// GET /api/fincas?destacada=1
  Future<List<FincaModel>> getFincasDestacadas() async {
    try {
      final response = await _api.get(ApiConfig.fincas, queryParameters: {'destacada': 1});
      final data = response.data;
      final List list = data is Map ? (data['data'] ?? data['fincas'] ?? []) : data;
      return list.map((e) => FincaModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// GET /api/fincas/{id}
  Future<FincaModel> getFinca(String id) async {
    try {
      final response = await _api.get(ApiConfig.fincaDetalle(id));
      final data = response.data;
      return FincaModel.fromJson(data is Map && data.containsKey('finca')
          ? data['finca'] as Map<String, dynamic>
          : data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  // ── Mis fincas (propietario) ───────────────────────────────────────────────

  /// GET /api/mis-fincas
  Future<List<FincaModel>> getMisFincas() async {
    try {
      final response = await _api.get(ApiConfig.misFincas);
      final data = response.data;
      final List list = data is Map ? (data['data'] ?? data['fincas'] ?? []) : data;
      return list.map((e) => FincaModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// POST /api/mis-fincas
  Future<FincaModel> crearFinca(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post(ApiConfig.misFincas, data: payload);
      final data = response.data;
      return FincaModel.fromJson(data is Map && data.containsKey('finca')
          ? data['finca'] as Map<String, dynamic>
          : data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// PATCH /api/mis-fincas/{id}/estado
  Future<void> cambiarEstado(String id, String estado) async {
    try {
      await _api.patch(ApiConfig.miFincaEstado(id), data: {'estado': estado});
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// DELETE /api/mis-fincas/{id}
  Future<void> eliminarFinca(String id) async {
    try {
      await _api.delete(ApiConfig.miFincaDetalle(id));
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  String _parseError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) return data['message'] as String;
    }
    return 'Error de conexión con el servidor.';
  }
}
