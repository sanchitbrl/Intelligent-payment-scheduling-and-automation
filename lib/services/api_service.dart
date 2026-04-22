import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // For Android emulator use 10.0.2.2, for physical device use your PC's IP
  static const String _baseUrl = 'http://192.168.0.105:3000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // ─── Token Management ───

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  bool get isAuthenticated => _token != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── Auth APIs ───

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await saveToken(data['token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', data['user']['name']);
      await prefs.setString('user_email', data['user']['email']);
    }
    return {'statusCode': response.statusCode, ...data};
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await saveToken(data['token']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', data['user']['name']);
      await prefs.setString('user_email', data['user']['email']);
    }
    return {'statusCode': response.statusCode, ...data};
  }

  // ─── Payment APIs ───

  Future<List<dynamic>> getAllPayments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payments'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    }
    throw Exception('Failed to load payments');
  }

  Future<List<dynamic>> getUpcomingPayments() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payments/upcoming'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    }
    throw Exception('Failed to load upcoming payments');
  }

  Future<Map<String, dynamic>> getSummary() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payments/summary'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load summary');
  }

  Future<List<dynamic>> getHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/payments/history'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    }
    throw Exception('Failed to load history');
  }

  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to create payment');
  }

  Future<Map<String, dynamic>> updatePayment(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/payments/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to update payment');
  }

  Future<void> deletePayment(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/payments/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete payment');
    }
  }

  Future<Map<String, dynamic>> markPaid(int id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/$id/pay'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to mark as paid');
  }

  Future<Map<String, dynamic>> skipPayment(int id) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments/$id/skip'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to skip payment');
  }
}
