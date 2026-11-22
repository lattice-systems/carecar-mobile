import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/carecar_api.dart';
import 'api_cliente.dart';

/// Costura entre Riverpod y el cliente de red v1.
///
/// Los proveedores no construyen nada: la app (`main.dart`) arma el cliente con
/// su configuracion real y lo inyecta con `overrides`. Asi hay un solo punto
/// que conoce la direccion del servidor y, en pruebas, basta sustituir el
/// proveedor por un fake.
///
/// Si alguien lee un proveedor sin haberlo inyectado, falla con un mensaje que
/// dice que hacer, en vez de un error de nulo mas adelante.
Never _sinInyectar(String nombre) => throw StateError(
  '$nombre no esta inyectado. Agrega '
  '`$nombre.overrideWithValue(...)` en el ProviderScope de la app o de la '
  'prueba.',
);

/// Cliente HTTP (tokens, refresco, errores). Los modulos no lo usan directo:
/// lo reciben por [carecarApiProvider].
final apiClienteProvider = Provider<ApiCliente>(
  (ref) => _sinInyectar('apiClienteProvider'),
  name: 'apiClienteProvider',
);

/// Contrato de la API (`CarecarApi`): lo que consumen los repositorios de los
/// modulos. En pruebas se sustituye por un fake.
final carecarApiProvider = Provider<CarecarApi>(
  (ref) => _sinInyectar('carecarApiProvider'),
  name: 'carecarApiProvider',
);
