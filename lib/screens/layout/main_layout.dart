import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';
import '../../utils/constants.dart';
import '../dashboard/dashboard_screen.dart';
import '../usuarios/usuarios_screen.dart';
import '../insumos/insumos_screen.dart';
import '../proveedores/proveedores_screen.dart';
import '../movimientos/movimientos_screen.dart';
import '../reportes/reportes_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  
  const MainLayout({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;

  final List<Widget> _screens = [];
  
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _screens.add(DashboardScreen(onNavigate: _onNavigate));
    _screens.add(const UsuariosScreen());
    _screens.add(const InsumosScreen());
    _screens.add(const ProveedoresScreen());
    _screens.add(const MovimientosScreen());
    _screens.add(const ReportesScreen());
  }

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.read<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isAdmin = authProvider.currentUser?.isAdmin ?? false;

    if (!isAdmin) {
      // Si es empleado, solo mostrar pantalla de movimientos (el AppBar y logout lo maneja MovimientosScreen)
      return const MovimientosScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sistema de Inventario – Clínica San José"),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(child: Icon(Icons.person_outline)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "theme",
                child: ListTile(
                  leading: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  title: Text(themeProvider.isDarkMode ? "Modo Claro" : "Modo Oscuro"),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: "logout",
                child: const ListTile(leading: Icon(Icons.logout), title: Text("Cerrar Sesión")),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case "theme":
                  themeProvider.toggleTheme();
                  break;
                case "logout":
                  await authProvider.logout();
                  if (mounted) {
                    AppRoutes.navigateToReplacing(context, AppRoutes.login);
                    AppUtils.showSnackBar(context, "Sesión cerrada correctamente");
                  }
                  break;
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() { _selectedIndex = index; });
          Navigator.pop(context); // Cierra el drawer
        },
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Clínica San José", style: theme.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(authProvider.currentUser?.nombreUsuario ?? "", style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
            ]),
          ),
          const Divider(),
          NavigationDrawerDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: const Text("Dashboard")),
          NavigationDrawerDestination(icon: const Icon(Icons.people_outline), selectedIcon: const Icon(Icons.people), label: const Text("Usuarios (Áreas)")),
          NavigationDrawerDestination(icon: const Icon(Icons.inventory_2_outlined), selectedIcon: const Icon(Icons.inventory_2), label: const Text("Insumos")),
          NavigationDrawerDestination(icon: const Icon(Icons.local_shipping_outlined), selectedIcon: const Icon(Icons.local_shipping), label: const Text("Proveedores")),
          NavigationDrawerDestination(icon: const Icon(Icons.swap_horiz_outlined), selectedIcon: const Icon(Icons.swap_horiz), label: const Text("Movimientos")),
          NavigationDrawerDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: const Text("Reportes")),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _screens),
    );
  }
} 