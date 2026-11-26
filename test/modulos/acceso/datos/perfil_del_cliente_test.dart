import 'package:carecar_mobile/api/modelos/modelos.dart';
import 'package:carecar_mobile/modulos/acceso/datos/repositorio_acceso_api.dart';
import 'package:carecar_mobile/modulos/acceso/dominio/perfil_del_cliente.dart';
import 'package:carecar_mobile/nucleo/datos/fallo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../ayudas/api_falsa.dart';
import '../../../ayudas/fallos_de_prueba.dart';

/// V2-M01.06 · el perfil que lee la pantalla.
///
/// Lo que importa del dominio es que **distinga «no hay teléfono» de «hay un
/// teléfono vacío»**: la agencia no siempre lo captura, y la pantalla tiene
/// que poder decir que falta en vez de dejar un renglón en blanco.
void main() {
  Perfil delContrato({String? telefono}) => Perfil(
    id: 7,
    nombre: 'Ana López',
    correo: 'ana.lopez@correo.com',
    telefono: telefono,
    clienteDesde: DateTime(2024, 3, 15),
  );

  group('leer el perfil', () {
    test('traduce lo del contrato a dominio', () async {
      final api = ApiFalsa()
        ..alPedirPerfil = () async => delContrato(telefono: '477 123 4567');

      final perfil = await RepositorioAccesoApi(api).perfil();

      expect(perfil.nombre, 'Ana López');
      expect(perfil.correo, 'ana.lopez@correo.com');
      expect(perfil.telefono, '477 123 4567');
      expect(perfil.clienteDesde, DateTime(2024, 3, 15));
    });

    test('sin conexion sale como Fallo tipado', () async {
      final api = ApiFalsa()
        ..alPedirPerfil = () async => throw Fallos.sinConexion();

      await expectLater(
        RepositorioAccesoApi(api).perfil(),
        throwsA(
          isA<Fallo>().having((f) => f.esSinConexion, 'esSinConexion', isTrue),
        ),
      );
    });
  });

  group('el telefono que falta', () {
    test('sin telefono, no hay telefono', () {
      final perfil = PerfilDelCliente(
        nombre: 'Ana',
        correo: 'ana@correo.com',
        clienteDesde: DateTime(2024, 3),
      );

      expect(perfil.telefono, isNull);
      expect(perfil.tieneTelefono, isFalse);
    });

    test('un telefono en blanco cuenta como que no hay', () {
      // El backend guarda `varchar(20)` sin obligar a que tenga contenido, y
      // un espacio se pintaria como un renglon vacio que parece un error de
      // la app. Es lo mismo que no tenerlo.
      final perfil = PerfilDelCliente(
        nombre: 'Ana',
        correo: 'ana@correo.com',
        telefono: '   ',
        clienteDesde: DateTime(2024, 3),
      );

      expect(perfil.tieneTelefono, isFalse);
    });

    test('con telefono, se recorta', () {
      final perfil = PerfilDelCliente(
        nombre: 'Ana',
        correo: 'ana@correo.com',
        telefono: '  477 123 4567 ',
        clienteDesde: DateTime(2024, 3),
      );

      expect(perfil.tieneTelefono, isTrue);
      expect(perfil.telefono, '477 123 4567');
    });
  });
}
