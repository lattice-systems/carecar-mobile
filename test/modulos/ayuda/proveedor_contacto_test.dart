// V2-M27.03 · `contactoDeAgenciaProvider`: la sucursal principal manda y la
// config de la agencia respalda cuando falla, no hay sucursales o aún carga.
import 'dart:async';

import 'package:carecar_mobile/api/excepciones.dart';
import 'package:carecar_mobile/config/agencia.dart';
import 'package:carecar_mobile/modulos/ayuda/ayuda.dart';
import 'package:carecar_mobile/modulos/ayuda/datos/repositorio_sucursales_fake.dart';
import 'package:carecar_mobile/modulos/ayuda/dominio/repositorio_sucursales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repo implements RepositorioSucursales {
  _Repo(this.alPedir);
  final Future<List<Sucursal>> Function() alPedir;

  @override
  Future<List<Sucursal>> sucursales() => alPedir();
}

ProviderContainer _contenedor(RepositorioSucursales repo) {
  final contenedor = ProviderContainer(
    overrides: [repositorioSucursalesProvider.overrideWithValue(repo)],
  );
  addTearDown(contenedor.dispose);
  return contenedor;
}

/// Mantiene vivo el proveedor (es `autoDispose`) mientras se espera la carga.
Future<ContactoDeAgencia> _leer(ProviderContainer contenedor) async {
  final suscripcion = contenedor.listen(contactoDeAgenciaProvider, (_, _) {});
  await contenedor.read(sucursalPrincipalProvider.future).catchError((_) => null);
  final contacto = contenedor.read(contactoDeAgenciaProvider);
  suscripcion.close();
  return contacto;
}

void main() {
  test('con sucursal principal usa su teléfono, correo y dirección', () async {
    final contacto = await _leer(_contenedor(RepositorioSucursalesFake()));

    expect(contacto.esRespaldo, isFalse);
    expect(contacto.telefono, '+52 477 000 0000');
    expect(contacto.nombreSucursal, 'CareCar León');
    expect(
      contacto.direccionParaEvento,
      'CareCar León, Blvd. Ejemplo 100, Col. Centro, 37000 León, Gto.',
    );
  });

  test('sin sucursales queda el respaldo de Agencia', () async {
    final contacto = await _leer(
      _contenedor(RepositorioSucursalesFake(sucursales: [])),
    );

    expect(contacto.esRespaldo, isTrue);
    expect(contacto.telefono, Agencia.telefono);
    expect(contacto.direccion, Agencia.direccion);
  });

  test('si la lectura falla queda el respaldo de Agencia', () async {
    final contacto = await _leer(
      _contenedor(_Repo(() async => throw const SinConexion())),
    );

    expect(contacto.esRespaldo, isTrue);
    expect(contacto.telefono, Agencia.telefono);
  });

  test('mientras carga queda el respaldo y luego cambia a la sucursal', () async {
    final espera = Completer<List<Sucursal>>();
    final contenedor = _contenedor(_Repo(() => espera.future));
    final cambios = <bool>[];
    final suscripcion = contenedor.listen(contactoDeAgenciaProvider, (_, nuevo) {
      cambios.add(nuevo.esRespaldo);
    }, fireImmediately: true);

    expect(contenedor.read(contactoDeAgenciaProvider).esRespaldo, isTrue);

    espera.complete(RepositorioSucursalesFake.ejemplo);
    await contenedor.read(sucursalPrincipalProvider.future);

    expect(contenedor.read(contactoDeAgenciaProvider).esRespaldo, isFalse);
    expect(cambios, [true, false]);
    suscripcion.close();
  });
}
