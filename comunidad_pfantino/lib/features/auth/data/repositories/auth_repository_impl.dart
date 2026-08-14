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

        final profilePhotoUrl = user['profile_photo_url'];

        // Guardamos la sesión (24 horas) con el token real y los datos del usuario
        await _localStorage.saveSession(
          username, 
          name, 
          role, 
          token, 
          profilePhotoUrl: profilePhotoUrl,
        );

        return UserEntity(
          id: user['id'],
          name: name,
          username: username,
          role: role,
          profilePhotoUrl: profilePhotoUrl,
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
      final profilePhotoUrl = _localStorage.getProfilePhotoUrl();

      if (username != null) {
        return UserEntity(
          name: name, 
          username: username, 
          role: role,
          profilePhotoUrl: profilePhotoUrl,
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

  @override
  Future<UserEntity> updateProfile(String name, String currentPassword) async {
    final token = _localStorage.getToken();
    if (token == null) throw Exception('No hay sesión activa');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'name': name, 'current_password': currentPassword}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      final username = user['username'];
      final newName = user['name'];
      
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

      final profilePhotoUrl = user['profile_photo_url'];

      await _localStorage.saveSession(
        username, 
        newName, 
        role, 
        token,
        profilePhotoUrl: profilePhotoUrl,
      );

      return UserEntity(
        id: user['id'] ?? 0,
        name: newName,
        username: username,
        role: role,
        profilePhotoUrl: profilePhotoUrl,
      );
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al actualizar perfil');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    final token = _localStorage.getToken();
    if (token == null) throw Exception('No hay sesión activa');

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/profile/password'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al cambiar la contraseña');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSessions() async {
    final token = _localStorage.getToken();
    if (token == null) throw Exception('No hay sesión activa');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile/sessions'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener los accesos');
    }
  }

  @override
  Future<List<String>> getPermissions() async {
    final token = _localStorage.getToken();
    if (token == null) throw Exception('No hay sesión activa');

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/profile/permissions'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(response.body));
    } else {
      throw Exception('Error al obtener los permisos');
    }
  }

  @override
  Future<UserEntity> uploadProfilePhoto(List<int> fileBytes, String fileName) async {
    final token = _localStorage.getToken();
    if (token == null) throw Exception('No hay sesión activa');

    final uri = Uri.parse('${ApiConfig.baseUrl}/profile/photo');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    final multipartFile = http.MultipartFile.fromBytes(
      'photo',
      fileBytes,
      filename: fileName,
    );
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newPhotoUrl = data['profile_photo_url'];

      // Actualizar localStorage y retornar el usuario
      final user = await checkSession();
      if (user != null) {
        await _localStorage.saveSession(
          user.username,
          user.name,
          user.role,
          token,
          profilePhotoUrl: newPhotoUrl,
        );
        return user.copyWith(profilePhotoUrl: newPhotoUrl);
      }
      throw Exception('Sesión inválida después de subir foto');
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al subir la foto');
    }
  }
}
