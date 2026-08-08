import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/user_entity.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../../../../core/storage/local_storage.dart';

// 1. Proveedor de SharedPreferences (se inicializa en main.dart)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

// 2. Proveedor del Repositorio de Auth
final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final localStorage = LocalStorage(prefs);
  return AuthRepositoryImpl(localStorage);
});

// 3. Estado de la Autenticación
enum AuthState { initial, authenticated, unauthenticated, loading, error }

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepositoryImpl _repository;
  UserEntity? currentUser;
  String? errorMessage;

  AuthStateNotifier(this._repository) : super(AuthState.initial) {
    checkSession();
  }

  Future<void> checkSession() async {
    state = AuthState.loading;

    // Pequeño retraso para asegurar que la animación del Splash Screen
    // se luzca al menos 2 segundos antes de cambiar de pantalla.
    await Future.delayed(const Duration(seconds: 2));

    final user = await _repository.checkSession();
    if (user != null) {
      currentUser = user;
      state = AuthState.authenticated;
    } else {
      currentUser = null;
      state = AuthState.unauthenticated;
    }
  }

  Future<void> login(String username, String password) async {
    state = AuthState.loading;
    errorMessage = null;
    try {
      final user = await _repository.login(username, password);
      if (user != null) {
        currentUser = user;
        state = AuthState.authenticated;
      }
    } catch (e) {
      errorMessage = e.toString().replaceAll('Exception: ', '');
      state = AuthState.error;
      // Regresa a unauthenticated para poder reintentar
      await Future.delayed(const Duration(seconds: 3));
      state = AuthState.unauthenticated;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    currentUser = null;
    state = AuthState.unauthenticated;
  }

  String? getToken() {
    return _repository.getToken();
  }
}

// 4. Proveedor Principal del Estado
final authProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repository);
});
