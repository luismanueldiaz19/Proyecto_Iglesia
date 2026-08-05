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
      //   {
      // "username": "ludeveloper",
      // "password": "199512"
      // }

      print('${ApiConfig.baseUrl}/login');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        final user = data['user'];
        final name = user['name'] ?? username;
        final userRoles = user['roles'] as List<dynamic>;
        String role = 'Usuario';
        if (userRoles.isNotEmpty) {
          final firstRole = userRoles.first;
          if (firstRole is String) {
            role = firstRole;
          } else if (firstRole is Map && firstRole['name'] != null) {
            role = firstRole['name'].toString();
          }
        }

        // Guardamos la sesión (24 horas) con el token real y los datos del usuario
        await _localStorage.saveSession(username, name, role, token);

        return UserEntity(
          id: user['id'],
          name: name,
          username: username,
          role: role,
        );
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
      throw Exception('Fallo de conexión al servidor: $e');
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
      final name = _localStorage.getName() ?? username ?? '';
      final role = _localStorage.getRole() ?? 'Usuario';

      if (username != null) {
        return UserEntity(name: name, username: username, role: role);
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
