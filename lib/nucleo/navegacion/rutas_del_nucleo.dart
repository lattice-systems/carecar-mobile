import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../pantallas/pantalla_cambiar_contrasena.dart';
import '../../pantallas/pantalla_inicio.dart';
import '../../pantallas/pantalla_login.dart';
import '../../pantallas/pantalla_recuperar_contrasena.dart';
import '../api/proveedores_api.dart';
import '../sesion/proveedores_sesion.dart';
import 'proveedores_navegacion.dart';
import 'rutas.dart';

/// Rutas del nucleo. Montan las pantallas v1 tal cual: reciben por Riverpod
/// lo que antes llegaba por constructor y cambian los `Navigator.push` del
/// flujo por rutas. La guardia de sesion (no estas pantallas) decide el
/// destino tras iniciar sesion, cambiar la contrasena o cerrar sesion.
List<RouteBase> rutasDelNucleo() => [
  GoRoute(
    path: Rutas.inicio,
    name: NombresRuta.inicio,
    builder: (context, state) => Consumer(
      builder: (context, ref, _) => PantallaInicio(
        api: ref.watch(carecarApiProvider),
        controlador: ref.watch(controladorSesionProvider),
        // Al cerrar sesion la guardia lleva al acceso.
        alCerrarSesion: () {},
      ),
    ),
  ),
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
