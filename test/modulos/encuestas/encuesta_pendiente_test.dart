import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/l10n/app_localizations.dart';
import 'package:carecar_mobile/modulos/encuestas/datos/repositorio_encuestas.dart';
import 'package:carecar_mobile/modulos/encuestas/presentacion/encuestas_pantallas.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/boton.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets(
    'muestra una tarjeta y retira la encuesta al posponer o responder',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1500);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var disponible = true;
      var respuestas = 0;
      var contactos = 0;
      final api = ClienteApi(
        config: ApiConfig.para('http://localhost:3000/api/v1/app'),
        http: MockClient((peticion) async {
          final accion = peticion.url.pathSegments.last;
          if (accion == 'pendientes') {
            return http.Response(
              disponible
                  ? '[{"ordenId":7,"modelo":"March de prueba","cerradaEn":"2026-11-27T12:00:00Z"}]'
                  : '[]',
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          if (accion == 'responder') {
            expect(disponible, isTrue);
            respuestas++;
          } else if (accion == 'contacto') {
            expect(respuestas, 1);
            contactos++;
          } else {
            expect(accion, 'posponer');
          }
          disponible = false;
          return http.Response('', 204);
        }),
      );
      addTearDown(api.cerrar);
      final contenedor = ProviderContainer(
        overrides: [
          repositorioEncuestasProvider.overrideWithValue(
            RepositorioEncuestas(api),
          ),
        ],
      );
      addTearDown(contenedor.dispose);
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: EncuestasInicio()),
          ),
          ...rutasEncuestas,
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: contenedor,
          child: MaterialApp.router(
            routerConfig: router,
            theme: TemaPista.claro(),
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Encuestas de servicio'), findsOneWidget);

      router.go('/encuestas/8');
      await tester.pumpAndSettle();
      final textos = AppLocalizations.of(
        tester.element(find.byType(Scaffold).last),
      );
      expect(find.text(textos.m15NoDisponible), findsOneWidget);
      expect(find.text(textos.m15Enviar), findsNothing);

      router.go('/');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Encuestas de servicio'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('March de prueba'));
      await tester.pumpAndSettle();
      final posponer = find.text('Posponer por 24 horas');
      await tester.ensureVisible(posponer);
      await tester.tap(posponer);
      await tester.pumpAndSettle();
      expect(find.text('No tienes encuestas pendientes'), findsOneWidget);

      disponible = true;
      contenedor.invalidate(encuestasPendientesProvider);
      await tester.pumpAndSettle();
      await tester.tap(find.text('March de prueba'));
      await tester.pumpAndSettle();
      final opciones = find.widgetWithText(Boton, '5');
      expect(opciones, findsNWidgets(5));
      for (var indice = 0; indice < 5; indice++) {
        await tester.ensureVisible(opciones.at(indice));
        await tester.tap(opciones.at(indice));
        await tester.pump();
      }
      final enviar = find.text('Enviar encuesta');
      await tester.ensureVisible(enviar);
      await tester.tap(enviar);
      await tester.pumpAndSettle();
      expect(find.text('Gracias por calificar tu servicio'), findsOneWidget);
      await tester.tap(find.text('Pedir que la agencia me contacte'));
      await tester.pumpAndSettle();
      expect(
        find.text('La agencia recibió tu solicitud de contacto.'),
        findsOneWidget,
      );
      expect(contactos, 1);
      router.go('/');
      await tester.pumpAndSettle();
      expect(find.text('Encuestas de servicio'), findsNothing);
      expect(respuestas, 1);
    },
  );
}
