import 'package:carecar_mobile/l10n/app_localizations.dart';
import 'package:carecar_mobile/modulos/documentos/dominio/documento_vehiculo.dart';
import 'package:carecar_mobile/modulos/documentos/presentacion/pantalla_calendario_documentos.dart';
import 'package:carecar_mobile/modulos/documentos/presentacion/proveedores_documentos.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/calendario.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/fila_lista.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _autos = [
  VehiculoGaraje(id: 1, modelo: 'Versa', anio: 2024),
  VehiculoGaraje(id: 2, modelo: 'Kicks', anio: 2025),
];

DocumentoVehiculo _doc(int id, TipoDocumento tipo, DateTime? fecha) =>
    DocumentoVehiculo(
      id: id,
      vehiculoId: id,
      tipo: tipo,
      origen: OrigenDocumento.cliente,
      estado: EstadoDocumento.vigente,
      venceEn: fecha,
    );

Future<void> _montar(
  WidgetTester tester,
  Future<List<DocumentoVehiculo>> Function(int id) consultar,
) async {
  await tester.binding.setSurfaceSize(const Size(480, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        garajeProvider.overrideWith((ref) async => _autos),
        documentosProvider.overrideWith((ref, id) => consultar(id)),
      ],
      child: MaterialApp(
        theme: TemaPista.claro(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const PantallaCalendarioDocumentos(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'V2-M09.06: combina los autos, marca los días y filtra la lista',
    (tester) async {
      final hoy = DateTime.now();
      DateTime fecha(int dia, {int meses = 0}) =>
          DateTime(hoy.year, hoy.month + meses, dia);
      await _montar(
        tester,
        (id) async => id == 1
            ? [_doc(1, TipoDocumento.poliza, fecha(15))]
            : [
                _doc(2, TipoDocumento.garantia, fecha(3)),
                _doc(2, TipoDocumento.factura, fecha(7, meses: 1)),
                _doc(2, TipoDocumento.otro, null),
              ],
      );

      final calendario = tester.widget<Calendario>(find.byType(Calendario));
      expect(calendario.marcaDelDia!(fecha(3)), '1 vencimiento');
      expect(calendario.marcaDelDia!(fecha(5)), isNull);
      final filas = tester
          .widgetList<FilaLista>(find.byType(FilaLista))
          .toList();
      expect(filas.map((fila) => fila.titulo), [
        'Póliza de garantía',
        'Póliza de seguro',
      ]);
      expect(filas.first.subtitulo, contains('Kicks 2025'));
      expect(filas.last.subtitulo, contains('Versa 2024'));

      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();
      expect(find.text('Póliza de garantía'), findsNothing);
      expect(find.text('Póliza de seguro'), findsOneWidget);

      await tester.tap(find.byTooltip('Mes siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('Factura de compra'), findsOneWidget);
      expect(find.text('Póliza de seguro'), findsNothing);
      expect(find.text('Vencimientos del mes'), findsOneWidget);
    },
  );

  testWidgets(
    'V2-M09.06: ofrece reintentar cuando falla la consulta de un auto',
    (tester) async {
      var falla = true;
      await _montar(tester, (id) async {
        if (id == 2 && falla) throw StateError('Sin respuesta');
        return [];
      });
      expect(
        find.text('No se pudieron cargar los vencimientos'),
        findsOneWidget,
      );
      falla = false;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('No hay vencimientos este mes.'), findsOneWidget);
    },
  );
}
