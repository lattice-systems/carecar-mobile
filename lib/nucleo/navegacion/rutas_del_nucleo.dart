import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../pantallas/pantalla_cambiar_contrasena.dart';
import '../../pantallas/pantalla_inicio.dart';
import '../../pantallas/pantalla_login.dart';
import '../../pantallas/pantalla_recuperar_contrasena.dart';
import '../api/proveedores_api.dart';
import '../migracion/interruptor_modulos.dart';
import '../sesion/proveedores_sesion.dart';
import 'proveedores_navegacion.dart';
import 'rutas.dart';

/// Rutas del nucleo. Montan las pantallas v1 tal cual: reciben por Riverpod
/// lo que antes llegaba por constructor y cambian los `Navigator.push` del
/// flujo por rutas. La guardia de sesion (no estas pantallas) decide el
/// destino tras iniciar sesion, cambiar la contrasena o cerrar sesion.
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
  // Las pantallas v1 del acceso solo se montan si su modulo sigue en v1: la
  // v2 sirve los mismos caminos desde `lib/modulos/acceso` y nunca van las dos.
  if (!interruptor.esV2(ModuloMigrable.acceso)) ...[
    GoRoute(
      path: Rutas.acceso,
      name: NombresRuta.acceso,
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => PantallaLogin(
          controlador: ref.watch(controladorSesionProvider),
          alOlvidarContrasena: (correo) =>
              context.push(Rutas.localizacionRecuperar(correo: correo)),
        ),
      ),
    ),
    GoRoute(
      path: Rutas.cambiarContrasena,
      name: NombresRuta.cambiarContrasena,
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => PantallaCambiarContrasena(
          api: ref.watch(carecarApiProvider),
          alCambiar: () =>
              ref.read(contrasenaCambiadaProvider.notifier).marcarCambiada(),
          alCerrarSesion: () =>
              ref.read(controladorSesionProvider).cerrarSesion(),
        ),
      ),
    ),
  ],
  if (!interruptor.esV2(ModuloMigrable.recuperacion)) ...[
    GoRoute(
      path: Rutas.recuperar,
      name: NombresRuta.recuperar,
      builder: (context, state) =>
          _Recuperar(correo: state.uri.queryParameters['correo']),
    ),
    GoRoute(
      path: Rutas.restablecer,
      name: NombresRuta.restablecer,
      builder: (context, state) => _Recuperar(
        correo: state.uri.queryParameters['correo'],
        codigo: state.uri.queryParameters['token'],
      ),
    ),
  ],
];

/// Recuperar y restablecer son la misma pantalla v1; cambia con que llega.
class _Recuperar extends ConsumerWidget {
  const _Recuperar({this.correo, this.codigo});

  final String? correo;
  final String? codigo;

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      PantallaRecuperarContrasena(
        api: ref.watch(carecarApiProvider),
        correoInicial: correo,
        codigoInicial: codigo,
        alVolver: () =>
            context.canPop() ? context.pop() : context.go(Rutas.acceso),
      );
}
