import 'package:carecar_mobile/modulos/asistencia/dominio/contacto_de_llamada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('siempre ofrece el 911 y la agencia, en ese orden de importancia', () {
    final contactos = contactosDeLlamada(
      telefonoAgencia: '+52 477 123 4567',
      aseguradora: null,
    );
    expect(contactos.map((c) => c.tipo), [
      TipoContacto.emergencias,
      TipoContacto.agencia,
      TipoContacto.aseguradora,
    ]);
    expect(contactos.first.telefono, '911');
  });

  test('sin aseguradora registrada el contacto queda sin numero', () {
    final aseguradora = contactosDeLlamada(
      telefonoAgencia: '+52 477 123 4567',
      aseguradora: null,
    ).last;
    expect(aseguradora.telefono, isNull);
    expect(aseguradora.puedeLlamar, isFalse);
  });

  test('con aseguradora registrada se puede llamar y trae su nombre', () {
    final aseguradora = contactosDeLlamada(
      telefonoAgencia: '+52 477 123 4567',
      aseguradora: const Aseguradora(
        nombre: 'Seguros Sol',
        telefono: '800 111 2222',
      ),
    ).last;
    expect(aseguradora.nombre, 'Seguros Sol');
    expect(aseguradora.puedeLlamar, isTrue);
  });

  test('el enlace tel: quita espacios y guiones pero conserva el +', () {
    const c = ContactoDeLlamada(
      tipo: TipoContacto.agencia,
      telefono: '+52 (477) 123-4567',
    );
    expect(c.enlace, Uri.parse('tel:+524771234567'));
  });

  test('un numero con solo basura no se puede llamar', () {
    const c = ContactoDeLlamada(tipo: TipoContacto.agencia, telefono: 'abc');
    expect(c.puedeLlamar, isFalse);
  });
}
