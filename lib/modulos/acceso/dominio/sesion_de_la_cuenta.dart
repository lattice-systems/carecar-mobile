/// Una sesion abierta de la cuenta, como la ve la lista · V2-M01.09.
///
/// Dart puro: no sabe de Flutter ni de la red. Devuelve **fechas, nunca
/// texto**: quien decide si se lee «hace 5 minutos» o «el 24 de noviembre» es
/// la pantalla, con el idioma y la zona del celular.
///
/// Las tres fechas y el nombre pueden faltar, y no es un caso raro: una sesion
/// recien abierta nunca se ha refrescado, y las abiertas antes de esta historia
/// no tienen ninguno de los tres datos porque esas columnas no existian.
class SesionDeLaCuenta {
  const SesionDeLaCuenta({
    required this.id,
    required this.expiraEn,
    this.dispositivo,
    this.ultimoUso,
    this.iniciadaEn,
  });

  final int id;

  /// Nombre que mando la app al entrar, si lo mando.
  final String? dispositivo;

  /// Cuando se refresco por ultima vez. Nulo si nunca se ha refrescado.
  final DateTime? ultimoUso;

  /// Cuando empezo la sesion de verdad: se conserva entre refrescos.
  final DateTime? iniciadaEn;

  /// A los 30 dias del **ultimo refresco**, no del inicio: usar la app la
  /// mantiene viva.
  final DateTime expiraEn;

  /// La fecha que la lista muestra como actividad: el ultimo refresco, o el
  /// inicio si todavia no hay ninguno.
  ///
  /// Sin esto, la sesion de este mismo celular -recien abierta y por tanto sin
  /// refrescos- apareceria como si no tuviera actividad. Es nula solo en las
  /// sesiones anteriores a esta historia, y entonces la pantalla no muestra
  /// fecha en vez de inventar una.
  DateTime? get ultimaSenal => ultimoUso ?? iniciadaEn;
}
