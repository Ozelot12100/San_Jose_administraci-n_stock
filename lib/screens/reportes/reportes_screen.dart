import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/reporte_provider.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  String _selectedReport = 'inventario';
  DateTime _fechaInicio = DateTime.now().subtract(const Duration(days: 30));
  DateTime _fechaFin = DateTime.now();
  int _umbral = 10;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => ReporteProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reportes'),
          automaticallyImplyLeading:
              false, // Para no mostrar flecha de regreso (usa el drawer)
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabecera de bienvenida (opcional, similar a dashboard)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.bar_chart, size: 32, color: Colors.blue),
                      const SizedBox(width: 16),
                      Text(
                        'Genera y descarga reportes',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildReportSelector(theme),
              const SizedBox(height: 24),
              _buildReportParameters(theme),
              const SizedBox(height: 24),
              _buildFormatSelector(theme),
              const SizedBox(height: 24),
              _buildActionButtons(theme),
              const SizedBox(height: 24),
              Expanded(child: _buildReportResults(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Reporte',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              value: _selectedReport,
              items: const [
                DropdownMenuItem(
                  value: 'inventario',
                  child: Text('Inventario Actual'),
                ),
                DropdownMenuItem(
                  value: 'movimientos',
                  child: Text('Movimientos por Período'),
                ),
                DropdownMenuItem(
                  value: 'consumo',
                  child: Text('Consumo por Áreas'),
                ),
                DropdownMenuItem(
                  value: 'bajo-stock',
                  child: Text('Insumos con Bajo Stock'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedReport = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportParameters(ThemeData theme) {
    // Diferentes parámetros según el tipo de reporte
    switch (_selectedReport) {
      case 'inventario':
        return const SizedBox.shrink(); // No necesita parámetros

      case 'movimientos':
      case 'consumo':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parámetros',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Fecha Inicio',
                        value: _fechaInicio,
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateField(
                        label: 'Fecha Fin',
                        value: _fechaFin,
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

      case 'bajo-stock':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parámetros',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Umbral mínimo de stock',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _umbral.toString(),
                  onChanged: (value) {
                    setState(() {
                      _umbral = int.tryParse(value) ?? 10;
                    });
                  },
                ),
              ],
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFormatSelector(ThemeData theme) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Text(
              'Formato de descarga:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: provider.formatoDescarga,
              items: const [
                DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                DropdownMenuItem(value: 'excel', child: Text('Excel')),
                DropdownMenuItem(value: 'csv', child: Text('CSV')),
              ],
              onChanged: (value) {
                if (value != null) {
                  provider.cambiarFormato(value);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, _) {
        final buttonStyle = FilledButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Generar Reporte'),
                style: buttonStyle,
                onPressed:
                    provider.isLoading ? null : () => _generarReporte(provider),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.download),
                label: Text(
                  'Descargar ${provider.formatoDescarga.toUpperCase()}',
                ),
                style: buttonStyle,
                onPressed:
                    provider.isLoading || provider.reporteActual == null
                        ? null
                        : () => _descargarReporte(provider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReportResults(ThemeData theme) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando reporte...'),
              ],
            ),
          );
        }
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => provider.clearError(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        if (provider.reporteActual == null) {
          return const Center(
            child: Text(
              'Seleccione un reporte y genérelo para ver los resultados',
            ),
          );
        }
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.reporteActual!.titulo,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                if (provider.reporteActual!.datos.isEmpty)
                  Center(
                    child: Text(
                      'No hay datos para mostrar en este reporte',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns:
                          provider.reporteActual!.datos.first.keys
                              .map(
                                (col) => DataColumn(
                                  label: Text(
                                    col,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                      rows:
                          provider.reporteActual!.datos
                              .map(
                                (fila) => DataRow(
                                  cells:
                                      fila.values
                                          .map(
                                            (valor) => DataCell(
                                              Text(valor?.toString() ?? ''),
                                            ),
                                          )
                                          .toList(),
                                ),
                              )
                              .toList(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(DateFormat('dd/MM/yyyy').format(value)),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _fechaInicio : _fechaFin,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = picked;
          if (_fechaFin.isBefore(_fechaInicio)) {
            _fechaFin = _fechaInicio;
          }
        } else {
          _fechaFin = picked;
          if (_fechaInicio.isAfter(_fechaFin)) {
            _fechaInicio = _fechaFin;
          }
        }
      });
    }
  }

  Future<void> _generarReporte(ReporteProvider provider) async {
    switch (_selectedReport) {
      case 'inventario':
        await provider.obtenerReporteInventario();
        break;
      case 'movimientos':
        await provider.obtenerReporteMovimientos(_fechaInicio, _fechaFin);
        break;
      case 'consumo':
        await provider.obtenerReporteConsumoAreas(_fechaInicio, _fechaFin);
        break;
      case 'bajo-stock':
        await provider.obtenerReporteBajoStock(_umbral);
        break;
    }
  }

  Future<void> _descargarReporte(ReporteProvider provider) async {
    Map<String, dynamic> params = {};

    switch (_selectedReport) {
      case 'inventario':
        // Sin parámetros adicionales
        break;
      case 'movimientos':
      case 'consumo':
        params = {
          'inicio': _fechaInicio.toIso8601String().split('T')[0],
          'fin': _fechaFin.toIso8601String().split('T')[0],
        };
        break;
      case 'bajo-stock':
        params = {'umbral': _umbral};
        break;
    }

    final success = await provider.descargarReporteActual(
      _selectedReport,
      params,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reporte descargado correctamente')),
      );
    }
  }
}
