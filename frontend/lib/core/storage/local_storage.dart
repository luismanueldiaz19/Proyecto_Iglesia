import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _keyUsername = 'username';
  static const String _keyLoginTimestamp = 'login_timestamp';
  static const String _keyApiToken = 'api_token';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  Future<void> saveSession(String username, String token) async {
    await _prefs.setString(_keyUsername, username);
    await _prefs.setString(_keyApiToken, token);
    await _prefs.setString(
      _keyLoginTimestamp,
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> clearSession() async {
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyApiToken);
    await _prefs.remove(_keyLoginTimestamp);
  }

  String? getToken() {
    return _prefs.getString(_keyApiToken);
  }

  String? getUsername() {
    return _prefs.getString(_keyUsername);
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
