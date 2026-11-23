import 'dart:async';
import 'dart:typed_data';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/vehiculo.dart';
import 'package:carecar_mobile/manuales/guardar_pdf.dart';
import 'package:carecar_mobile/manuales/servicio_manuales.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_manual.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

class _Servicio implements ServicioManuales {
  _Servicio(this.alCargar);
  final Future<DocumentoManual> Function(Vehiculo) alCargar;
  Vehiculo? pedido;
  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) {
    pedido = vehiculo;
    return alCargar(vehiculo);
  }
}

final _bytes = Uint8List.fromList([1, 2, 3]);
Future<DocumentoManual> _manual(Vehiculo _) async => DocumentoManual(
  titulo: 'Mazda CX-5 2024',
  identificador: 'agencia:1',
  bytes: _bytes,
);

/// Visor de mentira: el motor nativo de PDF no corre en pruebas.
Widget _visor(
  BuildContext context,
  Uint8List bytes,
  ValueChanged<int> alCargar,
  ValueChanged<int> alCambiarPagina,
) => _VisorFalso(bytes: bytes, alCargar: alCargar);

class _VisorFalso extends StatefulWidget {
  const _VisorFalso({required this.bytes, required this.alCargar});
  final Uint8List bytes;
  final ValueChanged<int> alCargar;
  @override
  State<_VisorFalso> createState() => _VisorFalsoState();
}

class _VisorFalsoState extends State<_VisorFalso> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.alCargar(5));
  }

  @override
  Widget build(BuildContext context) =>
      Text('PDF de ${widget.bytes.length} bytes');
}

Widget _app(
  ServicioManuales servicio, {
  int id = 1,
  Escenario escenario = Escenario.claro,
  Locale? idioma,
  Future<ResultadoGuardado> Function(Uint8List, String)? guardar,
  Future<void> Function(Uint8List, String)? compartir,
}) {
  final pantalla = PantallaManual(vehiculoId: id, fabricaVisor: _visor);
  return ProviderScope(
    overrides: [
      repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
      servicioManualesProvider.overrideWithValue(servicio),
      if (guardar != null) guardarManualProvider.overrideWithValue(guardar),
      if (compartir != null)
        compartirManualProvider.overrideWithValue(compartir),
    ],
    child: idioma == null
        ? conTemaPista(pantalla, escenario: escenario)
        : conTemaPista(pantalla, idioma: idioma),
  );
}

void main() {
  testWidgets('abre el manual del modelo y año del vehículo', (tester) async {
    final servicio = _Servicio(_manual);
    await tester.pumpWidget(_app(servicio));
    await tester.pumpAndSettle();
    expect(servicio.pedido!.modelo, 'CX-5');
    expect(servicio.pedido!.anio, 2024);
    expect(servicio.pedido!.id, 1);
    expect(find.text('Manual'), findsOneWidget);
    expect(find.text('PDF de 3 bytes'), findsOneWidget);
    expect(find.text('Página 1 de 5'), findsOneWidget);
  });

  testWidgets('descargar guarda el PDF con el nombre del manual', (
    tester,
  ) async {
    Uint8List? guardado;
    String? titulo;
    await tester.pumpWidget(
      _app(
        _Servicio(_manual),
        guardar: (b, t) async {
          guardado = b;
          titulo = t;
          return ResultadoGuardado.guardado;
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Descargar manual'));
    await tester.pumpAndSettle();
    expect(guardado, _bytes);
    expect(titulo, 'Mazda CX-5 2024');
    expect(find.text('Manual guardado'), findsOneWidget);
  });

  testWidgets('descargar cancelado no avisa de guardado', (tester) async {
    await tester.pumpWidget(
      _app(
        _Servicio(_manual),
        guardar: (_, _) async => ResultadoGuardado.cancelado,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Descargar manual'));
    await tester.pumpAndSettle();
    expect(find.text('Manual guardado'), findsNothing);
  });

  testWidgets('descargar con fallo avisa y no se rompe', (tester) async {
    await tester.pumpWidget(
      _app(_Servicio(_manual), guardar: (_, _) async => throw Exception('x')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Descargar manual'));
    await tester.pumpAndSettle();
    expect(
      find.text('No pudimos guardar el manual. Inténtalo de nuevo.'),
      findsOneWidget,
    );
  });

  testWidgets('compartir entrega el PDF con su nombre', (tester) async {
    Uint8List? enviado;
    String? nombre;
    await tester.pumpWidget(
      _app(
        _Servicio(_manual),
        compartir: (b, n) async {
          enviado = b;
          nombre = n;
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Compartir manual'));
    await tester.pumpAndSettle();
    expect(enviado, _bytes);
    expect(nombre, 'Manual Mazda CX-5 2024.pdf');
  });

  testWidgets('cargando: etiqueta para el lector de pantalla', (tester) async {
    final espera = Completer<DocumentoManual>();
    await tester.pumpWidget(_app(_Servicio((_) => espera.future)));
    await tester.pump();
    expect(find.bySemanticsLabel('Cargando el manual'), findsOneWidget);
    espera.complete(
      await _manual(const Vehiculo(id: 1, vin: '', modelo: '', anio: 2000)),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('sin manual (ni en la agencia ni en la app): estado vacío', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_Servicio((_) async => throw const FalloManual('no hay'))),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Manual no disponible'), findsOneWidget);
    expect(find.byTooltip('Descargar manual'), findsNothing);
  });

  testWidgets('error inesperado: reintentar vuelve a pedir', (tester) async {
    var llamadas = 0;
    await tester.pumpWidget(
      _app(
        _Servicio((v) async {
          llamadas++;
          if (llamadas == 1) throw Exception('falla');
          return _manual(v);
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    await tester.tap(find.byType(Boton));
    await tester.pumpAndSettle();
    expect(find.text('PDF de 3 bytes'), findsOneWidget);
  });

  testWidgets('sin conexión y sin copia local: estado sin conexión', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_Servicio((_) async => throw const SinConexion())),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<EstadoError>(find.byType(EstadoError)).causa,
      CausaError.sinConexion,
    );
  });

  testWidgets('un vehículo que ya no está cae en vacío', (tester) async {
    await tester.pumpWidget(_app(_Servicio(_manual), id: 99));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
  });

  for (final e in [Escenario.oscuro, Escenario.letraGrande]) {
    testWidgets('se arma sin desbordes en $e', (tester) async {
      await tester.pumpWidget(_app(_Servicio(_manual), escenario: e));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('PDF de 3 bytes'), findsOneWidget);
    });
  }

  testWidgets('habla inglés', (tester) async {
    await tester.pumpWidget(
      _app(_Servicio(_manual), idioma: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Download manual'), findsOneWidget);
  });
}
