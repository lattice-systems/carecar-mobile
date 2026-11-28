import 'dart:convert';

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
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets('V2-M27.04: envía únicamente la descripción y el diagnóstico', (
    tester,
  ) async {
    PackageInfo.setMockInitialValues(
      appName: 'CareCar',
      packageName: 'carecar',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    Map<String, dynamic>? datos;
    final api = ClienteApi(
      config: ApiConfig.para('http://localhost:3000/api/v1/app'),
      http: MockClient((peticion) async {
        expect(peticion.url.path, endsWith('/ayuda/reportes'));
        datos = jsonDecode(peticion.body) as Map<String, dynamic>;
        return http.Response('', 204);
      }),
    );
    addTearDown(api.cerrar);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositorioCentroAyudaProvider.overrideWithValue(
            RepositorioCentroAyudaApi(api),
          ),
        ],
        child: MaterialApp(
          theme: TemaPista.claro(),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PantallaReporteApp(
            leerEquipo: () async => (equipo: 'Modelo de prueba', sistema: null),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();
    expect(
      find.text('Describe el problema con entre 10 y 2000 caracteres.'),
      findsOneWidget,
    );
    expect(datos, isNull);

    await tester.enterText(
      find.byType(TextField),
      'Se cerró la pantalla al volver',
    );
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();
    expect(find.text('Reporte enviado'), findsOneWidget);
    expect(
      datos?.keys,
      unorderedEquals(['descripcion', 'versionApp', 'sistema', 'dispositivo']),
    );
    expect(datos?['descripcion'], 'Se cerró la pantalla al volver');
  });
}
