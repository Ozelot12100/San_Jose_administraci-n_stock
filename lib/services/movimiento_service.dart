import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movimiento.dart';
import '../config/api_config.dart';

class MovimientoService {
  // Obtener todos los movimientos
  Future<List<Movimiento>> getMovimientos() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/movimientos'),
      );

      if (response.statusCode == 200) {
        List<dynamic> movimientosJson = json.decode(response.body);
        return movimientosJson
            .map((json) => Movimiento.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al cargar movimientos');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener movimiento por ID
  Future<Movimiento> getMovimientoById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/movimientos/$id'),
      );

      if (response.statusCode == 200) {
        return Movimiento.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar el movimiento');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Crear movimiento
  Future<Movimiento> createMovimiento(Movimiento movimiento) async {
    try {
      final jsonBody = movimiento.toCreateJson();
      print('JSON enviado al backend (movimiento): ${json.encode(jsonBody)}');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/movimientos'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonBody),
      );

      if (response.statusCode == 201) {
        return Movimiento.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear el movimiento');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener movimientos por insumo
  Future<List<Movimiento>> getMovimientosByInsumo(int insumoId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/movimientos/insumo/$insumoId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> movimientosJson = json.decode(response.body);
        return movimientosJson.map((e) => Movimiento.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar movimientos del insumo');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener movimientos por fecha
  Future<List<Movimiento>> getMovimientosByFecha(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      final inicio = fechaInicio.toIso8601String().split('T')[0];
      final fin = fechaFin.toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse(
          '${ApiConfig.baseUrl}/api/movimientos/fecha?inicio=$inicio&fin=$fin',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> movimientosJson = json.decode(response.body);
        return movimientosJson.map((e) => Movimiento.fromJson(e)).toList();
      } else {
        throw Exception('Error al cargar movimientos por fecha');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
