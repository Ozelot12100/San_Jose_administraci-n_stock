import 'package:flutter/foundation.dart';
import '../models/alerta_stock.dart';
import '../services/alerta_service.dart';

class AlertaProvider with ChangeNotifier {
  final AlertaService _alertaService = AlertaService();
  List<AlertaStock> _alertas = [];
  bool _isLoading = false;
  String? _error;
  bool _disposed = false;

  List<AlertaStock> get alertas => _alertas;
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

  Future<void> fetchAlertas() async {
    try {
      _isLoading = true;
      _error = null;
      safeNotifyListeners();

      _alertas = await _alertaService.getAlertasStock();
      _isLoading = false;
      safeNotifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      safeNotifyListeners();
    }
  }

  List<AlertaStock> get alertasUrgentes => 
    _alertas.where((alerta) => alerta.esUrgente).toList();

  List<AlertaStock> get alertasNoUrgentes =>
    _alertas.where((alerta) => !alerta.esUrgente).toList();

  int get totalAlertas => _alertas.length;
  int get totalUrgentes => alertasUrgentes.length;
} 