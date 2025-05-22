import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/insumo_provider.dart';
import '../../providers/proveedor_provider.dart';
import '../../models/proveedor.dart';

class InsumosScreen extends StatelessWidget {
  const InsumosScreen({super.key});

  void _mostrarModalInsumo(BuildContext context, {insumo, required bool esEdicion}) {
    final provider = Provider.of<InsumoProvider>(context, listen: false);
    final proveedorProvider = Provider.of<ProveedorProvider>(context, listen: false);
    final formKey = GlobalKey<FormState>();
    final nombreController = TextEditingController(text: insumo?.nombreInsumo ?? '');
    final descripcionController = TextEditingController(text: insumo?.descripcion ?? '');
    final unidadController = TextEditingController(text: insumo?.unidad ?? '');
    final stockController = TextEditingController(text: insumo?.stock?.toString() ?? '');
    final stockMinimoController = TextEditingController(text: insumo?.stockMinimo?.toString() ?? '');
    int? proveedorSeleccionado = insumo?.idProveedor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final proveedores = proveedorProvider.proveedores;
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    esEdicion ? 'Editar Insumo' : 'Nuevo Insumo',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: unidadController,
                    decoration: const InputDecoration(labelText: 'Unidad'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: stockMinimoController,
                    decoration: const InputDecoration(labelText: 'Stock Mínimo'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: proveedorSeleccionado,
                    decoration: const InputDecoration(labelText: 'Proveedor'),
                    items: proveedores.map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(p.nombreProveedor),
                    )).toList(),
                    onChanged: (value) {
                      proveedorSeleccionado = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        icon: esEdicion ? const Icon(Icons.save_as) : const Icon(Icons.add_circle),
                        label: Text(esEdicion ? 'Guardar Cambios' : 'Crear Insumo'),
                        style: FilledButton.styleFrom(
                          backgroundColor: esEdicion ? Colors.blue : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final dataCompleto = {
                            'id': esEdicion ? insumo.id : 0,
                            'nombreInsumo': nombreController.text,
                            'descripcion': descripcionController.text.isNotEmpty ? descripcionController.text : null,
                            'unidad': unidadController.text.isNotEmpty ? unidadController.text : null,
                            'stock': int.tryParse(stockController.text) ?? 0,
                            'stockMinimo': int.tryParse(stockMinimoController.text) ?? 0,
                            'idProveedor': proveedorSeleccionado,
                            'proveedor': proveedorSeleccionado != null
                                ? proveedorProvider.proveedores.firstWhere((p) => p.id == proveedorSeleccionado).toJson()
                                : null,
                          };
                          bool ok;
                          if (esEdicion) {
                            ok = await provider.updateInsumo(insumo.id, dataCompleto);
                          } else {
                            ok = await provider.createInsumo(dataCompleto);
                          }
                          if (ok && context.mounted) {
                            Navigator.pop(context);
                          } else if (provider.error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(provider.error!)),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmarEliminar(BuildContext context, insumo) {
    final provider = Provider.of<InsumoProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Insumo'),
        content: Text('¿Seguro que deseas eliminar "${insumo.nombreInsumo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.deleteInsumo(insumo.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InsumoProvider()..fetchInsumos()),
        ChangeNotifierProvider(create: (_) => ProveedorProvider()..fetchProveedores()),
      ],
      child: Consumer2<InsumoProvider, ProveedorProvider>(
        builder: (context, provider, proveedorProvider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(child: Text('Error: \\${provider.error}'));
          }
          if (provider.insumos.isEmpty) {
            return const Center(child: Text('No hay insumos registrados.'));
          }
          return Stack(
            children: [
              ListView.builder(
                itemCount: provider.insumos.length,
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final insumo = provider.insumos[index];
                  final isLowStock = insumo.stock <= insumo.stockMinimo;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.inventory_2,
                        color: isLowStock ? Colors.red : Colors.blue,
                      ),
                      title: Text(
                        insumo.nombreInsumo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (insumo.descripcion != null && insumo.descripcion!.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.description, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Descripción: ${insumo.descripcion!}'),
                              ],
                            ),
                          if (insumo.unidad != null && insumo.unidad!.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.straighten, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Unidad: ${insumo.unidad!}'),
                              ],
                            ),
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('Stock: ', style: TextStyle(fontWeight: FontWeight.w500)),
                              Text(
                                '${insumo.stock}',
                                style: TextStyle(
                                  color: isLowStock ? Colors.red : Colors.black,
                                  fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                              Text('Mínimo: ${insumo.stockMinimo}'),
                            ],
                          ),
                          if (insumo.idProveedor != null && proveedorProvider.proveedores.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.local_shipping, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('Proveedor: ${proveedorProvider.proveedores.firstWhere((p) => p.id == insumo.idProveedor, orElse: () => Proveedor(id: 0, nombreProveedor: 'Desconocido')).nombreProveedor}'),
                              ],
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLowStock)
                            const Icon(Icons.warning, color: Colors.red),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar',
                            onPressed: () => _confirmarEliminar(context, insumo),
                          ),
                        ],
                      ),
                      onTap: () => _mostrarModalInsumo(context, insumo: insumo, esEdicion: true),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () => _mostrarModalInsumo(context, esEdicion: false),
                  tooltip: 'Agregar Insumo',
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 