import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static final _storage = FlutterSecureStorage();
  static const _userDataKey = 'user_data';

  static Future<void> saveUserData({
    required String token,
    required int id,
    required String username,
    required String email,
  }) async {
    // Save token to secure storage
    await _storage.write(key: 'auth_token', value: token);
    await _storage.write(key: 'user_id', value: id.toString());

    // Save user data to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userData = {'id': id, 'username': username, 'email': email};
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }

  static Future<int?> getUserId() async {
    final id = await _storage.read(key: 'user_id');
    return id != null ? int.tryParse(id) : null;
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
