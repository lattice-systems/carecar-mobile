import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/garantia/datos/repositorio_garantia_fake.dart';
import 'package:carecar_mobile/modulos/garantia/dominio/garantia_vehiculo.dart';
import 'package:carecar_mobile/modulos/garantia/presentacion/pantalla_garantia.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/esqueleto.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../ayudas/tema_pista.dart';
import 'ayudas_garantia.dart';

const _pantalla = PantallaGarantia(vehiculoId: 5);

String _fecha(DateTime fecha) => DateFormat.yMMMd('es').format(fecha);

void main() {
  pruebaGarantia('mientras carga muestra esqueleto', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(garantia: garantiaDeEjemplo()),
      ),
    );
    expect(find.byType(Esqueleto), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.byType(Esqueleto), findsNothing);
  });

  pruebaGarantia('muestra cada cobertura con su estado (V2-M10.01)', (
    tester,
  ) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(garantia: garantiaDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Garantía'), findsWidgets);
    expect(find.text('Tu auto lleva 59,200 km'), findsWidgets);
    expect(find.byType(TarjetaCobertura), findsNWidgets(3));
    expect(find.text('Batería'), findsOneWidget);
    expect(find.text('Motor y transmisión'), findsOneWidget);
    expect(find.text('Corrosión'), findsOneWidget);
    expect(find.text('Por vencer'), findsNWidgets(2));
    expect(find.text('Vigente'), findsOneWidget);
    expect(
      find.text('Falla de fábrica de la batería original.'),
      findsOneWidget,
    );
  });

  pruebaGarantia('dice hasta cuando cubre y lo que le queda', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(garantia: garantiaDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Vence el ${_fecha(DateTime(2026, 12, 23))}'),
      findsOneWidget,
    );
    expect(
      find.text('Vence el ${_fecha(DateTime(2027, 1, 15))} o a los 60,000 km'),
      findsOneWidget,
    );
    expect(find.text('Quedan 30 días'), findsOneWidget);
    expect(find.text('Quedan 800 km'), findsOneWidget);
    expect(find.text('Quedan 1149 días'), findsOneWidget);
  });

  pruebaGarantia('el lector oye cada cobertura con lo usado en porcentaje', (
    tester,
  ) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(garantia: garantiaDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();
    final motor = find.bySemanticsLabel(RegExp(r'^Motor y transmisión, '));
    expect(motor, findsOneWidget);
    final nodo = tester.getSemantics(motor);
    expect(nodo.label, contains('Por vencer'));
    expect(nodo.label, contains('Quedan 800 km'));
    expect(nodo.value, '98 %');
  });

  pruebaGarantia('una cobertura vencida dice por que', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(
          garantia: GarantiaVehiculo(
            vehiculoId: 5,
            coberturas: [
              CoberturaGarantia(
                id: 9,
                componente: 'Suspensión',
                iniciaEn: DateTime(2023, 1, 1),
                venceEn: DateTime(2027, 1, 1),
                kmLimite: 50000,
                diasRestantes: 39,
                kmRestantes: 0,
                consumo: 100,
                estado: EstadoCobertura.vencida,
                limite: LimiteCobertura.km,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vencida'), findsOneWidget);
    expect(find.text('Venció por kilometraje'), findsOneWidget);
    expect(find.textContaining('Tu auto lleva'), findsNothing);
  });

  pruebaGarantia('sin coberturas muestra el estado vacio', (tester) async {
    await tester.pumpWidget(appGarantia(_pantalla, RepositorioGarantiaFake()));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoVacio), findsOneWidget);
    expect(find.text('Sin garantía registrada'), findsOneWidget);
  });

  pruebaGarantia('si falla deja reintentar', (tester) async {
    final repo = RepositorioGarantiaFake(
      garantia: garantiaDeEjemplo(),
      falla: const SinConexion('sin red'),
    );
    await tester.pumpWidget(appGarantia(_pantalla, repo));
    await tester.pumpAndSettle();
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(find.byType(TarjetaCobertura), findsNWidgets(3));
  });

  pruebaGarantia('ofrece las campanas del vehiculo', (tester) async {
    await tester.pumpWidget(
      appGarantia(
        _pantalla,
        RepositorioGarantiaFake(garantia: garantiaDeEjemplo()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Campañas de seguridad'), findsOneWidget);
  });

  group('en vivo (V2-M10.05)', () {
    pruebaGarantia('el aviso de este vehiculo la vuelve a pedir', (
      tester,
    ) async {
      final eventos = EventosEnVivoFake();
      final repo = RepositorioGarantiaFake(garantia: garantiaDeEjemplo());
      await tester.pumpWidget(appGarantia(_pantalla, repo, eventos: eventos));
      await tester.pumpAndSettle();
      expect(repo.garantiasPedidas, 1);

      repo.garantiaActual = garantiaDeEjemplo(kmActual: 59900);
      eventos.emitir('garantia.por_vencer', {
        'vehiculoId': 5,
        'garantiaId': 2,
        'componente': 'Motor y transmisión',
        'venceEn': '2027-01-15',
        'diasRestantes': 53,
        'kmRestantes': 100,
        'motivo': 'km_1000',
      });
      await tester.pumpAndSettle();

      expect(repo.garantiasPedidas, 2);
      expect(find.text('Tu auto lleva 59,900 km'), findsWidgets);
      expect(find.byType(Esqueleto), findsNothing);
    });

    pruebaGarantia('el aviso de otro vehiculo no la toca', (tester) async {
      final eventos = EventosEnVivoFake();
      final repo = RepositorioGarantiaFake(garantia: garantiaDeEjemplo());
      await tester.pumpWidget(appGarantia(_pantalla, repo, eventos: eventos));
      await tester.pumpAndSettle();

      eventos.emitir('garantia.por_vencer', {'vehiculoId': 99});
      await tester.pumpAndSettle();
      expect(repo.garantiasPedidas, 1);
    });

    pruebaGarantia('al volver la conexion la vuelve a pedir', (tester) async {
      final eventos = EventosEnVivoFake();
      final repo = RepositorioGarantiaFake(garantia: garantiaDeEjemplo());
      await tester.pumpWidget(appGarantia(_pantalla, repo, eventos: eventos));
      await tester.pumpAndSettle();

      eventos.emitir(eventoReconectado);
      await tester.pumpAndSettle();
      expect(repo.garantiasPedidas, 2);
    });

    pruebaGarantia('si la recarga falla se queda la que se ve', (tester) async {
      final eventos = EventosEnVivoFake();
      final repo = RepositorioGarantiaFake(garantia: garantiaDeEjemplo());
      await tester.pumpWidget(appGarantia(_pantalla, repo, eventos: eventos));
      await tester.pumpAndSettle();

      repo.falla = const SinConexion('sin red');
      eventos.emitir('garantia.por_vencer', {'vehiculoId': 5});
      await tester.pumpAndSettle();
      expect(find.byType(TarjetaCobertura), findsNWidgets(3));
      expect(find.byType(EstadoError), findsNothing);
    });
  });

  for (final escenario in Escenario.values) {
    pruebaGarantia('se ve sin desbordes en $escenario', (tester) async {
      await tester.pumpWidget(
        appGarantia(
          _pantalla,
          RepositorioGarantiaFake(garantia: garantiaDeEjemplo()),
          escenario: escenario,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
