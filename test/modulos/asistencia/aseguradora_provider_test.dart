import 'dart:async';

import 'package:carecar_mobile/modulos/asistencia/asistencia.dart';
import 'package:carecar_mobile/modulos/documentos/datos/repositorio_documentos_fake.dart';
import 'package:carecar_mobile/modulos/documentos/dominio/documento_vehiculo.dart';
import 'package:carecar_mobile/modulos/documentos/dominio/repositorio_documentos.dart';
import 'package:carecar_mobile/modulos/documentos/documentos.dart';
import 'package:carecar_mobile/modulos/vehiculos/datos/repositorio_garaje_fake.dart';
import 'package:carecar_mobile/modulos/vehiculos/vehiculos.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../documentos/ayudas_documentos.dart';

DocumentoVehiculo _poliza({
  int id = 1,
  int vehiculoId = 1,
  EstadoDocumento estado = EstadoDocumento.vigente,
  String? aseguradora = 'Seguros Sol',
  String? telefono = '800 111 2222',
}) => documento(
  id: id,
  vehiculoId: vehiculoId,
  tipo: TipoDocumento.poliza,
  estado: estado,
  aseguradora: aseguradora,
  telefono: telefono,
);

/// Un contenedor con el garaje de ejemplo (autos 1 y 2) y estos documentos.
ProviderContainer _contenedor(
  RepositorioDocumentos documentos, {
  RepositorioGarajeFake? garaje,
}) {
  final contenedor = ProviderContainer(
    overrides: [
      repositorioGarajeProvider.overrideWithValue(
        garaje ?? RepositorioGarajeFake(),
      ),
      repositorioDocumentosProvider.overrideWithValue(documentos),
    ],
  );
  addTearDown(contenedor.dispose);
  return contenedor;
}

/// Espera a que el garaje y los documentos de sus autos terminen de cargar y
/// deja la aseguradora a la escucha para que no se libere en medio.
Future<Aseguradora?> _aseguradora(ProviderContainer contenedor) async {
  contenedor.listen(aseguradoraProvider, (_, _) {});
  contenedor.listen(aseguradoraCargandoProvider, (_, _) {});
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
  return contenedor.read(aseguradoraProvider);
}

class _DocumentosLentos implements RepositorioDocumentos {
  final espera = Completer<List<DocumentoVehiculo>>();

  @override
  Future<List<DocumentoVehiculo>> documentos(int vehiculoId) => espera.future;
}

void main() {
  group('aseguradoraProvider (V2-M11.02 con V2-M09.01)', () {
    test('toma la aseguradora y el telefono de la poliza vigente', () async {
      final contenedor = _contenedor(
        RepositorioDocumentosFake(documentos: [_poliza()]),
      );

      final aseguradora = await _aseguradora(contenedor);

      expect(aseguradora?.nombre, 'Seguros Sol');
      expect(aseguradora?.telefono, '800 111 2222');
    });

    test('la busca en todos los autos del garaje', () async {
      final contenedor = _contenedor(
        RepositorioDocumentosFake(documentos: [_poliza(vehiculoId: 2)]),
      );

      expect((await _aseguradora(contenedor))?.nombre, 'Seguros Sol');
    });

    test('sin poliza no hay aseguradora y no se inventa una', () async {
      final contenedor = _contenedor(RepositorioDocumentosFake());

      expect(await _aseguradora(contenedor), isNull);
      expect(contenedor.read(aseguradoraCargandoProvider), isFalse);
    });

    test('una poliza vencida no sirve', () async {
      final contenedor = _contenedor(
        RepositorioDocumentosFake(
          documentos: [_poliza(estado: EstadoDocumento.vencido)],
        ),
      );

      expect(await _aseguradora(contenedor), isNull);
    });

    test('una poliza sin telefono no sirve', () async {
      final contenedor = _contenedor(
        RepositorioDocumentosFake(documentos: [_poliza(telefono: null)]),
      );

      expect(await _aseguradora(contenedor), isNull);
    });

    test('si la poliza esta por vencer todavia se puede llamar', () async {
      final contenedor = _contenedor(
        RepositorioDocumentosFake(
          documentos: [_poliza(estado: EstadoDocumento.porVencer)],
        ),
      );

      expect((await _aseguradora(contenedor))?.nombre, 'Seguros Sol');
    });

    test(
      'si falla leer los documentos no hay aseguradora ni se rompe',
      () async {
        final contenedor = _contenedor(
          RepositorioDocumentosFake(
            documentos: [_poliza()],
            falla: Exception('sin red'),
          ),
        );

        expect(await _aseguradora(contenedor), isNull);
        expect(contenedor.read(aseguradoraCargandoProvider), isFalse);
      },
    );

    test('si falla el garaje no hay aseguradora ni se rompe', () async {
      final contenedor = _contenedor(
        RepositorioDocumentosFake(documentos: [_poliza()]),
        garaje: RepositorioGarajeFake(fallar: true),
      );

      expect(await _aseguradora(contenedor), isNull);
      expect(contenedor.read(aseguradoraCargandoProvider), isFalse);
    });

    test('mientras carga lo dice y despues entrega la aseguradora', () async {
      final lentos = _DocumentosLentos();
      final contenedor = _contenedor(lentos);
      contenedor.listen(aseguradoraProvider, (_, _) {});
      contenedor.listen(aseguradoraCargandoProvider, (_, _) {});
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(contenedor.read(aseguradoraCargandoProvider), isTrue);
      expect(contenedor.read(aseguradoraProvider), isNull);

      lentos.espera.complete([_poliza()]);
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(contenedor.read(aseguradoraCargandoProvider), isFalse);
      expect(contenedor.read(aseguradoraProvider)?.nombre, 'Seguros Sol');
    });
  });
}
