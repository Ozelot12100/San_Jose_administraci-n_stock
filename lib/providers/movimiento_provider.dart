import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movimiento.dart';
import '../services/movimiento_service.dart';

class MovimientoProvider extends ChangeNotifier {
  final MovimientoService _service = MovimientoService();
  List<Movimiento> _movimientos = [];
  Movimiento? _selectedMovimiento;
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  // Filtros
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  int? _insumoId;
  String? _tipoMovimiento; // 'entrada', 'salida', o null para todos

  // Getters
  List<Movimiento> get movimientos => _movimientos;
  Movimiento? get selectedMovimiento => _selectedMovimiento;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get fechaInicio => _fechaInicio;
  DateTime? get fechaFin => _fechaFin;
  int? get insumoId => _insumoId;
  String? get tipoMovimiento => _tipoMovimiento;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  // Obtener todos los movimientos (con filtros opcionales)
  Future<void> fetchMovimientos() async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      // Si hay filtros de fecha, usamos ese endpoint
      if (_fechaInicio != null && _fechaFin != null) {
        _movimientos = await _service.getMovimientosByFecha(
          _fechaInicio!,
          _fechaFin!,
        );
      }
      // Si hay filtro de insumo
      else if (_insumoId != null) {
        _movimientos = await _service.getMovimientosByInsumo(_insumoId!);
      }
      // Si no hay filtros específicos
      else {
        _movimientos = await _service.getMovimientos();
      }

      // Aplicamos filtro por tipo si está establecido
      if (_tipoMovimiento != null) {
        _movimientos =
            _movimientos.where((m) => m.tipo == _tipoMovimiento).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Obtener un movimiento específico
  Future<void> fetchMovimiento(int id) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      _selectedMovimiento = await _service.getMovimientoById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Crear un nuevo movimiento (entrada o salida)
  Future<bool> createMovimiento(Map<String, dynamic> movimientoData) async {
    _isLoading = true;
    _error = null;
    safeNotifyListeners();

    try {
      // Convertir el Map a un objeto Movimiento
      final movimiento = Movimiento.fromJson(movimientoData);

      // Usar el método actualizado del servicio
      final newMovimiento = await _service.createMovimiento(movimiento);

      _movimientos.add(newMovimiento);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  // Configurar filtros
  void setFiltros({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? insumoId,
    String? tipoMovimiento,
  }) {
    bool changed = false;

    if (fechaInicio != _fechaInicio) {
      _fechaInicio = fechaInicio;
      changed = true;
    }

    if (fechaFin != _fechaFin) {
      _fechaFin = fechaFin;
      changed = true;
    }

    if (insumoId != _insumoId) {
      _insumoId = insumoId;
      changed = true;
    }

    if (tipoMovimiento != _tipoMovimiento) {
      _tipoMovimiento = tipoMovimiento;
      changed = true;
    }

    if (changed) {
      safeNotifyListeners();
      fetchMovimientos(); // Recargar con los nuevos filtros
    }
  }

  // Limpiar filtros
  void clearFiltros() {
    _fechaInicio = null;
    _fechaFin = null;
    _insumoId = null;
    _tipoMovimiento = null;
    safeNotifyListeners();
    fetchMovimientos(); // Recargar sin filtros
  }

  // Limpiar error
  void clearError() {
    _error = null;
    safeNotifyListeners();
  }

  // Formatear fecha para mostrar
  String formatFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }
}
