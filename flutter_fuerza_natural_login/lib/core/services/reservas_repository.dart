import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';
import 'package:flutter_fuerza_natural_login/core/models/reserva_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';

class ReservasRepository {
  final _api = ApiService();

  static List _extractList(dynamic data, [List<String> keys = const ['data', 'reservas']]) {
    if (data is List) return data;
    if (data is Map) {
      for (final k in keys) {
        if (data[k] is List) return data[k] as List;
      }
    }
    return [];
  }

  
  Future<List<ReservaModel>> getMisReservas() async {
    try {
      final response = await _api.get(ApiConfig.misReservas);
      debugPrint('[ReservasRepo] GET mis-reservas status: ${response.statusCode}');
      final list = _extractList(response.data);
      return list.map((e) => ReservaModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      debugPrint('[ReservasRepo] getMisReservas error: $e');
      throw e.toString();
    }
  }

  
  Future<ReservaModel> getReserva(String id) async {
    try {
      final response = await _api.get(ApiConfig.reservaDetalle(id));
      final data = response.data;
      final map = (data is Map && data['reserva'] is Map)
          ? data['reserva'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return ReservaModel.fromJson(map);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  
  Future<ReservaModel> crearReserva({
    required String fincaId,
    required DateTime fecha,
    required String tipoReserva,
    required int numeroPersonas,
    String? notas,
  }) async {
    try {
      final response = await _api.post(ApiConfig.crearReserva, data: {
        'finca_id': fincaId,
        'fecha': fecha.toIso8601String().split('T').first,
        'tipo_reserva': tipoReserva,
        'numero_personas': numeroPersonas,
        if (notas != null && notas.isNotEmpty) 'notas': notas,
      });
      final data = response.data;
      final map = (data is Map && data['reserva'] is Map)
          ? data['reserva'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return ReservaModel.fromJson(map);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  String _parseDioError(DioException e) {
    debugPrint('[ReservasRepo] DioException ${e.response?.statusCode}: ${e.response?.data}');
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
      if (e.response!.statusCode == 422) {
        final errors = (data as Map?)?['errors'] as Map?;
        return errors?.values.first?.first?.toString() ?? 'Error de validación';
      }
      if (data is String && data.isNotEmpty) return data;
    }
    return 'Error de conexión con el servidor (${e.type.name}).';
  }
}
