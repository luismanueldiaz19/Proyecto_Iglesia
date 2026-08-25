import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../auth/domain/entities/user_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/repositories/users_repository.dart';

final usersProvider =
    StateNotifierProvider<UsersNotifier, AsyncValue<List<UserEntity>>>((ref) {
      final repository = ref.watch(usersRepositoryProvider);
      final token = ref.watch(authProvider.notifier).getToken();
      return UsersNotifier(repository, token)..loadUsers();
    });

class UsersNotifier extends StateNotifier<AsyncValue<List<UserEntity>>> {
  final UsersRepository _repository;
  final String? _token;

  UsersNotifier(this._repository, this._token)
    : super(const AsyncValue.loading());

  Future<void> loadUsers() async {
    if (_token == null) {
      state = AsyncValue.error('No autenticado', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final users = await _repository.getUsers(_token);
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createUser(
    String name,
    String username,
    String password,
    String role,
  ) async {
    if (_token == null) throw Exception('No autenticado');

    try {
      await _repository.createUser(_token, name, username, password, role);
      await loadUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(
    int id,
    String name,
    String username,
    String? password,
    String role,
  ) async {
    if (_token == null) throw Exception('No autenticado');

    try {
      await _repository.updateUser(_token, id, name, username, password, role);
      await loadUsers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    if (_token == null) throw Exception('No autenticado');

    try {
      await _repository.deleteUser(_token, id);
      await loadUsers();
    } catch (e) {
      rethrow;
    }
  }
}
