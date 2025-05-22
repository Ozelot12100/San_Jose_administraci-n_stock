import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Usuario? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Constructor para intentar cargar la sesión automáticamente
  AuthProvider() {
    _checkExistingSession();
  }

  // Getters
  Usuario? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  // Login
  Future<bool> login(String nombreUsuario, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(nombreUsuario, password);
      _currentUser = user;
      // Debug
      print('Login exitoso: ${user.toString()}');
      notifyListeners();
      return true;
    } catch (e) {
      // Extraer solo el mensaje de error desde la excepción
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }
      _error = errorMsg;
      print('Error de login: $_error');
      notifyListeners();
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
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }
      _error = errorMsg;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verificar si hay una sesión existente
  Future<bool> checkExistingSession() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = await _authService.getStoredUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método privado para inicialización automática (sin mostrar carga)
  Future<void> _checkExistingSession() async {
    try {
      final user = await _authService.getStoredUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      print('Error al verificar sesión: $e');
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 