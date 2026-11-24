import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/navegacion/rutas.dart';
import 'pantalla_acceso.dart';

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
/// El camino y el nombre salen de [Rutas] y [NombresRuta] a proposito, en vez
/// de escribirse aqui: son los mismos que usa el guardia de sesion y
/// `Rutas.localizacionAcceso`, asi que al encender el modulo nada mas tiene
/// que cambiar.
///
/// ## Todavia no esta registrada
///
/// `registro_de_rutas.dart` **no** la incluye, y `ModuloMigrable` no tiene
/// valor `acceso`: hoy `/acceso` lo sirve la pantalla v1 desde
/// `rutas_del_nucleo.dart`. Encenderla pide tres cosas que no son de
/// V2-M01.01:
///
/// 1. **V2-M01.04**, la recuperacion en v2. Sin ella, «¿Olvidaste tu
///    contraseña?» no lleva a ningun lado y el cliente **pierde** algo que la
///    v1 si le da.
/// 2. **V2-M01.03**, el cambio obligatorio en v2. Si no, quien entra con
///    contrasena temporal pasa de una pantalla nueva a una vieja, porque el
///    guardia lo manda a `Rutas.cambiarContrasena`, que sigue en v1.
/// 3. Actualizar las **trece pruebas** que hoy comprueban el destino de la
///    redireccion por el widget (`find.byType(PantallaLogin)`) y no por la
///    ruta. `AppEnrutadaDePrueba` usa `InterruptorModulos.todoV2` por
///    omision, asi que agregar el valor al enum las pone rojas de golpe, en
///    los modulos de otras cuatro personas.
///
/// Y al encenderla, `rutas_del_nucleo.dart` tiene que dejar de registrar su
/// `/acceso` cuando el modulo este en v2, o habria dos rutas con el mismo
/// camino. Puede hacerlo con el enum, sin importar este modulo, asi que la
/// regla R2 se respeta.
final rutasAcceso = <RouteBase>[
  GoRoute(
    path: Rutas.acceso,
    name: NombresRuta.acceso,
    builder: (context, state) => _conTemaPista(context, const PantallaAcceso()),
  ),
];
