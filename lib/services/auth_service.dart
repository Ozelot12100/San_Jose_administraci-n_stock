import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/usuario.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _baseUrl = 'http://localhost:5000/api'; // TODO: Configurar URL base
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  // Obtener el token almacenado
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Obtener el usuario almacenado
  Future<Usuario?> getStoredUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    return Usuario.fromJson(json.decode(userJson));
  }

  // Login
  Future<Usuario> login(String usuario, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario': usuario,
          'contrasena': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = Usuario.fromJson(data['usuario']);
        final token = data['token'];

        // Guardar token y usuario
        await _storage.write(key: _tokenKey, value: token);
        await _storage.write(key: _userKey, value: json.encode(user.toJson()));

        return user;
      } else {
        final error = json.decode(response.body)['message'] ?? 'Error de autenticación';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Verificar si hay una sesión activa
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/auth/verify'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtener headers con el token
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
} 