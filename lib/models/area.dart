class Area {
  final int id;
  final String nombreArea;
  final bool estado;

  Area({
    required this.id,
    required this.nombreArea,
    required this.estado,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      nombreArea: json['nombreArea'] ?? '',
      estado: json['estado'] is bool ? json['estado'] : (json['estado']?.toString() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreArea': nombreArea,
      'estado': estado,
    };
  }

  @override
  String toString() {
    return 'Area(id: $id, nombreArea: $nombreArea, estado: $estado)';
  }
} 