import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Usuario? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Constructor
  AuthProvider() {
    _loadStoredUser();
  }

  // Cargar usuario almacenado
  Future<void> _loadStoredUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.getStoredUser();
      if (user != null && await _authService.isAuthenticated()) {
        _currentUser = user;
        _error = null;
      } else {
        await logout();
      }
    } catch (e) {
      _error = e.toString();
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String usuario, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(usuario, password);
      _currentUser = user;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 