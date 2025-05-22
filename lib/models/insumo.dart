import 'proveedor.dart';

class Insumo {
  final int id;
  final String nombreInsumo;
  final String? descripcion;
  final String? unidad;
  final int stock;
  final int stockMinimo;
  final int? idProveedor;
  final Proveedor? proveedor;

  Insumo({
    required this.id,
    required this.nombreInsumo,
    this.descripcion,
    this.unidad,
    required this.stock,
    required this.stockMinimo,
    this.idProveedor,
    this.proveedor,
  });

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombreInsumo: json['nombreInsumo'] ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      unidad: json['unidad']?.toString() ?? '',
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock']?.toString() ?? '') ?? 0,
      stockMinimo: json['stockMinimo'] is int ? json['stockMinimo'] : int.tryParse(json['stockMinimo']?.toString() ?? '') ?? 0,
      idProveedor: json['idProveedor'] is int ? json['idProveedor'] : int.tryParse(json['idProveedor']?.toString() ?? ''),
      proveedor: json['proveedor'] != null ? Proveedor.fromJson(json['proveedor'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreInsumo': nombreInsumo,
      'descripcion': descripcion ?? '',
      'unidad': unidad ?? '',
      'stock': stock,
      'stockMinimo': stockMinimo,
      'idProveedor': idProveedor,
      'proveedor': proveedor?.toJson(),
    };
  }

  @override
  String toString() {
    return 'Insumo(id: $id, nombreInsumo: $nombreInsumo, descripcion: $descripcion, unidad: $unidad, stock: $stock, stockMinimo: $stockMinimo, idProveedor: $idProveedor, proveedor: $proveedor)';
  }
} 