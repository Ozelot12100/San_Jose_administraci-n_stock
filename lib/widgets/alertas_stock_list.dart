import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alerta_provider.dart';
import 'alerta_stock_card.dart';

class AlertasStockList extends StatefulWidget {
  const AlertasStockList({super.key});

  @override
  State<AlertasStockList> createState() => _AlertasStockListState();
}

class _AlertasStockListState extends State<AlertasStockList> {
  @override
  void initState() {
    super.initState();
    // Cargar las alertas cuando se inicia el widget
    Future.microtask(() => 
      Provider.of<AlertaProvider>(context, listen: false).fetchAlertas()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AlertaProvider>(
      builder: (context, provider, _) {
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al cargar las alertas:\n${provider.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchAlertas(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.alertas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay alertas de stock bajo',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchAlertas(),
                  child: const Text('Actualizar'),
                ),
              ],
            ),
          );
        }

        // Mostrar primero las alertas urgentes
        final alertasOrdenadas = [
          ...provider.alertasUrgentes,
          ...provider.alertasNoUrgentes,
        ];

        return RefreshIndicator(
          onRefresh: () => provider.fetchAlertas(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alertasOrdenadas.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AlertaStockCard(alerta: alertasOrdenadas[index]),
              );
            },
          ),
        );
      },
    );
  }
} 