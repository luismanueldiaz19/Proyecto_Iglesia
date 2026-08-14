import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyUsername = 'username';
  static const String _keyName = 'name';
  static const String _keyRole = 'role';
  static const String _keyLoginTimestamp = 'login_timestamp';
  static const String _keyApiToken = 'api_token';

  static const String _keyProfilePhoto = 'profile_photo_url';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  Future<void> saveSession(
    String username,
    String name,
    String role,
    String token, {
    String? profilePhotoUrl,
  }) async {
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyName, name);
    await _prefs.setString(_keyRole, role);
    await _prefs.setString(_keyApiToken, token);
    if (profilePhotoUrl != null) {
      await _prefs.setString(_keyProfilePhoto, profilePhotoUrl);
    } else {
      await _prefs.remove(_keyProfilePhoto);
    }
    await _prefs.setString(
      _keyLoginTimestamp,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyName);
    await _prefs.remove(_keyRole);
    await _prefs.remove(_keyApiToken);
    await _prefs.remove(_keyProfilePhoto);
    await _prefs.remove(_keyLoginTimestamp);
  }

  String? getProfilePhotoUrl() {
    return _prefs.getString(_keyProfilePhoto);
  }

  String? getToken() {
    return _prefs.getString(_keyApiToken);
  }

  String? getUsername() {
    return _prefs.getString(_keyUsername);
  }

  String? getName() {
    return _prefs.getString(_keyName);
  }

  String? getRole() {
    return _prefs.getString(_keyRole);
  }

  bool isSessionValid() {
    final timestampStr = _prefs.getString(_keyLoginTimestamp);
    if (timestampStr == null) return false;

    final loginTime = DateTime.tryParse(timestampStr);
    if (loginTime == null) return false;

    final now = DateTime.now();
    final difference = now.difference(loginTime);

    // Si la diferencia es mayor o igual a 24 horas, la sesión expira.
    return difference.inHours < 24;
  }
}
