import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../nucleo/diseno/tema_pista.dart';
import '../../../nucleo/privacidad/pantalla_segura.dart';
import 'pantalla_calendario_documentos.dart';
import 'pantalla_documento_agencia.dart';
import 'pantalla_documentos.dart';

/// Raiz de las rutas de documentos.
const rutaDocumentos = '/documentos';

const rutaCalendarioDocumentos = '$rutaDocumentos/calendario';

/// Documentos del vehiculo: `/documentos/5`.
String rutaDocumentosVehiculo(int vehiculoId) => '$rutaDocumentos/$vehiculoId';

/// Los documentos del cliente van con tema Pista y sin capturas de pantalla
/// (`PantallaSegura`, V2-M22.06).
Widget _segura(BuildContext context, Widget hijo) => PantallaSegura(
  child: Theme(
    data: MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? TemaPista.oscuro()
        : TemaPista.claro(),
    child: hijo,
  ),
);

/// Rutas que el modulo `documentos` entrega al enrutador.
String rutaPdfDocumento(int documentoId) =>
    '$rutaDocumentos/archivo/$documentoId';

final rutasDocumentos = <RouteBase>[
  GoRoute(
    path: '$rutaDocumentos/archivo/:documentoId',
    name: 'archivo-documento',
    builder: (context, state) => _segura(
      context,
      PantallaDocumentoAgencia(
        documentoId:
            int.tryParse(state.pathParameters['documentoId'] ?? '') ?? -1,
      ),
    ),
  ),
  GoRoute(
    path: rutaCalendarioDocumentos,
    name: 'calendario-documentos',
    builder: (context, state) =>
        _segura(context, const PantallaCalendarioDocumentos()),
  ),
  GoRoute(
    path: '$rutaDocumentos/:vehiculoId',
    name: 'documentos-vehiculo',
    builder: (context, state) => _segura(
      context,
      PantallaDocumentos(
        vehiculoId:
            int.tryParse(state.pathParameters['vehiculoId'] ?? '') ?? -1,
      ),
    ),
  ),
];
