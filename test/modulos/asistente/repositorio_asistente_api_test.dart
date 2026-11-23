import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/asistente/datos/repositorio_asistente_api.dart';
import 'package:carecar_mobile/modulos/asistente/dominio/repositorio_asistente.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

Problema _problema(String codigo, int status) => Problema.fromJson({
  'timestamp': '2026-11-23T18:00:00Z',
  'status': status,
  'error': 'x',
  'message': 'x',
  'path': '/api/v1/app/asistente/preguntas',
  'codigo': codigo,
});

void main() {
  group('RepositorioAsistenteApi (V2-M24.03)', () {
    test('traduce la respuesta con sus paginas citadas', () async {
      final api = ApiFalsa()
        ..alPreguntarAlAsistente = (vehiculoId, pregunta) async {
          expect(vehiculoId, 7);
          expect(pregunta, '¿Aceite?');
          return const RespuestaAsistente(
            consultaId: 3,
            respuesta: 'Cada 10 000 km.',
            encontrado: true,
            fuentes: [FuenteAsistente(manualId: 26, pagina: 12)],
          );
        };

      final r = await RepositorioAsistenteApi(api)
          .preguntar(vehiculoId: 7, pregunta: '¿Aceite?');

      expect(r.texto, 'Cada 10 000 km.');
      expect(r.encontrado, isTrue);
      expect(r.fuentes.single.pagina, 12);
      expect(r.fuentes.single.manualId, 26);
    });

    Future<FalloAsistente> falloDe(ExcepcionApi error) async {
      final api = ApiFalsa()
        ..alPreguntarAlAsistente = (_, _) => Future.error(error);
      try {
        await RepositorioAsistenteApi(api)
            .preguntar(vehiculoId: 1, pregunta: 'x');
      } on FalloAsistente catch (fallo) {
        return fallo;
      }
      fail('Debio fallar');
    }

    test('decide cada error por su codigo, no por el texto', () async {
      expect(await falloDe(const SinConexion()), isA<AsistenteSinConexion>());
      expect(
        await falloDe(
          Conflicto('x', problema: _problema('ASISTENTE_SIN_MANUAL', 409)),
        ),
        isA<AsistenteSinManual>(),
      );
      expect(
        await falloDe(
          DemasiadosIntentos('x', problema: _problema('ASISTENTE_LIMITE', 429)),
        ),
        isA<AsistenteLimiteDiario>(),
      );
      expect(
        await falloDe(
          ErrorDelServidor(
            'x',
            problema: _problema('ASISTENTE_NO_DISPONIBLE', 503),
            status: 503,
          ),
        ),
        isA<AsistenteNoDisponible>(),
      );
    });

    test('solo se reintenta lo que puede cambiar al volver a intentar', () {
      expect(const AsistenteSinConexion().sePuedeReintentar, isTrue);
      expect(const AsistenteNoDisponible().sePuedeReintentar, isTrue);
      expect(const AsistenteSinManual().sePuedeReintentar, isFalse);
      expect(const AsistenteLimiteDiario().sePuedeReintentar, isFalse);
    });
  });
}
