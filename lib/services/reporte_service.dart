import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../config/api_config.dart';

class ReporteData {
  final String titulo;
  final List<Map<String, dynamic>> datos;
  final Map<String, dynamic>? resumen;

  ReporteData({
    required this.titulo,
    required this.datos,
    this.resumen,
  });

  factory ReporteData.fromJson(Map<String, dynamic> json) {
    return ReporteData(
      titulo: json['titulo'] as String,
      datos: List<Map<String, dynamic>>.from(json['datos']),
      resumen: json['resumen'] as Map<String, dynamic>?,
    );
  }
}

class ReporteService {
  // Obtener reporte de inventario
  Future<ReporteData> getReporteInventario() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/inventario')
      );
      
      if (response.statusCode == 200) {
        return ReporteData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener reporte de inventario');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener reporte de stock actual simplificado
  Future<List<Map<String, dynamic>>> getReporteStockSimple() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/stock'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener reporte de stock');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener reporte de movimientos en un rango de fechas
  Future<ReporteData> getReporteMovimientos(DateTime inicio, DateTime fin) async {
    try {
      final inicioStr = inicio.toIso8601String().split('T')[0];
      final finStr = fin.toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/movimientos?inicio=$inicioStr&fin=$finStr'),
      );
      
      if (response.statusCode == 200) {
        return ReporteData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener reporte de movimientos');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener reporte de movimientos simplificado
  Future<List<Map<String, dynamic>>> getReporteMovimientosSimple(DateTime inicio, DateTime fin) async {
    try {
      final inicioStr = inicio.toIso8601String().split('T')[0];
      final finStr = fin.toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/movimientos-simple?inicio=$inicioStr&fin=$finStr'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener reporte de movimientos simplificado');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener reporte de insumos por proveedor
  Future<List<Map<String, dynamic>>> getReporteInsumosPorProveedor(int proveedorId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/insumos-proveedor/$proveedorId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener reporte de insumos por proveedor');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener reporte de consumo por área
  Future<ReporteData> getReporteConsumoAreas(DateTime inicio, DateTime fin) async {
    try {
      final inicioStr = inicio.toIso8601String().split('T')[0];
      final finStr = fin.toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/consumo-areas?inicio=$inicioStr&fin=$finStr'),
      );
      
      if (response.statusCode == 200) {
        return ReporteData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener reporte de consumo por áreas');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener reporte de consumo por área específica
  Future<List<Map<String, dynamic>>> getReporteConsumoPorAreaEspecifica(int areaId, DateTime inicio, DateTime fin) async {
    try {
      final inicioStr = inicio.toIso8601String().split('T')[0];
      final finStr = fin.toIso8601String().split('T')[0];
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/consumo-area/$areaId?inicio=$inicioStr&fin=$finStr'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener reporte de consumo por área específica');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener reporte de insumos de bajo stock
  Future<ReporteData> getReporteBajoStock(int umbral) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/bajo-stock?umbral=$umbral'),
      );
      
      if (response.statusCode == 200) {
        return ReporteData.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al obtener reporte de bajo stock');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Descargar reporte en PDF
  Future<String> descargarReportePDF(String tipoReporte, Map<String, dynamic> params) async {
    try {
      final queryParams = params.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/$tipoReporte/pdf?$queryParams'),
      );
      
      if (response.statusCode == 200) {
        // Guardar el PDF en el dispositivo
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/reporte_$tipoReporte.pdf';
        
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        return filePath;
      } else {
        throw Exception('Error al descargar reporte PDF');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Descargar reporte en Excel
  Future<String> descargarReporteExcel(String tipoReporte, Map<String, dynamic> params) async {
    try {
      final queryParams = params.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/reportes/$tipoReporte/excel?$queryParams'),
      );
      
      if (response.statusCode == 200) {
        // Guardar el Excel en el dispositivo
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/reporte_$tipoReporte.xlsx';
        
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        return filePath;
      } else {
        throw Exception('Error al descargar reporte Excel');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
} 