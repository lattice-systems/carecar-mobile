import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/espera_servidor.dart';
import 'package:carecar_mobile/modulos/acceso/presentacion/pantalla_acceso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tono.dart';
import 'package:carecar_mobile/nucleo/sesion/proveedores_sesion.dart';
import 'package:carecar_mobile/sesion/almacen_sesion.dart';
import 'package:carecar_mobile/sesion/controlador_sesion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/vista_telefono.dart';
import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/tema_pista.dart';

/// V2-M01.01 · el aviso de servidor despertando, en la pantalla v2.
///
/// Es de **V2-M01.12**, que Daniel ya entrego y vive en la pantalla v1. Se
/// porta aqui porque si no, el dia que el interruptor pase el acceso a v2 se
/// perderia una historia terminada.
///
/// El backend de Azure se apaga sin trafico y tarda ~35 s en despertar. Sin
/// aviso, el cliente ve un boton girando y cree que la app esta colgada.
void main() {
  late Completer<RespuestaLogin> respuesta;

  /// Un login que no contesta hasta que la prueba lo decide.
  ControladorSesion controladorQueTarda() {
    respuesta = Completer<RespuestaLogin>();
    return ControladorSesion(
      ApiFalsa(alIniciarSesion: (_) => respuesta.future),
      AlmacenEnMemoria(),
    );
  }

  Future<void> montar(WidgetTester tester, ControladorSesion sesion) {
    vistaDeTelefono(tester);
    return tester.pumpWidget(
      ProviderScope(
        overrides: [controladorSesionProvider.overrideWithValue(sesion)],
        child: conTemaPista(const PantallaAcceso()),
      ),
    );
  }

  Future<void> pedirAcceso(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(PantallaAcceso.campoCorreo),
      'cliente1@example.com',
    );
    await tester.enterText(
      find.byKey(PantallaAcceso.campoContrasena),
      'CareCar2026',
    );
    await tester.tap(find.byKey(PantallaAcceso.botonEntrar));
    await tester.pump();
  }

  group('aparece solo si el servidor tarda', () {
    testWidgets('con una respuesta normal no se ve nunca', (tester) async {
      await montar(tester, controladorQueTarda());
      await pedirAcceso(tester);

      // Menos de un segundo, que es lo normal.
      respuesta.complete(ApiFalsa.respuesta());
      await tester.pumpAndSettle();

      expect(find.byType(AvisoEsperaServidor), findsNothing);
    });

    testWidgets('antes del umbral todavia no se ve', (tester) async {
      await montar(tester, controladorQueTarda());
      await pedirAcceso(tester);

      await tester.pump(umbralEsperaServidor - const Duration(seconds: 1));
      expect(find.byType(AvisoEsperaServidor), findsNothing);

      respuesta.complete(ApiFalsa.respuesta());
      await tester.pumpAndSettle();
    });

    testWidgets('pasado el umbral avisa, y el boton sigue en carga', (
      tester,
    ) async {
      await montar(tester, controladorQueTarda());
      await pedirAcceso(tester);

      await tester.pump(umbralEsperaServidor);

      expect(find.byType(AvisoEsperaServidor), findsOneWidget);
      expect(find.text('Despertando el servidor…'), findsOneWidget);
      // Informa, no es un error: la peticion sigue en curso y el cliente no
      // tiene nada que hacer.
      final aviso = tester.widget<Aviso>(
        find.descendant(
          of: find.byType(AvisoEsperaServidor),
          matching: find.byType(Aviso),
        ),
      );
      expect(aviso.tono, Tono.informacion);

      respuesta.complete(ApiFalsa.respuesta());
      await tester.pumpAndSettle();
    });
  });

  group('se va cuando el servidor contesta', () {
    testWidgets('con exito', (tester) async {
      await montar(tester, controladorQueTarda());
      await pedirAcceso(tester);
      await tester.pump(umbralEsperaServidor);
      expect(find.byType(AvisoEsperaServidor), findsOneWidget);

      respuesta.complete(ApiFalsa.respuesta());
      await tester.pumpAndSettle();

      expect(find.byType(AvisoEsperaServidor), findsNothing);
    });

    testWidgets('y tambien con error', (tester) async {
      await montar(tester, controladorQueTarda());
      await pedirAcceso(tester);
      await tester.pump(umbralEsperaServidor);
      expect(find.byType(AvisoEsperaServidor), findsOneWidget);

      respuesta.completeError(const CredencialesInvalidas('Datos malos.'));
      await tester.pumpAndSettle();

      // Si se quedara, el usuario leeria «despertando» junto al error.
      expect(find.byType(AvisoEsperaServidor), findsNothing);
      expect(find.byKey(PantallaAcceso.avisoDeError), findsOneWidget);
    });
  });

  group('no deja temporizadores colgados', () {
    testWidgets('al salir de la pantalla mientras espera', (tester) async {
      await montar(tester, controladorQueTarda());
      await pedirAcceso(tester);
      await tester.pump(const Duration(seconds: 2));

      await tester.pumpWidget(conTemaPista(const Aviso(mensaje: 'otra cosa')));
      respuesta.complete(ApiFalsa.respuesta());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
