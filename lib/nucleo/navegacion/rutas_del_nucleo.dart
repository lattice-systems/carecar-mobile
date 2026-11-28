import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../pantallas/pantalla_inicio.dart';
import '../api/proveedores_api.dart';
import '../migracion/interruptor_modulos.dart';
import '../sesion/proveedores_sesion.dart';
import 'rutas.dart';

/// Rutas del nucleo: el inicio. Monta la pantalla v1 que lo contiene y le da
/// por Riverpod lo que antes llegaba por constructor. El acceso y la
/// recuperacion viven en `lib/modulos/acceso` desde V2-T02.27. La guardia de
/// sesion decide el destino tras iniciar sesion o cerrarla.
///
/// [destinosV2] dice a que ruta v2 lleva cada tarjeta del menu; solo se usa
/// para los modulos que [interruptor] tiene en v2 (V2-T01.05).
List<RouteBase> rutasDelNucleo({
  InterruptorModulos interruptor = InterruptorModulos.porDefecto,
  Map<ModuloMigrable, String> destinosV2 = const {},
}) => [
  GoRoute(
    path: Rutas.inicio,
    name: NombresRuta.inicio,
    builder: (context, state) => Consumer(
      builder: (context, ref, _) => PantallaInicio(
        api: ref.watch(carecarApiProvider),
        controlador: ref.watch(controladorSesionProvider),
        // Al cerrar sesion la guardia lleva al acceso.
        alCerrarSesion: () {},
        abrirEnV2: {
          for (final e in destinosV2.entries)
            if (interruptor.esV2(e.key)) e.key: () => context.push(e.value),
        },
      ),
    ),
  ),
];
