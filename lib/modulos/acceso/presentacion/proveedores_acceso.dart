import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../api/excepciones.dart';
import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_acceso_api.dart';
import '../dominio/fallos_acceso.dart';
import '../dominio/perfil_del_cliente.dart';
import '../dominio/repositorio_acceso.dart';
import '../dominio/sesion_de_la_cuenta.dart';

/// Lo que el modulo necesita del servidor.
///
/// En pruebas se sustituye por `RepositorioAccesoFake` con
/// `overrideWithValue`, asi que ninguna prueba de pantalla levanta red.
final repositorioAccesoProvider = Provider<RepositorioAcceso>(
  (ref) => RepositorioAccesoApi(ref.watch(carecarApiProvider)),
  name: 'repositorioAccesoProvider',
);

/// De donde sale «ahora» en el modulo de acceso.
///
/// Existe para que la cuenta regresiva del bloqueo por intentos se pueda
/// probar sin esperar quince minutos.
///
/// **Hay otro igual en `citas/presentacion/`**, y no es por gusto: la regla R1
/// prohibe importar lo interno de otro modulo, y el nucleo todavia no tiene un
/// reloj comun. Su lugar natural seria `lib/nucleo/`, pero subirlo obligaria a
/// tocar la carpeta de `citas` para migrarla, que no es de esta historia.
/// Candidato a una historia del nucleo.
final relojAccesoProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
  name: 'relojAccesoProvider',
);

/// Los datos del cliente que inicio sesion · V2-M01.06.
///
/// De solo lectura, asi que basta un `FutureProvider`: no hay nada que
/// modificar hasta que exista la edicion (V2-M01.07).
final perfilProvider = FutureProvider<PerfilDelCliente>(
  (ref) => ref.watch(repositorioAccesoProvider).perfil(),
  // El reintento es del usuario, con el boton de `EstadoError`.
  retry: (_, _) => null,
  name: 'perfilProvider',
);

/// Las sesiones abiertas de la cuenta · V2-M01.09.
///
/// El `AsyncValue` trae cargando, datos y error. Cerrar una o todas actualiza
/// la lista **sin volver a pedirla**, salvo en el caso que obliga a releerla.
class SesionesNotifier extends AsyncNotifier<List<SesionDeLaCuenta>> {
  @override
  Future<List<SesionDeLaCuenta>> build() =>
      ref.watch(repositorioAccesoProvider).sesiones();

  RepositorioAcceso get _repo => ref.read(repositorioAccesoProvider);

  /// Cierra esa sesion y la quita de la lista.
  ///
  /// Un **404 no se trata como exito**. El backend crea una fila nueva en cada
  /// refresco, asi que el `id` de la lista envejece: si la otra sesion se
  /// refresco entremedias, el `DELETE` no encuentra nada y la sesion **sigue
  /// viva con otro id**. En ese caso se vuelve a leer la lista -para que
  /// aparezca con su id nuevo y el reintento funcione- y se lanza
  /// [SesionYaNoEsta], que la pantalla muestra como «vuelve a intentarlo».
  ///
  /// Cualquier otro fallo sale tal cual y la lista no se toca: sin conexion no
  /// significa «ya no esta», significa que no se sabe.
  Future<void> cerrar(int sesionId) async {
    try {
      await _repo.cerrarUnaSesion(sesionId);
    } on NoEncontrado {
      state = AsyncData(await _repo.sesiones());
      throw const SesionYaNoEsta();
    }
    state = AsyncData([
      for (final s in state.value ?? const <SesionDeLaCuenta>[])
        if (s.id != sesionId) s,
    ]);
  }

  /// Cierra **todas**, incluida la de este celular.
  ///
  /// Quien llame tiene que cerrar la sesion local despues: el access token en
  /// curso sigue valiendo hasta que expire.
  Future<void> cerrarTodas() async {
    await _repo.cerrarTodasLasSesiones();
    state = const AsyncData([]);
  }
}

final sesionesProvider =
    AsyncNotifierProvider<SesionesNotifier, List<SesionDeLaCuenta>>(
      SesionesNotifier.new,
      // El reintento es del usuario, con el boton de `EstadoError`: reintentar
      // solo una lista de sesiones sin que nadie lo pida no aporta nada.
      retry: (_, _) => null,
      name: 'sesionesProvider',
    );

/// Como se abre un `tel:` o un `mailto:` · V2-M01.08.
///
/// Va detras de un proveedor para que la prueba del aviso de cuenta
/// desactivada no toque la plataforma: `launchUrl` no existe en una prueba de
/// widget y la pantalla no deberia saberlo.
final abrirEnlaceProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => launchUrl,
  name: 'abrirEnlaceProvider',
);
