import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionService {
  static const String baseUrl = 'https://wallet-gzb6.onrender.com/api';

  static Future<List<dynamic>?> getTransactions(String token, String categoryId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/transactions/$categoryId'), headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      });
      if (res.statusCode == 200) {
        return List<dynamic>.from(jsonDecode(res.body) as List);
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> addMoney(String token, String categoryId, double amount) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/transactions/add'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
          body: jsonEncode({'categoryId': categoryId, 'amount': amount}));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> subtractMoney(String token, String categoryId, double amount) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/transactions/subtract'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
          body: jsonEncode({'categoryId': categoryId, 'amount': amount}));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}