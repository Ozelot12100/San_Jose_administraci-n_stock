import 'insumo.dart';
import 'area.dart';

class Movimiento {
  final int id;
  final String tipo;
  final DateTime fecha;
  final int cantidad;
  final int insumoId;
  final int areaId;
  final int usuarioId;
  final Insumo? insumo;
  final Area? area;

  Movimiento({
    required this.id,
    required this.tipo,
    required this.fecha,
    required this.cantidad,
    required this.insumoId,
    required this.areaId,
    required this.usuarioId,
    this.insumo,
    this.area,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    String parseString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      return value.toString();
    }

    return Movimiento(
      id: parseInt(json['id']),
      tipo: parseString(json['tipo_movimiento'] ?? json['tipo']),
      fecha:
          json['fecha'] != null &&
                  json['fecha'] is String &&
                  (json['fecha'] as String).isNotEmpty
              ? DateTime.parse(json['fecha'] as String)
              : DateTime.now(),
      cantidad: parseInt(json['cantidad']),
      insumoId: parseInt(json['id_insumo'] ?? json['insumoId']),
      areaId: parseInt(json['id_area'] ?? json['areaId']),
      usuarioId: parseInt(json['id_usuario'] ?? json['usuarioId']),
      insumo:
          (json['insumo'] is Map<String, dynamic>)
              ? Insumo.fromJson(json['insumo'] as Map<String, dynamic>)
              : Insumo(
                id: 0,
                nombreInsumo: '',
                descripcion: '',
                unidad: '',
                stock: 0,
                stockMinimo: 0,
              ),
      area:
          (json['area'] is Map<String, dynamic>)
              ? Area.fromJson(json['area'] as Map<String, dynamic>)
              : Area(id: 0, nombreArea: '', estado: true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo_movimiento': tipo,
      'fecha': fecha.toIso8601String(),
      'cantidad': cantidad,
      'id_insumo': insumoId,
      'id_area': areaId,
      'id_usuario': usuarioId,
      'insumo': insumo?.toJson(),
      'area': area?.toJson(),
    };
  }

  /// Solo para creación de movimientos: envía solo los campos requeridos por el backend
  Map<String, dynamic> toCreateJson() {
    return {
      'tipo_movimiento': tipo,
      'cantidad': cantidad,
      'id_insumo': insumoId,
      'id_area': areaId,
      'id_usuario': usuarioId,
    };
  }

  @override
  String toString() {
    return 'Movimiento(id: $id, tipo: $tipo, fecha: $fecha, cantidad: $cantidad, insumoId: $insumoId, areaId: $areaId, usuarioId: $usuarioId, insumo: $insumo, area: $area)';
  }
}
