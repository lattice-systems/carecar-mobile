/// Traduce los enlaces que abren la app a rutas internas (V2-T01.03).
///
/// Hay tres formas de entrar, todas terminan en la misma ruta:
///
/// | Enlace | Ruta interna |
/// | --- | --- |
/// | `carecar://restablecer?token=123456` | `/restablecer?token=123456` |
/// | `https://<hostEnlacesUniversales>/app/restablecer?token=123456` | `/restablecer?token=123456` |
/// | `/restablecer?token=123456` (interna) | sin cambio |
///
/// En `carecar://` el primer segmento va en el *host* (`carecar://citas/5` es
/// `/citas/5`), asi se escribe igual en notificaciones, widgets y correos.
library;

abstract final class EnlacesApp {
  /// Esquema propio de la app, registrado en Android e iOS.
  static const esquema = 'carecar';

  /// CONFIGURAR: dominio de la agencia para enlaces universales (iOS) y App
  /// Links (Android). Debe coincidir con el `android:host` del
  /// `AndroidManifest.xml` y con los Associated Domains de iOS. Mientras el
  /// dominio no sirva `assetlinks.json` y `apple-app-site-association`, estos
  /// enlaces abren el navegador y no la app (ver
  /// `plan/modulos/T01-arquitectura-v2.md`).
  static const hostEnlacesUniversales = 'carecar.example.com';

  /// Todo enlace universal cuelga de este prefijo; el resto del dominio sigue
  /// siendo del sitio web.
  static const prefijoEnlacesUniversales = '/app';

  /// Devuelve la ruta interna de [enlace], o `null` si ya es interna o no es
  /// un enlace de la app.
  static Uri? aRutaInterna(Uri enlace) {
    if (enlace.scheme == esquema) {
      final camino = '/${enlace.host}${enlace.path}';
      return Uri(
        path: camino.length > 1 && camino.endsWith('/')
            ? camino.substring(0, camino.length - 1)
            : camino,
        query: enlace.hasQuery ? enlace.query : null,
      );
    }
    final esWeb = enlace.scheme == 'https' || enlace.scheme == 'http';
    if (esWeb && enlace.host == hostEnlacesUniversales) {
      var camino = enlace.path;
      if (camino == prefijoEnlacesUniversales) camino = '/';
      if (camino.startsWith('$prefijoEnlacesUniversales/')) {
        camino = camino.substring(prefijoEnlacesUniversales.length);
      }
      return Uri(
        path: camino.isEmpty ? '/' : camino,
        query: enlace.hasQuery ? enlace.query : null,
      );
    }
    return null;
  }
}
