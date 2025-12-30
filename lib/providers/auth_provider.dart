import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _token = '';
  String _name = '';
  String _email = '';
  String _userId = '';

  bool get isLoggedIn => _isLoggedIn;
  String get token => _token;
  String get name => _name;
  String get email => _email;
  String get userId => _userId;

  // Decode JWT to extract userId
  String _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      final payload = parts[1];
      // Add padding if needed
      String normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = jsonDecode(decoded);
      return data['userId'] ?? '';
    } catch (e) {
      print('[AUTH_PROVIDER] Failed to decode token: $e');
      return '';
    }
  }

  Future<void> _saveToPrefs(String token, String name, String email, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('userId', userId);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    final n = prefs.getString('name');
    final e = prefs.getString('email');
    final u = prefs.getString('userId');
    if (t != null) {
      _token = t;
      _name = n ?? '';
      _email = e ?? '';
      _userId = u ?? _extractUserIdFromToken(t);
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    final resp = await AuthService.signIn(email, password);
    if (resp != null) {
      if (resp['token'] != null) {
        _token = resp['token'];
        _email = email;
        _userId = _extractUserIdFromToken(_token);
        // Name may not be available from backend; keep existing or empty
        await _saveToPrefs(_token, _name, _email, _userId);
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else if (resp['error'] != null) {
        print('[AUTH_PROVIDER] Sign-in error: ${resp['error']}');
      }
    }
    return false;
  }

  Future<bool> signUp(String name, String email, String password) async {
    final resp = await AuthService.signUp(name, email, password);
    if (resp != null && resp['token'] != null) {
      _token = resp['token'];
      _name = name;
      _email = email;
      _userId = _extractUserIdFromToken(_token);
      await _saveToPrefs(_token, _name, _email, _userId);
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> updatePassword(String oldPassword, String newPassword) async {
    if (_userId.isEmpty) {
      return {'success': false, 'error': 'User ID not found. Please sign in again.'};
    }
    final resp = await AuthService.updatePassword(_token, _userId, oldPassword, newPassword);
    if (resp != null) {
      if (resp['msg'] != null && resp['error'] == null) {
        return {'success': true, 'message': resp['msg']};
      } else if (resp['error'] != null) {
        return {'success': false, 'error': resp['error']};
      }
    }
    return {'success': false, 'error': 'Password update failed'};
  }

  void logout() async {
    _isLoggedIn = false;
    _token = '';
    _name = '';
    _email = '';
    _userId = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('userId');
    notifyListeners();
  }
}
