import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../../catalogo/catalogo.dart';
import '../datos/repositorio_estreno_api.dart';
import '../dominio/estreno.dart';

/// Repositorio del modulo. En pruebas:
/// `repositorioEstrenoProvider.overrideWithValue(...)`.
final repositorioEstrenoProvider = Provider<RepositorioEstreno>(
  (ref) => RepositorioEstrenoApi(ref.watch(carecarApiProvider)),
  name: 'repositorioEstrenoProvider',
);

/// Primera pagina de Mis solicitudes (V2-M16.04).
final misSolicitudesProvider = FutureProvider.autoDispose<PaginaDeSolicitudes>(
  (ref) => ref.watch(repositorioEstrenoProvider).solicitudes(),
  // El reintento es del usuario (boton de EstadoError), no automatico.
  retry: (_, _) => null,
  name: 'misSolicitudesProvider',
);

/// Hoy, para elegir dias desde mañana. En pruebas se fija.
final relojEstrenoProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
  name: 'relojEstrenoProvider',
);

/// Estimaciones de toma a cuenta que el cliente puede adjuntar (V2-M16.03).
final estimacionesParaAdjuntarProvider =
    FutureProvider.autoDispose<List<Estimacion>>(
      (ref) async =>
          (await ref
                  .watch(repositorioTomaACuentaProvider)
                  .guardadas(tamano: 10))
              .estimaciones,
      // Si falla, la seccion simplemente no aparece: no se insiste de fondo.
      retry: (_, _) => null,
      name: 'estimacionesParaAdjuntarProvider',
    );
