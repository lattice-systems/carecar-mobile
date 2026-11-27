import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../sesion/controlador_sesion.dart';
import '../idioma/proveedores_idioma.dart';
import '../sesion/proveedores_sesion.dart';

/// Si la persona prendio el candado.
const claveCandadoActivo = 'biometria_activa';

/// Que biometrias habia cuando lo prendio.
const claveCandadoFirma = 'biometria_firma';

/// En que estado esta el candado de huella o rostro · V2-M01.05.
enum EstadoCandado {
  /// Nadie lo prendio, o no hay biometria en el equipo.
  apagado,

  /// Esta prendido y esta ejecucion de la app todavia no se ha desbloqueado.
  porAbrir,

  /// Ya se identifico en esta ejecucion. No se vuelve a pedir hasta reabrir.
  abierto,
}

/// El candado de huella o rostro.
///
/// **Es un candado local, no otra forma de iniciar sesion.** Los tokens siguen
/// donde estaban (`AlmacenSesion`, el Keystore o el Keychain) y la sesion se
/// renueva igual (V2-M01.11): esto solo decide si la app se abre sin escribir
/// la contrasena.
///
/// Arranca en [EstadoCandado.porAbrir] si las preferencias dicen que esta
/// prendido. Quien lo aplica es la guardia de rutas, y solo con sesion: sin
/// ella no hay nada que proteger y el login manda.
class Candado extends Notifier<EstadoCandado> {
  @override
  EstadoCandado build() {
    // Quien acaba de escribir su contrasena ya se identifico: pedirle la huella
    // encima solo molesta. El login pasa por `Autenticando` y restaurar la
    // sesion guardada no, y eso es justo lo que distingue los dos casos.
    ref.listen(estadoSesionProvider, (previo, nuevo) {
      if (previo is Autenticando && nuevo is Autenticada) abrir();
    });

    final prefs = ref.read(preferenciasProvider);
    final activo = prefs?.getBool(claveCandadoActivo) ?? false;
    return activo ? EstadoCandado.porAbrir : EstadoCandado.apagado;
  }

  /// La firma guardada cuando se prendio, o nulo si no hay.
  String? get firmaGuardada =>
      ref.read(preferenciasProvider)?.getString(claveCandadoFirma);

  /// Lo prende y recuerda que biometrias habia.
  ///
  /// Queda [EstadoCandado.abierto]: la persona acaba de identificarse para
  /// prenderlo, asi que volver a pedirlo en el mismo momento solo molesta.
  Future<void> prender(String firma) async {
    state = EstadoCandado.abierto;
    final prefs = ref.read(preferenciasProvider);
    await prefs?.setBool(claveCandadoActivo, true);
    await prefs?.setString(claveCandadoFirma, firma);
  }

  /// Lo apaga y **olvida la firma**: la proxima vez que se prenda se toma la
  /// de ese momento, que es la que vale.
  Future<void> apagar() async {
    state = EstadoCandado.apagado;
    final prefs = ref.read(preferenciasProvider);
    await prefs?.setBool(claveCandadoActivo, false);
    await prefs?.remove(claveCandadoFirma);
  }

  /// Se identifico: la app se abre y no se vuelve a pedir en esta ejecucion.
  void abrir() => state = EstadoCandado.abierto;
}

final candadoProvider = NotifierProvider<Candado, EstadoCandado>(
  Candado.new,
  name: 'candadoProvider',
);

/// Si la guardia tiene que llevar al desbloqueo.
final candadoPorAbrirProvider = Provider<bool>(
  (ref) => ref.watch(candadoProvider) == EstadoCandado.porAbrir,
  name: 'candadoPorAbrirProvider',
);
