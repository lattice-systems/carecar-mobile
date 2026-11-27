import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/documentos/datos/repositorio_documentos_fake.dart';
import 'package:carecar_mobile/modulos/documentos/dominio/documento_vehiculo.dart';
import 'package:carecar_mobile/modulos/documentos/presentacion/pantalla_documentos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/encabezado_grande.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_documentos.dart';

const _pantalla = PantallaDocumentos(vehiculoId: 5);

/// Monta la pantalla en un telefono de [tamano] con la letra a [escala].
Future<void> _montar(
  WidgetTester tester,
  RepositorioDocumentosFake repo, {
  Size tamano = const Size(360, 2400),
  Escenario escenario = Escenario.claro,
  Locale idioma = const Locale('es'),
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = tamano;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDocumentos(
      _pantalla,
      repo,
      escenario: escenario,
      ancho: tamano.width,
      idioma: idioma,
    ),
  );
  await tester.pumpAndSettle();
}

RepositorioDocumentosFake _conEjemplo() =>
    RepositorioDocumentosFake(documentos: documentosDeEjemplo());

Finder _insignia(String texto) => find.widgetWithText(Insignia, texto);

void main() {
  pruebaDocumentos('mientras carga muestra esqueleto', (tester) async {
    await tester.pumpWidget(appDocumentos(_pantalla, _conEjemplo()));
    expect(find.byType(Esqueleto), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  group('con documentos (V2-M09.01)', () {
    testWidgets('los agrupa por estado, de lo mas urgente a lo menos', (
      tester,
    ) async {
      await _montar(tester, _conEjemplo());

      expect(find.text('Documentos'), findsWidgets);
      expect(find.text('4 documentos'), findsWidgets);
      final vencidos = tester.getTopLeft(find.text('Vencidos')).dy;
      final porVencer = tester.getTopLeft(find.text('Por vencer').first).dy;
      final vigentes = tester.getTopLeft(find.text('Vigentes')).dy;
      final sinFecha = tester
          .getTopLeft(find.text('Sin fecha de vencimiento'))
          .dy;
      expect(vencidos, lessThan(porVencer));
      expect(porVencer, lessThan(vigentes));
      expect(vigentes, lessThan(sinFecha));
    });

    testWidgets('cada documento lleva su nombre y su insignia de estado', (
      tester,
    ) async {
      await _montar(tester, _conEjemplo());

      expect(find.text('Verificación vehicular'), findsOneWidget);
      expect(find.text('Póliza de seguro'), findsOneWidget);
      expect(find.text('Tarjeta de circulación'), findsOneWidget);
      expect(find.text('Factura de compra'), findsOneWidget);
      expect(_insignia('Vencido'), findsOneWidget);
      expect(_insignia('Por vencer'), findsOneWidget);
      expect(_insignia('Vigente'), findsOneWidget);
      expect(_insignia('Sin fecha'), findsOneWidget);
    });

    testWidgets('dice cuando vence o vencio y cuantos dias', (tester) async {
      await _montar(tester, _conEjemplo());

      expect(
        find.textContaining('Venció el 23 oct 2026 · hace 35 días'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Vence el 27 dic 2026 · en 30 días'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Vence el 10 may 2028 · en 530 días'),
        findsOneWidget,
      );
    });

    testWidgets('muestra el numero y la aseguradora de la poliza', (
      tester,
    ) async {
      await _montar(tester, _conEjemplo());

      expect(
        find.textContaining('N.º POL-501-2026 · Seguros Ejemplo'),
        findsOneWidget,
      );
      expect(
        find.textContaining('N.º A-1042 · Cargado por la agencia'),
        findsOneWidget,
      );
    });

    testWidgets('un documento «otro» se llama como su titulo', (tester) async {
      await _montar(
        tester,
        RepositorioDocumentosFake(
          documentos: [
            documento(
              tipo: TipoDocumento.otro,
              titulo: 'Permiso de carga',
              venceEn: DateTime(2027, 3, 1),
              estado: EstadoDocumento.vigente,
              diasRestantes: 90,
            ),
          ],
        ),
      );

      expect(find.text('Permiso de carga'), findsOneWidget);
      expect(find.text('Otro documento'), findsNothing);
    });

    testWidgets('la portada resume lo que necesita atencion', (tester) async {
      await _montar(tester, _conEjemplo());

      expect(find.text('2 documentos necesitan atención'), findsOneWidget);
      expect(
        find.text('Verificación vehicular venció hace 35 días.'),
        findsOneWidget,
      );
    });

    testWidgets('con todo vigente la portada dice que esta en orden', (
      tester,
    ) async {
      await _montar(
        tester,
        RepositorioDocumentosFake(
          documentos: [
            documento(
              tipo: TipoDocumento.tarjetaCirculacion,
              venceEn: DateTime(2028, 5, 10),
              diasRestantes: 530,
            ),
          ],
        ),
      );

      expect(find.text('Todo en orden'), findsOneWidget);
      expect(find.text('Tus documentos están al día.'), findsOneWidget);
      expect(find.text('Vencidos'), findsNothing);
      expect(find.text('Por vencer'), findsNothing);
    });

    testWidgets('un documento que vence hoy lo dice en la portada', (
      tester,
    ) async {
      await _montar(
        tester,
        RepositorioDocumentosFake(
          documentos: [
            documento(
              tipo: TipoDocumento.verificacion,
              venceEn: DateTime(2026, 11, 27),
              estado: EstadoDocumento.porVencer,
              diasRestantes: 0,
            ),
          ],
        ),
      );

      expect(find.text('1 documento necesita atención'), findsOneWidget);
      expect(find.text('Verificación vehicular vence hoy.'), findsOneWidget);
    });

    testWidgets('el lector oye un solo nodo por documento', (tester) async {
      final semantica = tester.ensureSemantics();
      await _montar(tester, _conEjemplo());

      final poliza = find.bySemanticsLabel(RegExp(r'^Póliza de seguro\. '));
      expect(poliza, findsOneWidget);
      final etiqueta = tester.getSemantics(poliza).label;
      expect(etiqueta, contains('Vence el 27 dic 2026'));
      expect(etiqueta, contains('Seguros Ejemplo'));
      expect(etiqueta, endsWith('Por vencer'));
      expect(
        find.bySemanticsLabel(RegExp(r'^Verificación vehicular\. ')),
        findsOneWidget,
      );
      semantica.dispose();
    });

    testWidgets('pasa la auditoria de accesibilidad en claro y oscuro', (
      tester,
    ) async {
      await _montar(tester, _conEjemplo());
      await auditarAccesibilidad(tester);
      await _montar(tester, _conEjemplo(), escenario: Escenario.oscuro);
      await auditarAccesibilidad(tester);
    });
  });

  group('estados de la pantalla', () {
    testWidgets('sin documentos muestra el estado vacio', (tester) async {
      await _montar(tester, RepositorioDocumentosFake());

      expect(find.byType(EstadoVacio), findsOneWidget);
      expect(find.text('Aún no hay documentos'), findsOneWidget);
    });

    testWidgets('si falla deja reintentar y recarga', (tester) async {
      final repo = _conEjemplo()..falla = Exception('boom');
      await _montar(tester, repo);

      expect(find.byType(EstadoError), findsOneWidget);
      repo.falla = null;
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(repo.lecturas, 2);
      expect(find.byType(EstadoError), findsNothing);
      expect(find.text('Póliza de seguro'), findsOneWidget);
    });

    testWidgets('sin conexion lo explica y deja reintentar', (tester) async {
      final repo = _conEjemplo()..falla = const SinConexion();
      await _montar(tester, repo);

      final estado = tester.widget<EstadoError>(find.byType(EstadoError));
      expect(estado.causa, CausaError.sinConexion);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('un vehiculo ajeno (404) cae en el estado de error', (
      tester,
    ) async {
      final repo = _conEjemplo()..falla = const NoEncontrado('No existe');
      await _montar(tester, repo);

      expect(find.byType(EstadoError), findsOneWidget);
    });
  });

  group('diseno', () {
    testWidgets('se ve bien en oscuro', (tester) async {
      await _montar(tester, _conEjemplo(), escenario: Escenario.oscuro);

      expect(tester.takeException(), isNull);
      expect(find.text('Póliza de seguro'), findsOneWidget);
      expect(find.byType(EncabezadoGrande), findsOneWidget);
    });

    testWidgets('con letra al 200 % en 320×568 nada se desborda', (
      tester,
    ) async {
      await _montar(
        tester,
        _conEjemplo(),
        tamano: const Size(320, 568),
        escenario: Escenario.letraGrande,
      );
      expect(tester.takeException(), isNull);

      // Recorre toda la lista: cada fila se construye y se mide.
      for (var i = 0; i < 14; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.text('Factura de compra'), findsOneWidget);
    });

    testWidgets('con letra al 200 % y documentos largos tampoco', (
      tester,
    ) async {
      await _montar(
        tester,
        RepositorioDocumentosFake(
          documentos: [
            documento(
              tipo: TipoDocumento.otro,
              titulo:
                  'Permiso especial de circulación para transporte de carga '
                  'pesada en la zona metropolitana',
              numero: 'FOLIO-ABCDEFGHIJKLMNOPQRSTUVWXYZ-0123456789',
              venceEn: DateTime(2026, 12, 1),
              estado: EstadoDocumento.porVencer,
              diasRestantes: 4,
            ),
            documento(
              id: 2,
              tipo: TipoDocumento.poliza,
              numero: 'POL-0000000000000000000000000000',
              venceEn: DateTime(2027, 12, 1),
              diasRestantes: 369,
              aseguradora: 'Aseguradora Nacional de Seguros del Bajío SA de CV',
              telefono: '800 000 0000',
            ),
          ],
        ),
        tamano: const Size(320, 568),
        escenario: Escenario.letraGrande,
      );
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 8; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('en pantalla ancha el contenido se limita y se centra', (
      tester,
    ) async {
      await _montar(tester, _conEjemplo(), tamano: const Size(1024, 900));

      expect(tester.takeException(), isNull);
      final fila = tester.getRect(find.text('Póliza de seguro'));
      expect(fila.left, greaterThan(200));
      expect(fila.right, lessThan(824));
    });

    testWidgets('ningun contenido atraviesa el titulo al desplazar', (
      tester,
    ) async {
      await _montar(tester, _conEjemplo(), tamano: const Size(390, 500));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // La barra recogida desenfoca lo que pasa por detras y muestra el titulo
      // pequeno una sola vez.
      expect(find.byType(BackdropFilter), findsWidgets);
      expect(find.byType(EncabezadoGrande), findsOneWidget);
    });

    testWidgets('en ingles usa los textos traducidos', (tester) async {
      await _montar(tester, _conEjemplo(), idioma: const Locale('en'));

      expect(find.text('Documents'), findsWidgets);
      expect(find.text('Insurance policy'), findsOneWidget);
      expect(find.text('Expired'), findsWidgets);
      expect(find.text('2 documents need attention'), findsOneWidget);
    });
  });
}
