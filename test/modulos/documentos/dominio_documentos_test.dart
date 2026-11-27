import 'package:carecar_mobile/modulos/documentos/dominio/documento_vehiculo.dart';
import 'package:carecar_mobile/modulos/documentos/dominio/poliza_para_llamar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas_documentos.dart';

void main() {
  group('tipos y estados del contrato', () {
    test('cada tipo del contrato se reconoce', () {
      expect(TipoDocumento.desde('POLIZA'), TipoDocumento.poliza);
      expect(
        TipoDocumento.desde('TARJETA_CIRCULACION'),
        TipoDocumento.tarjetaCirculacion,
      );
      expect(TipoDocumento.desde('VERIFICACION'), TipoDocumento.verificacion);
      expect(TipoDocumento.desde('TENENCIA'), TipoDocumento.tenencia);
      expect(TipoDocumento.desde('LICENCIA'), TipoDocumento.licencia);
      expect(TipoDocumento.desde('GARANTIA'), TipoDocumento.garantia);
      expect(TipoDocumento.desde('FACTURA'), TipoDocumento.factura);
      expect(TipoDocumento.desde('OTRO'), TipoDocumento.otro);
    });

    test('un tipo que la app no conoce se trata como otro', () {
      expect(TipoDocumento.desde('SEGURO_NUEVO'), TipoDocumento.otro);
      expect(TipoDocumento.desde(null), TipoDocumento.otro);
    });

    test('cada estado del contrato se reconoce', () {
      expect(EstadoDocumento.desde('VIGENTE'), EstadoDocumento.vigente);
      expect(EstadoDocumento.desde('POR_VENCER'), EstadoDocumento.porVencer);
      expect(EstadoDocumento.desde('VENCIDO'), EstadoDocumento.vencido);
      expect(EstadoDocumento.desde('SIN_FECHA'), EstadoDocumento.sinFecha);
    });

    test('un estado desconocido no inventa un vencimiento', () {
      expect(EstadoDocumento.desde('RARO'), EstadoDocumento.sinFecha);
      expect(EstadoDocumento.desde(null), EstadoDocumento.sinFecha);
    });

    test('el origen distingue a la agencia del cliente', () {
      expect(OrigenDocumento.desde('AGENCIA'), OrigenDocumento.agencia);
      expect(OrigenDocumento.desde('CLIENTE'), OrigenDocumento.cliente);
      expect(OrigenDocumento.desde(null), OrigenDocumento.cliente);
    });
  });

  group('polizaParaLlamar (V2-M11.02)', () {
    test('sin documentos no hay aseguradora', () {
      expect(polizaParaLlamar(const []), isNull);
    });

    test('solo cuenta la poliza con nombre y telefono', () {
      expect(
        polizaParaLlamar([
          documento(tipo: TipoDocumento.verificacion),
          documento(
            tipo: TipoDocumento.poliza,
            aseguradora: 'Seguros Sol',
            telefono: null,
          ),
          documento(tipo: TipoDocumento.poliza, telefono: '800 111 2222'),
        ]),
        isNull,
      );
    });

    test('una poliza vencida no sirve para llamar', () {
      expect(
        polizaParaLlamar([
          documento(
            tipo: TipoDocumento.poliza,
            estado: EstadoDocumento.vencido,
            aseguradora: 'Seguros Sol',
            telefono: '800 111 2222',
          ),
        ]),
        isNull,
      );
    });

    test('una poliza por vencer todavia protege', () {
      final poliza = polizaParaLlamar([
        documento(
          tipo: TipoDocumento.poliza,
          estado: EstadoDocumento.porVencer,
          aseguradora: 'Seguros Sol',
          telefono: '800 111 2222',
        ),
      ]);
      expect(poliza?.aseguradora, 'Seguros Sol');
      expect(poliza?.telefonoAseguradora, '800 111 2222');
    });

    test('entre dos polizas gana la vigente a la por vencer', () {
      final poliza = polizaParaLlamar([
        documento(
          id: 1,
          tipo: TipoDocumento.poliza,
          estado: EstadoDocumento.porVencer,
          aseguradora: 'Vieja',
          telefono: '800 000 0001',
        ),
        documento(
          id: 2,
          tipo: TipoDocumento.poliza,
          estado: EstadoDocumento.vigente,
          aseguradora: 'Nueva',
          telefono: '800 000 0002',
        ),
      ]);
      expect(poliza?.id, 2);
    });
  });
}
