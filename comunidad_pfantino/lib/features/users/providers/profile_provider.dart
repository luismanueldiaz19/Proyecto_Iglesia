import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../auth/providers/auth_provider.dart';

// Proveedor para las sesiones de perfil (accesos)
final profileSessionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final repository = ref.watch(authRepositoryProvider);
      return await repository.getSessions();
    });

// Proveedor para los permisos del perfil
final profilePermissionsProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getPermissions();
});

// Lógica de perfil (StateNotifier para manejar carga y errores si fuera necesario)
class ProfileStateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ProfileStateNotifier(this.ref) : super(const AsyncData(null));

  Future<void> updateName(String name, String currentPassword) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final updatedUser = await repository.updateProfile(name, currentPassword);

      // Actualizamos el estado global de auth para reflejar el nuevo nombre
      ref.read(authProvider.notifier).currentUser = updatedUser;

      // Eliminamos checkSession() porque ponía la app en estado loading
      // y causaba que el router redigiriera a /splash, desmontando la pantalla.

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.changePassword(
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> uploadPhoto(List<int> fileBytes, String fileName) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final updatedUser = await repository.uploadProfilePhoto(
        fileBytes,
        fileName,
      );

      // Actualizamos el estado global de auth para reflejar la nueva foto
      ref.read(authProvider.notifier).currentUser = updatedUser;

      // Forzamos la actualización de la interfaz emitiendo un nuevo estado
      // clonando la sesión actual para no alterar el AuthState.
      final authNotifier = ref.read(authProvider.notifier);
      authNotifier.state = authNotifier.state;

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileStateNotifier, AsyncValue<void>>((ref) {
      return ProfileStateNotifier(ref);
    });
