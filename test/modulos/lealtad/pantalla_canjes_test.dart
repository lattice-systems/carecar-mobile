import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/lealtad/datos/repositorio_lealtad_fake.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/pantalla_canje.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/pantalla_canjes.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/pantalla_recompensas.dart';
import 'package:carecar_mobile/modulos/lealtad/presentacion/rutas_lealtad.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/aviso.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_lealtad.dart';

String _fecha(DateTime momento) =>
    DateFormat.yMMMd('es').format(momento.toLocal());

void main() {
  group('Mis canjes (V2-M12.03)', () {
    pruebaLealtad('muestra cada canje con codigo, estado y fecha', (
      tester,
    ) async {
      await tester.pumpWidget(
        appLealtad(const PantallaCanjes(), repoDeEjemplo()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TarjetaCanje), findsNWidgets(2));
      expect(find.text('10 % en mano de obra'), findsOneWidget);
      expect(find.text('Código 5A6H4J78'), findsOneWidget);
      expect(find.text('Vigente'), findsOneWidget);
      expect(
        find.text('Vence el ${_fecha(DateTime.utc(2026, 12, 24, 18))}'),
        findsOneWidget,
      );
      expect(find.text('Usado'), findsOneWidget);
      expect(
        find.text('Usado el ${_fecha(DateTime.utc(2026, 10, 12, 18))}'),
        findsOneWidget,
      );
    });

    pruebaLealtad('al tocar un canje abre su codigo', (tester) async {
      await tester.pumpWidget(
        appLealtadEnrutada(repoDeEjemplo(), inicial: rutaCanjes),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('10 % en mano de obra'));
      await tester.pumpAndSettle();

      final pantalla = tester.widget<PantallaCanje>(find.byType(PantallaCanje));
      expect(pantalla.canjeId, 2);
    });

    pruebaLealtad('sin canjes invita a ver las recompensas', (tester) async {
      await tester.pumpWidget(
        appLealtadEnrutada(RepositorioLealtadFake(), inicial: rutaCanjes),
      );
      await tester.pumpAndSettle();
      expect(find.byType(EstadoVacio), findsOneWidget);
      expect(find.text('Aún no canjeas nada'), findsOneWidget);

      await tester.tap(find.text('Ver recompensas'));
      await tester.pumpAndSettle();
      expect(find.byType(PantallaRecompensas), findsOneWidget);
    });

    pruebaLealtad('sin conexion lo dice', (tester) async {
      await tester.pumpWidget(
        appLealtad(
          const PantallaCanjes(),
          repoDeEjemplo()..falla = const SinConexion(),
        ),
      );
      await tester.pumpAndSettle();
      final error = tester.widget<EstadoError>(find.byType(EstadoError));
      expect(error.causa, CausaError.sinConexion);
    });
  });

  group('Un canje (V2-M12.03)', () {
    pruebaLealtad('vigente: QR y codigo para mostrar en la agencia', (
      tester,
    ) async {
      await tester.pumpWidget(
        appLealtad(const PantallaCanje(canjeId: 2), repoDeEjemplo()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.byKey(const ValueKey('qr-canje:5A6H4J78')), findsOneWidget);
      expect(find.text('5A6H4J78'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Código QR del canje 5A6H4J78'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(
          Aviso,
          'Muestra este código en caja o en servicio para usar tu recompensa.',
        ),
        findsOneWidget,
      );
      expect(find.text('800 puntos'), findsOneWidget);
    });

    pruebaLealtad('usado: sin QR y lo dice', (tester) async {
      await tester.pumpWidget(
        appLealtad(const PantallaCanje(canjeId: 1), repoDeEjemplo()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(QrImageView), findsNothing);
      expect(find.text('Este canje ya se usó.'), findsOneWidget);
      expect(find.text(_fecha(DateTime.utc(2026, 10, 12, 18))), findsOneWidget);
    });

    pruebaLealtad('un canje que ya no esta en la lista lo dice', (
      tester,
    ) async {
      await tester.pumpWidget(
        appLealtad(const PantallaCanje(canjeId: 99), repoDeEjemplo()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ya no encontramos este canje'), findsOneWidget);
    });

    for (final escenario in Escenario.values) {
      pruebaLealtad('se ve sin desbordes en ${escenario.name}', (tester) async {
        await tester.pumpWidget(
          appLealtad(
            const PantallaCanje(canjeId: 2),
            repoDeEjemplo(),
            escenario: escenario,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
