// AVISO: No agregar botones ni lógica para editar o eliminar movimientos. Solo se permite registrar nuevos movimientos.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/movimiento_provider.dart';
import 'movimiento_form.dart';
import '../../providers/auth_provider.dart';

class MovimientosScreen extends StatelessWidget {
  const MovimientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovimientoProvider()..fetchMovimientos(),
      child: Builder(
        builder: (context) {
          final isAdmin = Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin ?? false;
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          return Scaffold(
        appBar: AppBar(
          title: const Text('Movimientos'),
              automaticallyImplyLeading: false,
          actions: [
                if (!isAdmin)
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Cerrar Sesión',
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                  ),
            Builder(
              builder: (context) {
                final provider = context.watch<MovimientoProvider>();
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _mostrarFiltros(context),
                  tooltip: 'Filtrar',
                );
              },
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            final provider = context.watch<MovimientoProvider>();
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.fetchMovimientos(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            // Mostrar filtros activos
            final filtersActive = provider.fechaInicio != null || 
                                  provider.fechaFin != null || 
                                  provider.insumoId != null || 
                                  provider.tipoMovimiento != null;
            
            if (provider.movimientos.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (filtersActive) ...[
                      const Text('No hay movimientos con los filtros seleccionados'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.clearFiltros(),
                        child: const Text('Limpiar Filtros'),
                      ),
                    ] else
                      const Text('No hay movimientos registrados'),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Mostrar barra de filtros activos
                if (filtersActive)
                  Container(
                    color: Colors.blue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _buildFilterText(provider),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => provider.clearFiltros(),
                          tooltip: 'Limpiar filtros',
                        ),
                      ],
                    ),
                  ),
                
                // Lista de movimientos
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.movimientos.length,
                        padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final movimiento = provider.movimientos[index];
                      return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Icon(
                            movimiento.tipo == 'entrada' ? Icons.add_circle : Icons.remove_circle,
                            color: movimiento.tipo == 'entrada' ? Colors.green : Colors.red,
                                size: 32,
                          ),
                          title: Text(
                            'Cantidad: ${movimiento.cantidad} | ${movimiento.insumo?.nombreInsumo ?? 'Insumo #${movimiento.insumoId}'}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                              Text('Fecha: ${provider.formatFecha(movimiento.fecha)}'),
                            ],
                          ),
                                  if (movimiento.area != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.apartment, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text('Área: ${movimiento.area?.nombreArea ?? ''}'),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: movimiento.tipo == 'entrada' ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                              movimiento.tipo == 'entrada' ? 'ENTRADA' : 'SALIDA',
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: _buildFab(context),
          );
        },
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAdmin)
        FloatingActionButton(
          onPressed: () => _registrarMovimiento(context, 'entrada'),
          heroTag: 'fab-entrada',
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
        if (isAdmin) const SizedBox(height: 8),
        FloatingActionButton(
          onPressed: () => _registrarMovimiento(context, 'salida'),
          heroTag: 'fab-salida',
          backgroundColor: Colors.red,
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }

  void _registrarMovimiento(BuildContext context, String tipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChangeNotifierProvider.value(
        value: Provider.of<MovimientoProvider>(context, listen: false),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: MovimientoForm(tipo: tipo),
        ),
      ),
    );
  }

  void _mostrarFiltros(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FiltrosMovimientos(),
    );
  }

  String _buildFilterText(MovimientoProvider provider) {
    final List<String> filters = [];
    
    if (provider.fechaInicio != null && provider.fechaFin != null) {
      final inicio = DateFormat('dd/MM/yyyy').format(provider.fechaInicio!);
      final fin = DateFormat('dd/MM/yyyy').format(provider.fechaFin!);
      filters.add('Fecha: $inicio - $fin');
    }
    
    if (provider.tipoMovimiento != null) {
      filters.add('Tipo: ${provider.tipoMovimiento == 'entrada' ? 'Entradas' : 'Salidas'}');
    }
    
    if (provider.insumoId != null) {
      filters.add('Insumo: #${provider.insumoId}');
    }
    
    return filters.join(' | ');
  }
}

class _FiltrosMovimientos extends StatefulWidget {
  @override
  _FiltrosMovimientosState createState() => _FiltrosMovimientosState();
}

class _FiltrosMovimientosState extends State<_FiltrosMovimientos> {
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  String? _tipoMovimiento;
  
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MovimientoProvider>(context, listen: false);
    _fechaInicio = provider.fechaInicio;
    _fechaFin = provider.fechaFin;
    _tipoMovimiento = provider.tipoMovimiento;
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filtrar Movimientos',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Filtro de tipo
          const Text('Tipo de Movimiento'),
          SegmentedButton<String?>(
            segments: const [
              ButtonSegment(value: null, label: Text('Todos')),
              ButtonSegment(value: 'entrada', label: Text('Entradas')),
              ButtonSegment(value: 'salida', label: Text('Salidas')),
            ],
            selected: {_tipoMovimiento},
            onSelectionChanged: (values) {
              setState(() {
                _tipoMovimiento = values.first;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Filtro de fechas
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Fecha Inicio',
                  value: _fechaInicio,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateField(
                  label: 'Fecha Fin',
                  value: _fechaFin,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Botones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Provider.of<MovimientoProvider>(context, listen: false).clearFiltros();
                  Navigator.pop(context);
                },
                child: const Text('Limpiar Filtros'),
              ),
              FilledButton(
                onPressed: () {
                  Provider.of<MovimientoProvider>(context, listen: false).setFiltros(
                    fechaInicio: _fechaInicio,
                    fechaFin: _fechaFin,
                    tipoMovimiento: _tipoMovimiento,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Aplicar Filtros'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value != null
              ? DateFormat('dd/MM/yyyy').format(value)
              : 'Seleccionar',
        ),
      ),
    );
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _fechaInicio ?? now : _fechaFin ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaInicio = picked;
          // Si la fecha de inicio es posterior a la de fin, actualizar la de fin
          if (_fechaFin != null && _fechaInicio!.isAfter(_fechaFin!)) {
            _fechaFin = _fechaInicio;
          }
        } else {
          _fechaFin = picked;
          // Si la fecha de fin es anterior a la de inicio, actualizar la de inicio
          if (_fechaInicio != null && _fechaFin!.isBefore(_fechaInicio!)) {
            _fechaInicio = _fechaFin;
          }
        }
      });
    }
  }
} 