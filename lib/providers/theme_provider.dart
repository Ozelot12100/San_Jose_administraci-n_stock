import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  final _storage = const FlutterSecureStorage();
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final storedTheme = await _storage.read(key: _themeKey);
      _isDarkMode = storedTheme == 'true';
      notifyListeners();
    } catch (e) {
      // En caso de error al leer, mantener el tema predeterminado
      _isDarkMode = false;
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    try {
      await _storage.write(key: _themeKey, value: _isDarkMode.toString());
    } catch (e) {
      // Registrar error pero no interrumpir la aplicación
      debugPrint('Error al guardar preferencia de tema: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
} 