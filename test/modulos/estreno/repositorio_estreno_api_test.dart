import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/estreno/datos/repositorio_estreno_api.dart';
import 'package:carecar_mobile/modulos/estreno/dominio/estreno.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../ayudas/api_falsa.dart';

Problema _problema(String codigo, int status) => Problema.fromJson({
  'timestamp': '2026-11-24T18:00:00Z',
  'status': status,
  'error': 'x',
  'message': 'x',
  'path': '/api/v1/app/estreno/solicitudes',
  'codigo': codigo,
});

/// Lo que falla al pedir una cotización cuando el servidor responde [error].
Future<FalloEstreno> _falloAlPedir(Object error) async {
  final api = ApiFalsa()..alCrearSolicitudEstreno = (_) => Future.error(error);
  try {
    await RepositorioEstrenoApi(api)
        .pedirCotizacion(modeloId: 1, enganche: 1, plazoMeses: 12);
  } on FalloEstreno catch (f) {
    return f;
  }
  fail('no fallo');
}

const _cotizacion = CotizacionEstreno(
  precio: 300000,
  enganche: 60000,
  montoFinanciado: 240000,
  tasaAnual: 0.1499,
  plazoMeses: 48,
  mensualidad: 6678.16,
  leyenda: 'Estimación no vinculante.',
);

