import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import 'pantalla_acceso.dart';
import 'pantalla_bienvenida.dart';
import 'pantalla_cambiar_contrasena.dart';
import 'pantalla_cambiar_correo.dart';
import 'pantalla_cuenta_desactivada.dart';
import 'pantalla_desbloqueo.dart';
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
/// Desde V2-T02.27 el login v1 ya no existe: se registran siempre.
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

/// Recuperar y restablecer la contrasena · V2-M01.04 y V2-T02.27.
///
/// El correo de recuperacion trae un codigo de 6 digitos y un enlace. Hoy se
/// usa el codigo: `/recuperar` lo pide y lleva a `/restablecer?correo=...`,
/// donde se escribe junto con la contrasena nueva. El enlace
/// (`carecar://restablecer?token=...`) cae en la misma pantalla sin pedir
/// codigo; para que abra la app desde el correo falta el dominio con enlaces
/// universales (`assetlinks.json` y `apple-app-site-association`).
///
/// Desde V2-T02.27 ya no hay version v1: se registran siempre.
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
      // Desde «Recupera tu contraseña» llega el correo y se pide el codigo;
      // por el enlace del correo llega el token.
      PantallaNuevaContrasena(
        token: state.uri.queryParameters['token'],
        correo: state.uri.queryParameters['correo'],
      ),
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
    path: Rutas.desbloquear,
    name: 'desbloquear',
    builder: (context, state) =>
        _conTemaPista(context, const PantallaDesbloqueo()),
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
