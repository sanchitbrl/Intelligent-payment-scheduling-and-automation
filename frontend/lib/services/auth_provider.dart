import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiService();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _userName;
  String? _userEmail;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get error => _error;

  Future<void> checkAuth() async {
    _isLoading = true;
    notifyListeners();

    await _api.loadToken();
    if (_api.isAuthenticated) {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name');
      _userEmail = prefs.getString('user_email');
      _isAuthenticated = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.login(email, password);
      if (result['statusCode'] == 200) {
        _isAuthenticated = true;
        _userName = result['user']['name'];
        _userEmail = result['user']['email'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Is the server running?';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _api.register(name, email, password);
      if (result['statusCode'] == 201) {
        _isAuthenticated = true;
        _userName = result['user']['name'];
        _userEmail = result['user']['email'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Connection error. Is the server running?';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;
    notifyListeners();
  }
}
