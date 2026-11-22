import '../../sesion/controlador_sesion.dart';
import 'rutas.dart';

/// Regla de redireccion por sesion, pura y sin Flutter (V2-T01.03).
///
/// - Sin sesion y ruta privada: al acceso, guardando a donde volver (`desde`).
/// - Con sesion y contrasena temporal sin cambiar: al cambio obligatorio.
/// - Con sesion en acceso o en cambio ya resuelto: a `desde`, o al inicio.
///
/// Devuelve `null` si no hay que redirigir.
String? redirigirPorSesion({
  required Uri destino,
  required EstadoSesion estado,
  required bool contrasenaCambiada,
}) {
  final camino = destino.path;
  final desdeEnConsulta = _desdeValido(
    destino.queryParameters[Rutas.parametroDesde],
  );

  if (estado is! Autenticada) {
    if (Rutas.publicas.contains(camino)) return null;
    return Rutas.localizacionAcceso(desde: _destinoParaVolver(destino));
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

  if (camino == Rutas.acceso || camino == Rutas.cambiarContrasena) {
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
      camino == Rutas.cambiarContrasena) {
    return null;
  }
  return valor;
}
