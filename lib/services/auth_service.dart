import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _userKey = 'current_user';

  // Login simple
  Future<Usuario> login(String nombreUsuario, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/Auth/login-simple'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'usuario': nombreUsuario,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['exito'] == true && data['usuario'] != null) {
        final user = Usuario.fromJson(data['usuario']);
        
        // Guardar usuario en preferencias
        await _saveUserToPrefs(user);
        
        return user;
      } else {
        final error = data['mensaje'] ?? 'Error de autenticación';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Logout - eliminar datos de sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Guardar usuario en preferencias
  Future<void> _saveUserToPrefs(Usuario user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  // Obtener usuario almacenado en preferencias
  Future<Usuario?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        return Usuario.fromJson(userData);
      } catch (e) {
        print('Error deserializando usuario: $e');
        return null;
      }
    }
    return null;
  }

  // Verificar si hay una sesión activa
  Future<bool> isAuthenticated() async {
    final user = await getStoredUser();
    return user != null;
  }
} 