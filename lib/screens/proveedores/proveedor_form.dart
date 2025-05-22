import 'package:flutter/material.dart';
import '../../models/proveedor.dart';
import '../../providers/proveedor_provider.dart';

class ProveedorForm extends StatefulWidget {
  final Proveedor? proveedor;
  final ProveedorProvider provider;

  const ProveedorForm({super.key, this.proveedor, required this.provider});

  @override
  State<ProveedorForm> createState() => _ProveedorFormState();
}

class _ProveedorFormState extends State<ProveedorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.proveedor != null) {
      _nombreController.text = widget.proveedor!.nombreProveedor;
      _telefonoController.text = widget.proveedor!.telefono ?? '';
      _direccionController.text = widget.proveedor!.direccion ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.proveedor != null;
    final provider = widget.provider;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese el nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
                  icon: isEditing ? const Icon(Icons.save_as) : const Icon(Icons.add_circle),
                  label: Text(isEditing ? 'Guardar Cambios' : 'Crear Proveedor'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isEditing ? Colors.blue : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isLoading ? null : _guardar,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final proveedorDataCompleto = {
      'id': widget.proveedor?.id ?? 0,
      'nombreProveedor': _nombreController.text,
      'telefono': _telefonoController.text.isEmpty ? null : _telefonoController.text,
      'direccion': _direccionController.text.isEmpty ? null : _direccionController.text,
    };
    bool success;
    if (widget.proveedor != null) {
      success = await widget.provider.updateProveedor(widget.proveedor!.id, proveedorDataCompleto);
    } else {
      success = await widget.provider.createProveedor(proveedorDataCompleto);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
      } else if (widget.provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.provider.error!)),
        );
      }
      setState(() => _isLoading = false);
    }
  }
} 