void main() {
  group('RepositorioEstrenoApi (V2-M16)', () {
    test('calcula la mensualidad', () async {
      final api = ApiFalsa()
        ..alCalcularMensualidad = (modelo, enganche, plazo) async {
          expect((modelo, enganche, plazo), (7, 60000.0, 48));
          return _cotizacion;
        };
      final m = await RepositorioEstrenoApi(api)
          .calcular(modeloId: 7, enganche: 60000, plazoMeses: 48);
      expect(m.mensualidad, 6678.16);
      expect(m.leyenda, contains('no vinculante'));
    });

    test('pide la prueba con dia, franja y estimacion', () async {
      NuevaSolicitudEstreno? enviada;
      final api = ApiFalsa()
        ..alCrearSolicitudEstreno = (n) async {
          enviada = n;
          return SolicitudEstreno(
            id: 1,
            tipo: 'PRUEBA_MANEJO',
            modeloCatalogoId: 7,
            modelo: 'Nissan Kicks 2026',
            estado: 'RECIBIDA',
            creadaEn: DateTime(2026, 11, 24),
          );
        };
      final s = await RepositorioEstrenoApi(api).pedirPrueba(
        modeloId: 7,
        fecha: DateTime(2026, 11, 26),
        franja: FranjaPreferida.tarde,
        estimacionId: 3,
      );
      expect(enviada!.toJson(), {
        'tipo': 'PRUEBA_MANEJO',
        'modeloCatalogoId': 7,
        'preferenciaFecha': '2026-11-26',
        'preferenciaFranja': 'TARDE',
        'estimacionTomaCuentaId': 3,
      });
      expect(s.estado, EstadoSolicitud.recibida);
    });

    test('traduce los errores por su codigo', () async {
      final falloDe = _falloAlPedir;

      expect(
        await falloDe(
          Conflicto('x', problema: _problema('ESTRENO_DUPLICADA', 409)),
        ),
        isA<EstrenoDuplicada>(),
      );
      expect(
        await falloDe(
          Conflicto('x', problema: _problema('ESTRENO_SIN_PRECIO', 409)),
        ),
        isA<EstrenoSinPrecio>(),
      );
      expect(await falloDe(const SinConexion()), isA<EstrenoSinConexion>());
      expect(
        await falloDe(DatosInvalidos('El plazo debe ser uno de [12, 24]')),
        isA<EstrenoDatosInvalidos>(),
      );
    });

    test('lee el estado y el vendedor de mis solicitudes', () async {
      final api = ApiFalsa()
        ..alPedirSolicitudesEstreno = (_) async => Pagina(
          contenido: [
            SolicitudEstreno(
              id: 1,
              tipo: 'COTIZACION',
              modeloCatalogoId: 7,
              modelo: 'Nissan Kicks 2026',
              estado: 'EN_ATENCION',
              vendedor: 'Vera',
              cotizacion: _cotizacion,
              creadaEn: DateTime(2026, 11, 24),
            ),
          ],
        );
      final p = await RepositorioEstrenoApi(api).solicitudes();
      expect(p.solicitudes.single.estado, EstadoSolicitud.enAtencion);
      expect(p.solicitudes.single.vendedor, 'Vera');
      expect(p.solicitudes.single.cotizacion!.plazoMeses, 48);
      expect(p.hayMas, isFalse);
    });

    test('pide la cotizacion con enganche, plazo y estimacion', () async {
      NuevaSolicitudEstreno? enviada;
      final api = ApiFalsa()
        ..alCrearSolicitudEstreno = (n) async {
          enviada = n;
          return SolicitudEstreno(
            id: 2,
            tipo: 'COTIZACION',
            modeloCatalogoId: 7,
            modelo: 'Nissan Kicks 2026',
            estado: 'RECIBIDA',
            cotizacion: _cotizacion,
            creadaEn: DateTime(2026, 11, 24),
          );
        };
      final s = await RepositorioEstrenoApi(api).pedirCotizacion(
        modeloId: 7,
        enganche: 60000,
        plazoMeses: 48,
        estimacionId: 3,
      );
      expect(enviada!.toJson(), {
        'tipo': 'COTIZACION',
        'modeloCatalogoId': 7,
        'enganche': 60000,
        'plazoMeses': 48,
        'estimacionTomaCuentaId': 3,
      });
      expect(s.tipo, TipoSolicitud.cotizacion);
      expect(s.cotizacion!.mensualidad, 6678.16);
    });

    test('lee el tipo, el dia y la franja de una prueba', () async {
      final api = ApiFalsa()
        ..alCrearSolicitudEstreno = (_) async => SolicitudEstreno(
          id: 1,
          tipo: 'PRUEBA_MANEJO',
          modeloCatalogoId: 7,
          modelo: 'Nissan Kicks 2026',
          estado: 'RECIBIDA',
          preferenciaFecha: DateTime(2026, 11, 26),
          preferenciaFranja: 'MANANA',
          creadaEn: DateTime(2026, 11, 24),
        );
      final s = await RepositorioEstrenoApi(api).pedirPrueba(
        modeloId: 7,
        fecha: DateTime(2026, 11, 26),
        franja: FranjaPreferida.manana,
      );
      expect(s.tipo, TipoSolicitud.pruebaManejo);
      expect(s.fecha, DateTime(2026, 11, 26));
      expect(s.franja, FranjaPreferida.manana);
    });

    test('hay mas paginas mientras no sea la ultima', () async {
      final api = ApiFalsa()
        ..alPedirSolicitudesEstreno = (n) async => Pagina<SolicitudEstreno>(
          contenido: const [],
          pagina: n,
          totalPaginas: 3,
        );
      final repo = RepositorioEstrenoApi(api);
      expect((await repo.solicitudes()).hayMas, isTrue);
      expect((await repo.solicitudes(pagina: 1)).hayMas, isTrue);
      expect((await repo.solicitudes(pagina: 2)).hayMas, isFalse);
    });

    test('un error del servidor o un codigo nuevo es no disponible', () async {
      expect(
        await _falloAlPedir(const ErrorDelServidor('x', status: 500)),
        isA<EstrenoNoDisponible>(),
      );
      expect(
        await _falloAlPedir(
          Conflicto('x', problema: _problema('CODIGO_NUEVO', 409)),
        ),
        isA<EstrenoNoDisponible>(),
      );
    });

    test('los datos invalidos traen el mensaje del servidor', () async {
      final fallo = await _falloAlPedir(
        DatosInvalidos('El enganche debe ser de al menos \$32990'),
      );
      expect(
        (fallo as EstrenoDatosInvalidos).mensaje,
        'El enganche debe ser de al menos \$32990',
      );
    });
  });
}
