import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/insumo.dart';
import '../config/api_config.dart';

class InsumoService {
  // Obtener todos los insumos
  Future<List<Insumo>> getInsumos() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/insumos'),
      );

      if (response.statusCode == 200) {
        List<dynamic> insumosJson = json.decode(response.body);
        return insumosJson.map((json) => Insumo.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar insumos');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener insumo por ID
  Future<Insumo> getInsumoById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/insumos/$id'),
      );

      if (response.statusCode == 200) {
        return Insumo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar el insumo');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Crear insumo
  Future<Insumo> createInsumo(Insumo insumo) async {
    try {
      final jsonBody = json.encode(insumo.toJson());
      print('JSON enviado al backend (crear insumo): $jsonBody');
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/insumos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonBody,
      );

      if (response.statusCode == 201) {
        return Insumo.fromJson(json.decode(response.body));
      } else {
        String backendMsg = '';
        try {
          final decoded = json.decode(response.body);
          backendMsg = decoded['message'] ?? decoded['error'] ?? response.body;
        } catch (_) {
          backendMsg = response.body;
        }
        throw Exception('Error al crear el insumo: $backendMsg');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualizar insumo
  Future<Insumo> updateInsumo(int id, Insumo insumo) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/insumos/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(insumo.toJson()),
      );
      print('PUT /insumos/$id status: \\${response.statusCode}, body: \\${response.body}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Si es 204, simplemente retorna el insumo actualizado localmente
        if (response.statusCode == 204) return insumo;
        return Insumo.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar el insumo');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar insumo
  Future<bool> deleteInsumo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/insumos/$id'),
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
} 