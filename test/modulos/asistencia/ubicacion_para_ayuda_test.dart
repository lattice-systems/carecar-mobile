import 'package:carecar_mobile/modulos/asistencia/presentacion/ubicacion_para_ayuda.dart';
import 'package:carecar_mobile/nucleo/mapas/mapas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('con permiso concedido lee la posicion una sola vez', () async {
    final falsa = UbicacionFalsa(posicion: const Coordenada(10, 20));
    final r = await obtenerUbicacionParaAyuda(falsa);
    expect(r, isA<UbicacionObtenida>());
    expect((r as UbicacionObtenida).coordenada, const Coordenada(10, 20));
    expect(falsa.consultasDePosicion, 1);
    expect(falsa.peticionesDePermiso, 0);
  });

  test('si el permiso estaba denegado lo pide y, si lo dan, lee', () async {
    final falsa = UbicacionFalsa(
      permiso: PermisoUbicacion.denegado,
      permisoTrasPedir: PermisoUbicacion.concedido,
    );
    final r = await obtenerUbicacionParaAyuda(falsa);
    expect(r, isA<UbicacionObtenida>());
    expect(falsa.peticionesDePermiso, 1);
  });

  test('si lo niegan al pedir, no lee y explica el permiso', () async {
    final falsa = UbicacionFalsa(permiso: PermisoUbicacion.denegado);
    final r = await obtenerUbicacionParaAyuda(falsa);
    expect(
      (r as UbicacionNoDisponible).motivo,
      MotivoSinUbicacion.permisoDenegado,
    );
    expect(falsa.consultasDePosicion, 0);
  });

  test('denegado para siempre ni siquiera lo vuelve a pedir', () async {
    final falsa = UbicacionFalsa(permiso: PermisoUbicacion.denegadoParaSiempre);
    final r = await obtenerUbicacionParaAyuda(falsa);
    expect(
      (r as UbicacionNoDisponible).motivo,
      MotivoSinUbicacion.permisoBloqueado,
    );
    expect(falsa.peticionesDePermiso, 0);
    expect(falsa.consultasDePosicion, 0);
  });

  test('servicio apagado y tiempo agotado tienen su motivo', () async {
    final apagado = await obtenerUbicacionParaAyuda(
      UbicacionFalsa(error: const UbicacionServicioApagado()),
    );
    expect(
      (apagado as UbicacionNoDisponible).motivo,
      MotivoSinUbicacion.servicioApagado,
    );
    final lento = await obtenerUbicacionParaAyuda(
      UbicacionFalsa(error: const UbicacionTiempoAgotado()),
    );
    expect(
      (lento as UbicacionNoDisponible).motivo,
      MotivoSinUbicacion.tiempoAgotado,
    );
  });

  test('un permiso que cambia durante la lectura se traduce', () async {
    final r = await obtenerUbicacionParaAyuda(
      UbicacionFalsa(error: const UbicacionPermisoDenegadoParaSiempre()),
    );
    expect(
      (r as UbicacionNoDisponible).motivo,
      MotivoSinUbicacion.permisoBloqueado,
    );
  });
}
