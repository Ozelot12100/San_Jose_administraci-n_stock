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
  String? _busquedaInsumo;

  // Getters
  List<Movimiento> get movimientos => _movimientos;
  Movimiento? get selectedMovimiento => _selectedMovimiento;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get fechaInicio => _fechaInicio;
  DateTime? get fechaFin => _fechaFin;
  int? get insumoId => _insumoId;
  String? get tipoMovimiento => _tipoMovimiento;
  String? get busquedaInsumo => _busquedaInsumo;

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
      // Filtro por rango de fechas (si hay fechaInicio y/o fechaFin, ignorar hora)
      if (_fechaInicio != null || _fechaFin != null) {
        _movimientos = _movimientos.where((m) {
          final movFecha = DateTime(m.fecha.year, m.fecha.month, m.fecha.day);
          final desde = _fechaInicio != null ? DateTime(_fechaInicio!.year, _fechaInicio!.month, _fechaInicio!.day) : null;
          final hasta = _fechaFin != null ? DateTime(_fechaFin!.year, _fechaFin!.month, _fechaFin!.day) : null;
          if (desde != null && hasta != null) {
            return (movFecha.isAtSameMomentAs(desde) || movFecha.isAfter(desde)) &&
                   (movFecha.isAtSameMomentAs(hasta) || movFecha.isBefore(hasta));
          } else if (desde != null) {
            return movFecha.isAtSameMomentAs(desde) || movFecha.isAfter(desde);
          } else if (hasta != null) {
            return movFecha.isAtSameMomentAs(hasta) || movFecha.isBefore(hasta);
          }
          return true;
        }).toList();
      }
      // Filtro por nombre de insumo (en memoria)
      if (_busquedaInsumo != null && _busquedaInsumo!.trim().isNotEmpty) {
        final busqueda = _busquedaInsumo!.toLowerCase();
        _movimientos = _movimientos.where((m) =>
          m.insumo?.nombreInsumo.toLowerCase().contains(busqueda) ?? false
        ).toList();
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
    String? busquedaInsumo,
    bool forzar = false,
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

    if (busquedaInsumo != _busquedaInsumo) {
      _busquedaInsumo = busquedaInsumo;
      changed = true;
    }

    if (changed || forzar) {
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
    _busquedaInsumo = null;
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
