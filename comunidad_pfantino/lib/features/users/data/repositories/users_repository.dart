import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_config.dart';
import '../../../auth/domain/entities/user_entity.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepositoryImpl();
});

abstract class UsersRepository {
  Future<List<UserEntity>> getUsers(String token);
  Future<UserEntity> createUser(
    String token,
    String name,
    String username,
    String password,
    String role,
  );
  Future<UserEntity> updateUser(
    String token,
    int id,
    String name,
    String username,
    String? password,
    String role,
  );
  Future<void> deleteUser(String token, int id);
}

class UsersRepositoryImpl implements UsersRepository {
  @override
  Future<List<UserEntity>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) {
        final roles = json['roles'] as List<dynamic>;
        final role = roles.isNotEmpty ? roles.first['name'] : 'Usuario';
        return UserEntity(
          id: json['id'],
          name: json['name'],
          username: json['username'],
          role: role.toString(),
          profilePhotoUrl: json['profile_photo_url'],
        );
      }).toList();
    } else {
      throw Exception('Error al obtener usuarios');
    }
  }

  @override
  Future<UserEntity> createUser(
    String token,
    String name,
    String username,
    String password,
    String role,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body)['user'];
      final roles = data['roles'] as List<dynamic>;
      final userRole = roles.isNotEmpty ? roles.first['name'] : 'Usuario';
      return UserEntity(
        id: data['id'],
        name: data['name'],
        username: data['username'],
        role: userRole.toString(),
        profilePhotoUrl: data['profile_photo_url'],
      );
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al crear usuario');
    }
  }

  @override
  Future<UserEntity> updateUser(
    String token,
    int id,
    String name,
    String username,
    String? password,
    String role,
  ) async {
    final body = {'name': name, 'username': username, 'role': role};
    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['user'];
      final roles = data['roles'] as List<dynamic>;
      final userRole = roles.isNotEmpty ? roles.first['name'] : 'Usuario';
      return UserEntity(
        id: data['id'],
        name: data['name'],
        username: data['username'],
        role: userRole.toString(),
        profilePhotoUrl: data['profile_photo_url'],
      );
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al actualizar usuario');
    }
  }

  @override
  Future<void> deleteUser(String token, int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/users/$id'),
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error al eliminar usuario');
    }
  }
}
