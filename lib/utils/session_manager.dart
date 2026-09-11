import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const int sessionTimeoutMinutes = 15;

  static Future<void> saveLoginSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);

    await prefs.setInt(
      'lastActiveTime',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<void> updateLastActiveTime() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      'lastActiveTime',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();

    final lastActive = prefs.getInt('lastActiveTime');

    print("Stored Last Active: $lastActive");

    if (lastActive == null) {
      print("NO LAST ACTIVE FOUND");
      return false;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final difference = (now - lastActive) ~/ (1000 * 60);

    print("Now: $now");
    print("Difference: $difference");
    print("Timeout: $sessionTimeoutMinutes");

    return difference <= sessionTimeoutMinutes;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();
  }
}
