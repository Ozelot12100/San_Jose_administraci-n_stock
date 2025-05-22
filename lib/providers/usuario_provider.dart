import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/api_service.dart';

class UsuarioProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Usuario> _usuarios = [];
  bool _isLoading = false;
  String? _error;

  List<Usuario> get usuarios => _usuarios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsuarios() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.get('/api/usuarios');
      _usuarios = (response as List)
          .map((json) => Usuario.fromJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUsuario(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post('/api/usuarios', data);
      if (response != null) {
        _usuarios.add(Usuario.fromJson(response));
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUsuario(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.put('/api/usuarios/$id', data);
      if (response != null) {
        final index = _usuarios.indexWhere((u) => u.id == id);
        if (index != -1) {
          _usuarios[index] = Usuario.fromJson(response);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUsuario(int id) async {
    try {
      await _apiService.delete('/api/usuarios/$id');
      _usuarios.removeWhere((u) => u.id == id);
      await fetchUsuarios();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleUsuarioEstado(Usuario usuario) async {
    try {
      final response = await _apiService.put(
        '/api/usuarios/${usuario.id}/toggle-estado',
        {'activo': !usuario.activo},
      );
      
      if (response != null) {
        final index = _usuarios.indexWhere((u) => u.id == usuario.id);
        if (index != -1) {
          _usuarios[index] = Usuario.fromJson(response);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
} 