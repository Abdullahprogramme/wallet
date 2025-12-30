import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryService {
  static const String baseUrl = 'https://wallet-gzb6.onrender.com/api';

  static Future<List<dynamic>?> getCategories(String token) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/categories'), headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });

      if (res.statusCode == 200) {
        return List<dynamic>.from(jsonDecode(res.body) as List);
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> createCategory(String token, String name) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/categories'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
          body: jsonEncode({'name': name}));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> deleteCategory(String token, String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/categories/$id'), headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });
      return res.statusCode == 200;
    } catch (_) {}
    return false;
  }
}