import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import 'pantalla_acceso.dart';
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

/// Rutas que el modulo `acceso` entrega al enrutador.
///
/// Los caminos y los nombres salen de [Rutas] y [NombresRuta] a proposito, en
/// vez de escribirse aqui: son los mismos que usa el guardia de sesion,
/// `Rutas.localizacionAcceso` y `Rutas.localizacionCambiarContrasena`, asi
/// que al encender el modulo nada mas tiene que cambiar.
///
/// ## Todavia no esta registrada
///
/// `registro_de_rutas.dart` **no** las incluye, y `ModuloMigrable` no tiene
/// valor `acceso`: hoy `/acceso` y `/cambiar-contrasena` los sirven las
/// pantallas v1 desde `rutas_del_nucleo.dart`.
///
/// **V2-M01.03 y V2-M01.04 cerraron dos de los tres bloqueos**: el cambio
/// obligatorio y la recuperacion por enlace ya existen en v2, asi que ninguna
/// de las cuatro pantallas del flujo salta a una vieja ni deja un boton
/// muerto. **Queda uno solo:**
///
/// - Actualizar las **trece pruebas** que hoy comprueban el destino de la
///   redireccion por el widget (`find.byType(PantallaLogin)`) y no por la
///   ruta. `AppEnrutadaDePrueba` usa `InterruptorModulos.todoV2` por omision,
///   asi que agregar el valor al enum las pone rojas de golpe, en los modulos
///   de otras cuatro personas. Es mecanico, pero toca codigo ajeno y merece
///   su propia historia.
///
/// Y al encenderlas, `rutas_del_nucleo.dart` tiene que dejar de registrar sus
/// cuatro rutas de acceso cuando el modulo este en v2, o habria dos rutas con
/// el mismo camino. Puede hacerlo con el enum, sin importar este modulo, asi que la
/// regla R2 se respeta.
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
/// Va en su propia lista **y si se registra hoy**. Las otras cuatro esperan a
/// que el modulo se encienda porque sus caminos ya los sirven pantallas v1 y
/// habria dos rutas iguales. Esta no: `/sesiones` no existe en la v1, asi que
/// no choca con nada y no necesita el interruptor ni tocar las trece pruebas
/// ajenas. Sin esto la pantalla existiria y nadie podria abrirla.
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
  // V2-M01.08. El camino vive en `Rutas` y no aqui porque la guardia de sesion
  // tiene que conocerlo, y esta en el nucleo: no puede importar un modulo.
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
