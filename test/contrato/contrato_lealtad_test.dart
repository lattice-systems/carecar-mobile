import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'ResumenLealtad': {
    'saldo',
    'nivel',
    'ganados',
    'siguienteNivel',
    'puntosParaSiguiente',
    'codigoReferido',
  },
  'MovimientoPuntos': {
    'id',
    'puntos',
    'motivo',
    'referenciaTipo',
    'referenciaId',
    'creadoEn',
  },
  'PaginaMovimientosPuntos': {
    'contenido',
    'pagina',
    'tamano',
    'totalElementos',
    'totalPaginas',
  },
  'Recompensa': {'id', 'nombre', 'descripcion', 'puntos', 'existencia'},
  'CanjearRecompensa': {'recompensaId'},
  'Canje': {
    'id',
    'codigo',
    'recompensa',
    'puntos',
    'estado',
    'venceEn',
    'usadoEn',
    'creadoEn',
  },
  'ReferirAmigo': {'nombre', 'telefono', 'correo', 'consentimiento'},
  'Referido': {
    'id',
    'nombre',
    'estado',
    'puntos',
    'creadoEn',
    'recompensadoEn',
  },
  'AvisoPuntosMovidos': {'puntos', 'motivo', 'saldo'},
};

const _operaciones = <String>{
  'GET /lealtad',
  'GET /lealtad/movimientos',
  'GET /lealtad/recompensas',
  'GET /lealtad/canjes',
  'POST /lealtad/canjes',
  'GET /lealtad/referidos',
  'POST /lealtad/referidos',
};

List<String> _enumeracion(YamlMap esquema) =>
    (esquema['enum'] as YamlList).cast<String>().toList();

void main() {
  late YamlMap contrato;
  late YamlMap esquemas;

  setUpAll(() {
    contrato = loadYaml(File(_rutaContratoV2).readAsStringSync()) as YamlMap;
    esquemas = contrato['components']['schemas'] as YamlMap;
  });

  group('el contrato v2 trae lealtad y recompensas (V2-M12)', () {
    test('la version es 2.19.0 o posterior', () {
      final partes = (contrato['info']['version'] as String)
          .split('.')
          .map(int.parse)
          .toList();
      expect(partes[0], 2);
      expect(partes[1], greaterThanOrEqualTo(19));
    });

    test('cada esquema tiene exactamente sus propiedades', () {
      _propiedades.forEach((nombre, esperadas) {
        final reales = (esquemas[nombre]['properties'] as YamlMap).keys.toSet();
        expect(reales, esperadas, reason: nombre);
      });
    });

    test('niveles, motivos y estados son los que la app lee', () {
      expect(_enumeracion(esquemas['NivelLealtad'] as YamlMap), [
        'BRONCE',
        'PLATA',
        'ORO',
      ]);
      final movimiento = esquemas['MovimientoPuntos']['properties'] as YamlMap;
      expect(_enumeracion(movimiento['motivo'] as YamlMap), [
        'SERVICIO',
        'CANJE',
        'DEVOLUCION_CANJE',
        'REFERIDO',
        'AJUSTE',
      ]);
      expect(_enumeracion(movimiento['referenciaTipo'] as YamlMap), [
        'ORDEN',
        'CANJE',
        'REFERIDO',
      ]);
      final canje = esquemas['Canje']['properties'] as YamlMap;
      expect(_enumeracion(canje['estado'] as YamlMap), [
        'VIGENTE',
        'USADO',
        'VENCIDO',
      ]);
      final referido = esquemas['Referido']['properties'] as YamlMap;
      expect(_enumeracion(referido['estado'] as YamlMap), [
        'REGISTRADO',
        'EN_SEGUIMIENTO',
        'COMPRO',
        'DESCARTADO',
      ]);
    });

    test('el ticket dice cuantos puntos dio la orden (V2-M12.02)', () {
      final ticket = esquemas['ServicioDetalle']['properties'] as YamlMap;
      expect(ticket['puntosGanados']['nullable'], isTrue);
    });

    test('declara sus operaciones', () {
      final enElContrato = <String>{};
      (contrato['paths'] as YamlMap).forEach((ruta, operaciones) {
        (operaciones as YamlMap).forEach((metodo, _) {
          enElContrato.add('${(metodo as String).toUpperCase()} $ruta');
        });
      });
      expect(enElContrato.containsAll(_operaciones), isTrue);
    });

    test('canjear y referir pueden dar 409 y la app mapea sus codigos', () {
      final paths = contrato['paths'] as YamlMap;
      for (final ruta in ['/lealtad/canjes', '/lealtad/referidos']) {
        final respuestas = paths[ruta]['post']['responses'] as YamlMap;
        expect(respuestas.containsKey('201'), isTrue, reason: ruta);
        expect(respuestas.containsKey('409'), isTrue, reason: ruta);
      }
      final codigos =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>()
              .toSet();
      const esperados = {
        'SALDO_INSUFICIENTE',
        'RECOMPENSA_AGOTADA',
        'REFERIDO_DUPLICADO',
        'LIMITE_REFERIDOS',
      };
      expect(codigos.containsAll(esperados), isTrue);
      expect(
        CodigoProblema.values.map((c) => c.enElContrato),
        containsAll(esperados),
      );
    });

    test('el canal en vivo anuncia puntos.movidos', () {
      final descripcion =
          contrato['paths']['/eventos']['get']['description'] as String;
      expect(descripcion, contains('puntos.movidos'));
    });
  });
}
