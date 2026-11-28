// V2-M27.03 · el contacto de la agencia sale de la sucursal principal y, si no
// hay, de la config de la agencia.
import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/contacto_de_agencia.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/sucursal.dart';
import 'package:flutter_test/flutter_test.dart';

const _principal = Sucursal(
  id: 1,
  nombre: 'CareCar León',
  direccion: 'Blvd. Ejemplo 100, Col. Centro, 37000 León, Gto.',
  latitud: 21.125,
  longitud: -101.686,
  telefono: '+52 477 111 2233',
  correo: 'leon@carecar.mx',
  abiertaAhora: true,
);

void main() {
  group('ContactoDeAgencia.deSucursal', () {
    test('toma teléfono, correo y dirección de la sucursal', () {
      final contacto = ContactoDeAgencia.deSucursal(_principal);

      expect(contacto.telefono, '+52 477 111 2233');
      expect(contacto.correo, 'leon@carecar.mx');
      expect(contacto.direccion, _principal.direccion);
      expect(contacto.nombreSucursal, 'CareCar León');
      expect(contacto.abiertaAhora, isTrue);
      expect(contacto.esRespaldo, isFalse);
    });

    test('la dirección del evento lleva el nombre y la dirección', () {
      expect(
        ContactoDeAgencia.deSucursal(_principal).direccionParaEvento,
        'CareCar León, Blvd. Ejemplo 100, Col. Centro, 37000 León, Gto.',
      );
    });

    test('lo que la sucursal no trae se completa con la config', () {
      const sinTelefonoNiCorreo = Sucursal(
        id: 2,
        nombre: 'CareCar Norte',
        direccion: 'Av. Norte 450',
        latitud: 21.15,
        longitud: -101.68,
        abiertaAhora: false,
      );

      final contacto = ContactoDeAgencia.deSucursal(sinTelefonoNiCorreo);

      expect(contacto.telefono, Agencia.telefono);
      expect(contacto.correo, Agencia.correo);
      expect(contacto.direccion, 'Av. Norte 450');
      expect(contacto.abiertaAhora, isFalse);
    });
  });

  group('ContactoDeAgencia.respaldo', () {
    test('usa los datos de Agencia y no dice que está abierta', () {
      const contacto = ContactoDeAgencia.respaldo();

      expect(contacto.telefono, Agencia.telefono);
      expect(contacto.correo, Agencia.correo);
      expect(contacto.direccion, Agencia.direccion);
      expect(contacto.nombreSucursal, isNull);
      expect(contacto.abiertaAhora, isNull);
      expect(contacto.esRespaldo, isTrue);
    });

    test('la dirección del evento es solo la dirección', () {
      expect(
        const ContactoDeAgencia.respaldo().direccionParaEvento,
        Agencia.direccion,
      );
    });
  });

  group('enlaces', () {
    test('llamar deja solo el más y los dígitos', () {
      expect(
        ContactoDeAgencia.deSucursal(_principal).enlaceDeLlamada.toString(),
        'tel:+524771112233',
      );
    });

    test('escribir es un mailto con el correo', () {
      expect(
        ContactoDeAgencia.deSucursal(_principal).enlaceDeCorreo.toString(),
        'mailto:leon@carecar.mx',
      );
    });
  });
}
