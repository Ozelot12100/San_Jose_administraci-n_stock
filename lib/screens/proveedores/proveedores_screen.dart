import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/proveedor.dart';
import '../../providers/proveedor_provider.dart';
import '../../providers/insumo_provider.dart';
import '../../providers/movimiento_provider.dart';
import 'proveedor_form.dart';

class ProveedoresScreen extends StatelessWidget {
  const ProveedoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usar el provider global
    final proveedorProvider = Provider.of<ProveedorProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
        automaticallyImplyLeading: false, // Para no mostrar flecha de regreso (usa el drawer)
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () async {
              await proveedorProvider.fetchProveedores();
              await Provider.of<InsumoProvider>(context, listen: false).fetchInsumos();
              await Provider.of<MovimientoProvider>(context, listen: false).fetchMovimientos();
            },
          ),
        ],
      ),
      body: Consumer<ProveedorProvider>(
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
                    onPressed: () => provider.fetchProveedores(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (provider.proveedores.isEmpty) {
            return const Center(child: Text('No hay proveedores registrados.'));
          }
          return ListView.builder(
            itemCount: provider.proveedores.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final proveedor = provider.proveedores[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.local_shipping, color: Colors.blue),
                  title: Text(
                    proveedor.nombreProveedor,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (proveedor.direccion != null && proveedor.direccion!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Dirección: ${proveedor.direccion!}'),
                          ],
                        ),
                      if (proveedor.telefono != null && proveedor.telefono!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Teléfono: ${proveedor.telefono!}'),
                          ],
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _mostrarFormulario(context, proveedorProvider, proveedor);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmarEliminacion(context, proveedorProvider, proveedor);
                        },
                      ),
                    ],
                  ),
                  onTap: () => _mostrarFormulario(context, proveedorProvider, proveedor),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(context, proveedorProvider),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, ProveedorProvider provider, [Proveedor? proveedor]) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ProveedorForm(proveedor: proveedor, provider: provider),
      ),
    );
    if (result == true) {
      provider.fetchProveedores();
      Provider.of<InsumoProvider>(context, listen: false).fetchInsumos();
      Provider.of<MovimientoProvider>(context, listen: false).fetchMovimientos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(proveedor == null ? 'Proveedor creado correctamente' : 'Proveedor actualizado correctamente'),
          backgroundColor: proveedor == null ? Colors.green : Colors.blue,
        ),
      );
    }
  }

  void _confirmarEliminacion(BuildContext context, ProveedorProvider provider, Proveedor proveedor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de eliminar el proveedor "${proveedor.nombreProveedor}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteProveedor(proveedor.id);
              if (context.mounted && provider.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.error!)),
                );
              }
              provider.fetchProveedores();
              Provider.of<InsumoProvider>(context, listen: false).fetchInsumos();
              Provider.of<MovimientoProvider>(context, listen: false).fetchMovimientos();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Proveedor eliminado correctamente'), backgroundColor: Colors.red),
              );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
} 