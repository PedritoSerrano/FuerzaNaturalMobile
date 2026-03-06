import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';
import 'package:flutter_fuerza_natural_login/core/models/finca_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';

class FincasRepository {
  final _api = ApiService();

  
  static List _extractList(dynamic data, [List<String> keys = const ['data', 'fincas']]) {
    if (data is List) return data;
    if (data is Map) {
      for (final k in keys) {
        if (data[k] is List) return data[k] as List;
      }
    }
    return [];
  }

  
  Future<List<FincaModel>> getFincas({String? search, String? provincia}) async {
    try {
      final Map<String, dynamic> params = {};
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (provincia != null && provincia.isNotEmpty) params['provincia'] = provincia;

      final response = await _api.get(ApiConfig.fincas, queryParameters: params.isEmpty ? null : params);
      final list = _extractList(response.data);
      return list.map((e) => FincaModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      debugPrint('[FincasRepo] getFincas error: $e');
      throw e.toString();
    }
  }

  
  Future<List<FincaModel>> getFincasDestacadas() async {
    try {
      final response = await _api.get(ApiConfig.fincas, queryParameters: {'destacada': 1});
      final list = _extractList(response.data);
      
      final fincas = list.map((e) => FincaModel.fromJson(e as Map<String, dynamic>)).toList();
      return fincas.where((f) => f.destacada).toList();
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      debugPrint('[FincasRepo] getFincasDestacadas error: $e');
      throw e.toString();
    }
  }

  
  Future<FincaModel> getFinca(String id) async {
    try {
      final response = await _api.get(ApiConfig.fincaDetalle(id));
      final data = response.data;
      final map = (data is Map && data['finca'] is Map)
          ? data['finca'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return FincaModel.fromJson(map);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      debugPrint('[FincasRepo] getFinca error: $e');
      throw e.toString();
    }
  }

  

  
  Future<List<FincaModel>> getMisFincas() async {
    try {
      final response = await _api.get(ApiConfig.misFincas);
      final list = _extractList(response.data);
      return list.map((e) => FincaModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      debugPrint('[FincasRepo] getMisFincas error: $e');
      throw e.toString();
    }
  }

  
  Future<FincaModel> crearFincaFormData(FormData formData) async {
    try {
      final response = await _api.postFormData(ApiConfig.misFincas, data: formData);
      final data = response.data;
      final map = (data is Map && data['finca'] is Map)
          ? data['finca'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return FincaModel.fromJson(map);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  
  Future<FincaModel> crearFinca(Map<String, dynamic> payload) async {
    try {
      final response = await _api.post(ApiConfig.misFincas, data: payload);
      final data = response.data;
      final map = (data is Map && data['finca'] is Map)
          ? data['finca'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return FincaModel.fromJson(map);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  
  Future<FincaModel> actualizarFincaFormData(String id, FormData formData) async {
    try {
      final response = await _api.patchFormData(ApiConfig.miFincaDetalle(id), data: formData);
      final data = response.data;
      final map = (data is Map && data['finca'] is Map)
          ? data['finca'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return FincaModel.fromJson(map);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  
  Future<FincaModel> agregarFotosFinca(String id, List<String> fotoPaths) async {
    try {
      final form = FormData();
      for (final path in fotoPaths) {
        form.files.add(
          MapEntry('imagenes[]', await MultipartFile.fromFile(path)),
        );
      }
      final response = await _api.patchFormData(ApiConfig.miFincaDetalle(id), data: form);
      final data = response.data;
      final map = (data is Map && data['finca'] is Map)
          ? data['finca'] as Map<String, dynamic>
          : data as Map<String, dynamic>;
      return FincaModel.fromJson(map);
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  
  Future<void> cambiarEstado(String id, String estado) async {
    try {
      await _api.patch(ApiConfig.miFincaEstado(id), data: {'estado': estado});
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  
  Future<void> eliminarFinca(String id) async {
    try {
      await _api.delete(ApiConfig.miFincaDetalle(id));
    } on DioException catch (e) {
      throw _parseDioError(e);
    } catch (e) {
      throw e.toString();
    }
  }

  String _parseDioError(DioException e) {
    debugPrint('[FincasRepo] DioException ${e.response?.statusCode}: ${e.response?.data}');
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
      if (data is String && data.isNotEmpty) return data;
    }
    return 'Error de conexión con el servidor (${e.type.name}).';
  }
}
