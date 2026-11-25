import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/modulos/asistencia/datos/repositorio_asistencia_fake.dart';
import 'package:carecar_mobile/modulos/asistencia/dominio/solicitud_asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/presentacion/proveedores_asistencia.dart';
import 'package:carecar_mobile/modulos/asistencia/presentacion/seguimiento_solicitud.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo.dart';
import 'package:carecar_mobile/nucleo/eventos/eventos_en_vivo_fake.dart';
import 'package:carecar_mobile/nucleo/eventos/proveedores_eventos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _turno() => Future<void>.delayed(Duration.zero);

Future<(ProviderContainer, EventosEnVivoFake, RepositorioAsistenciaFake)>
_montar() async {
  final canal = EventosEnVivoFake();
  final repo = RepositorioAsistenciaFake();
  final s = await repo.pedirAyuda(vehiculoId: 1, tipo: TipoAsistencia.llanta);
  expect(s.id, 1);
  final contenedor = ProviderContainer(
    overrides: [
      eventosEnVivoProvider.overrideWithValue(canal),
      repositorioAsistenciaProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(contenedor.dispose);
  contenedor.listen(seguimientoSolicitudProvider(1), (_, _) {});
  await _turno();
  return (contenedor, canal, repo);
}

void main() {
  test('asistencia.estado de esta solicitud cambia el estado', () async {
    final (c, canal, _) = await _montar();

    canal.emitir('asistencia.estado', {
      'solicitudId': 1,
      'estado': 'en_camino',
    });
    await _turno();

    expect(
      c.read(seguimientoSolicitudProvider(1)).estado,
      EstadoSolicitud.enCamino,
    );
  });

  test('el evento de otra solicitud se ignora', () async {
    final (c, canal, _) = await _montar();

    canal.emitir('asistencia.estado', {'solicitudId': 2, 'estado': 'atendida'});
    await _turno();

    expect(c.read(seguimientoSolicitudProvider(1)).estado, isNull);
  });

  test('refrescar consulta el servidor y aplica su estado', () async {
    final (c, _, repo) = await _montar();
    repo.abierta = SolicitudAsistencia(
      id: 1,
      vehiculoId: 1,
      tipo: TipoAsistencia.llanta,
      estado: EstadoSolicitud.atendida,
      creadaEn: DateTime(2026),
    );

    await c.read(seguimientoSolicitudProvider(1).notifier).refrescar();

    final estado = c.read(seguimientoSolicitudProvider(1));
    expect(estado.estado, EstadoSolicitud.atendida);
    expect(estado.actualizando, isFalse);
    expect(estado.fallo, isFalse);
  });

  test('si refrescar falla conserva lo sabido y marca el fallo', () async {
    final (c, canal, repo) = await _montar();
    canal.emitir('asistencia.estado', {
      'solicitudId': 1,
      'estado': 'en_camino',
    });
    await _turno();
    repo.falloAlConsultar = const SinConexion();

    await c.read(seguimientoSolicitudProvider(1).notifier).refrescar();

    final estado = c.read(seguimientoSolicitudProvider(1));
    expect(estado.estado, EstadoSolicitud.enCamino);
    expect(estado.fallo, isTrue);
  });

  test('al reconectar vuelve a consultar el estado', () async {
    final (c, canal, repo) = await _montar();
    final antes = repo.consultas;

    canal.emitir(eventoReconectado);
    await _turno();
    await _turno();

    expect(repo.consultas, antes + 1);
    expect(
      c.read(seguimientoSolicitudProvider(1)).estado,
      EstadoSolicitud.recibida,
    );
  });

  test('sin pantalla mirando no hay conexion abierta', () async {
    final canal = EventosEnVivoFake();
    final contenedor = ProviderContainer(
      overrides: [eventosEnVivoProvider.overrideWithValue(canal)],
    );
    addTearDown(contenedor.dispose);

    final sub = contenedor.listen(seguimientoSolicitudProvider(1), (_, _) {});
    await _turno();
    expect(canal.escuchas, 1);

    sub.close();
    await _turno();
    await _turno();
    expect(canal.escuchas, 0);
  });
}
