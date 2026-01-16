import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static Future<void> setToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('authToken');
    return token;
  }
}
