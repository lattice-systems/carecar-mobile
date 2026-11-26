// V2-M14.05: mis pedidos y su detalle con actualización en vivo. También
// cancelar (V2-M14.02) y cambiar la instalación (V2-M14.03) desde el pedido.
import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/citas/citas.dart';
import 'package:carecar_mobile/modulos/tienda/datos/repositorio_tienda_fake.dart';
import 'package:carecar_mobile/modulos/tienda/presentacion/proveedores_tienda.dart';
import 'package:carecar_mobile/modulos/tienda/tienda.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_vacio.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/insignia.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/tarjeta_resumen.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_tienda.dart';

// El estado del pedido, sin contar los pasos de la línea de tiempo.
Finder _insignia(String texto) =>
    find.descendant(of: find.byType(Insignia), matching: find.text(texto));

// El paso actual de la línea de tiempo «respira» sin fin: no se puede esperar
// a que la pantalla se asiente.
Future<void> _asentar(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _lista(
  WidgetTester tester,
  RepositorioTiendaFake repo, {
  EventosEnVivoFake? eventos,
  Escenario escenario = Escenario.claro,
  int? tamano,
}) async {
  pantallaAlta(tester);
  await tester.pumpWidget(
    app(
      const PantallaMisPedidos(),
      repositorio: repo,
      eventos: eventos,
      escenario: escenario,
      extra: [
        if (tamano != null)
          tamanoPaginaTiendaProvider.overrideWithValue(tamano),
      ],
    ),
  );
  await _asentar(tester);
}

Future<void> _detalle(
  WidgetTester tester,
  RepositorioTiendaFake repo, {
  EventosEnVivoFake? eventos,
  List<CitaCliente> citas = const [],
  Escenario escenario = Escenario.claro,
}) async {
  pantallaAlta(tester);
  await tester.pumpWidget(
    app(
      const PantallaPedido(pedidoId: 7),
      repositorio: repo,
      eventos: eventos,
      citas: citas,
      escenario: escenario,
    ),
  );
  await _asentar(tester);
}

Future<void> _tocar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto));
  await _asentar(tester);
}

final _citaDelPedido = CitaDePedido(
  id: 31,
  fecha: DateTime(2026, 11, 28),
  hora: '09:00',
  vehiculoId: 5,
);

