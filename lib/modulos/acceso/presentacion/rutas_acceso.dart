import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import 'pantalla_acceso.dart';
import 'pantalla_bienvenida.dart';
import 'pantalla_cambiar_contrasena.dart';
import 'pantalla_cambiar_correo.dart';
import 'pantalla_cuenta_desactivada.dart';
import 'pantalla_mi_contrasena.dart';
import 'pantalla_mi_perfil.dart';
import 'pantalla_nueva_contrasena.dart';
import 'pantalla_recuperar.dart';
import 'pantalla_sesiones.dart';

/// Mi perfil (V2-M01.06). Se abre desde Ajustes.
///
/// `/perfil` esta tomado por el endpoint del contrato y `/ajustes` es la
/// pantalla v1 que sigue viva, asi que no se usa ninguno de los dos.
const rutaMiPerfil = '/mi-perfil';

/// Cambiar mi correo (V2-M01.07). Se abre desde el perfil.
const rutaCambiarCorreo = '/mi-perfil/correo';

/// Cambiar mi contrasena cuando yo quiera (V2-M01.10). Se abre desde Ajustes.
///
/// Camino propio y no `Rutas.cambiarContrasena`: ese lo sirve hoy la pantalla
/// v1 del cambio **obligatorio**, y son dos pantallas distintas.
const rutaMiContrasena = '/mi-contrasena';

/// Mis sesiones abiertas (V2-M01.09). Se abre desde el perfil.
///
/// Se declara **aqui y no en `Rutas`**: el nucleo guarda solo las rutas que el
/// guardia de sesion necesita conocer, y esta no es una de ellas. Es la misma
/// regla que sigue `rutas_privacidad.dart`.
const rutaSesiones = '/sesiones';

// Mientras la app no tenga el tema v2 global (V2-T01.05), la ruta de un
// modulo v2 se envuelve con el tema Pista.
Widget _conTemaPista(BuildContext context, Widget hijo) => Theme(
  data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
      ? TemaPista.oscuro()
      : TemaPista.claro(),
  child: hijo,
);

/// Inicio de sesion y cambio obligatorio de la contrasena temporal.
///
/// Los caminos y los nombres salen de [Rutas] y [NombresRuta] a proposito, en
/// vez de escribirse aqui: son los mismos que usa el guardia de sesion,
/// `Rutas.localizacionAcceso` y `Rutas.localizacionCambiarContrasena`, asi
/// que el guardia no se entera de que version las sirve.
///
/// Se registran por el interruptor (`ModuloMigrable.acceso`, encendido por
/// defecto desde V2-T01.10). Con el modulo en v1, `rutas_del_nucleo.dart`
/// sirve esos mismos caminos con las pantallas v1; nunca las dos a la vez.
final rutasAcceso = <RouteBase>[
  GoRoute(
    path: Rutas.acceso,
    name: NombresRuta.acceso,
    builder: (context, state) => _conTemaPista(context, const PantallaAcceso()),
  ),
  GoRoute(
    path: Rutas.cambiarContrasena,
    name: NombresRuta.cambiarContrasena,
    builder: (context, state) =>
        _conTemaPista(context, const PantallaCambiarContrasena()),
  ),
];

/// Recuperar y restablecer la contrasena con el enlace del correo (V2-M01.04).
///
/// Es un modulo del interruptor **aparte** (`ModuloMigrable.recuperacion`) y
/// **no esta encendido por defecto**: la pantalla de restablecer espera un
/// enlace que abra la app, y hoy no lo hace.
///
/// - El correo del backend trae `carecar://restablecer-contrasena?token=...`
///   (`RECUPERACION_ENLACE`) y la app entiende `carecar://restablecer?token=...`.
/// - El enlace universal `https://<host>/app/restablecer` apunta a
///   `carecar.example.com`, un marcador: aun no hay dominio con
///   `assetlinks.json` ni `apple-app-site-association`.
/// - El mismo correo trae el codigo de 6 digitos, que solo la pantalla v1
///   sabe recibir.
///
/// Mientras tanto la v1 resuelve la recuperacion con el codigo, y por eso
/// sigue siendo la que se ve. Para encenderla falta: el dominio y los dos
/// archivos de verificacion, que el backend mande un enlace que la app
/// reconozca, y probarlo en un celular con un correo real.
final rutasRecuperacion = <RouteBase>[
  GoRoute(
    path: Rutas.recuperar,
    name: NombresRuta.recuperar,
    builder: (context, state) => _conTemaPista(
      context,
      // El acceso pasa lo que ya se escribio, para no pedirlo otra vez.
      PantallaRecuperar(correoInicial: state.uri.queryParameters['correo']),
    ),
  ),
  GoRoute(
    path: Rutas.restablecer,
    name: NombresRuta.restablecer,
    builder: (context, state) => _conTemaPista(
      context,
      // El token llega por enlace profundo; sin el, la pantalla lo dice.
      PantallaNuevaContrasena(token: state.uri.queryParameters['token']),
    ),
  ),
];

/// Mi perfil y mis sesiones, aparte de [rutasAcceso] · V2-M01.06 y V2-M01.09.
///
/// Va en su propia lista y **se registra siempre**: `/sesiones` no existe en
/// la v1, asi que no choca con nada y no necesita el interruptor.
final rutasSesiones = <RouteBase>[
  GoRoute(
    path: rutaMiPerfil,
    name: 'mi-perfil',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMiPerfil()),
  ),
  GoRoute(
    path: rutaCambiarCorreo,
    name: 'cambiar-correo',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaCambiarCorreo()),
  ),
  // V2-M01.02 y V2-M01.08. Sus caminos viven en `Rutas` y no aqui porque la
  // guardia de sesion tiene que conocerlos, y esta en el nucleo: no puede
  // importar un modulo.
  GoRoute(
    path: Rutas.bienvenida,
    name: 'bienvenida',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaBienvenida()),
  ),
  GoRoute(
    path: Rutas.cuentaDesactivada,
    name: 'cuenta-desactivada',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaCuentaDesactivada()),
  ),
  GoRoute(
    path: rutaMiContrasena,
    name: 'mi-contrasena',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaMiContrasena()),
  ),
  GoRoute(
    path: rutaSesiones,
    name: 'sesiones',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaSesiones()),
  ),
];
