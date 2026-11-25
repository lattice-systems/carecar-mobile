import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/l10n/idiomas.dart';
import 'package:carecar_mobile/modulos/asistencia/datos/repositorio_asistencia_fake.dart';
import 'package:carecar_mobile/modulos/asistencia/dominio/solicitud_asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/presentacion/proveedores_asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/presentacion/vista_solicitud.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/presentacion/proveedores_vehiculos.dart';
import 'package:carecar_mobile/nucleo/diseno/componentes/linea_de_tiempo.dart';
import 'package:carecar_mobile/nucleo/diseno/tema_pista.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

SolicitudAsistencia _solicitud([
  EstadoSolicitud estado = EstadoSolicitud.recibida,
]) => SolicitudAsistencia(
  id: 7,
  vehiculoId: 1,
  tipo: TipoAsistencia.llanta,
  estado: estado,
  creadaEn: DateTime(2026, 11, 23, 15, 30),
);

Future<(EventosEnVivoFake, RepositorioAsistenciaFake)> _montar(
  WidgetTester tester, {
  EstadoSolicitud estado = EstadoSolicitud.recibida,
  Brightness brillo = Brightness.light,
  Size tamano = const Size(800, 1800),
  double escala = 1,
}) async {
  tester.view.physicalSize = tamano;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final canal = EventosEnVivoFake();
  final repo = RepositorioAsistenciaFake(abierta: _solicitud(estado));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventosEnVivoProvider.overrideWithValue(canal),
        repositorioAsistenciaProvider.overrideWithValue(repo),
        repositorioGarajeProvider.overrideWithValue(RepositorioGarajeFake()),
      ],
      child: MaterialApp(
        theme: brillo == Brightness.dark
            ? TemaPista.oscuro()
            : TemaPista.claro(),
        locale: const Locale('es'),
        localizationsDelegates: delegadasDeIdioma,
        supportedLocales: idiomasSoportados,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(escala),
            disableAnimations: true,
          ),
          child: child!,
        ),
        home: VistaSolicitud(solicitud: _solicitud(estado), yaAbierta: false),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (canal, repo);
}

void main() {
  testWidgets('muestra recibida, en camino y atendida en la linea de tiempo', (
    tester,
  ) async {
    await _montar(tester);

    expect(find.byType(LineaDeTiempo), findsOneWidget);
    expect(find.text('Estado de tu solicitud'), findsOneWidget);
    expect(find.text('La agencia ya tiene tu solicitud.'), findsOneWidget);
    expect(find.text('En camino'), findsOneWidget);
    expect(find.text('Atendida'), findsOneWidget);
    expect(find.text('15:30'), findsOneWidget);
  });

  testWidgets('asistencia.estado actualiza la linea sin recargar', (
    tester,
  ) async {
    final (canal, _) = await _montar(tester);

    canal.emitir('asistencia.estado', {
      'solicitudId': 7,
      'estado': 'en_camino',
    });
    await tester.pumpAndSettle();

    expect(find.text('Hay ayuda en camino hacia ti.'), findsOneWidget);
    expect(find.text('La agencia ya tiene tu solicitud.'), findsNothing);

    canal.emitir('asistencia.estado', {'solicitudId': 7, 'estado': 'atendida'});
    await tester.pumpAndSettle();

    expect(find.text('Tu solicitud ya fue atendida.'), findsOneWidget);
    expect(
      find.text(
        'La solicitud ya está cerrada: tu ubicación dejó de compartirse.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('una solicitud cancelada cierra la linea con su estado', (
    tester,
  ) async {
    await _montar(tester, estado: EstadoSolicitud.cancelada);

    expect(find.text('La solicitud se cerró.'), findsOneWidget);
    expect(find.text('Atendida'), findsNothing);
    expect(
      find.text(
        'La solicitud ya está cerrada: tu ubicación dejó de compartirse.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Actualizar estado consulta el servidor', (tester) async {
    final (_, repo) = await _montar(tester);
    repo.abierta = _solicitud(EstadoSolicitud.enCamino);

    await tester.ensureVisible(find.text('Actualizar estado'));
    await tester.tap(find.text('Actualizar estado'));
    await tester.pumpAndSettle();

    expect(repo.consultas, 1);
    expect(find.text('Hay ayuda en camino hacia ti.'), findsOneWidget);
  });

  testWidgets('si no se puede actualizar lo dice y conserva el estado', (
    tester,
  ) async {
    final (canal, repo) = await _montar(tester);
    canal.emitir('asistencia.estado', {
      'solicitudId': 7,
      'estado': 'en_camino',
    });
    await tester.pumpAndSettle();
    repo.falloAlConsultar = const SinConexion();

    await tester.ensureVisible(find.text('Actualizar estado'));
    await tester.tap(find.text('Actualizar estado'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'No pudimos actualizar el estado. Revisa tu conexión e inténtalo de nuevo.',
      ),
      findsOneWidget,
    );
    expect(find.text('Hay ayuda en camino hacia ti.'), findsOneWidget);
  });

  testWidgets('abre el canal solo mientras la pantalla esta puesta', (
    tester,
  ) async {
    final (canal, _) = await _montar(tester);
    expect(canal.escuchas, 1);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    expect(canal.escuchas, 0);
  });

  testWidgets('el estado actual se anuncia como region viva', (tester) async {
    final manejador = tester.ensureSemantics();
    await _montar(tester);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Estado: Recibida')),
      matchesSemantics(label: 'Estado: Recibida', isLiveRegion: true),
    );
    manejador.dispose();
  });

  testWidgets('aguanta letra al 200 % en pantalla chica y en oscuro', (
    tester,
  ) async {
    await _montar(
      tester,
      brillo: Brightness.dark,
      tamano: const Size(320, 568),
      escala: 2,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(LineaDeTiempo), findsOneWidget);
  });
}
