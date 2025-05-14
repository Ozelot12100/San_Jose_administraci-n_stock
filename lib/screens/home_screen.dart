import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Inventario'),
        actions: [
          // Botón de perfil
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              child: Icon(Icons.person_outline),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'perfil',
                child: const ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Editar Perfil'),
                ),
              ),
              PopupMenuItem(
                value: 'tema',
                child: ListTile(
                  leading: Icon(
                    themeProvider.isDarkMode 
                      ? Icons.light_mode 
                      : Icons.dark_mode,
                  ),
                  title: Text(
                    themeProvider.isDarkMode 
                      ? 'Modo Claro' 
                      : 'Modo Oscuro',
                  ),
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar Sesión'),
                ),
              ),
            ],
            onSelected: (value) async {
              switch (value) {
                case 'perfil':
                  // TODO: Implementar edición de perfil
                  break;
                case 'tema':
                  themeProvider.toggleTheme();
                  break;
                case 'logout':
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                    );
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
          setState(() => _selectedIndex = index);
          Navigator.pop(context); // Cerrar el drawer
        },
        children: [
          // Encabezado del drawer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clínica San José',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  authProvider.currentUser?.usuario ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          
          // Menú de navegación
          NavigationDrawerDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: const Text('Insumos'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.local_shipping_outlined),
            selectedIcon: const Icon(Icons.local_shipping),
            label: const Text('Proveedores'),
          ),
          NavigationDrawerDestination(
            icon: const Icon(Icons.swap_horiz_outlined),
            selectedIcon: const Icon(Icons.swap_horiz),
            label: const Text('Movimientos'),
          ),
          
          // Menú de administración (solo visible para admin)
          if (authProvider.isAdmin) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Administración',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: const Text('Áreas'),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              selectedIcon: const Icon(Icons.admin_panel_settings),
              label: const Text('Usuarios'),
            ),
          ],
          
          const Divider(),
          NavigationDrawerDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: const Text('Reportes'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // TODO: Implementar las diferentes pantallas
          const Center(child: Text('Insumos')),
          const Center(child: Text('Proveedores')),
          const Center(child: Text('Movimientos')),
          if (authProvider.isAdmin) ...[
            const Center(child: Text('Áreas')),
            const Center(child: Text('Usuarios')),
          ],
          const Center(child: Text('Reportes')),
        ],
      ),
    );
  }
} 