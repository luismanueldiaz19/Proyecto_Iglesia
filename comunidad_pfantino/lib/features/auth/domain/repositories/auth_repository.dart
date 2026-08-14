import 'package:comunidad_pfantino/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String username, String password);
  Future<void> logout();
  Future<UserEntity?> checkSession();
  String? getToken();
  Future<UserEntity> updateProfile(String name, String currentPassword);
  Future<void> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation);
  Future<List<Map<String, dynamic>>> getSessions();
  Future<List<String>> getPermissions();
  Future<UserEntity> uploadProfilePhoto(List<int> fileBytes, String fileName);
}
