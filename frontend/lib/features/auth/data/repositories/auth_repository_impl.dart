import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/network/api_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorage _localStorage;

  AuthRepositoryImpl(this._localStorage);

  @override
  Future<UserEntity?> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      throw Exception('Usuario y contraseña son requeridos');
    }

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final userRoles = data['user']['roles'] as List<dynamic>;
        final role = userRoles.isNotEmpty ? userRoles.first : 'Usuario';

        // Guardamos la sesión (24 horas) con el token real
        await _localStorage.saveSession(username, token);

        return UserEntity(username: username, role: role.toString());
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ??
              'Las credenciales proporcionadas son incorrectas.',
        );
      }
    } catch (e) {
      if (e.toString().contains('credenciales') ||
          e.toString().contains('requeridos')) {
        rethrow; // Es nuestro error de validación
      }
      throw Exception('Fallo de conexión al servidor. Comprueba tu red local.');
    }
  }

  @override
  Future<void> logout() async {
    final token = _localStorage.getToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse('${ApiConfig.baseUrl}/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (e) {
        // Ignoramos el error de red en el logout para limpiar la sesión local igualmente
      }
    }
    await _localStorage.clearSession();
  }

  @override
  Future<UserEntity?> checkSession() async {
    if (_localStorage.isSessionValid()) {
      final username = _localStorage.getUsername();
      if (username != null) {
        return UserEntity(
          username: username,
          role: username == 'admin' ? 'Administrador' : 'Cajera',
        );
      }
    }

    // Si no es válida o no hay token, limpia y retorna null
    await _localStorage.clearSession();
    return null;
  }

  @override
  String? getToken() {
    return _localStorage.getToken();
  }
}
