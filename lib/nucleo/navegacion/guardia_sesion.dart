import '../../sesion/controlador_sesion.dart';
import 'rutas.dart';

/// Regla de redireccion por sesion, pura y sin Flutter (V2-T01.03).
///
/// - Primer arranque con la bienvenida sin ver: a la bienvenida, antes de todo.
/// - Con sesion y el candado de huella sin abrir: al desbloqueo (V2-M01.05).
/// - Sin sesion porque la agencia desactivo la cuenta: al aviso que lo explica.
/// - Sin sesion y ruta privada: al acceso, guardando a donde volver (`desde`).
/// - Con sesion y contrasena temporal sin cambiar: al cambio obligatorio.
/// - Con sesion y el aviso de privacidad por aceptar (V2-M22.01), resuelta ya
///   la contrasena: a la puerta del aviso, guardando el destino.
/// - Con sesion y los avisos sin explicar (V2-M06.01), ya resuelto lo de
///   arriba: a la pantalla que los explica antes de pedir el permiso.
/// - Con sesion en acceso o en un paso ya resuelto: a `desde`, o al inicio.
///
/// Devuelve `null` si no hay que redirigir.
String? redirigirPorSesion({
  required Uri destino,
  required EstadoSesion estado,
  required bool contrasenaCambiada,
  bool avisoPorAceptar = false,
  bool bienvenidaPendiente = false,
  bool candadoPorAbrir = false,
  bool avisosPorExplicar = false,
}) {
  final camino = destino.path;

  // V2-M01.02: la bienvenida va antes que todo, incluido el login. Es del
  // primer arranque, no de la cuenta: explica que puede hacer la app a quien
  // todavia no entro.
  if (bienvenidaPendiente) {
    return camino == Rutas.bienvenida ? null : Rutas.bienvenida;
  }
  final desdeEnConsulta = _desdeValido(
    destino.queryParameters[Rutas.parametroDesde],
  );

  if (estado is! Autenticada) {
    // V2-M01.08: una cuenta desactivada no se arregla volviendo a escribir la
    // contrasena, asi que el login no es la salida; se explica y se ofrece
    // contactar a la agencia.
    if (estado is SinSesion && estado.porCuentaDesactivada) {
      return camino == Rutas.cuentaDesactivada ? null : Rutas.cuentaDesactivada;
    }
    if (Rutas.publicas.contains(camino)) return null;
    return Rutas.localizacionAcceso(desde: _destinoParaVolver(destino));
  }

  // V2-M01.05: el candado de huella va antes que todo lo de la cuenta. Con la
  // app cerrada no se decide nada mas, ni cambiar la contrasena.
  if (candadoPorAbrir) {
    return camino == Rutas.desbloquear ? null : Rutas.desbloquear;
  }

  final debeCambiar = estado.debeCambiarContrasena && !contrasenaCambiada;
  if (debeCambiar) {
    if (camino == Rutas.cambiarContrasena) return null;
    return Rutas.localizacionCambiarContrasena(
      desde: camino == Rutas.acceso
          ? desdeEnConsulta
          : _destinoParaVolver(destino),
    );
  }

  if (avisoPorAceptar) {
    if (camino == Rutas.aceptarAviso) return null;
    return Rutas.localizacionAceptarAviso(
      desde: camino == Rutas.acceso || camino == Rutas.cambiarContrasena
          ? desdeEnConsulta
          : _destinoParaVolver(destino),
    );
  }

  // V2-M06.01: lo ultimo de la fila, y con razon. Explicar para que sirven
  // los avisos puede esperar a que la cuenta este en orden; el aviso de
  // privacidad no. Negarlos no estorba: la pantalla deja pasar igual.
  if (avisosPorExplicar) {
    return camino == Rutas.permisoAvisos ? null : Rutas.permisoAvisos;
  }

  if (camino == Rutas.acceso ||
      camino == Rutas.cambiarContrasena ||
      camino == Rutas.aceptarAviso) {
    return desdeEnConsulta ?? Rutas.inicio;
  }
  return null;
}

/// La ruta completa a la que se vuelve; `null` si es el inicio (no aporta).
String? _destinoParaVolver(Uri destino) {
  if (destino.path == Rutas.inicio && !destino.hasQuery) return null;
  return _desdeValido(destino.toString());
}

/// Solo se acepta una ruta interna: empieza con `/`, no es `//host` y no
/// vuelve a las pantallas de acceso (evita bucles y redirecciones abiertas).
String? _desdeValido(String? valor) {
  if (valor == null || !valor.startsWith('/') || valor.startsWith('//')) {
    return null;
  }
  final camino = Uri.tryParse(valor)?.path;
  if (camino == null ||
      camino == Rutas.acceso ||
      camino == Rutas.cambiarContrasena ||
      camino == Rutas.aceptarAviso) {
    return null;
  }
  return valor;
}
