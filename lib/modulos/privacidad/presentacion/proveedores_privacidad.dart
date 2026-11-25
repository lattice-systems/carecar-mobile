import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../nucleo/api/proveedores_api.dart';
import '../datos/repositorio_privacidad_api.dart';
import '../dominio/privacidad.dart';

/// Repositorio del módulo. En pruebas:
/// `repositorioPrivacidadProvider.overrideWithValue(...)`.
final repositorioPrivacidadProvider = Provider<RepositorioPrivacidad>(
  (ref) => RepositorioPrivacidadApi(ref.watch(carecarApiProvider)),
  name: 'repositorioPrivacidadProvider',
);

/// El aviso vigente con el estado de esta cuenta (V2-M22.01).
///
/// Se queda en memoria para que el verificador y la puerta compartan una sola
/// lectura. Quien sabe que cambió (al iniciar sesión, al aceptar, al abrir el
/// aviso desde el perfil) la invalida: no hay copia que dure entre sesiones.
final avisoVigenteProvider = FutureProvider<AvisoDePrivacidad>(
  (ref) => ref.watch(repositorioPrivacidadProvider).avisoVigente(),
  // El reintento es de la persona (botón de EstadoError), no automático.
  retry: (_, _) => null,
  name: 'avisoVigenteProvider',
);
