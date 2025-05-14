class Usuario {
  final int id;
  final String usuario;
  final String rol;
  final bool activo;

  Usuario({
    required this.id,
    required this.usuario,
    required this.rol,
    required this.activo,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id_usuario'] as int,
      usuario: json['usuario'] as String,
      rol: json['rol'] as String,
      activo: json['activo'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': id,
      'usuario': usuario,
      'rol': rol,
      'activo': activo,
    };
  }

  bool get isAdmin => rol == 'admin';

  @override
  String toString() {
    return 'Usuario(id: $id, usuario: $usuario, rol: $rol, activo: $activo)';
  }
} 