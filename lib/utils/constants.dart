import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Constantes de la aplicación
class AppConstants {
  // Nombre de la aplicación
  static const String appName = 'Sistema de Inventario - Clínica San José';
  
  // Colores principales
  static const Color primaryColor = Color(0xFF1A237E); // Azul institucional
  static const Color secondaryColor = Color(0xFF303F9F);
  static const Color accentColor = Color(0xFF536DFE);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  
  // Dimensiones
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  
  // Duración para animaciones
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Formato de fechas
  static final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');
  
  // Mensajes comunes
  static const String errorGenerico = 'Ocurrió un error inesperado';
  static const String errorConexion = 'Error de conexión. Verifica tu conexión a Internet.';
  static const String datosGuardadosExito = 'Datos guardados correctamente';
  static const String datosBorradosExito = 'Elemento eliminado correctamente';
  static const String confirmacionEliminar = '¿Estás seguro de que deseas eliminar este elemento?';
  
  // No permitir instanciación
  AppConstants._();
}

/// Utilidades para la aplicación
class AppUtils {
  // Formatear número con dos decimales
  static String formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
  
  // Formatear fecha
  static String formatDate(DateTime date) {
    return AppConstants.dateFormat.format(date);
  }
  
  // Formatear fecha y hora
  static String formatDateTime(DateTime date) {
    return AppConstants.dateTimeFormat.format(date);
  }
  
  // Mostrar SnackBar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppConstants.errorColor : AppConstants.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Mostrar diálogo de confirmación
  static Future<bool> showConfirmDialog(
    BuildContext context, 
    String title, 
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
  
  // No permitir instanciación
  AppUtils._();
} 