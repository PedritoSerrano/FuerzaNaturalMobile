enum UserRole {
  admin,
  cliente,
  propietario,
}

class UserModel {
  final String id;
  final String email;
  final String nombre;
  final String? apellidos;
  final String? telefono;
  final String? avatar;
  final String? ubicacion;
  final UserRole rol;
  final bool activo;
  final int reservasRealizadas;
  final int fincasCount;
  final int valoracionesCount;
  final DateTime fechaRegistro;
  final DateTime? ultimoAcceso;

  const UserModel({
    required this.id,
    required this.email,
    required this.nombre,
    this.apellidos,
    this.telefono,
    this.avatar,
    this.ubicacion,
    required this.rol,
    this.activo = true,
    this.reservasRealizadas = 0,
    this.fincasCount = 0,
    this.valoracionesCount = 0,
    required this.fechaRegistro,
    this.ultimoAcceso,
  });

  String get nombreCompleto => apellidos != null ? '$nombre $apellidos' : nombre;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // id puede ser int o String según el backend
    final rawId = json['id'];
    final id = rawId?.toString() ?? '0';

    // nombre: campo propio del proyecto o 'name' estándar de Laravel
    final nombre = (json['nombre'] ?? json['name'] ?? 'Usuario') as String;

    // fecha de registro: campo propio o 'created_at' de Laravel
    final fechaRaw = json['fechaRegistro'] ?? json['created_at'];
    final fechaRegistro = fechaRaw != null
        ? DateTime.tryParse(fechaRaw as String) ?? DateTime.now()
        : DateTime.now();

    // último acceso: campo propio o 'updated_at'
    final ultimoRaw = json['ultimoAcceso'] ?? json['updated_at'];

    // rol: soporta 'admin', 'cliente', 'propietario'
    final rolStr = (json['rol'] ?? json['role'] ?? 'cliente') as String;

    return UserModel(
      id: id,
      email: json['email'] as String,
      nombre: nombre,
      apellidos: json['apellidos'] as String?,
      telefono: json['telefono'] as String?,
      avatar: json['avatar'] as String?,
      ubicacion: json['ubicacion'] as String?,
      rol: UserRole.values.firstWhere(
        (e) => e.name == rolStr,
        orElse: () => UserRole.cliente,
      ),
      activo: json['activo'] as bool? ?? true,
      reservasRealizadas: (json['reservas_count'] ?? json['reservasRealizadas']) as int? ?? 0,
      fincasCount: (json['fincas_count'] ?? json['fincasCount'] ?? json['fincasFavoritas']) as int? ?? 0,
      valoracionesCount: (json['valoraciones_count'] ?? json['valoracionesCount']) as int? ?? 0,
      fechaRegistro: fechaRegistro,
      ultimoAcceso: ultimoRaw != null
          ? DateTime.tryParse(ultimoRaw as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellidos': apellidos,
      'telefono': telefono,
      'avatar': avatar,
      'rol': rol.toString().split('.').last,
      'activo': activo,
      'ubicacion': ubicacion,
      'reservasRealizadas': reservasRealizadas,
      'fincasCount': fincasCount,
      'valoracionesCount': valoracionesCount,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nombre,
    String? apellidos,
    String? telefono,
    String? avatar,
    String? ubicacion,
    UserRole? rol,
    bool? activo,
    int? reservasRealizadas,
    int? fincasCount,
    int? valoracionesCount,
    DateTime? fechaRegistro,
    DateTime? ultimoAcceso,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      telefono: telefono ?? this.telefono,
      avatar: avatar ?? this.avatar,
      ubicacion: ubicacion ?? this.ubicacion,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
      reservasRealizadas: reservasRealizadas ?? this.reservasRealizadas,
      fincasCount: fincasCount ?? this.fincasCount,
      valoracionesCount: valoracionesCount ?? this.valoracionesCount,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }
}
