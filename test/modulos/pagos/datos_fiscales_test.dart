import 'package:carecar_mobile/modulos/pagos/dominio/datos_fiscales.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ayudas_pagos.dart';

BorradorPerfilFiscal _borrador({
  String rfc = 'GODE561231GR8',
  String razon = 'Dolores Gómez',
  String cp = '76000',
  String? regimen = '612',
  String? uso = 'G03',
  String correo = '',
}) => BorradorPerfilFiscal(
  rfc: rfc,
  razonSocial: razon,
  codigoPostal: cp,
  regimenFiscal: regimen,
  usoCfdi: uso,
  correo: correo,
);

void main() {
  group('ReglasRfc (las mismas del servidor)', () {
    test('acepta RFC con forma, fecha y digito del SAT', () {
      for (final rfc in [
        'EKU9003173C9',
        'GODE561231GR8',
        'MUÑO900516NL7',
        'A&B0101018UA',
        'PEGJ800229AB2',
      ]) {
        expect(ReglasRfc.problema(rfc), isNull, reason: rfc);
      }
    });

    test('dice por que no sirve', () {
      expect(ReglasRfc.problema(''), MotivoFiscal.rfcVacio);
      expect(ReglasRfc.problema('ABC123'), MotivoFiscal.rfcLargo);
      expect(ReglasRfc.problema('1234567890123'), MotivoFiscal.rfcForma);
      expect(ReglasRfc.problema('XAXX010101000'), MotivoFiscal.rfcGenerico);
      expect(ReglasRfc.problema('PEGJ810229AB5'), MotivoFiscal.rfcFecha);
      expect(ReglasRfc.problema('GODE561331GR8'), MotivoFiscal.rfcFecha);
      expect(ReglasRfc.problema('GODE561231GR9'), MotivoFiscal.rfcDigito);
    });

    test('el largo dice la persona', () {
      expect(TipoPersona.delRfc('EKU9003173C9'), TipoPersona.moral);
      expect(TipoPersona.delRfc('GODE561231GR8'), TipoPersona.fisica);
      expect(TipoPersona.delRfc('GODE'), isNull);
      expect(_borrador(rfc: ' gode561231gr8 ').rfcNormalizado, 'GODE561231GR8');
    });
  });

  group('CatalogoFiscal', () {
    test('ofrece los regimenes de la persona', () {
      final fisica = catalogoDeEjemplo.regimenesPara(TipoPersona.fisica);
      final moral = catalogoDeEjemplo.regimenesPara(TipoPersona.moral);
      expect(fisica.map((r) => r.clave), ['605', '612', '626']);
      expect(moral.map((r) => r.clave), ['601', '626']);
      expect(catalogoDeEjemplo.regimenesPara(null), hasLength(4));
    });

    test('ofrece los usos de la persona que acepta el regimen', () {
      expect(
        catalogoDeEjemplo
            .usosPara(TipoPersona.fisica, '605')
            .map((u) => u.clave),
        ['D01', 'S01'],
      );
      expect(
        catalogoDeEjemplo
            .usosPara(TipoPersona.moral, '601')
            .map((u) => u.clave),
        ['G03', 'I03', 'S01'],
      );
    });
  });

  group('BorradorPerfilFiscal.errores', () {
    test('sin errores cuando todo cumple', () {
      expect(_borrador().errores(catalogoDeEjemplo), isEmpty);
      expect(
        _borrador(
          rfc: 'EKU9003173C9',
          regimen: '601',
          correo: 'a@b.mx',
        ).errores(catalogoDeEjemplo),
        isEmpty,
      );
    });

    test('el correo pide arroba y un dominio con puntos bien puestos', () {
      for (final correo in [
        'lola@correo.mx',
        'ana.lopez+facturas@empresa.com.mx',
      ]) {
        expect(_borrador(correo: correo).errores(catalogoDeEjemplo), isEmpty);
      }
      for (final correo in [
        'lola@correo',
        'lola@@correo.mx',
        'lo la@correo.mx',
        'lola@.correo.mx',
        'lola@correo.mx.',
        'lola@correo..mx',
      ]) {
        expect(_borrador(correo: correo).errores(catalogoDeEjemplo), {
          CampoFiscal.correo: MotivoFiscal.correo,
        }, reason: correo);
      }
    });

    test('marca todos los campos que fallan', () {
      final errores = _borrador(
        rfc: 'GODE561231GR9',
        razon: ' ',
        cp: '760',
        regimen: null,
        uso: null,
        correo: 'sin-arroba',
      ).errores(catalogoDeEjemplo);

      expect(errores, {
        CampoFiscal.rfc: MotivoFiscal.rfcDigito,
        CampoFiscal.razonSocial: MotivoFiscal.razonSocialVacia,
        CampoFiscal.codigoPostal: MotivoFiscal.codigoPostal,
        CampoFiscal.regimenFiscal: MotivoFiscal.regimenFalta,
        CampoFiscal.usoCfdi: MotivoFiscal.usoFalta,
        CampoFiscal.correo: MotivoFiscal.correo,
      });
    });

    test('regimen y uso deben aplicar a la persona y combinar', () {
      expect(_borrador(rfc: 'EKU9003173C9').errores(catalogoDeEjemplo), {
        CampoFiscal.regimenFiscal: MotivoFiscal.regimenNoAplica,
      });
      expect(
        _borrador(
          rfc: 'EKU9003173C9',
          regimen: '601',
          uso: 'D01',
        ).errores(catalogoDeEjemplo),
        {CampoFiscal.usoCfdi: MotivoFiscal.usoNoAplica},
      );
      expect(_borrador(regimen: '605').errores(catalogoDeEjemplo), {
        CampoFiscal.usoCfdi: MotivoFiscal.usoNoAceptaRegimen,
      });
    });
  });
}
