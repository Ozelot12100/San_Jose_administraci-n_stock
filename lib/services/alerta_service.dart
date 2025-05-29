import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/alerta_stock.dart';
import '../models/insumo.dart';

class AlertaService {
  Future<List<AlertaStock>> getAlertasStock() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/insumos/bajo-stock'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> insumosJson = json.decode(response.body);
        final insumos = insumosJson.map((json) => Insumo.fromJson(json)).toList();
        
        return insumos.map((insumo) => AlertaStock.fromInsumo(insumo)).toList();
      } else {
        throw Exception('Error al obtener alertas de stock: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 