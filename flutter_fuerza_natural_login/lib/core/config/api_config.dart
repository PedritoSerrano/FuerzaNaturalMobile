class ApiConfig {
  // ─── Change to http://10.0.2.2:8000/api when using Android emulator ──────
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/user';
  static const String miPerfil = '/mi-perfil';

  // Fincas públicas
  static const String fincas = '/fincas';
  static String fincaDetalle(String id) => '/fincas/$id';
  static String fincaResenas(String id) => '/fincas/$id/resenas';

  // Mis reservas (cliente)
  static const String misReservas = '/mis-reservas';
  static String reservaDetalle(String id) => '/mis-reservas/$id';
  static const String crearReserva = '/mis-reservas';

  // Mis valoraciones
  static const String misValoraciones = '/mis-valoraciones';

  // Mis fincas (propietario)
  static const String misFincas = '/mis-fincas';
  static String miFincaDetalle(String id) => '/mis-fincas/$id';
  static String miFincaEstado(String id) => '/mis-fincas/$id/estado';
}
