import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_acceso_api.dart';
import '../dominio/repositorio_acceso.dart';

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
