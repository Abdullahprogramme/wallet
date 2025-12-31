import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://wallet-gzb6.onrender.com/api/auth';

  static Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 60));

      print('[AUTH] Sign-in response status: ${resp.statusCode}');
      print('[AUTH] Sign-in response body: ${resp.body}');

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else {
        // Try to parse error message from backend
        try {
          final errorBody = jsonDecode(resp.body);
          final errorMsg = errorBody['msg'] ?? errorBody['message'] ?? 'Authentication failed';
          print('[AUTH] Error from backend: $errorMsg');
          return {'error': errorMsg, 'statusCode': resp.statusCode};
        } catch (_) {
          return {'error': 'Server error (${resp.statusCode})', 'statusCode': resp.statusCode};
        }
      }
    } catch (e) {
      print('[AUTH] Sign-in exception: $e');
      return {'error': 'Network error: $e', 'exception': true};
    }
  }

  static Future<Map<String, dynamic>?> signUp(String name, String email, String password) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 60));
      print('[AUTH] Sign-up response status: ${resp.statusCode}');
      print('[AUTH] Sign-up response body: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else {
        // Try to parse error message from backend
        try {
          final errorBody = jsonDecode(resp.body);
          final errorMsg = errorBody['msg'] ?? errorBody['message'] ?? 'Registration failed';
          print('[AUTH] Error from backend: $errorMsg');
          return {'error': errorMsg, 'statusCode': resp.statusCode};
        } catch (_) {
          return {'error': 'Server error (${resp.statusCode})', 'statusCode': resp.statusCode};
        }
      }
    } catch (e) {
      print('[AUTH] Sign-up exception: $e');
      return {'error': 'Network error: $e', 'exception': true};
    }
  }

  static Future<Map<String, dynamic>?> updatePassword(
    String token,
    String userId,
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final resp = await http.put(
        Uri.parse('$baseUrl/update-password/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({'oldPassword': oldPassword, 'newPassword': newPassword}),
      ).timeout(const Duration(seconds: 60));

      print('[AUTH] Update-password response status: ${resp.statusCode}');
      print('[AUTH] Update-password response body: ${resp.body}');

      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } else {
        try {
          final errorBody = jsonDecode(resp.body);
          final errorMsg = errorBody['msg'] ?? errorBody['message'] ?? 'Password update failed';
          return {'error': errorMsg, 'statusCode': resp.statusCode};
        } catch (_) {
          return {'error': 'Server error (${resp.statusCode})', 'statusCode': resp.statusCode};
        }
      }
    } catch (e) {
      print('[AUTH] Update-password exception: $e');
      return {'error': 'Network error: $e', 'exception': true};
    }
  }
}
