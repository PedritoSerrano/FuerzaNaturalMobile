import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';
import 'package:flutter_fuerza_natural_login/core/models/user_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';

class AuthRepository {
  final _api = ApiService();

  
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _api.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );
      debugPrint('[AuthRepo] login status: ${response.statusCode}');
      debugPrint('[AuthRepo] login response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      
      final token = (data['access_token'] ?? data['token']) as String?;
      if (token == null) throw 'El servidor no devolvió un token válido';
      await _api.saveToken(token);
      
      final userJson = (data['user'] as Map<String, dynamic>?) ?? data;
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      debugPrint('[AuthRepo] DioException status: ${e.response?.statusCode}');
      debugPrint('[AuthRepo] DioException data: ${e.response?.data}');
      throw _parseError(e);
    } catch (e) {
      debugPrint('[AuthRepo] error inesperado en login: $e');
      rethrow;
    }
  }

  
  Future<UserModel> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiConfig.register,
        data: {
          'name': nombre,
          'apellidos': apellidos,
          'email': email,
          'password': password,
          'password_confirmation': password,
        },
      );
      debugPrint('[AuthRepo] register status: ${response.statusCode}');
      final data = response.data as Map<String, dynamic>;
      final token = (data['access_token'] ?? data['token']) as String?;
      if (token == null) throw 'El servidor no devolvió un token válido';
      await _api.saveToken(token);
      final userJson = (data['user'] as Map<String, dynamic>?) ?? data;
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      debugPrint('[AuthRepo] DioException register: ${e.response?.data}');
      throw _parseError(e);
    } catch (e) {
      debugPrint('[AuthRepo] error inesperado en register: $e');
      rethrow;
    }
  }

  
  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout);
    } catch (_) {
      
    } finally {
      await _api.deleteToken();
    }
  }

  
  Future<UserModel> getMe() async {
    try {
      final response = await _api.get(ApiConfig.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  
  Future<UserModel> updateMiPerfil({
    String? nombre,
    String? apellidos,
    String? telefono,
    String? ubicacion,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nombre != null) body['nombre'] = nombre;
      if (apellidos != null) body['apellidos'] = apellidos;
      if (telefono != null) body['telefono'] = telefono;
      if (ubicacion != null) body['ubicacion'] = ubicacion;
      final response = await _api.patch(ApiConfig.miPerfil, data: body);
      final data = response.data as Map<String, dynamic>;
      final userJson = (data['user'] as Map<String, dynamic>?) ?? data;
      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  
  Future<void> crearValoracion({
    required String idReserva,
    required int puntuacion,
    String? comentario,
  }) async {
    try {
      final body = <String, dynamic>{
        'id_reserva': idReserva,
        'puntuacion': puntuacion,
        if (comentario != null && comentario.isNotEmpty) 'comentario': comentario,
      };
      await _api.post(ApiConfig.misValoraciones, data: body);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  Future<bool> isLoggedIn() => _api.hasToken();

  Future<void> deleteToken() => _api.deleteToken();

  String _parseError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      if (e.response!.statusCode == 401) return 'Credenciales incorrectas';
      if (e.response!.statusCode == 422) {
        final errors = data['errors'] as Map?;
        return errors?.values.first?.first ?? 'Error de validación';
      }
    }
    return 'Error de conexión. Verifica que la API está corriendo.';
  }
}
