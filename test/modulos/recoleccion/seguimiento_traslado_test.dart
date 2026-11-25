import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/traslado.dart';
import 'package:carecar_mobile/modulos/recoleccion/datos/repositorio_recoleccion_fake.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/proveedores_recoleccion.dart';
import 'package:carecar_mobile/modulos/recoleccion/presentacion/seguimiento_traslado.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

TrasladoDetalle _traslado({
  EstadoTraslado estado = EstadoTraslado.programado,
  UbicacionChofer? chofer,
}) => TrasladoDetalle(
  id: 5,
  citaId: 9,
  tipo: 'recoger',
  estado: estado,
  costo: 150,
  fecha: DateTime(2026, 12),
  ventanaInicio: '07:00',
  ventanaFin: '09:00',
  ubicacionChofer: chofer,
);

Future<void> _turno() => Future<void>.delayed(Duration.zero);

Future<(ProviderContainer, EventosEnVivoFake, RepositorioRecoleccionFake)>
_montar(TrasladoDetalle traslado) async {
  final canal = EventosEnVivoFake();
  final repo = RepositorioRecoleccionFake(traslados: [traslado]);
  final contenedor = ProviderContainer(
    overrides: [
      eventosEnVivoProvider.overrideWithValue(canal),
      repositorioRecoleccionProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(contenedor.dispose);
  contenedor.listen(seguimientoTrasladoProvider(5), (_, _) {});
  await contenedor.read(seguimientoTrasladoProvider(5).future);
  return (contenedor, canal, repo);
}

void main() {
  test('carga el traslado al abrir', () async {
    final (c, _, repo) = await _montar(_traslado());

    expect(c.read(seguimientoTrasladoProvider(5)).value?.id, 5);
    expect(repo.consultasTraslado, 1);
  });

  test('traslado.estado de este traslado cambia el estado', () async {
    final (c, canal, _) = await _montar(_traslado());

    canal.emitir('traslado.estado', {
      'trasladoId': 5,
      'citaId': 9,
      'tipo': 'recoger',
      'estado': 'en_camino',
    });
    await _turno();

    expect(
      c.read(seguimientoTrasladoProvider(5)).value?.estado,
      EstadoTraslado.enCamino,
    );
  });

  test('el evento de otro traslado se ignora', () async {
    final (c, canal, _) = await _montar(_traslado());

    canal.emitir('traslado.estado', {'trasladoId': 6, 'estado': 'entregado'});
    await _turno();

    expect(
      c.read(seguimientoTrasladoProvider(5)).value?.estado,
      EstadoTraslado.programado,
    );
  });

  test('traslado.ubicacion mueve al chofer solo si va en camino', () async {
    final (c, canal, _) = await _montar(_traslado());

    canal.emitir('traslado.ubicacion', {
      'trasladoId': 5,
      'lat': 19.4,
      'lng': -99.1,
      'actualizadaEn': '2026-12-01T13:00:00Z',
    });
    await _turno();
    expect(
      c.read(seguimientoTrasladoProvider(5)).value?.ubicacionChofer,
      isNull,
    );

    canal.emitir('traslado.estado', {'trasladoId': 5, 'estado': 'en_camino'});
    canal.emitir('traslado.ubicacion', {
      'trasladoId': 5,
      'lat': 19.5,
      'lng': -99.2,
      'actualizadaEn': '2026-12-01T13:01:00Z',
    });
    await _turno();

    final chofer = c
        .read(seguimientoTrasladoProvider(5))
        .value
        ?.ubicacionChofer;
    expect(chofer?.lat, 19.5);
    expect(chofer?.lng, -99.2);
  });

  test('al salir de en camino la ubicacion desaparece', () async {
    final (c, canal, _) = await _montar(
      _traslado(
        estado: EstadoTraslado.enCamino,
        chofer: UbicacionChofer(
          lat: 19.4,
          lng: -99.1,
          actualizadaEn: DateTime.utc(2026, 12, 1, 13),
        ),
      ),
    );

    canal.emitir('traslado.estado', {'trasladoId': 5, 'estado': 'recogido'});
    await _turno();

    expect(
      c.read(seguimientoTrasladoProvider(5)).value?.ubicacionChofer,
      isNull,
    );
  });

  test('al reconectar vuelve a consultar el traslado', () async {
    final (c, canal, repo) = await _montar(_traslado());
    repo.traslados[5] = _traslado(estado: EstadoTraslado.enTaller);

    canal.emitir(eventoReconectado);
    await _turno();
    await _turno();

    expect(repo.consultasTraslado, 2);
    expect(
      c.read(seguimientoTrasladoProvider(5)).value?.estado,
      EstadoTraslado.enTaller,
    );
  });

  test('si refrescar falla conserva lo que ya se sabia', () async {
    final canal = EventosEnVivoFake();
    final repo = RepositorioRecoleccionFake(traslados: [_traslado()]);
    final c = ProviderContainer(
      overrides: [
        eventosEnVivoProvider.overrideWithValue(canal),
        repositorioRecoleccionProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);
    c.listen(seguimientoTrasladoProvider(5), (_, _) {});
    await c.read(seguimientoTrasladoProvider(5).future);
    repo.traslados.remove(5);

    await c.read(seguimientoTrasladoProvider(5).notifier).refrescar();

    final estado = c.read(seguimientoTrasladoProvider(5));
    expect(estado.hasError, isTrue);
    expect(estado.value?.id, 5);
    expect(estado.error, isA<NoEncontrado>());
  });

  test('sin pantalla mirando no hay conexion abierta', () async {
    final canal = EventosEnVivoFake();
    final repo = RepositorioRecoleccionFake(traslados: [_traslado()]);
    final c = ProviderContainer(
      overrides: [
        eventosEnVivoProvider.overrideWithValue(canal),
        repositorioRecoleccionProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(c.dispose);

    final sub = c.listen(seguimientoTrasladoProvider(5), (_, _) {});
    await _turno();
    expect(canal.escuchas, 1);

    sub.close();
    await _turno();
    await _turno();
    expect(canal.escuchas, 0);
  });
}
