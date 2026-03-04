import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_fuerza_natural_login/core/config/api_config.dart';
import 'package:flutter_fuerza_natural_login/core/models/user_model.dart';
import 'package:flutter_fuerza_natural_login/core/services/api_service.dart';

class AuthRepository {
  final _api = ApiService();

  /// POST /api/login → guarda el token y devuelve el usuario
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _api.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );
      debugPrint('[AuthRepo] login status: ${response.statusCode}');
      debugPrint('[AuthRepo] login response: ${response.data}');
      final data = response.data as Map<String, dynamic>;
      // Sanctum puede devolver 'token' o 'access_token'
      final token = (data['access_token'] ?? data['token']) as String?;
      if (token == null) throw 'El servidor no devolvió un token válido';
      await _api.saveToken(token);
      // El usuario puede venir en 'user' o directamente en la raíz
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

  /// POST /api/logout → elimina el token localmente y en el servidor
  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout);
    } catch (_) {
      // aunque falle el servidor, limpiamos el token local
    } finally {
      await _api.deleteToken();
    }
  }

  /// GET /api/user → datos del usuario autenticado
  Future<UserModel> getMe() async {
    try {
      final response = await _api.get(ApiConfig.me);
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _parseError(e);
    }
  }

  /// PATCH /api/mi-perfil → actualiza nombre, apellidos, telefono, ubicacion
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

  /// POST /api/mis-valoraciones → crea una reseña para una reserva pasada
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
