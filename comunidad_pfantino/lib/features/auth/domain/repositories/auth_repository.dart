import 'package:comunidad_pfantino/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String username, String password);
  Future<void> logout();
  Future<UserEntity?> checkSession();
  String? getToken();
}
