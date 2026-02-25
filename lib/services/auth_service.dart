import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intra/models/oa_user.dart';

class AuthService {
  static const String _baseUrl = 'https://devci.opinionarena.com/mobile-api/v1';
  static const String _keyToken = 'auth_token';
  static const String _keyDeviceId = 'device_id';
  static const String _keyPin = 'auth_pin';

  // ── Token storage ───────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  // ── PIN storage ─────────────────────────────────────────────────────────────

  static Future<void> savePin(String pin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, pin);
  }

  /// Returns true if [pin] matches the stored PIN.
  static Future<bool> verifyPin(String pin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? stored = prefs.getString(_keyPin);
    if (stored == null) return false;
    return stored == pin;
  }

  static Future<bool> hasPin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyPin);
  }

  // ── Device ID ───────────────────────────────────────────────────────────────

  static Future<String> getOrCreateDeviceId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_keyDeviceId);
    if (id == null) {
      id = _generateUuidV4();
      await prefs.setString(_keyDeviceId, id);
    }
    return id;
  }

  // ── Password login (used as PIN fallback from auth screen) ──────────────────

  static Future<bool> loginWithPassword(String email, String password) async {
    final String deviceId = await getOrCreateDeviceId();
    try {
      final http.Response response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'X-Device-Id': deviceId,
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) return false;

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (body['status'] != 'success') return false;

      final String? token =
          (body['data'] as Map<String, dynamic>)['accessToken'] as String?;
      if (token != null) await saveToken(token);

      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Token validation ────────────────────────────────────────────────────────

  /// Calls GET /auth/me with the stored token.
  /// Returns [OAUser] if the token is valid, null if expired/missing.
  static Future<OAUser?> validateToken() async {
    final String? token = await getToken();
    if (token == null) return null;

    final String deviceId = await getOrCreateDeviceId();

    try {
      final http.Response response = await http.get(
        Uri.parse('$_baseUrl/auth/me'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Device-Id': deviceId,
        },
      );

      if (response.statusCode != 200) {
        await clearToken();
        return null;
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (body['status'] != 'success') {
        await clearToken();
        return null;
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>;
      return OAUser.fromApiJson(
        data['user'] as Map<String, dynamic>,
        accessToken: token,
      );
    } catch (_) {
      // Network error — don't clear the token, let the user retry later
      return null;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _generateUuidV4() {
    final Random rng = Random.secure();
    final List<int> b = List<int>.generate(16, (_) => rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // version 4
    b[8] = (b[8] & 0x3f) | 0x80; // variant bits
    String h(int n) => n.toRadixString(16).padLeft(2, '0');
    return '${h(b[0])}${h(b[1])}${h(b[2])}${h(b[3])}'
        '-${h(b[4])}${h(b[5])}'
        '-${h(b[6])}${h(b[7])}'
        '-${h(b[8])}${h(b[9])}'
        '-${h(b[10])}${h(b[11])}${h(b[12])}${h(b[13])}${h(b[14])}${h(b[15])}';
  }
}
