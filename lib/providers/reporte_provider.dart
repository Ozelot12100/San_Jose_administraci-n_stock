import 'package:flutter/material.dart';
import '../services/reporte_service.dart';

class ReporteProvider extends ChangeNotifier {
  final ReporteService _service = ReporteService();
  ReporteData? _reporteActual;
  List<Map<String, dynamic>>? _datosSimples;
  bool _isLoading = false;
  String? _error;
  String _formatoDescarga = 'pdf'; // 'pdf' o 'excel'
  String? _rutaArchivoDescargado;

  // Getters
  ReporteData? get reporteActual => _reporteActual;
  List<Map<String, dynamic>>? get datosSimples => _datosSimples;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get formatoDescarga => _formatoDescarga;
  String? get rutaArchivoDescargado => _rutaArchivoDescargado;

  // Cambiar formato de descarga
  void cambiarFormato(String formato) {
    _formatoDescarga = formato;
    notifyListeners();
  }

  // Obtener reporte de inventario
  Future<void> obtenerReporteInventario() async {
    _isLoading = true;
    _error = null;
    _reporteActual = null;
    _datosSimples = null;
    notifyListeners();

    try {
      _reporteActual = await _service.getReporteInventario();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener reporte de stock simplificado
  Future<void> obtenerReporteStockSimple() async {
    _isLoading = true;
    _error = null;
    _datosSimples = null;
    notifyListeners();

    try {
      _datosSimples = await _service.getReporteStockSimple();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener reporte de movimientos
  Future<void> obtenerReporteMovimientos(DateTime inicio, DateTime fin) async {
    _isLoading = true;
    _error = null;
    _reporteActual = null;
    _datosSimples = null;
    notifyListeners();

    try {
      _reporteActual = await _service.getReporteMovimientos(inicio, fin);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener reporte de movimientos simplificado
  Future<void> obtenerReporteMovimientosSimple(
    DateTime inicio,
    DateTime fin,
  ) async {
    _isLoading = true;
    _error = null;
    _datosSimples = null;
    notifyListeners();

    try {
      _datosSimples = await _service.getReporteMovimientosSimple(inicio, fin);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener reporte de consumo por áreas
  Future<void> obtenerReporteConsumoAreas(DateTime inicio, DateTime fin) async {
    _isLoading = true;
    _error = null;
    _reporteActual = null;
    _datosSimples = null;
    notifyListeners();

    try {
      _reporteActual = await _service.getReporteConsumoAreas(inicio, fin);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener reporte de consumo por área específica
  Future<void> obtenerReporteConsumoPorArea(
    int areaId,
    DateTime inicio,
    DateTime fin,
  ) async {
    _isLoading = true;
    _error = null;
    _datosSimples = null;
    notifyListeners();

    try {
      _datosSimples = await _service.getReporteConsumoPorAreaEspecifica(
        areaId,
        inicio,
        fin,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener reporte de bajo stock
  Future<void> obtenerReporteBajoStock(int umbral) async {
    _isLoading = true;
    _error = null;
    _reporteActual = null;
    _datosSimples = null;
    notifyListeners();

    try {
      _reporteActual = await _service.getReporteBajoStock(umbral);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Descargar reporte actual
  Future<bool> descargarReporteActual(
    String tipoReporte,
    Map<String, dynamic> params,
  ) async {
    _isLoading = true;
    _error = null;
    _rutaArchivoDescargado = null;
    notifyListeners();

    try {
      if (_formatoDescarga == 'pdf') {
        _rutaArchivoDescargado = await _service.descargarReportePDF(
          tipoReporte,
          params,
        );
      } else if (_formatoDescarga == 'excel') {
        _rutaArchivoDescargado = await _service.descargarReporteExcel(
          tipoReporte,
          params,
        );
      } else if (_formatoDescarga == 'csv') {
        _rutaArchivoDescargado = await _service.descargarReporteCSV(
          tipoReporte,
          params,
        );
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar datos
  void limpiarDatos() {
    _reporteActual = null;
    _datosSimples = null;
    _error = null;
    notifyListeners();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
