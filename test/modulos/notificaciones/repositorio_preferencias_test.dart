import 'package:carecar_mobile/api/modelos/preferencias_notificacion.dart';
import 'package:carecar_mobile/modulos/notificaciones/datos/repositorio_preferencias_api.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/aviso_cliente.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/preferencias_de_avisos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

/// V2-M06.05 · la traducción de las preferencias.
///
/// Aquí vive lo que el contrato deja como texto y el dominio necesita tipado:
/// la categoría y el `HH:mm` del horario silencioso.
void main() {
  ({RepositorioPreferenciasAvisosApi repo, ApiFalsa api}) armar() {
    final api = ApiFalsa();
    return (repo: RepositorioPreferenciasAvisosApi(api), api: api);
  }

  test('las seis categorías del contrato llegan tipadas', () async {
    final a = armar();

    final p = await a.repo.preferencias();

    expect(p.porCategoria[CategoriaDeAviso.taller], isTrue);
    // Lo comercial se pide, no se asume.
    expect(p.porCategoria[CategoriaDeAviso.promociones], isFalse);
    expect(p.porCategoria.length, 6);
  });

  test('una categoría nueva del backend no tumba la pantalla', () async {
    final a = armar();
    a.api.preferencias = const PreferenciasNotificacion(
      categorias: [
        PreferenciaNotificacion(categoria: 'TALLER', push: true),
        PreferenciaNotificacion(categoria: 'CUPONES', push: true),
      ],
    );

    final p = await a.repo.preferencias();

    expect(p.porCategoria[CategoriaDeAviso.desconocida], isTrue);
  });

  test('sin horario silencioso el dominio dice que no hay', () async {
    final a = armar();

    final p = await a.repo.preferencias();

    expect(p.silencio, isNull);
    expect(p.haySilencio, isFalse);
  });

  test('el horario que cruza la medianoche se lee tal cual', () async {
    final a = armar();
    a.api.preferencias = const PreferenciasNotificacion(
      categorias: [PreferenciaNotificacion(categoria: 'TALLER', push: true)],
      silencioDesde: '22:00',
      silencioHasta: '07:00',
    );

    final p = await a.repo.preferencias();

    expect(p.silencio!.desde, const HoraDelDia(22, 0));
    expect(p.silencio!.hasta, const HoraDelDia(7, 0));
    expect(p.silencio!.silencia(const HoraDelDia(3, 0)), isTrue);
  });

  test('una hora que no se puede leer deja el horario en nulo', () async {
    // Mejor sin silencio que silenciando a una hora que nadie eligió.
    final a = armar();
    a.api.preferencias = const PreferenciasNotificacion(
      categorias: [PreferenciaNotificacion(categoria: 'TALLER', push: true)],
      silencioDesde: '25:00',
      silencioHasta: '07:00',
    );

    final p = await a.repo.preferencias();

    expect(p.silencio, isNull);
  });

  test('guardar manda las seis categorías y el horario con formato', () async {
    final a = armar();
    final p = await a.repo.preferencias();

    await a.repo.guardar(
      p
          .con(CategoriaDeAviso.promociones, true)
          .conHorario(
            const HorarioSilencioso(
              desde: HoraDelDia(22, 0),
              hasta: HoraDelDia(7, 5),
            ),
          ),
    );

    final enviado = a.api.preferenciasGuardadas!;
    expect(enviado.categorias.length, 6);
    expect(
      enviado.categorias.firstWhere((c) => c.categoria == 'PROMOCIONES').push,
      isTrue,
    );
    // Dos dígitos: es lo que el contrato exige.
    expect(enviado.silencioDesde, '22:00');
    expect(enviado.silencioHasta, '07:05');
  });

  test('quitar el horario manda los dos nulos, no uno', () async {
    // Uno sin el otro es 400 en el contrato.
    final a = armar();
    final p = await a.repo.preferencias();

    await a.repo.guardar(p.sinHorario());

    expect(a.api.preferenciasGuardadas!.silencioDesde, isNull);
    expect(a.api.preferenciasGuardadas!.silencioHasta, isNull);
  });

  test('la categoría desconocida no se le manda al servidor', () async {
    final a = armar();
    a.api.preferencias = const PreferenciasNotificacion(
      categorias: [
        PreferenciaNotificacion(categoria: 'TALLER', push: true),
        PreferenciaNotificacion(categoria: 'CUPONES', push: true),
      ],
    );
    final p = await a.repo.preferencias();

    await a.repo.guardar(p);

    // El contrato no la declara: mandarla sería un 400.
    expect(a.api.preferenciasGuardadas!.categorias.map((c) => c.categoria), [
      'TALLER',
    ]);
  });
}
