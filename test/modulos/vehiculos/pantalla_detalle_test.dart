import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/asistente/asistente.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/repositorio_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/dominio/vehiculo_garaje.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/pantalla_detalle_vehiculo.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/grupo_lista.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/tema_pista.dart';

class _Repo implements RepositorioGaraje {
  _Repo(this.alPedir);
  final Future<List<VehiculoGaraje>> Function() alPedir;
  @override
  Future<List<VehiculoGaraje>> vehiculos() => alPedir();
}

Widget _app(
  RepositorioGaraje repo, {
  int id = 1,
  Escenario escenario = Escenario.claro,
  Locale? idioma,
}) => ProviderScope(
  overrides: [repositorioGarajeProvider.overrideWithValue(repo)],
  child: idioma == null
      ? conTemaPista(
          PantallaDetalleVehiculo(vehiculoId: id),
          escenario: escenario,
        )
      : conTemaPista(PantallaDetalleVehiculo(vehiculoId: id), idioma: idioma),
);

/// Como `testWidgets` pero con una pantalla alta: el detalle es una lista
/// perezosa y lo de abajo no se construye si no cabe.
void _prueba(String descripcion, Future<void> Function(WidgetTester) cuerpo) {
  testWidgets(descripcion, (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await cuerpo(tester);
  });
}

void main() {
  _prueba('muestra vin, placas, anio, color, version y km', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    // El auto es el titulo del encabezado; las placas, su subtitulo.
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
    expect(find.text('Placas ABC-123'), findsOneWidget);
    expect(find.text('JM3KFBDM0R0123456'), findsOneWidget);
    expect(find.text('ABC-123'), findsOneWidget);
    expect(find.text('Rojo'), findsOneWidget);
    expect(find.text('Signature'), findsOneWidget);
    expect(find.text('12,500 km'), findsOneWidget);
  });

  _prueba('el km dice cuando lo actualizo el taller', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    expect(find.textContaining('Actualizado por el taller el'), findsOneWidget);
    expect(find.textContaining('2026'), findsOneWidget);
  });

  _prueba('sin fecha de cierre lo dice en vez de inventarla', (tester) async {
    final repo = RepositorioGarajeFake(
      datos: const [
        VehiculoGaraje(
          id: 1,
          modelo: 'CX-5',
          anio: 2024,
          kilometraje: 900,
          vin: 'VIN1',
        ),
      ],
    );
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();
    expect(find.text('900 km'), findsOneWidget);
    expect(find.text('Aún sin actualización del taller'), findsOneWidget);
  });

  _prueba('sin km registrado lo dice y no muestra fecha', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake(), id: 2));
    await tester.pumpAndSettle();
    expect(find.text('Sin kilometraje registrado'), findsOneWidget);
    expect(find.textContaining('Actualizado por el taller'), findsNothing);
  });

  _prueba('copiar el VIN lo deja en el portapapeles y avisa', (tester) async {
    String? copiado;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (llamada) async {
        if (llamada.method == 'Clipboard.setData') {
          copiado =
              (llamada.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Copiar VIN'));
    await tester.pumpAndSettle();
    expect(copiado, 'JM3KFBDM0R0123456');
    expect(find.text('VIN copiado'), findsOneWidget);
  });

  _prueba('Tu auto ofrece ficha e historial como filas de lista', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    for (final texto in ['Historial de servicios', 'Ficha técnica']) {
      expect(find.text(texto), findsOneWidget);
    }
    // Seis destinos en un solo grupo con chevron (V2-T02.23).
    // Una flecha por fila de la lista (la tarjeta del próximo servicio lleva la
    // suya, fuera de la lista).
    expect(
      find.descendant(
        of: find.byType(GrupoLista),
        matching: find.byIcon(Icons.chevron_right_rounded),
      ),
      findsNWidgets(6),
    );
    // Manual y Agendar ya estan en la portada: no se repiten abajo.
    expect(find.text('Manuales'), findsNothing);
    expect(find.text('Disponible pronto'), findsNothing);
    expect(find.bySemanticsLabel('Historial de servicios'), findsOneWidget);
  });

  _prueba('trae la tarjeta del asistente (V2-M24.10)', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    expect(find.byType(TarjetaAsistente), findsOneWidget);
    expect(find.text('Pregúntale a tu auto'), findsOneWidget);
  });

  _prueba('mantenimiento es un acceso del grupo Tu auto', (tester) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    expect(find.text('Mantenimiento'), findsOneWidget);
    expect(find.bySemanticsLabel('Mantenimiento'), findsOneWidget);
  });

  _prueba('garantia y campanas son accesos del grupo Tu auto (V2-M10)', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake()));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Garantía'), findsOneWidget);
    expect(find.bySemanticsLabel('Campañas de seguridad'), findsOneWidget);
  });

  _prueba('un id que no esta en el garaje explica y no deja en blanco', (
    tester,
  ) async {
    await tester.pumpWidget(_app(RepositorioGarajeFake(), id: 99));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('No encontramos el vehículo'), findsOneWidget);
  });

  _prueba('mientras carga muestra el esqueleto y lo anuncia', (tester) async {
    await tester.pumpWidget(
      _app(_Repo(() => Future.delayed(const Duration(seconds: 5), () => []))),
    );
    expect(find.bySemanticsLabel('Cargando tu garaje'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  _prueba('un fallo muestra el error y reintenta', (tester) async {
    var intentos = 0;
    await tester.pumpWidget(
      _app(
        _Repo(() async {
          intentos++;
          if (intentos == 1) throw Exception('fallo');
          return RepositorioGarajeFake().vehiculos();
        }),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.text('Mazda CX-5 2024'), findsOneWidget);
  });

  _prueba('sin conexion y sin copia guardada lo dice distinto', (tester) async {
    await tester.pumpWidget(_app(_Repo(() async => throw const SinConexion())));
    await tester.pumpAndSettle();
    expect(find.text('Sin conexión'), findsOneWidget);
  });

  _prueba('en ingles traduce los textos', (tester) async {
    await tester.pumpWidget(
      _app(RepositorioGarajeFake(), idioma: const Locale('en')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Plates ABC-123'), findsOneWidget);
    expect(find.text('Service history'), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
    expect(find.textContaining('Updated by the workshop on'), findsOneWidget);
  });

  _prueba('se ve en claro, oscuro y letra grande sin desbordar', (
    tester,
  ) async {
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        _app(RepositorioGarajeFake(), escenario: escenario),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
