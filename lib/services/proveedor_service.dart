import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/proveedor.dart';
import '../config/api_config.dart';

class ProveedorService {
  // Obtener todos los proveedores
  Future<List<Proveedor>> getProveedores() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/proveedores'),
      );

      if (response.statusCode == 200) {
        List<dynamic> proveedoresJson = json.decode(response.body);
        return proveedoresJson.map((json) => Proveedor.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar proveedores');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Obtener proveedor por ID
  Future<Proveedor> getProveedorById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/proveedores/$id'),
      );

      if (response.statusCode == 200) {
        return Proveedor.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al cargar el proveedor');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Crear proveedor
  Future<Proveedor> createProveedor(Proveedor proveedor) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/proveedores'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(proveedor.toJson()),
      );

      if (response.statusCode == 201) {
        return Proveedor.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear el proveedor');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Actualizar proveedor
  Future<Proveedor> updateProveedor(int id, Proveedor proveedor) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/proveedores/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(proveedor.toJson()),
      );

      if (response.statusCode == 200) {
        return Proveedor.fromJson(json.decode(response.body));
      } else if (response.statusCode == 204) {
        // Si el backend responde 204 No Content, devolvemos el proveedor enviado
        return proveedor;
      } else {
        throw Exception('Error al actualizar el proveedor');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Eliminar proveedor
  Future<bool> deleteProveedor(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/proveedores/$id'),
      );

      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
} 