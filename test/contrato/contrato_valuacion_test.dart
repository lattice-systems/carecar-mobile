import 'dart:io';

import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/valuacion/datos/lectura_valuacion.dart';
import 'package:carecar_mobile/modulos/valuacion/valuacion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _rutaContratoV2 = 'api/agencia360-api-app-v2.yaml';

const _propiedades = <String, Set<String>>{
  'NuevaValuacion': {'estimacionTomaCuentaId'},
  'Valuacion': {
    'id',
    'estado',
    'creadaEn',
    'vehiculoId',
    'estimacion',
    'fotos',
    'puedeAgendar',
    'cita',
    'oferta',
    'respondidaEn',
    'asesor',
  },
  'PaginaValuaciones': {
    'contenido',
    'pagina',
    'tamano',
    'totalElementos',
    'totalPaginas',
  },
  'FotoValuacion': {'toma', 'url', 'subidaEn'},
  'InspeccionValuacion': {'citaId', 'fecha', 'horaInicio', 'horaFin'},
  'OfertaValuacion': {'monto', 'vigenciaHasta', 'nota', 'ofertadaEn'},
  'AgendarInspeccion': {'franjaId', 'fecha'},
  'RespuestaOferta': {'aceptada', 'monto'},
  'ValorEstimado': {'vehiculoId', 'puntos'},
  'PuntoValorEstimado': {
    'mes',
    'estimacionTomaCuentaId',
    'creadaEn',
    'minimo',
    'maximo',
    'medio',
    'km',
    'estado',
  },
  'AvisoValuacionOferta': {'valuacionId', 'vehiculoId', 'vigenciaHasta'},
};

const _obligatorias = <String, Set<String>>{
  'Valuacion': {
    'id',
    'estado',
    'creadaEn',
    'vehiculoId',
    'estimacion',
    'fotos',
    'puedeAgendar',
  },
};

/// Cada operacion con los codigos de error que la app explica.
const _operaciones = <String, Set<String>>{
  'post /valuaciones': {'201', '200', '404', '422'},
  'get /valuaciones': {'200'},
  'get /valuaciones/{valuacionId}': {'200', '404'},
  'post /valuaciones/{valuacionId}/fotos/{toma}': {'200', '404', '409'},
  'post /valuaciones/{valuacionId}/cita': {'201', '404', '409'},
  'post /valuaciones/{valuacionId}/respuesta': {'200', '404', '409'},
  'get /vehiculos/{vehiculoId}/valor-estimado': {'200', '400', '404'},
};

const _codigos = {
  'VALUACION_SIN_VEHICULO',
  'VALUACION_CERRADA',
  'VALUACION_NO_AGENDABLE',
  'OFERTA_VENCIDA',
  'OFERTA_NO_DISPONIBLE',
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

  group('el contrato v2 trae la valuacion formal (V2-M26)', () {
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

    test('lo que la app lee sin preguntar es obligatorio', () {
      _obligatorias.forEach((nombre, esperadas) {
        expect(
          (esquemas[nombre]['required'] as YamlList).toSet(),
          esperadas,
          reason: nombre,
        );
      });
    });

    test('declara sus operaciones con sus respuestas', () {
      _operaciones.forEach((operacion, esperadas) {
        final [metodo, ruta] = operacion.split(' ');
        final respuestas =
            contrato['paths'][ruta]?[metodo]?['responses'] as YamlMap?;
        expect(respuestas, isNotNull, reason: operacion);
        expect(
          respuestas!.keys.map((k) => '$k'),
          containsAll(esperadas),
          reason: operacion,
        );
      });
    });

    test('las 8 tomas son las de la app y en el mismo orden', () {
      expect(_enumeracion(esquemas['TomaValuacion'] as YamlMap), [
        for (final t in TomaValuacion.values) tomasEnElContrato[t],
      ]);
    });

    test('los estados son los que la app lee', () {
      expect(
        _enumeracion(esquemas['EstadoValuacion'] as YamlMap),
        estadosEnElContrato.values.toList(),
      );
      // Todos menos la red de seguridad.
      expect(
        estadosEnElContrato.keys,
        EstadoValuacion.values.where((e) => e != EstadoValuacion.desconocido),
      );
    });

    test('la inspeccion usa el motivo valuacion', () {
      expect(
        _enumeracion(esquemas['MotivoCita'] as YamlMap),
        contains('valuacion'),
      );
    });

    test('la foto va en el campo imagen', () {
      final esquema =
          contrato['paths']['/valuaciones/{valuacionId}/fotos/{toma}']['post']['requestBody']['content']['multipart/form-data']['schema']
              as YamlMap;
      expect((esquema['properties'] as YamlMap).keys, ['imagen']);
    });

    test('los cinco codigos estan en el contrato y en la app', () {
      final codigos =
          (esquemas['Problema']['properties']['codigo']['enum'] as YamlList)
              .cast<String>()
              .toSet();
      expect(codigos, containsAll(_codigos));
      expect(
        CodigoProblema.values.map((c) => c.enElContrato),
        containsAll(_codigos),
      );
    });

    test('el canal en vivo anuncia la oferta', () {
      final descripcion =
          contrato['paths']['/eventos']['get']['description'] as String;
      expect(descripcion, contains('valuacion.oferta'));
    });
  });
}
