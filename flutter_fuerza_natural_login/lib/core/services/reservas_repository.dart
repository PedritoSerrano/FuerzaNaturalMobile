import 'package:dio/dio.dart';
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';
import 'package:flutter_fuerza_natural_login/core/models/reserva_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';

class ReservasRepository {
  final _api = ApiService();

  /// GET /api/mis-reservas
  Future<List<ReservaModel>> getMisReservas() async {
    try {
      final response = await _api.get(ApiConfig.misReservas);
      final data = response.data;
      final List list = data is Map ? (data['data'] ?? data['reservas'] ?? []) : data;
      return list.map((e) => ReservaModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// GET /api/mis-reservas/{id}
  Future<ReservaModel> getReserva(String id) async {
    try {
      final response = await _api.get(ApiConfig.reservaDetalle(id));
      final data = response.data;
      return ReservaModel.fromJson(data is Map && data.containsKey('reserva')
          ? data['reserva'] as Map<String, dynamic>
          : data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// POST /api/reservas  { finca_id, fecha_inicio, fecha_fin, numero_personas }
  Future<ReservaModel> crearReserva({
    required String fincaId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required int numeroPersonas,
    String? notas,
  }) async {
    try {
      final response = await _api.post(ApiConfig.crearReserva, data: {
        'finca_id': fincaId,
        'fecha_inicio': fechaInicio.toIso8601String().split('T').first,
        'fecha_fin': fechaFin.toIso8601String().split('T').first,
        'numero_personas': numeroPersonas,
        if (notas != null) 'notas': notas,
      });
      final data = response.data;
      return ReservaModel.fromJson(data is Map && data.containsKey('reserva')
          ? data['reserva'] as Map<String, dynamic>
          : data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  String _parseError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) return data['message'] as String;
      if (e.response!.statusCode == 422) {
        final errors = (data as Map?)?['errors'] as Map?;
        return errors?.values.first?.first ?? 'Error de validación';
      }
    }
    return 'Error de conexión con el servidor.';
  }
}
