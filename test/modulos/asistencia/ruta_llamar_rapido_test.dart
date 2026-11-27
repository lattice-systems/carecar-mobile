import 'package:carecar_mobile/api/modelos/sucursal.dart';
import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/modulos/documentos/datos/repositorio_documentos_fake.dart';
import 'package:carecar_mobile/modulos/documentos/dominio/documento_vehiculo.dart';
import 'package:carecar_mobile/modulos/documentos/dominio/repositorio_documentos.dart';
import 'package:carecar_mobile/modulos/documentos/documentos.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';
import '../../ayudas/app_enrutada.dart';
import '../documentos/ayudas_documentos.dart';

Future<List<Uri>> _montar(
  WidgetTester tester, {
  Aseguradora? aseguradora,
  bool abre = true,
  double letra = 1,
  List<SucursalApi> sucursales = const [],
  bool buscando = false,
  RepositorioDocumentos? documentos,
}) async {
  tester.platformDispatcher.localesTestValue = const [Locale('es')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.platformDispatcher.textScaleFactorTestValue = letra;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final llamadas = <Uri>[];
  final api = ApiFalsa()..sucursalesApi = sucursales;
  final sesion = ControladorSesion(api, AlmacenEnMemoria());
  addTearDown(sesion.dispose);
  await sesion.iniciarSesion(correo: 'a@b.mx', contrasena: 'CareCar2026');
  await tester.pumpWidget(
    AppEnrutadaDePrueba(
      api: api,
      controlador: sesion,
      overrides: [
        // Con `documentos` la aseguradora sale de la poliza del auto, como en
        // la app; sin ellos se fija el resultado para probar solo la pantalla.
        if (documentos == null) ...[
          aseguradoraProvider.overrideWithValue(aseguradora),
          aseguradoraCargandoProvider.overrideWithValue(buscando),
        ] else ...[
          repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
          repositorioDocumentosProvider.overrideWithValue(documentos),
        ],
        abrirLlamadaProvider.overrideWithValue((uri) async {
          llamadas.add(uri);
          return abre;
        }),
      ],
    ),
  );
  await tester.pumpAndSettle();
  enrutadorDe(tester).go(rutaLlamarRapido);
  await tester.pumpAndSettle();
  return llamadas;
}

void main() {
  testWidgets('muestra el 911, la agencia y la aseguradora', (tester) async {
    await _montar(tester);
    expect(find.byType(PantallaLlamarRapido), findsOneWidget);
    expect(find.text('Emergencias'), findsOneWidget);
    expect(find.text('La agencia'), findsOneWidget);
    expect(find.text('Mi aseguradora'), findsOneWidget);
  });

  testWidgets('la agencia se llama al teléfono de la sucursal principal', (
    tester,
  ) async {
    final llamadas = await _montar(
      tester,
      sucursales: const [
        SucursalApi(
          id: 1,
          nombre: 'CareCar León',
          direccion: 'Blvd. Ejemplo 100',
          latitud: 21.125,
          longitud: -101.686,
          telefono: '+52 477 111 2233',
          abiertaAhora: true,
        ),
      ],
    );
    expect(find.text('+52 477 111 2233'), findsOneWidget);
    expect(find.text(Agencia.telefono), findsNothing);

    await tester.tap(find.text('La agencia'));
    await tester.pumpAndSettle();
    expect(llamadas, [Uri.parse('tel:+524771112233')]);
  });

  testWidgets('sin sucursales la agencia usa el teléfono de la config', (
    tester,
  ) async {
    final llamadas = await _montar(tester);
    expect(find.text(Agencia.telefono), findsOneWidget);

    await tester.tap(find.text('La agencia'));
    await tester.pumpAndSettle();
    expect(llamadas, hasLength(1));
    expect(llamadas.single.scheme, 'tel');
  });

  testWidgets('un toque en el 911 abre el marcador con tel:911', (
    tester,
  ) async {
    final llamadas = await _montar(tester);
    await tester.tap(find.text('Emergencias'));
    await tester.pumpAndSettle();
    expect(llamadas, [Uri.parse('tel:911')]);
  });

  testWidgets('sin aseguradora explica como agregarla y no llama', (
    tester,
  ) async {
    final llamadas = await _montar(tester);
    expect(
      find.textContaining('Aún no registras tu aseguradora'),
      findsWidgets,
    );
    await tester.tap(find.text('Mi aseguradora'));
    await tester.pumpAndSettle();
    expect(llamadas, isEmpty);
  });

  testWidgets('con aseguradora registrada la llama por su nombre', (
    tester,
  ) async {
    final llamadas = await _montar(
      tester,
      aseguradora: const Aseguradora(
        nombre: 'Seguros Sol',
        telefono: '800 111 2222',
      ),
    );
    await tester.tap(find.text('Seguros Sol'));
    await tester.pumpAndSettle();
    expect(llamadas, [Uri.parse('tel:8001112222')]);
  });

  testWidgets('si el marcador no abre avisa el numero para marcarlo a mano', (
    tester,
  ) async {
    await _montar(tester, abre: false);
    await tester.tap(find.text('Emergencias'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Marca 911 a mano'), findsOneWidget);
  });

  testWidgets('con letra al 200 % en pantalla chica no desborda', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _montar(tester, letra: 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mientras busca la poliza no dice que falta', (tester) async {
    await _montar(tester, buscando: true);
    expect(find.text('Buscando tu póliza…'), findsOneWidget);
    expect(find.textContaining('Aún no registras'), findsNothing);
  });

  testWidgets('con la poliza guardada en documentos llama a esa aseguradora', (
    tester,
  ) async {
    final llamadas = await _montar(
      tester,
      documentos: RepositorioDocumentosFake(
        documentos: [
          documento(
            vehiculoId: 1,
            tipo: TipoDocumento.poliza,
            aseguradora: 'Seguros Ejemplo',
            telefono: '+52 800 000 1234',
          ),
        ],
      ),
    );
    expect(find.text('Seguros Ejemplo'), findsOneWidget);
    expect(find.textContaining('Aún no registras'), findsNothing);
    await tester.tap(find.text('Seguros Ejemplo'));
    await tester.pumpAndSettle();
    expect(llamadas, [Uri.parse('tel:+528000001234')]);
  });

  testWidgets('sin poliza en documentos sigue pidiendo agregarla', (
    tester,
  ) async {
    await _montar(tester, documentos: RepositorioDocumentosFake());
    expect(
      find.textContaining('Aún no registras tu aseguradora'),
      findsWidgets,
    );
  });
}
