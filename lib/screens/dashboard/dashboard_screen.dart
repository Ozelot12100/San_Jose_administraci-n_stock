import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/insumo_provider.dart';
import '../../providers/movimiento_provider.dart';
import '../../providers/alerta_provider.dart';
import '../../providers/proveedor_provider.dart';
import '../../models/insumo.dart';
import '../../services/insumo_service.dart';
import '../../services/movimiento_service.dart';
import '../../services/proveedor_service.dart';
import '../../models/alerta_stock.dart';
import '../../widgets/alerta_stock_card.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int index)? onNavigate;
  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
          final insumoProvider = context.watch<InsumoProvider>();
          final movimientoProvider = context.watch<MovimientoProvider>();
          final alertaProvider = context.watch<AlertaProvider>();
          final proveedorProvider = context.watch<ProveedorProvider>();
          return Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar',
                  onPressed: () async {
                    await insumoProvider.fetchInsumos();
                    await movimientoProvider.fetchMovimientos();
                    await proveedorProvider.fetchProveedores();
                    await alertaProvider.fetchAlertas();
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildWelcomeCard(context),
                    const SizedBox(height: 24),
                    _buildStatsCards(context),
                    const SizedBox(height: 24),
                    _buildQuickAccess(context),
                    const SizedBox(height: 24),
                    _buildRecentActivity(context),
                    const SizedBox(height: 24),
                    _buildLowStockWarning(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final currentTime = DateTime.now();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final nombreUsuario = authProvider.currentUser?.nombreUsuario ?? '';
    
    String saludo;
    if (currentTime.hour < 12) {
      saludo = "¡Buenos días";
    } else if (currentTime.hour < 18) {
      saludo = "¡Buenas tardes";
    } else {
      saludo = "¡Buenas noches";
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.waving_hand_rounded, color: Colors.white, size: 36),
                ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                    nombreUsuario.isNotEmpty
                        ? '$saludo,\n$nombreUsuario!'
                        : '$saludo!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '¡Bienvenido al sistema de inventario de la Clínica San José! Esperamos que tengas un excelente día gestionando tus insumos.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.85),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('EEEE, d MMMM yyyy', 'es').format(currentTime),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget Function(BuildContext) valueBuilder,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Builder(builder: valueBuilder),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.4,
      children: [
        FutureBuilder<int>(
          future: InsumoService().getInsumos().then((list) => list.length),
          builder: (context, snapshot) {
            return _buildStatCard(
              title: 'Total Insumos',
              icon: Icons.inventory,
              color: Colors.blue,
              valueBuilder: (_) => snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : Text(
                      (snapshot.data ?? 0).toString(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
            );
          },
        ),
        FutureBuilder<int>(
          future: MovimientoService().getMovimientos().then((list) {
            final hoy = DateTime.now();
            return list.where((m) =>
              m.fecha.year == hoy.year &&
              m.fecha.month == hoy.month &&
              m.fecha.day == hoy.day
            ).length;
          }),
          builder: (context, snapshot) {
            return _buildStatCard(
              title: 'Movimientos Hoy',
              icon: Icons.swap_horiz,
              color: Colors.orange,
              valueBuilder: (_) => snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : Text(
                      (snapshot.data ?? 0).toString(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
            );
          },
        ),
        FutureBuilder<int>(
          future: InsumoService().getInsumos().then((list) => list.where((i) => i.stock < i.stockMinimo).length),
          builder: (context, snapshot) {
            return _buildStatCard(
              title: 'Alertas Stock',
              icon: Icons.warning,
              color: Colors.red,
              valueBuilder: (_) => snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : Text(
                      (snapshot.data ?? 0).toString(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
            );
          },
        ),
        FutureBuilder<int>(
          future: ProveedorService().getProveedores().then((list) => list.length),
          builder: (context, snapshot) {
            return _buildStatCard(
              title: 'Proveedores',
              icon: Icons.local_shipping,
              color: Colors.purple,
              valueBuilder: (_) => snapshot.connectionState == ConnectionState.waiting
                  ? const Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : Text(
                      (snapshot.data ?? 0).toString(),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accesos Rápidos',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context,
                title: 'Nuevo Insumo',
                icon: Icons.add_circle,
                color: Colors.blue,
                onTap: () {
                  widget.onNavigate?.call(2); // InsumosScreen
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessCard(
                context,
                title: 'Nueva Entrada',
                icon: Icons.input,
                color: Colors.green,
                onTap: () {
                  widget.onNavigate?.call(4); // MovimientosScreen
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickAccessCard(
                context,
                title: 'Nueva Salida',
                icon: Icons.output,
                color: Colors.red,
                onTap: () {
                  widget.onNavigate?.call(4); // MovimientosScreen
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickAccessCard(
                context,
                title: 'Generar Reporte',
                icon: Icons.bar_chart,
                color: Colors.purple,
                onTap: () {
                  widget.onNavigate?.call(5); // ReportesScreen
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Actividad Reciente',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: Consumer<MovimientoProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (provider.error != null) {
                return Center(child: Text('Error: ${provider.error}'));
              }
              
              final movimientos = provider.movimientos;
              if (movimientos.isEmpty) {
                return const Center(child: Text('No hay movimientos recientes'));
              }
              
              // Mostrar solo los últimos 5 movimientos
              final recentMovimientos = movimientos.take(5).toList();
              
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: recentMovimientos.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final movimiento = recentMovimientos[index];
                    return ListTile(
                      leading: Icon(
                        movimiento.tipo == 'entrada' ? Icons.add_circle : Icons.remove_circle,
                        color: movimiento.tipo == 'entrada' ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      title: Text(
                        '${movimiento.tipo == 'entrada' ? 'Entrada' : 'Salida'} de ${movimiento.cantidad} ${movimiento.insumo?.nombreInsumo ?? 'unidades'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${provider.formatFecha(movimiento.fecha)} - Área: ${movimiento.area?.nombreArea ?? 'N/A'}',
                      ),
                      dense: true,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockWarning(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Alertas de Stock',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: FutureBuilder<List<Insumo>>(
            future: InsumoService().getInsumos().then((list) => list.where((i) => i.stock < i.stockMinimo).toList()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error al cargar alertas: ${snapshot.error}'));
              }
              final alertas = snapshot.data ?? [];
              if (alertas.isEmpty) {
                return const Center(child: Text('No hay alertas de stock bajo', style: TextStyle(fontSize: 18)));
              }
              return ListView.builder(
                itemCount: alertas.length,
                itemBuilder: (context, index) {
                  final insumo = alertas[index];
                  final alerta = AlertaStock(
                    insumo: insumo,
                    stockMinimo: insumo.stockMinimo,
                    stockActual: insumo.stock,
                    porcentajeStock: insumo.stockMinimo > 0 ? (insumo.stock / insumo.stockMinimo) * 100 : 0,
                    esUrgente: insumo.stockMinimo > 0 ? (insumo.stock / insumo.stockMinimo) * 100 < 10 : false,
                  );
                  return AlertaStockCard(alerta: alerta);
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 