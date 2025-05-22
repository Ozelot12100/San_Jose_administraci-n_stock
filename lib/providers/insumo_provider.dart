import 'package:flutter/material.dart';
import '../models/insumo.dart';
import '../services/insumo_service.dart';

class InsumoProvider extends ChangeNotifier {
  final InsumoService _service = InsumoService();
  List<Insumo> _insumos = [];
  Insumo? _selectedInsumo;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  // Getters
  List<Insumo> get insumos => _insumos;
  Insumo? get selectedInsumo => _selectedInsumo;
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

  // Obtener todos los insumos
  Future<void> fetchInsumos() async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();
    try {
      _insumos = await _service.getInsumos();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Obtener un insumo específico por ID
  Future<void> fetchInsumo(int id) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();
    try {
      _selectedInsumo = await _service.getInsumoById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Crear un nuevo insumo
  Future<bool> createInsumo(Map<String, dynamic> insumoData) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();
    try {
      // Convertir el Map a un objeto Insumo
      final insumo = Insumo.fromJson(insumoData);
      
      // Usar el método del servicio
      final createdInsumo = await _service.createInsumo(insumo);
      
      _insumos.add(createdInsumo);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Actualizar un insumo existente
  Future<bool> updateInsumo(int id, Map<String, dynamic> insumoData) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();
    try {
      // Convertir el Map a un objeto Insumo y asegurarse de que tenga el ID correcto
      final insumo = Insumo.fromJson({...insumoData, 'id': id});
      
      // Usar el método del servicio
      final updatedInsumo = await _service.updateInsumo(id, insumo);
      
      // Actualizar en la lista local
      final index = _insumos.indexWhere((i) => i.id == id);
      if (index >= 0) {
        _insumos[index] = updatedInsumo;
      }
      
      // Actualizar el seleccionado si corresponde
      if (_selectedInsumo?.id == id) {
        _selectedInsumo = updatedInsumo;
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

  // Eliminar un insumo
  Future<bool> deleteInsumo(int id) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();
    try {
      await _service.deleteInsumo(id);
      
      // Eliminar de la lista local
      _insumos.removeWhere((i) => i.id == id);
      
      // Limpiar seleccionado si corresponde
      if (_selectedInsumo?.id == id) {
        _selectedInsumo = null;
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