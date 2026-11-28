import 'package:carecar_mobile/l10n/app_localizations.dart';
import 'package:carecar_mobile/modulos/ayuda/presentacion/pantalla_acerca_de.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  testWidgets(
    'V2-M27.05: muestra la versión del paquete y abre las licencias',
    (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'CareCar',
        packageName: 'carecar',
        version: '2.7.3',
        buildNumber: '20',
        buildSignature: '',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: TemaPista.claro(),
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PantallaAcercaDe(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('2.7.3'), findsOneWidget);
      expect(find.text('Términos de uso'), findsOneWidget);

      await tester.tap(find.text('Licencias de software'));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
    },
  );
}
