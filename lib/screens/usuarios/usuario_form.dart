import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/usuario.dart';
import '../../providers/usuario_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/area.dart';

class UsuarioForm extends StatefulWidget {
  final Usuario? usuario;

  const UsuarioForm({super.key, this.usuario});

  @override
  State<UsuarioForm> createState() => _UsuarioFormState();
}

class _UsuarioFormState extends State<UsuarioForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _contrasenaController = TextEditingController();
  String _rol = 'empleado';
  bool _activo = true;
  int? _idArea;
  List<Area> _areas = [];
  bool _cargandoAreas = true;
  final _nombreUsuarioError = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _cargarAreas();
    if (widget.usuario != null) {
      _nombreController.text = widget.usuario!.nombreUsuario;
      _rol = widget.usuario!.rol;
      _activo = widget.usuario!.activo;
      _idArea = widget.usuario!.idArea;
    }
  }

  Future<void> _cargarAreas() async {
    final api = ApiService();
    try {
      final data = await api.getAreas();
      setState(() {
        _areas = data.map((json) => Area.fromJson(json)).toList();
        _cargandoAreas = false;
      });
    } catch (e) {
      setState(() {
        _cargandoAreas = false;
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UsuarioProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final esEdicion = widget.usuario != null;
    final esAdmin = authProvider.currentUser?.isAdmin ?? false;
    final esUsuarioActual = esEdicion && (authProvider.currentUser?.id == widget.usuario?.id);
    final String? rolOriginal = widget.usuario?.rol;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              esEdicion ? 'Editar Usuario' : 'Nuevo Usuario',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre de Usuario',
                border: OutlineInputBorder(),
                errorText: _nombreUsuarioError.value,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un nombre de usuario';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contrasenaController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (!esUsuarioActual)
            DropdownButtonFormField<String>(
              value: _rol,
              decoration: const InputDecoration(
                labelText: 'Rol',
                border: OutlineInputBorder(),
              ),
              items: const [
                  DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
              ],
              onChanged: (value) {
                if (value != null) {
                    setState(() {
                      _rol = value;
                      if (_rol == 'administrador') {
                        _idArea = null;
                      }
                    });
                }
              },
            ),
            const SizedBox(height: 16),
            if (!esUsuarioActual)
            SwitchListTile(
              title: const Text('Estado'),
              subtitle: Text(_activo ? 'Activo' : 'Inactivo'),
              value: _activo,
              onChanged: (value) => setState(() => _activo = value),
              ),
            const SizedBox(height: 16),
            if (_rol == 'administrador')
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  enabled: false,
                  initialValue: 'Administración',
                  decoration: const InputDecoration(
                    labelText: 'Área',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            if (_rol == 'empleado')
              _cargandoAreas
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<int>(
                      value: _idArea,
                      decoration: const InputDecoration(
                        labelText: 'Área',
                        border: OutlineInputBorder(),
                      ),
                      items: _areas
                          .where((area) => area.nombreArea != 'Administración')
                          .map((area) => DropdownMenuItem(
                                value: area.id,
                                child: Text(area.nombreArea),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _idArea = value);
                      },
                      isExpanded: true,
                      validator: (value) {
                        if (_rol == 'empleado' && value == null) {
                          return 'Selecciona un área';
                        }
                        return null;
                      },
                      hint: const Text('Selecciona un área'),
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
                ElevatedButton(
                  onPressed: () async {
                    _nombreUsuarioError.value = null;
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        if (esEdicion) 'id': widget.usuario!.id,
                        'usuario': _nombreController.text,
                        'rol': _rol,
                        'activo': _activo,
                        if (_rol == 'administrador') 'id_area': 5,
                        if (_rol == 'empleado' && _idArea != null) 'id_area': _idArea is int ? _idArea : int.tryParse(_idArea.toString()),
                        if (_contrasenaController.text.trim().isNotEmpty) 'contrasena': _contrasenaController.text,
                      };

                      bool ok;
                      if (esEdicion) {
                        ok = await provider.updateUsuario(widget.usuario!.id, data);
                      } else {
                        ok = await provider.createUsuario(data);
                      }

                      if (ok && context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(esEdicion ? 'Usuario actualizado correctamente' : 'Usuario creado correctamente'),
                            backgroundColor: esEdicion ? Colors.blue : Colors.green,
                          ),
                        );
                      } else if (context.mounted) {
                        _nombreUsuarioError.value = 'Ese nombre de usuario ya no está disponible. Por favor, elige otro.';
                        setState(() {});
                        if (provider.error != null && !provider.error!.contains('Ya existe un usuario con ese nombre')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
                          );
                        }
                      }
                    }
                  },
                  child: Text(esEdicion ? 'Guardar' : 'Crear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 