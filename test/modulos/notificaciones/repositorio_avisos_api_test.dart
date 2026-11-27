import 'package:carecar_mobile/api/modelos/notificacion.dart';
import 'package:carecar_mobile/modulos/notificaciones/datos/repositorio_avisos_api.dart';
import 'package:carecar_mobile/modulos/notificaciones/dominio/aviso_cliente.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

/// V2-M06.04 · la traducción del DTO a dominio.
///
/// Existe porque faltaba: las pruebas del estado usan un doble que **ya
/// entrega dominio**, así que se saltan esta traducción por completo. Y aquí
/// es donde se valida el `destino`, que lo escribe el servidor y entra a la
/// app como dato de fuera.
void main() {
  Notificacion dto({
    int id = 1,
    String categoria = 'TALLER',
    String destino = '/taller',
    DateTime? leidaEn,
  }) => Notificacion(
    id: id,
    categoria: categoria,
    titulo: 'Título',
    cuerpo: 'Cuerpo',
    destino: destino,
    creadaEn: DateTime.utc(2026, 11, 20, 18),
    leidaEn: leidaEn,
  );

  ({RepositorioAvisosApi repo, ApiFalsa api}) armar(List<Notificacion> avisos) {
    final api = ApiFalsa()..avisos = avisos;
    return (repo: RepositorioAvisosApi(api), api: api);
  }

  test('una categoría conocida se traduce', () async {
    final a = armar([dto(categoria: 'MANTENIMIENTO')]);

    final pagina = await a.repo.bandeja();

    expect(pagina.avisos.single.categoria, CategoriaDeAviso.mantenimiento);
  });

  test('una categoría que esta versión no conoce no tumba nada', () async {
    // El backend puede agregar una mañana. El aviso se sigue leyendo.
    final a = armar([dto(categoria: 'CUPONES')]);

    final pagina = await a.repo.bandeja();

    expect(pagina.avisos.single.categoria, CategoriaDeAviso.desconocida);
    expect(pagina.avisos.single.titulo, 'Título');
  });

  test('un destino interno pasa tal cual', () async {
    final a = armar([dto(destino: '/citas/7/comprobante')]);

    final pagina = await a.repo.bandeja();

    expect(pagina.avisos.single.destino, '/citas/7/comprobante');
  });

  test('un destino de fuera de la app se descarta, el aviso NO', () async {
    // Lo escribe el servidor: un destino sin revisar es una redirección
    // abierta. Se pierde el toque, no el mensaje.
    final a = armar([
      dto(id: 1, destino: 'https://example.com/pagar'),
      dto(id: 2, destino: '//example.com/citas'),
      dto(id: 3, destino: 'carecar://citas'),
    ]);

    final pagina = await a.repo.bandeja();

    expect(pagina.avisos, hasLength(3));
    expect(pagina.avisos.every((x) => x.destino == null), isTrue);
  });

  test('leidaEn se vuelve el booleano que la pantalla necesita', () async {
    final a = armar([
      dto(id: 1),
      dto(id: 2, leidaEn: DateTime.utc(2026, 11, 21)),
    ]);

    final pagina = await a.repo.bandeja();

    expect(pagina.avisos.map((x) => x.leida), [false, true]);
  });

  test('el total sin leer viene del servidor, no se recuenta', () async {
    final a = armar([dto(id: 1), dto(id: 2)]);

    final pagina = await a.repo.bandeja();

    expect(pagina.noLeidos, 2);
  });

  test('marcar pasa el id, y marcar todos no lo necesita', () async {
    final a = armar([dto()]);

    await a.repo.marcarLeido(7);
    await a.repo.marcarTodosLeidos();

    expect(a.api.avisosMarcados, [7]);
    expect(a.api.avisosLeidosEnLote, 1);
  });
}
