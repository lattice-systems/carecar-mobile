import 'package:carecar_mobile/l10n/app_localizations.dart';
import 'package:carecar_mobile/modulos/ayuda/presentacion/pantalla_acerca_de.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('V2-M27.05: abre los términos incluidos en el paquete', (
    tester,
  ) async {
    final paquete = await PackageInfo.fromPlatform();
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
    expect(find.text(paquete.version), findsOneWidget);

    await tester.tap(find.text('Licencias de software'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Términos de uso'));
    await tester.pumpAndSettle();
    expect(find.text('Términos de uso de CareCar'), findsOneWidget);
    expect(find.text('Uso de la aplicación'), findsOneWidget);
  });
}
