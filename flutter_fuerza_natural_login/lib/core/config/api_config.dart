class ApiConfig {
  // ─── Change to http://10.0.2.2:8000/api when using Android emulator ──────
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/user';

  // Fincas públicas
  static const String fincas = '/fincas';
  static String fincaDetalle(String id) => '/fincas/$id';

  // Mis reservas (cliente)
  static const String misReservas = '/mis-reservas';
  static String reservaDetalle(String id) => '/mis-reservas/$id';
  static const String crearReserva = '/reservas';

  // Mis fincas (propietario)
  static const String misFincas = '/mis-fincas';
  static String miFincaDetalle(String id) => '/mis-fincas/$id';
  static String miFincaEstado(String id) => '/mis-fincas/$id/estado';
}
