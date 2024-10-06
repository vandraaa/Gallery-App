import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  // save token jwt (login)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // get token
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // remove token (logout)
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // is expired
  Future<bool> isExpired(String token) async {
    if (token.isEmpty) {
      return true;
    }

    try {
      final expiryDate = Jwt.getExpiryDate(token);
      if (expiryDate != null) {
        return expiryDate.isBefore(DateTime.now());
      }
      return true;
    } catch (e) {
      print("Error decoding token: $e");
      return true;
    }
  }

  // data user
  Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final decodedToken = Jwt.parseJwt(token);
    print(decodedToken);
    return decodedToken;
  }
}
