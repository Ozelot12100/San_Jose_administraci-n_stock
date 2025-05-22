import 'insumo.dart';

class AlertaStock {
  final Insumo insumo;
  final int stockMinimo;
  final int stockActual;
  final double porcentajeStock;
  final bool esUrgente; // true si el stock está por debajo del 10%

  AlertaStock({
    required this.insumo,
    required this.stockMinimo,
    required this.stockActual,
    required this.porcentajeStock,
    required this.esUrgente,
  });

  factory AlertaStock.fromInsumo(Insumo insumo, {int stockMinimoDefault = 10}) {
    final porcentaje = (insumo.stock / stockMinimoDefault) * 100;
    return AlertaStock(
      insumo: insumo,
      stockMinimo: stockMinimoDefault,
      stockActual: insumo.stock,
      porcentajeStock: porcentaje,
      esUrgente: porcentaje < 10,
    );
  }
} 