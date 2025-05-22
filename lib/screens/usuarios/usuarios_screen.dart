import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/auth_provider.dart';
import 'usuario_form.dart';
import '../../services/api_service.dart';
import '../../models/area.dart';

class UsuariosScreen extends StatelessWidget {
  const UsuariosScreen({super.key});

  Future<List<Area>> _fetchAreas() async {
    final api = ApiService();
    final data = await api.getAreas();
    return data.map<Area>((json) => Area.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Area>>(
      future: _fetchAreas(),
      builder: (context, snapshot) {
        final areas = snapshot.data ?? [];
    return ChangeNotifierProvider(
      create: (_) => UsuarioProvider()..fetchUsuarios(),
          child: Builder(
            builder: (context) {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final currentUser = authProvider.currentUser;
              return Scaffold(
        appBar: AppBar(
          title: const Text('Usuarios'),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<UsuarioProvider>(
          builder: (context, provider, _) {
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
                      onPressed: () => provider.fetchUsuarios(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (provider.usuarios.isEmpty) {
              return const Center(child: Text('No hay usuarios registrados.'));
            }
            return ListView.builder(
              itemCount: provider.usuarios.length,
                      padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final usuario = provider.usuarios[index];
                        final esAdmin = currentUser?.isAdmin ?? false;
                        final esUsuarioActual = currentUser?.id == usuario.id;
                        String nombreArea = 'Sin área';
                        if (usuario.rol == 'administrador') {
                          nombreArea = 'Administración';
                        } else if (usuario.idArea != null) {
                          final area = areas.firstWhere(
                            (a) => a.id == usuario.idArea,
                            orElse: () => Area(id: 0, nombreArea: 'Sin área', estado: true),
                          );
                          nombreArea = area.nombreArea;
                        }
                return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                            leading: Icon(
                              usuario.activo ? Icons.verified_user : Icons.person_off,
                              color: usuario.activo ? Colors.green : Colors.red,
                              size: 32,
                            ),
                            title: Text(
                              usuario.nombreUsuario,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.badge, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('Rol: ${usuario.rol}'),
                                  ],
                                ),
                                if (usuario.idArea != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.apartment, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text('Área: $nombreArea'),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    const Icon(Icons.circle, size: 12, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(usuario.activo ? 'Activo' : 'Inactivo', style: TextStyle(color: usuario.activo ? Colors.green : Colors.red)),
                                  ],
                                ),
                              ],
                            ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: usuario.activo,
                                  onChanged: (esAdmin && !esUsuarioActual)
                                      ? (value) async {
                                          final success = await Provider.of<UsuarioProvider>(context, listen: false).toggleUsuarioEstado(usuario);
                            if (context.mounted && !success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error al cambiar el estado del usuario'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                                        }
                                      : null,
                        ),
                        IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: esAdmin ? () => _mostrarFormulario(context, Provider.of<UsuarioProvider>(context, listen: false), usuario) : null,
                                  tooltip: 'Editar',
                        ),
                                if (!esUsuarioActual)
                        IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: (esAdmin && !esUsuarioActual)
                                        ? () => _confirmarEliminacion(context, Provider.of<UsuarioProvider>(context, listen: false), usuario)
                                        : null,
                                    tooltip: 'Eliminar',
                        ),
                      ],
                    ),
                            onTap: esAdmin ? () => _mostrarFormulario(context, Provider.of<UsuarioProvider>(context, listen: false), usuario) : null,
                  ),
                );
              },
            );
          },
        ),
                floatingActionButton: (currentUser?.isAdmin ?? false)
                    ? FloatingActionButton(
          onPressed: () => _mostrarFormulario(
            context,
            Provider.of<UsuarioProvider>(context, listen: false),
          ),
          child: const Icon(Icons.add),
                      )
                    : null,
              );
            },
        ),
        );
      },
    );
  }

  void _mostrarFormulario(BuildContext context, UsuarioProvider provider, [Usuario? usuario]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) => ChangeNotifierProvider<UsuarioProvider>.value(
        value: provider,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          ),
          child: UsuarioForm(usuario: usuario),
        ),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, UsuarioProvider provider, Usuario usuario) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    if (currentUser != null && currentUser.id == usuario.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No puedes eliminar tu propio usuario.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar el usuario "${usuario.nombreUsuario}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteUsuario(usuario.id);
              if (context.mounted && provider.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error!)),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
} 