void main() {
  group('Mis pedidos', () {
    testWidgets('lista cada estado con su total y vencimiento', (tester) async {
      await _lista(
        tester,
        tiendaDePrueba(
          pedidos: [
            pedido(id: 4),
            pedido(id: 3, estado: EstadoPedido.listo),
            pedido(id: 2, estado: EstadoPedido.entregado),
            pedido(id: 1, estado: EstadoPedido.cancelado),
          ],
        ),
      );

      expect(find.byType(TarjetaResumen), findsNWidgets(4));
      for (final estado in ['Apartado', 'Listo', 'Entregado', 'Cancelado']) {
        expect(find.text(estado), findsOneWidget);
      }
      expect(find.textContaining(r'$1,700.00, 2 piezas'), findsNWidgets(4));
      // Solo los abiertos vencen.
      expect(find.textContaining('Vence el'), findsNWidgets(2));
    });

    testWidgets('carga, vacio, sin conexion y reintento', (tester) async {
      final repo = tiendaDePrueba(falla: const SinConexion());
      await tester.pumpWidget(
        app(const PantallaMisPedidos(), repositorio: repo),
      );
      expect(find.bySemanticsLabel('Cargando la tienda'), findsOneWidget);
      await _asentar(tester);
      expect(find.text('Sin conexión'), findsOneWidget);

      repo.falla = null;
      await _tocar(tester, 'Reintentar');
      expect(find.text('Aún no tienes pedidos'), findsOneWidget);
    });

    testWidgets('pide las paginas de a una', (tester) async {
      await _lista(
        tester,
        tiendaDePrueba(pedidos: [for (var i = 3; i >= 1; i--) pedido(id: i)]),
        tamano: 2,
      );
      expect(find.byType(TarjetaResumen), findsNWidgets(2));

      await _tocar(tester, 'Ver más');

      expect(find.byType(TarjetaResumen), findsNWidgets(3));
      expect(find.text('Ver más'), findsNothing);
    });

    testWidgets('pedido.estado la actualiza sin pasar por carga', (
      tester,
    ) async {
      final eventos = EventosEnVivoFake();
      final repo = tiendaDePrueba(pedidos: [pedido()]);
      await _lista(tester, repo, eventos: eventos);

      repo.pedidosActuales = [pedido(estado: EstadoPedido.listo)];
      eventos.emitir('pedido.estado', {'pedidoId': 7, 'estado': 'listo'});
      await _asentar(tester);

      expect(find.text('Listo'), findsOneWidget);
    });

    testWidgets('claro, oscuro y letra al 200 % sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await _lista(
          tester,
          tiendaDePrueba(pedidos: [pedido()]),
          escenario: escenario,
        );
        expect(tester.takeException(), isNull, reason: escenario.name);
        await auditarAccesibilidad(tester);
      }
    });
  });

  group('Un pedido', () {
    testWidgets('apartado dice cuando vence, que lleva y que se paga en caja', (
      tester,
    ) async {
      await _detalle(tester, tiendaDePrueba(pedidos: [pedido()]));

      expect(find.textContaining('Vence el'), findsOneWidget);
      expect(find.textContaining('28 nov'), findsOneWidget);
      expect(
        find.text('No se cobra en la app: pagas en caja.'),
        findsOneWidget,
      );
      expect(find.text('Tapetes de uso rudo'), findsOneWidget);
      expect(find.text('Se recoge en mostrador'), findsOneWidget);
      expect(find.text('Cancelar pedido'), findsOneWidget);
    });

    testWidgets('cancelado dice por que y ya no ofrece acciones', (
      tester,
    ) async {
      await _detalle(
        tester,
        tiendaDePrueba(
          pedidos: [
            pedido(
              estado: EstadoPedido.cancelado,
              motivo: MotivoCancelacion.vencido,
            ),
          ],
        ),
      );

      expect(find.text('El apartado venció'), findsOneWidget);
      expect(find.text('Cancelar pedido'), findsNothing);
      expect(find.text('Instalar en mi cita'), findsNothing);
      expect(find.textContaining('Vence el'), findsNothing);
    });

    testWidgets('cancelar pide confirmacion y libera', (tester) async {
      final repo = tiendaDePrueba(pedidos: [pedido()]);
      await _detalle(tester, repo);

      await _tocar(tester, 'Cancelar pedido');
      await _tocar(tester, 'Conservar');
      expect(repo.cancelados, isEmpty);

      await _tocar(tester, 'Cancelar pedido');
      await _tocar(tester, 'Sí, cancelar');

      expect(repo.cancelados, [7]);
      expect(find.text('Lo cancelaste tú'), findsOneWidget);
      expect(repo.productosActuales.first.existencia, 5);
    });

    testWidgets('si ya se entrego, cancelar lo explica y recarga', (
      tester,
    ) async {
      final repo = tiendaDePrueba(pedidos: [pedido()]);
      await _detalle(tester, repo);
      repo
        ..pedidosActuales = [pedido(estado: EstadoPedido.entregado)]
        ..fallaAlGuardar = const PedidoRechazado(
          MotivoRechazoPedido.noCancelable,
        );

      await _tocar(tester, 'Cancelar pedido');
      await _tocar(tester, 'Sí, cancelar');

      expect(find.textContaining('ya se entregó'), findsOneWidget);
      await _tocar(tester, 'Entendido');
      expect(find.text('Cancelar pedido'), findsNothing);
    });

    testWidgets('se liga despues a una cita confirmada futura', (tester) async {
      final repo = tiendaDePrueba(pedidos: [pedido()]);
      await _detalle(tester, repo, citas: [cita(), cita(id: 2, dia: 20)]);

      await _tocar(tester, 'Instalar en mi cita');
      expect(find.textContaining('20 nov'), findsNothing);
      await tester.tap(find.textContaining('09:00, Nissan March 2020'));
      await _asentar(tester);

      expect(repo.instalaciones.single, (pedidoId: 7, citaId: 31));
      expect(find.text('Se instala en tu cita'), findsOneWidget);
      expect(find.text('Cambiar de cita'), findsOneWidget);
    });

    testWidgets('puede volver a mostrador', (tester) async {
      final repo = tiendaDePrueba(pedidos: [pedido(cita: _citaDelPedido)]);
      await _detalle(tester, repo);

      await _tocar(tester, 'Recoger en mostrador');

      expect(repo.instalaciones.single, (pedidoId: 7, citaId: null));
      expect(find.text('Se recoge en mostrador'), findsOneWidget);
    });

    for (final (motivo, texto) in [
      (MotivoRechazoPedido.citaNoDisponible, 'cancelada o ya pasó'),
      (MotivoRechazoPedido.noModificable, 'no se puede cambiar'),
      (MotivoRechazoPedido.productoIncompatible, 'no le queda al auto'),
    ]) {
      testWidgets('el rechazo ${motivo.name} al instalar se explica', (
        tester,
      ) async {
        final repo = tiendaDePrueba(pedidos: [pedido()])
          ..fallaAlGuardar = PedidoRechazado(motivo);
        await _detalle(tester, repo, citas: [cita()]);

        await _tocar(tester, 'Instalar en mi cita');
        await tester.tap(find.textContaining('09:00, Nissan March 2020'));
        await _asentar(tester);

        expect(find.textContaining(texto), findsOneWidget);
      });
    }

    testWidgets('solo su aviso pedido.estado lo actualiza en vivo', (
      tester,
    ) async {
      final eventos = EventosEnVivoFake();
      final repo = tiendaDePrueba(pedidos: [pedido()]);
      await _detalle(tester, repo, eventos: eventos);
      repo.pedidosActuales = [pedido(estado: EstadoPedido.listo)];

      eventos.emitir('pedido.estado', {'pedidoId': 99, 'estado': 'listo'});
      await _asentar(tester);
      expect(_insignia('Listo'), findsNothing);

      eventos.emitir('pedido.estado', {'pedidoId': 7, 'estado': 'listo'});
      await _asentar(tester);
      expect(_insignia('Listo'), findsOneWidget);
    });

    testWidgets('al volver la conexion se recarga y una falla no lo borra', (
      tester,
    ) async {
      final eventos = EventosEnVivoFake();
      final repo = tiendaDePrueba(pedidos: [pedido()]);
      await _detalle(tester, repo, eventos: eventos);

      repo.falla = const SinConexion();
      eventos.emitir('conexion.restablecida');
      await _asentar(tester);

      expect(find.byType(EstadoError), findsNothing);
      expect(find.text('Tapetes de uso rudo'), findsOneWidget);
    });

    testWidgets('uno ajeno dice que no se encontro', (tester) async {
      await _detalle(tester, tiendaDePrueba());

      expect(find.byType(EstadoVacio), findsOneWidget);
      expect(find.text('No encontramos ese pedido'), findsOneWidget);
    });

    testWidgets('claro, oscuro y letra al 200 % sin desbordar', (tester) async {
      for (final escenario in Escenario.values) {
        await _detalle(
          tester,
          tiendaDePrueba(pedidos: [pedido(cita: _citaDelPedido)]),
          escenario: escenario,
        );
        expect(tester.takeException(), isNull, reason: escenario.name);
        await auditarAccesibilidad(tester);
      }
    });

    testWidgets('en una pantalla chica con letra grande no desborda', (
      tester,
    ) async {
      pantallaChica(tester);
      await tester.pumpWidget(
        app(
          const PantallaPedido(pedidoId: 7),
          repositorio: tiendaDePrueba(pedidos: [pedido()]),
          escenario: Escenario.letraGrande,
          ancho: 320,
        ),
      );
      await _asentar(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
