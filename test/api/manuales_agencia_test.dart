import 'dart:typed_data';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/manuales/servicio_manuales.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../ayudas/api_falsa.dart';

const _march = Vehiculo(
  id: 2,
  vin: '3N1CK3CD7RL900001',
  marca: 'Nissan',
  modelo: 'March',
  anio: 2026,
);

const _manual = Manual(
  id: 1,
  modelo: 'March',
  anio: 2026,
  url: 'http://localhost:8080/api/v1/app/manuales/1/archivo?firma=x',
  marca: 'Nissan',
  titulo: 'Nissan March 2026 Manual de propietario',
);

/// Respaldo que se puede vigilar.
class _Respaldo implements ServicioManuales {
  int llamadas = 0;

  @override
  Future<DocumentoManual> cargar(Vehiculo vehiculo) async {
    llamadas++;
    return DocumentoManual(
      titulo: 'local',
      identificador: 'assets/local.pdf',
      bytes: Uint8List.fromList([1]),
    );
  }
}

void main() {
  test('usa el manual que publica la agencia', () async {
    final api = ApiFalsa()..alPedirManuales = (_) async => const [_manual];
    final respaldo = _Respaldo();
    final servicio = ManualesDeLaAgencia(
      api: api,
      respaldo: respaldo,
      cliente: MockClient((peticion) async {
        expect(peticion.url.toString(), _manual.url);
        return http.Response.bytes([37, 80, 68, 70], 200);
      }),
    );

    final doc = await servicio.cargar(_march);

    expect(doc.titulo, 'Nissan March 2026');
    expect(doc.identificador, 'agencia:1');
    expect(doc.bytes, [37, 80, 68, 70]);
    expect(respaldo.llamadas, 0);
  });

  test('sin manual de la agencia usa el incluido en la app', () async {
    final respaldo = _Respaldo();
    final servicio = ManualesDeLaAgencia(
      api: ApiFalsa(),
      respaldo: respaldo,
      cliente: MockClient((_) async => fail('no debe descargar')),
    );

    final doc = await servicio.cargar(_march);

    expect(doc.identificador, 'assets/local.pdf');
    expect(respaldo.llamadas, 1);
  });

  test('si la API o la descarga fallan usa el incluido en la app', () async {
    for (final (api, codigo) in [
      (
        ApiFalsa()..alPedirManuales = (_) async => throw const SinConexion(),
        200,
      ),
      (ApiFalsa()..alPedirManuales = (_) async => const [_manual], 403),
    ]) {
      final respaldo = _Respaldo();
      final servicio = ManualesDeLaAgencia(
        api: api,
        respaldo: respaldo,
        cliente: MockClient((_) async => http.Response('', codigo)),
      );

      await servicio.cargar(_march);

      expect(respaldo.llamadas, 1);
    }
  });

  test('sin tipo resuelve el manual incluido con el modelo', () {
    const march2020 = Vehiculo(
      id: 1,
      vin: 'X',
      marca: 'Nissan',
      modelo: 'March',
      anio: 2020,
    );
    expect(
      ResolverManual.identificar(march2020),
      'assets/Manuales/Nissan/March/2020/NissanMarch2020Manual.pdf',
    );
  });
}
