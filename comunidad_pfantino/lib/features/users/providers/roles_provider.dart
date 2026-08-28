import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_config.dart';
import '../../auth/providers/auth_provider.dart';

class PermissionEntity {
  final int id;
  final String name;

  PermissionEntity({required this.id, required this.name});

  factory PermissionEntity.fromJson(Map<String, dynamic> json) {
    return PermissionEntity(id: json['id'], name: json['name']);
  }
}

class RoleEntity {
  final int id;
  final String name;
  final List<PermissionEntity> permissions;

  RoleEntity({required this.id, required this.name, required this.permissions});

  factory RoleEntity.fromJson(Map<String, dynamic> json) {
    var list = json['permissions'] as List? ?? [];
    List<PermissionEntity> permissionsList = list
        .map((i) => PermissionEntity.fromJson(i))
        .toList();

    return RoleEntity(
      id: json['id'],
      name: json['name'],
      permissions: permissionsList,
    );
  }
}

final rolesProvider = FutureProvider<List<RoleEntity>>((ref) async {
  final token = ref.watch(authProvider.notifier).getToken();

  if (token == null) {
    throw Exception('No autenticado');
  }

  final response = await http.get(
    Uri.parse('${ApiConfig.baseUrl}/roles'),
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> rolesList = data['data'];
    return rolesList.map((json) => RoleEntity.fromJson(json)).toList();
  } else {
    throw Exception('Error al obtener los roles');
  }
});
