import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/repositorio_valuacion_fake.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/deslizar_para_confirmar.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/dialogo.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/estado_error.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/galeria_fotos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/linea_de_tiempo.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/auditoria_accesibilidad.dart';
import '../../ayudas/tema_pista.dart';
import 'ayudas_valuacion.dart';

const _pantalla = PantallaValuacion(valuacionId: 1);

Future<void> _montar(
  WidgetTester tester,
  RepositorioValuacionFake repo, {
  EventosEnVivoFake? eventos,
}) async {
  pantallaAlta(tester);
  await tester.pumpWidget(app(_pantalla, repositorio: repo, eventos: eventos));
  // El paso actual «respira» sin fin: no se puede esperar a que se asiente.
  await _asentar(tester);
}

Future<void> _asentar(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _deslizar(WidgetTester tester) async {
  await tester.drag(
    find.byKey(const ValueKey('perilla')),
    const Offset(800, 0),
  );
  await _asentar(tester);
}

void main() {
  testWidgets('muestra auto, rango con la leyenda, avance y fotos', (
    tester,
  ) async {
    await _montar(
      tester,
      RepositorioValuacionFake(
        valuaciones: [
          valuacion(fotos: [foto(TomaValuacion.frente)]),
        ],
      ),
    );

    expect(find.text('Nissan March 2020'), findsOneWidget);
    expect(find.text(r'$100,000 a $120,000'), findsOneWidget);
    expect(find.text(leyenda), findsOneWidget);
    expect(find.byType(LineaDeTiempo), findsOneWidget);
    expect(find.text('1 de 8 fotos'), findsOneWidget);
    expect(find.byType(GaleriaFotos), findsOneWidget);
    expect(find.text('Subir fotos guiadas'), findsOneWidget);
    expect(find.text('Agendar inspección'), findsOneWidget);
    expect(find.text('Tu oferta'), findsNothing);
    expect(find.text('Tu asesor'), findsNothing);
  });

  testWidgets('con cita la muestra y solo ofrece agendar si el servidor deja', (
    tester,
  ) async {
    final repo = RepositorioValuacionFake(
      valuaciones: [
        valuacion(
          estado: EstadoValuacion.citaAgendada,
          cita: inspeccion,
          puedeAgendar: false,
          asesor: 'Vera Vendedora',
        ),
      ],
    );
    await _montar(tester, repo);

    expect(find.text('De 09:00 a 10:00'), findsOneWidget);
    expect(find.text('Ver en Mis citas'), findsOneWidget);
    expect(find.text('Agendar inspección'), findsNothing);
    expect(find.text('Vera Vendedora'), findsOneWidget);
  });

  testWidgets('una cita pasada sin oferta se puede reagendar', (tester) async {
    await _montar(
      tester,
      RepositorioValuacionFake(
        valuaciones: [
          valuacion(
            estado: EstadoValuacion.citaAgendada,
            cita: inspeccion,
            puedeAgendar: true,
          ),
        ],
      ),
    );
    expect(find.text('Agendar inspección'), findsOneWidget);
  });

  testWidgets('con oferta vigente muestra monto, vigencia y nota', (
    tester,
  ) async {
    await _montar(tester, RepositorioValuacionFake(valuaciones: [ofertada()]));

    expect(find.text(r'$112,500'), findsOneWidget);
    expect(find.text('Vigente hasta el 4 dic 2026'), findsOneWidget);
    expect(find.text('Incluye el juego de llantas.'), findsOneWidget);
    expect(find.byType(DeslizarParaConfirmar), findsOneWidget);
    expect(find.text('Rechazar oferta'), findsOneWidget);
    // Con oferta ya no se suben fotos.
    expect(find.text('Subir fotos guiadas'), findsNothing);
  });

  testWidgets('deslizar acepta la oferta una sola vez', (tester) async {
    final repo = RepositorioValuacionFake(valuaciones: [ofertada()]);
    await _montar(tester, repo);

    await _deslizar(tester);

    expect(repo.respuestas, [(1, true, 112500)]);
    expect(find.textContaining('Aceptaste esta oferta'), findsOneWidget);
    expect(find.byType(DeslizarParaConfirmar), findsNothing);
    expect(find.text('Rechazar oferta'), findsNothing);
  });

  testWidgets('rechazar pide confirmacion y se puede cancelar', (tester) async {
    final repo = RepositorioValuacionFake(valuaciones: [ofertada()]);
    await _montar(tester, repo);

    await tester.tap(find.text('Rechazar oferta'));
    await _asentar(tester);
    expect(find.byType(Dialogo), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await _asentar(tester);
    expect(repo.respuestas, isEmpty);

    await tester.tap(find.text('Rechazar oferta'));
    await _asentar(tester);
    await tester.tap(find.text('Sí, rechazar'));
    await _asentar(tester);

    expect(repo.respuestas, [(1, false, 112500)]);
    expect(find.text('Rechazaste esta oferta.'), findsOneWidget);
    expect(find.byType(DeslizarParaConfirmar), findsNothing);
  });

  testWidgets('una oferta vencida se ve sin acciones', (tester) async {
    await _montar(
      tester,
      RepositorioValuacionFake(
        valuaciones: [
          valuacion(
            estado: EstadoValuacion.vencida,
            cita: inspeccion,
            oferta: oferta,
          ),
        ],
      ),
    );

    expect(find.textContaining('Vencida.'), findsOneWidget);
    expect(find.text(r'$112,500'), findsOneWidget);
    expect(find.byType(DeslizarParaConfirmar), findsNothing);
    expect(find.text('Rechazar oferta'), findsNothing);
  });

  testWidgets('el 409 de oferta vencida se explica y recarga', (tester) async {
    final repo = RepositorioValuacionFake(
      valuaciones: [ofertada()],
      rechazo: MotivoRechazoValuacion.ofertaVencida,
    );
    await _montar(tester, repo);
    repo.valuaciones = [
      valuacion(estado: EstadoValuacion.vencida, oferta: oferta),
    ];

    await _deslizar(tester);

    expect(
      find.text('La oferta venció y no se registró tu respuesta.'),
      findsOneWidget,
    );
    expect(find.byType(DeslizarParaConfirmar), findsNothing);
  });

  testWidgets('si la oferta cambio no registra nada y vuelve a cargar', (
    tester,
  ) async {
    final repo = RepositorioValuacionFake(valuaciones: [ofertada()]);
    await _montar(tester, repo);
    // La agencia la renueva con la pantalla abierta, sin aviso.
    repo.valuaciones = [
      valuacion(
        estado: EstadoValuacion.ofertada,
        oferta: OfertaValuacion(
          monto: 118000,
          vigenciaHasta: DateTime(2026, 12, 10),
          ofertadaEn: DateTime.utc(2026, 11, 28),
        ),
      ),
    ];

    await _deslizar(tester);

    expect(repo.respuestas, isEmpty);
    expect(find.textContaining('La oferta cambió'), findsOneWidget);
    expect(find.text(r'$118,000'), findsOneWidget);
  });

  testWidgets('sin red al responder lo dice y deja las acciones', (
    tester,
  ) async {
    final repo = RepositorioValuacionFake(valuaciones: [ofertada()]);
    await _montar(tester, repo);
    repo.falla = const SinConexion();

    await _deslizar(tester);

    expect(find.textContaining('Sin conexión.'), findsOneWidget);
    expect(find.byType(DeslizarParaConfirmar), findsOneWidget);
  });

  testWidgets('el aviso de oferta la muestra sin recargar a mano', (
    tester,
  ) async {
    final eventos = EventosEnVivoFake();
    final repo = RepositorioValuacionFake(valuaciones: [valuacion()]);
    await _montar(tester, repo, eventos: eventos);
    repo.valuaciones = [ofertada()];

    // El de otra valuacion no la vuelve a pedir.
    final antes = repo.lecturas;
    eventos.emitir('valuacion.oferta', {'valuacionId': 2});
    await _asentar(tester);
    expect(repo.lecturas, antes);

    eventos.emitir('valuacion.oferta', {'valuacionId': 1});
    await _asentar(tester);
    expect(find.text(r'$112,500'), findsOneWidget);
  });

  testWidgets('una ajena se explica como no encontrada', (tester) async {
    await _montar(tester, RepositorioValuacionFake());
    expect(find.text('No encontramos esa valuación'), findsOneWidget);
  });

  testWidgets('sin conexion deja reintentar', (tester) async {
    final repo = RepositorioValuacionFake(
      valuaciones: [valuacion()],
      falla: const SinConexion(),
    );
    await _montar(tester, repo);
    expect(find.byType(EstadoError), findsOneWidget);

    repo.falla = null;
    await tester.tap(find.text('Reintentar'));
    await _asentar(tester);
    expect(find.text('Nissan March 2020'), findsOneWidget);
  });

  testWidgets('mientras carga lo anuncia', (tester) async {
    await tester.pumpWidget(
      app(
        _pantalla,
        repositorio: RepositorioValuacionFake(valuaciones: [valuacion()]),
      ),
    );
    expect(find.bySemanticsLabel('Cargando la valuación'), findsOneWidget);
    await _asentar(tester);
  });

  testWidgets('claro, oscuro y letra al 200 % con las guias', (tester) async {
    pantallaAlta(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        app(
          _pantalla,
          repositorio: RepositorioValuacionFake(valuaciones: [ofertada()]),
          escenario: escenario,
        ),
      );
      await _asentar(tester);
      expect(tester.takeException(), isNull, reason: escenario.name);
      expect(find.text(r'$112,500'), findsOneWidget);
      await auditarAccesibilidad(tester);
    }
  });

  testWidgets('en 320 de ancho pasa las guias en los tres escenarios', (
    tester,
  ) async {
    telefonoChicoYAlto(tester);
    for (final escenario in Escenario.values) {
      await tester.pumpWidget(
        app(
          _pantalla,
          repositorio: RepositorioValuacionFake(valuaciones: [ofertada()]),
          escenario: escenario,
          ancho: anchoTelefonoChico,
        ),
      );
      await _asentar(tester);
      expect(tester.takeException(), isNull, reason: escenario.name);
      await auditarAccesibilidad(tester);
    }
  });
}
