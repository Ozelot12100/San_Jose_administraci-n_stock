import 'package:flutter/material.dart';
import '../models/proveedor.dart';
import '../services/proveedor_service.dart';

class ProveedorProvider extends ChangeNotifier {
  final ProveedorService _service = ProveedorService();
  List<Proveedor> _proveedores = [];
  Proveedor? _selectedProveedor;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  // Getters
  List<Proveedor> get proveedores => _proveedores;
  Proveedor? get selectedProveedor => _selectedProveedor;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  // Obtener todos los proveedores
  Future<void> fetchProveedores() async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      _proveedores = await _service.getProveedores();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Obtener un proveedor por ID
  Future<void> fetchProveedor(int id) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      _selectedProveedor = await _service.getProveedorById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Crear un nuevo proveedor
  Future<bool> createProveedor(Map<String, dynamic> proveedorData) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      // Convertir el Map a un objeto Proveedor
      final proveedor = Proveedor.fromJson(proveedorData);
      
      // Usar el método actualizado del servicio
      final createdProveedor = await _service.createProveedor(proveedor);
      
      // Recargar la lista completa desde el backend para asegurar sincronización
      await fetchProveedores();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Actualizar un proveedor existente
  Future<bool> updateProveedor(int id, Map<String, dynamic> proveedorData) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      // Convertir el Map a un objeto Proveedor y asegurarse de que tenga el ID correcto
      final proveedor = Proveedor.fromJson({...proveedorData, 'id': id});
      
      // Usar el método actualizado del servicio
      final updatedProveedor = await _service.updateProveedor(id, proveedor);
      
      final index = _proveedores.indexWhere((p) => p.id == id);
      if (index >= 0) {
        _proveedores[index] = updatedProveedor;
      }
      if (_selectedProveedor?.id == id) {
        _selectedProveedor = updatedProveedor;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Eliminar un proveedor
  Future<bool> deleteProveedor(int id) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      await _service.deleteProveedor(id);
      _proveedores.removeWhere((p) => p.id == id);
      if (_selectedProveedor?.id == id) {
        _selectedProveedor = null;
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    safeNotifyListeners();
  }
} 