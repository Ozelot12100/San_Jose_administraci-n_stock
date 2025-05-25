import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/insumo.dart';
import '../../providers/insumo_provider.dart';
import '../../providers/movimiento_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/area.dart';
import 'package:collection/collection.dart';

class MovimientoForm extends StatefulWidget {
  final String tipo; // 'entrada' o 'salida'

  const MovimientoForm({super.key, required this.tipo});

  @override
  State<MovimientoForm> createState() => _MovimientoFormState();
}

class _MovimientoFormState extends State<MovimientoForm> {
  final _formKey = GlobalKey<FormState>();
  int? _insumoId;
  int _cantidad = 1;
  final TextEditingController _cantidadController = TextEditingController(
    text: '1',
  );
  bool _isLoading = false;
  final GlobalKey<FormFieldState> _insumoFieldKey = GlobalKey<FormFieldState>();
  List<Insumo> _insumosDisponibles = [];

  @override
  void dispose() {
    _cantidadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.isAdmin ?? false;
    final areaId = authProvider.currentUser?.idArea;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InsumoProvider()..fetchInsumos()),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.tipo == 'entrada' ? 'Nueva Entrada' : 'Nueva Salida',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildInsumoSelector(),
              const SizedBox(height: 12),
              _buildCantidadInput(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isLoading ? null : _guardar,
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              widget.tipo == 'entrada'
                                  ? 'Registrar Entrada'
                                  : 'Registrar Salida',
                            ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Area>> _fetchAreas() async {
    final api = ApiService();
    final data = await api.getAreas();
    return data.map<Area>((json) => Area.fromJson(json)).toList();
  }

  Widget _buildInsumoSelector() {
    return Consumer<InsumoProvider>(
      builder: (context, insumoProvider, _) {
        if (insumoProvider.isLoading) {
          return const CircularProgressIndicator();
        }
        if (insumoProvider.error != null) {
          return Text('Error: ${insumoProvider.error}');
        }
        final insumos = insumoProvider.insumos;
        if (insumos.isEmpty) {
          return const Text('No hay insumos disponibles');
        }
        _insumosDisponibles = insumos;
        return DropdownButtonFormField<int>(
          key: _insumoFieldKey,
          decoration: const InputDecoration(
            labelText: 'Insumo',
            border: OutlineInputBorder(),
          ),
          value: _insumoId,
          hint: const Text('Seleccionar insumo'),
          items:
              insumos.map((insumo) {
                return DropdownMenuItem<int>(
                  value: insumo.id,
                  child: Text(
                    '${insumo.nombreInsumo} (Stock: ${insumo.stock})',
                  ),
                );
              }).toList(),
          onChanged: (value) {
            setState(() {
              _insumoId = value;
              _cantidad = 1; // Resetear cantidad al cambiar insumo
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Por favor seleccione un insumo';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildCantidadInput() {
    return TextFormField(
      controller: _cantidadController,
      decoration: const InputDecoration(
        labelText: 'Cantidad',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        final cantidad = int.tryParse(value);
        setState(() {
          _cantidad = (cantidad != null && cantidad > 0) ? cantidad : 1;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese la cantidad';
        }
        final cantidad = int.tryParse(value);
        if (cantidad == null || cantidad <= 0) {
          return 'Ingrese solo números enteros positivos';
        }
        // Para salida, validar stock disponible
        if (widget.tipo == 'salida') {
          if (_insumoId == null) {
            return 'Seleccione un insumo primero';
          }
          final insumo = _insumosDisponibles.firstWhereOrNull(
            (i) => i.id == _insumoId,
          );
          if (insumo == null) {
            return 'Seleccione un insumo válido';
          }
          if (cantidad > insumo.stock) {
            return 'No hay suficiente stock (disponible: ${insumo.stock})';
          }
        }
        return null;
      },
      inputFormatters: [
        // Solo permitir números positivos
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final cantidad = int.tryParse(_cantidadController.text) ?? 1;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = authProvider.currentUser?.isAdmin ?? false;
    final areaId = authProvider.currentUser?.idArea;
    final usuarioId = authProvider.currentUser?.id;

    int? finalAreaId;
    if (isAdmin) {
      finalAreaId = 5; // Siempre Administración
    } else {
      finalAreaId = areaId; // Siempre el área asignada al usuario
    }

    // Validaciones estrictas
    if (widget.tipo != 'entrada' && widget.tipo != 'salida') {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tipo de movimiento inválido.')),
      );
      return;
    }
    if (_insumoId == null || _insumoId == 0) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un insumo válido.')),
      );
      return;
    }
    if (usuarioId == null || usuarioId == 0) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no válido.')),
      );
      return;
    }
    if (finalAreaId == null || finalAreaId == 0) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar un área válida.')),
      );
      return;
    }

    final movimientoData = {
      'id_insumo': _insumoId,
      'id_usuario': usuarioId,
      'id_area': finalAreaId,
      'tipo_movimiento': widget.tipo,
      'cantidad': cantidad,
    };

    final provider = Provider.of<MovimientoProvider>(context, listen: false);
    final success = await provider.createMovimiento(movimientoData);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        try {
          final insumoProvider = Provider.of<InsumoProvider>(
            context,
            listen: false,
          );
          insumoProvider.fetchInsumos();
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.tipo == 'entrada' ? 'Entrada' : 'Salida'} registrada correctamente',
            ),
          ),
        );
      } else if (provider.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(provider.error!)));
      }
      setState(() => _isLoading = false);
    }
  }
}
