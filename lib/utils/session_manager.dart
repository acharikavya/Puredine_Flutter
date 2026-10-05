import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _isLoggedInKey = 'isLoggedIn';

  static Future<void> saveLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear login only.
    await prefs.remove(_isLoggedInKey);
  }
}
