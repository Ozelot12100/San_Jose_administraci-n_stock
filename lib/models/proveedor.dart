class Proveedor {
  final int id;
  final String nombreProveedor;
  final String? telefono;
  final String? direccion;

  Proveedor({
    required this.id,
    required this.nombreProveedor,
    this.telefono,
    this.direccion,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'] as int,
      nombreProveedor: json['nombreProveedor'] as String,
      telefono: json['telefono'] as String?,
      direccion: json['direccion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreProveedor': nombreProveedor,
      'telefono': telefono,
      'direccion': direccion,
    };
  }

  @override
  String toString() {
    return 'Proveedor(id: $id, nombreProveedor: $nombreProveedor, telefono: $telefono, direccion: $direccion)';
  }
} 