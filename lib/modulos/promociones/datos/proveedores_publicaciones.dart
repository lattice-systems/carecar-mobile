import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../dominio/publicacion.dart';

final novedadesProvider = FutureProvider.autoDispose<List<Publicacion>>(
  (ref) => ref
      .watch(apiClienteProvider)
      .obtenerLista('/novedades', Publicacion.novedad),
  retry: (_, _) => null,
);

final promocionesProvider = FutureProvider.autoDispose<List<Publicacion>>(
  (ref) => ref
      .watch(apiClienteProvider)
      .obtenerLista('/promociones', Publicacion.promocion),
  retry: (_, _) => null,
);
