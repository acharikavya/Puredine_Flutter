import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<void> saveLoginSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
  }

  static Future<void> updateLastActiveTime() async {
    // Kept for compatibility with existing code.
    // Background time does not expire the login session.
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'lastActiveTime',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> isSessionValid() async {
    // A saved login session remains valid until explicit logout.
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
