// AVISO: No agregar botones ni lógica para editar o eliminar movimientos. Solo se permite registrar nuevos movimientos.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/movimiento_provider.dart';
import 'movimiento_form.dart';
import '../../providers/auth_provider.dart';
import '../../providers/insumo_provider.dart';
import '../../providers/proveedor_provider.dart';

class MovimientosScreen extends StatefulWidget {
  const MovimientosScreen({super.key});

  @override
  State<MovimientosScreen> createState() => _MovimientosScreenState();
}

class _MovimientosScreenState extends State<MovimientosScreen> {
  late TextEditingController _busquedaController;
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    final provider = MovimientoProvider();
    _busquedaController = TextEditingController(text: provider.busquedaInsumo ?? '');
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
          final isAdmin = Provider.of<AuthProvider>(context, listen: false).currentUser?.isAdmin ?? false;
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = context.watch<MovimientoProvider>();
    // Filtros activos
    final filtersActive = (provider.busquedaInsumo != null && provider.busquedaInsumo!.isNotEmpty) ||
                          provider.tipoMovimiento != null ||
                          provider.fechaInicio != null;
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
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: () async {
                await Provider.of<MovimientoProvider>(context, listen: false).fetchMovimientos();
                await Provider.of<InsumoProvider>(context, listen: false).fetchInsumos();
                await Provider.of<ProveedorProvider>(context, listen: false).fetchProveedores();
              },
            ),
          ],
        ),
      body: Column(
        children: [
          // Zona de filtros
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Buscador
                    TextField(
                      controller: _busquedaController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre de insumo',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      ),
                      onChanged: (value) {
                        context.read<MovimientoProvider>().setFiltros(busquedaInsumo: value);
                      },
                    ),
                    const SizedBox(height: 12),
                    // Filtro de tipo solo para admin
                    if (isAdmin)
                      Row(
                        children: [
                          const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SegmentedButton<String?>(
                              segments: const [
                                ButtonSegment(value: null, label: Text('Todos')),
                                ButtonSegment(value: 'entrada', label: Text('Entradas')),
                                ButtonSegment(value: 'salida', label: Text('Salidas')),
                              ],
                              selected: {provider.tipoMovimiento},
                              onSelectionChanged: (values) {
                                context.read<MovimientoProvider>().setFiltros(tipoMovimiento: values.first);
                              },
                            ),
                          ),
                        ],
                      ),
                    if (isAdmin) const SizedBox(height: 12),
                    // Filtro de rango de fechas
                    Row(
                      children: [
                        Expanded(
                          child: _FechaFiltroField(
                            label: 'Fecha inicio',
                            value: provider.fechaInicio,
                            onChanged: (date) {
                              context.read<MovimientoProvider>().setFiltros(fechaInicio: date);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FechaFiltroField(
                            label: 'Fecha fin',
                            value: provider.fechaFin,
                            onChanged: (date) {
                              context.read<MovimientoProvider>().setFiltros(fechaFin: date);
                            },
                          ),
                        ),
                        if (provider.fechaInicio != null || provider.fechaFin != null)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            tooltip: 'Limpiar rango',
                            onPressed: () {
                              context.read<MovimientoProvider>().setFiltros(fechaInicio: null, fechaFin: null);
                            },
                          ),
                  ],
                ),
                  ],
                ),
              ),
            ),
          ),
          // Barra de filtros activos
                if (filtersActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: \\${provider.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchMovimientos(),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : provider.movimientos.isEmpty
                  ? Center(
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
                            isAdmin
                              ? const Text('No hay movimientos registrados')
                              : const Text('Aún no has registrado salidas de insumos.'),
                        ],
                      ),
                    )
                  : ListView.builder(
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
                      '${movimiento.insumo?.nombreInsumo ?? 'Insumo #${movimiento.insumoId}'} | Cantidad: ${movimiento.cantidad}',
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
        ),
      floatingActionButton: isAdmin
        ? _buildFab(context)
        : FloatingActionButton(
            onPressed: () => _registrarMovimiento(context, 'salida'),
            heroTag: 'fab-salida',
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove),
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

  void _registrarMovimiento(BuildContext context, String tipo) async {
    final result = await showModalBottomSheet(
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
    if (result == true && mounted) {
      context.read<MovimientoProvider>().fetchMovimientos();
      context.read<InsumoProvider>().fetchInsumos();
      context.read<ProveedorProvider>().fetchProveedores();
      // Detectar tipo de movimiento para el color
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Movimiento registrado correctamente'),
          backgroundColor: tipo == 'entrada' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _buildFilterText(MovimientoProvider provider) {
    final List<String> filters = [];
    
    if (provider.fechaInicio != null) {
      final inicio = DateFormat('dd/MM/yyyy').format(provider.fechaInicio!);
      filters.add('Fecha: $inicio');
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

// Widget para el campo de fecha reutilizable
class _FechaFiltroField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _FechaFiltroField({required this.label, required this.value, required this.onChanged});
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime now = DateTime.now();
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 5),
          lastDate: DateTime(now.year + 1),
        );
        if (picked != null) {
          onChanged(DateTime(picked.year, picked.month, picked.day));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value != null
              ? DateFormat('dd/MM/yyyy').format(value!)
              : 'Seleccionar',
        ),
      ),
    );
  }
}