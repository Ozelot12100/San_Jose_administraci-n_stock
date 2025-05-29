import 'package:flutter/material.dart';
import '../models/alerta_stock.dart';

class AlertaStockCard extends StatelessWidget {
  final AlertaStock alerta;

  const AlertaStockCard({super.key, required this.alerta});

  Color _getColorPorNivel() {
    if (alerta.esUrgente) {
      return Colors.red.shade100;
    } else if (alerta.porcentajeStock < 30) {
      return Colors.orange.shade100;
    }
    return Colors.yellow.shade100;
  }

  IconData _getIconoPorNivel() {
    if (alerta.esUrgente) {
      return Icons.error_outline;
    } else if (alerta.porcentajeStock < 30) {
      return Icons.warning_amber_outlined;
    }
    return Icons.info_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getIconoPorNivel(), 
                  color: alerta.esUrgente ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.tertiary,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    alerta.insumo.nombreInsumo,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Actual: ${alerta.stockActual}',
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                    Text(
                      'Stock Mínimo: ${alerta.stockMinimo}',
                      style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                  ],
                ),
                CircularProgressIndicator(
                  value: alerta.porcentajeStock / 100,
                  backgroundColor: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.2),
                  color: alerta.esUrgente ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Nivel de Stock: ${alerta.porcentajeStock.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                color: alerta.esUrgente ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 