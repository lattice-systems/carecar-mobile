import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/privacidad/pantalla_segura.dart';
import 'pantalla_datos_fiscales.dart';
import 'pantalla_perfil_fiscal.dart';

/// Mis datos fiscales: `/datos-fiscales`.
const rutaDatosFiscales = '/datos-fiscales';

/// Alta de datos fiscales: `/datos-fiscales/nuevo`.
const rutaPerfilFiscalNuevo = '$rutaDatosFiscales/nuevo';

/// Edicion de un perfil fiscal: `/datos-fiscales/3`.
String rutaPerfilFiscal(int perfilId) => '$rutaDatosFiscales/$perfilId';

/// Las pantallas de pagos y facturas muestran datos fiscales del cliente: van
/// con tema Pista y sin capturas de pantalla (`PantallaSegura`, V2-M22.06).
Widget _segura(BuildContext context, Widget hijo) => PantallaSegura(
  child: Theme(
    data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? TemaPista.oscuro()
        : TemaPista.claro(),
    child: hijo,
  ),
);

/// Rutas que el modulo `pagos` entrega al enrutador.
final rutasPagos = <RouteBase>[
  GoRoute(
    path: rutaDatosFiscales,
    name: 'datos-fiscales',
    builder: (context, state) =>
        _segura(context, const PantallaDatosFiscales()),
    routes: [
      GoRoute(
        path: 'nuevo',
        name: 'datos-fiscales-nuevo',
        builder: (context, state) =>
            _segura(context, const PantallaPerfilFiscal()),
      ),
      GoRoute(
        path: ':perfilId',
        name: 'datos-fiscales-editar',
        builder: (context, state) => _segura(
          context,
          PantallaPerfilFiscal(
            perfilId:
                int.tryParse(state.pathParameters['perfilId'] ?? '') ?? -1,
          ),
        ),
      ),
    ],
  ),
];
