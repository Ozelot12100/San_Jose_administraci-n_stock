import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/reporte_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _rutaDescarga;

  @override
  void initState() {
    super.initState();
    _cargarRutaDescarga();
  }

  Future<void> _cargarRutaDescarga() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rutaDescarga = prefs.getString('ruta_descarga') ?? r'C:\Users\david\Downloads';
    });
  }

  Future<void> _seleccionarRutaDescarga() async {
    final path = await getDirectoryPath();
    if (path != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ruta_descarga', path);
      setState(() {
        _rutaDescarga = path;
      });
    }
  }

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
              _buildRutaDescarga(theme),
              const SizedBox(height: 16),
              _buildReportSelector(theme),
              const SizedBox(height: 24),
              _buildReportParameters(theme),
              const SizedBox(height: 24),
              _buildFormatAndActions(theme),
              const SizedBox(height: 24),
              Expanded(child: _buildReportResults(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRutaDescarga(ThemeData theme) {
    return Card(
      color: theme.brightness == Brightness.dark ? Colors.grey[800] : Colors.blueGrey[50],
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.folder, color: theme.brightness == Brightness.dark ? Colors.blue[200] : Colors.blueGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: _rutaDescarga ?? "C:/Users/david/Downloads",
                child: Text(
                  'Carpeta de descarga: ${_rutaDescarga ?? "C:/Users/david/Downloads"}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _seleccionarRutaDescarga,
              icon: Icon(Icons.folder_open, color: theme.brightness == Brightness.dark ? Colors.white : Colors.white),
              label: const Text('Cambiar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportSelector(ThemeData theme) {
    return Card(
      color: theme.brightness == Brightness.dark ? Colors.grey[900] : null,
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
                color: theme.brightness == Brightness.dark ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
              ),
              dropdownColor: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
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
              style: TextStyle(
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
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
          color: theme.brightness == Brightness.dark ? Colors.grey[900] : null,
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
                    color: theme.brightness == Brightness.dark ? Colors.white : null,
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
          color: theme.brightness == Brightness.dark ? Colors.grey[900] : null,
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
                    color: theme.brightness == Brightness.dark ? Colors.white : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Umbral mínimo de stock',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
                    labelStyle: TextStyle(
                      color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _umbral.toString(),
                  style: TextStyle(
                    color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
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

  Widget _buildFormatAndActions(ThemeData theme) {
    return Consumer<ReporteProvider>(
      builder: (context, provider, _) {
        final buttonStyle = FilledButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        );
        return Card(
          color: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.blueGrey[50],
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
          children: [
                Icon(Icons.file_download, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Formato de descarga:',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    value: provider.formatoDescarga,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                      DropdownMenuItem(value: 'excel', child: Text('Excel')),
                      DropdownMenuItem(value: 'csv', child: Text('CSV')),
                    ],
                    onChanged: (value) {
                      if (value != null) provider.cambiarFormato(value);
                    },
                  ),
                ),
                const SizedBox(width: 24),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Generar Reporte'),
                style: buttonStyle,
                    onPressed: provider.isLoading ? null : () => _generarReporte(provider),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.download),
                    label: Text('Descargar ${provider.formatoDescarga.toUpperCase()}'),
                style: buttonStyle,
                    onPressed: provider.isLoading ? null : () => _descargarReporte(provider),
              ),
            ),
          ],
            ),
          ),
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
                SizedBox(height: 24),
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 16),
                Text('Generando o descargando reporte...'),
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
              'Seleccione los parámetros y genere el reporte para ver la vista previa.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return Expanded(
          child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              color: Colors.blueGrey[25],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  Row(
                    children: [
                      const Icon(Icons.preview, color: Colors.blueGrey),
                      const SizedBox(width: 8),
                      Text(
                        'Vista previa del reporte',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                Text(
                  provider.reporteActual!.titulo,
                  style: theme.textTheme.titleLarge,
                ),
                  const SizedBox(height: 16),
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
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[900]
                              : Colors.white,
                          border: Border.all(
                            color: theme.brightness == Brightness.dark
                                ? Colors.blueGrey[700]!
                                : Colors.blueGrey[100]!,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                    child: DataTable(
                                columns: provider.reporteActual!.datos.first.keys
                              .map(
                                (col) => DataColumn(
                                  label: Text(
                                    col,
                                          style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                            color: theme.brightness == Brightness.dark
                                                ? Colors.white
                                                : Colors.black,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                                rows: provider.reporteActual!.datos
                              .map(
                                (fila) => DataRow(
                                        cells: fila.values
                                          .map(
                                            (valor) => DataCell(
                                                Text(
                                                  valor?.toString() ?? '',
                                                  style: TextStyle(
                                                    color: theme.brightness == Brightness.dark
                                                        ? Colors.white70
                                                        : Colors.black87,
                                                  ),
                                                ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              )
                              .toList(),
                              ),
                            ),
                          ),
                        ),
                    ),
                  ),
              ],
              ),
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
    String tipoReporte = _selectedReport;
    switch (_selectedReport) {
      case 'inventario':
        // Sin parámetros adicionales
        break;
      case 'movimientos':
        params = {
          'inicio': _fechaInicio.toIso8601String().split('T')[0],
          'fin': _fechaFin.toIso8601String().split('T')[0],
        };
        break;
      case 'consumo':
        tipoReporte = 'consumo-areas';
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
      tipoReporte,
      params,
    );

    if (success && mounted) {
      final ruta = provider.rutaArchivoDescargado;
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: isDark ? Colors.greenAccent : Colors.green, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reporte descargado correctamente en:\n$ruta',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.green[50],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
