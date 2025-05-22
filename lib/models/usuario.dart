class Usuario {
  final int id;
  final String nombreUsuario;
  final String rol;
  final bool activo;
  final int? idArea;

  Usuario({
    required this.id,
    required this.nombreUsuario,
    required this.rol,
    required this.activo,
    this.idArea,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombreUsuario: json['nombreUsuario'] as String,
      rol: json['rol'] as String,
      activo: json['activo'] as bool,
      idArea: json['id_area'] is int
          ? json['id_area']
          : (json['id_area'] != null ? int.tryParse(json['id_area'].toString()) : (json['idArea'] is int ? json['idArea'] : int.tryParse(json['idArea']?.toString() ?? ''))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreUsuario': nombreUsuario,
      'rol': rol,
      'activo': activo,
      'id_area': idArea,
    };
  }

  bool get isAdmin => rol == 'admin' || rol == 'administrador';

  @override
  String toString() {
    return 'Usuario(id: $id, nombreUsuario: $nombreUsuario, rol: $rol, activo: $activo)';
  }
} 