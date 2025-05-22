import 'package:flutter/material.dart';

// Pantallas
import 'screens/auth/login_screen.dart';
import 'screens/layout/main_layout.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/usuarios/usuarios_screen.dart';
import 'screens/insumos/insumos_screen.dart';
import 'screens/proveedores/proveedores_screen.dart';
import 'screens/movimientos/movimientos_screen.dart';
import 'screens/reportes/reportes_screen.dart';

class AppRoutes {
  // Nombres de rutas
  static const String login = '/login';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String usuarios = '/usuarios';
  static const String insumos = '/insumos';
  static const String proveedores = '/proveedores';
  static const String movimientos = '/movimientos';
  static const String reportes = '/reportes';

  // Mapa de rutas
  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
      main: (context) => const MainLayout(),
      dashboard: (context) => const DashboardScreen(),
      usuarios: (context) => const UsuariosScreen(),
      insumos: (context) => const InsumosScreen(),
      proveedores: (context) => const ProveedoresScreen(),
      movimientos: (context) => const MovimientosScreen(),
      reportes: (context) => const ReportesScreen(),
    };
  }

  // Navegación
  static void navigateTo(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  static void navigateToReplacing(BuildContext context, String routeName) {
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  static void goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Navegar a Layout principal con índice específico
  static void navigateToMainLayoutWithIndex(BuildContext context, int index) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MainLayout(initialIndex: index),
      ),
    );
  }
} 