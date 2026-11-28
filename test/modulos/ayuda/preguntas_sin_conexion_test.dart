import 'dart:io';

import 'package:carecar_mobile/api/api_config.dart';
import 'package:carecar_mobile/api/cliente_api.dart';
import 'package:carecar_mobile/l10n/app_localizations.dart';
import 'package:carecar_mobile/modulos/ayuda/datos/repositorio_centro_ayuda_api.dart';
import 'package:carecar_mobile/modulos/ayuda/presentacion/pantalla_centro_ayuda.dart';
import 'package:carecar_mobile/modulos/ayuda/presentacion/proveedores_ayuda.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'V2-M27.01: busca y abre preguntas guardadas cuando falla la red',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      var conectado = true;
      final api = ClienteApi(
        config: ApiConfig.para('http://localhost:3000/api/v1/app'),
        http: MockClient((peticion) async {
          expect(peticion.url.path, endsWith('/ayuda/preguntas-frecuentes'));
          if (!conectado) throw const SocketException('Sin red');
          return http.Response(
            '''
          [
            {"id":1,"tema":"Citas","pregunta":"Cambiar cita","respuesta":"Entra a Mis citas","orden":1},
            {"id":2,"tema":"Perfil","pregunta":"Cambiar contraseña","respuesta":"Entra a Perfil","orden":2}
          ]
          ''',
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      addTearDown(api.cerrar);
      final repositorio = RepositorioCentroAyudaApi(api);
      expect(await repositorio.preguntas(), hasLength(2));
      conectado = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            repositorioCentroAyudaProvider.overrideWithValue(repositorio),
          ],
          child: MaterialApp(
            theme: TemaPista.claro(),
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PantallaPreguntasFrecuentes(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'MIS CITAS');
      await tester.pumpAndSettle();
      expect(find.text('Cambiar contraseña'), findsNothing);
      await tester.tap(find.text('Cambiar cita'));
      await tester.pumpAndSettle();
      expect(find.text('Entra a Mis citas'), findsOneWidget);
    },
  );
}
