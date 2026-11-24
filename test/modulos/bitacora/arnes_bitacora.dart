import 'package:carecar_mobile/modulos/bitacora/datos/repositorio_bitacora_fake.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/gasto.dart';
import 'package:carecar_mobile/modulos/bitacora/dominio/lector_ticket.dart';
import 'package:carecar_mobile/modulos/bitacora/presentacion/proveedores_bitacora.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

/// «Hoy» de todas las pruebas de la bitácora.
final hoyDePrueba = DateTime(2026, 11, 23);

Gasto carga(
  int id,
  DateTime fecha,
  int km,
  double litros,
  double monto, {
  int vehiculoId = 4,
}) => Gasto(
  id: id,
  vehiculoId: vehiculoId,
  tipo: TipoGasto.gasolina,
  monto: monto,
  litros: litros,
  km: km,
  fecha: fecha,
);

Gasto otroGasto(
  int id,
  DateTime fecha,
  double monto, {
  TipoGasto tipo = TipoGasto.lavado,
  String? descripcion,
  int vehiculoId = 4,
}) => Gasto(
  id: id,
  vehiculoId: vehiculoId,
  tipo: tipo,
  monto: monto,
  fecha: fecha,
  descripcion: descripcion,
);

/// Dos cargas que dan 10 km/l y 2.10 \$/km, más un lavado de noviembre.
List<Gasto> gastosDePrueba() => [
  carga(1, DateTime(2026, 10, 1), 10000, 40, 800),
  carga(2, DateTime(2026, 10, 15), 10400, 40, 840),
  otroGasto(3, DateTime(2026, 11, 5), 80),
];

/// Cuerpo de la prueba con la pantalla alta (para no desplazar) y los
/// proveedores sustituidos.
Widget aplicacion(
  Widget pantalla, {
  required RepositorioBitacoraFake repo,
  LectorTicketFake? lector,
  CompartirArchivo? compartir,
  Escenario escenario = Escenario.claro,
}) => ProviderScope(
  overrides: [
    repositorioBitacoraProvider.overrideWithValue(repo),
    relojBitacoraProvider.overrideWithValue(() => hoyDePrueba),
    if (lector != null) lectorTicketProvider.overrideWithValue(lector),
    if (compartir != null)
      compartirBitacoraProvider.overrideWithValue(compartir),
  ],
  child: conTemaPista(pantalla, escenario: escenario),
);

void prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) =>
    testWidgets(descripcion, (tester) async {
      tester.view.physicalSize = const Size(800, 4000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await cuerpo(tester);
    });
